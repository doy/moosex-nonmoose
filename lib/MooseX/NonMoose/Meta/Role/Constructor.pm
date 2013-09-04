package MooseX::NonMoose::Meta::Role::Constructor;
use Moose::Role 2.0000;
# ABSTRACT: constructor method trait for L<MooseX::NonMoose>

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
      return Moose::Util::find_meta($options{for_class});
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
    if (Moose::Util::find_meta($super_meta)->can('does_role')
     && Moose::Util::find_meta($super_meta)->does_role('MooseX::NonMoose::Meta::Role::Class')) {
        return 1;
    }

    return $self->$orig(@_);
};

no Moose::Role;

1;
