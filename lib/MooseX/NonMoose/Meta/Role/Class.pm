package MooseX::NonMoose::Meta::Role::Class;
use Moose::Role;
use List::MoreUtils qw(any);

=head1 NAME

MooseX::NonMoose::Meta::Role::Class - metaclass trait for L<MooseX::NonMoose>

=head1 SYNOPSIS

  package Foo;
  use Moose -traits => 'MooseX::NonMoose::Meta::Role::Class';

  # or

  package My::Moose;
  use Moose ();
  use Moose::Exporter;

  Moose::Exporter->setup_import_methods;
  sub init_meta {
      shift;
      my %options = @_;
      Moose->init_meta(%options);
      Moose::Util::MetaRole::apply_metaclass_roles(
          for_class       => $options{for_class},
          metaclass_roles => ['MooseX::NonMoose::Meta::Role::Class'],
      );
      return Class::MOP::class_of($options{for_class});
  }

=head1 DESCRIPTION

This trait implements everything involved with extending non-Moose classes,
other than doing the actual inlining at C<make_immutable> time. See
L<MooseX::NonMoose> for more details.

=cut

has has_nonmoose_constructor => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has has_nonmoose_destructor => (
    is  => 'rw',
    isa => 'Bool',
    default => 0,
);

around _immutable_options => sub {
    my $orig = shift;
    my $self = shift;

    my @options = $self->$orig(@_);

    # do nothing if extends was never called
    return @options if !$self->has_nonmoose_constructor;

    # if we're using just the metaclass trait, but not the constructor trait,
    # then suppress the warning about not inlining a constructor
    my $cc_meta = Class::MOP::class_of($self->constructor_class);
    return (@options, inline_constructor => 0)
        unless $cc_meta->can('does_role')
            && $cc_meta->does_role('MooseX::NonMoose::Meta::Role::Constructor');

    # do nothing if extends was called, but we then added a method modifier to
    # the constructor (this will warn, but that's okay)
    # XXX: this is a fairly big hack, but it should cover most of the cases
    # that actually show up in practice... it would be nice to do this properly
    # though
    # XXX: get constructor name from the constructor metaclass?
    return @options
        if $self->get_method('new')->isa('Class::MOP::Method::Wrapped');

    # do nothing if we explicitly ask for the constructor to not be inlined
    my %options = @options;
    return @options if !$options{inline_constructor};

    # otherwise, explicitly ask for the constructor to be replaced (to suppress
    # the warning message), since this is the expected usage, and shouldn't
    # cause a warning
    return (replace_constructor => 1, @options);
};

sub _check_superclass_constructor {
    my $self = shift;

    # if the current class defined a custom new method (since subs happen at
    # BEGIN time), don't try to override it
    return if $self->has_method('new');

    # we need to get the non-moose constructor from the superclass
    # of the class where this method actually exists, regardless of what class
    # we're calling it on
    # XXX: get constructor name from the constructor metaclass?
    my $super_new = $self->find_next_method_by_name('new');

    # if we're trying to extend a (non-immutable) moose class, just do nothing
    return if $super_new->package_name eq 'Moose::Object';

    if ($super_new->associated_metaclass->can('constructor_class')) {
        my $constructor_class_meta = Class::MOP::Class->initialize(
            $super_new->associated_metaclass->constructor_class
        );

        # if the constructor we're inheriting is already one of ours, there's
        # no reason to install a new one
        return if $constructor_class_meta->can('does_role')
               && $constructor_class_meta->does_role('MooseX::NonMoose::Meta::Role::Constructor');

        # if the constructor we're inheriting is an inlined version of the
        # default moose constructor, don't do anything either
        return if any { $_->isa($constructor_class_meta->name) }
                      $super_new->associated_metaclass->_inlined_methods;
    }

    $self->add_method(new => sub {
        my $class = shift;

        my $params = $class->BUILDARGS(@_);
        my @foreign_params = $class->can('FOREIGNBUILDARGS')
                           ? $class->FOREIGNBUILDARGS(@_)
                           : @_;
        my $instance = $super_new->execute($class, @foreign_params);
        my $self = Class::MOP::Class->initialize($class)->new_object(
            __INSTANCE__ => $instance,
            %$params,
        );
        $self->BUILDALL($params);
        return $self;
    });
    $self->has_nonmoose_constructor(1);
}

sub _check_superclass_destructor {
    my $self = shift;

    # if the current class defined a custom DESTROY method (since subs happen
    # at BEGIN time), don't try to override it
    return if $self->has_method('DESTROY');

    # we need to get the non-moose destructor from the superclass
    # of the class where this method actually exists, regardless of what class
    # we're calling it on
    my $super_DESTROY = $self->find_next_method_by_name('DESTROY');

    # if we're trying to extend a (non-immutable) moose class, just do nothing
    return if $super_DESTROY->package_name eq 'Moose::Object';

    if ($super_DESTROY->associated_metaclass->can('destructor_class')
     && $super_DESTROY->associated_metaclass->destructor_class) {
        my $destructor_class_meta = Class::MOP::Class->initialize(
            $super_DESTROY->associated_metaclass->destructor_class
        );

        # if the destructor we're inheriting is already one of ours, there's
        # no reason to install a new one
        return if $destructor_class_meta->can('does_role')
               && $destructor_class_meta->does_role('MooseX::NonMoose::Meta::Role::Destructor');

        # if the destructor we're inheriting is an inlined version of the
        # default moose destructor, don't do anything
        return if any { $_->isa($destructor_class_meta->name) }
                      $super_DESTROY->associated_metaclass->_inlined_methods;
    }

    $self->add_method(DESTROY => sub {
        my $self = shift;

        local $?;

        Try::Tiny::try {
            $super_DESTROY->execute($self);
            $self->DEMOLISHALL(Devel::GlobalDestruction::in_global_destruction);
        }
        Try::Tiny::catch {
            # Without this, Perl will warn "\t(in cleanup)$@" because of some
            # bizarre fucked-up logic deep in the internals.
            no warnings 'misc';
            die $_;
        };

        return;
    });
    $self->has_nonmoose_destructor(1);
}

around superclasses => sub {
    my $orig = shift;
    my $self = shift;

    return $self->$orig unless @_;

    my @superclasses = @_;
    push @superclasses, 'Moose::Object'
        unless grep { $_->isa('Moose::Object') } @superclasses;

    my @ret = $self->$orig(@superclasses);

    $self->_check_superclass_constructor;
    $self->_check_superclass_destructor;

    return @ret;
};

no Moose::Role;

=head1 AUTHOR

  Jesse Luehrs <doy at tozt dot net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Jesse Luehrs.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
