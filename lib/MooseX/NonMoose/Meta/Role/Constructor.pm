package MooseX::NonMoose::Meta::Role::Constructor;
use Moose::Role;

=head1 NAME

MooseX::NonMoose::Meta::Role::Constructor - constructor method trait for L<MooseX::NonMoose>

=head1 SYNOPSIS

  package My::Moose;
  use Moose ();
  use Moose::Exporter;

  Moose::Exporter->setup_import_methods;
  sub init_meta {
      shift;
      my %options = @_;
      Moose->init_meta(%options);
      Moose::Util::MetaRole::apply_metaclass_roles(
          for_class               => $options{for_class},
          metaclass_roles         => ['MooseX::NonMoose::Meta::Role::Class'],
          constructor_class_roles =>
              ['MooseX::NonMoose::Meta::Role::Constructor'],
      );
      return Class::MOP::class_of($options{for_class});
  }

=head1 DESCRIPTION

This trait implements inlining of the constructor for classes using the
L<MooseX::NonMoose::Meta::Role::Class> metaclass trait; it has no effect unless
that trait is also used. See those docs and the docs for L<MooseX::NonMoose>
for more information.

=cut

around can_be_inlined => sub {
    my $orig = shift;
    my $self = shift;

    my $meta = $self->associated_metaclass;
    my $super_new = $meta->find_method_by_name($self->name);
    my $super_meta = $super_new->associated_metaclass;
    if (Class::MOP::class_of($super_meta)->can('does_role')
     && Class::MOP::class_of($super_meta)->does_role('MooseX::NonMoose::Meta::Role::Class')) {
        return 1;
    }

    return $self->$orig(@_);
};

sub _generate_instance {
    my $self = shift;
    my ($var, $class_var) = @_;
    my $new = $self->name;
    my $meta = $self->associated_metaclass;
    my $super_new_class = $meta->find_next_method_by_name($new)->package_name;
    my $arglist = $meta->get_method('FOREIGNBUILDARGS')
                ? "${class_var}->FOREIGNBUILDARGS(\@_)"
                : '@_';
    # XXX: this should probably be taking something from the meta-instance api,
    # rather than calling bless directly, but this works fine for now, and i
    # want to wait for the whole immutablization stuff to settle down before
    # digging too deeply into it
    "my $var = bless $super_new_class->$new($arglist), $class_var;\n";
}

no Moose::Role;

=head1 AUTHOR

  Jesse Luehrs <doy at tozt dot net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Jesse Luehrs.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
