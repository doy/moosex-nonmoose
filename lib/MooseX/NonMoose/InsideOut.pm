package MooseX::NonMoose::InsideOut;
use Moose ();
use Moose::Exporter;

=head1 NAME

MooseX::NonMoose::InsideOut - easy subclassing of non-Moose non-hashref classes

=head1 SYNOPSIS

  package Term::VT102::NBased;
  use Moose;
  use MooseX::NonMoose::InsideOut;
  extends 'Term::VT102';

  has [qw/x_base y_base/] => (
      is      => 'ro',
      isa     => 'Int',
      default => 1,
  );

  around x => sub {
      my $orig = shift;
      my $self = shift;
      $self->$orig(@_) + $self->x_base - 1;
  };

  # ... (wrap other methods)

  no Moose;
  # no need to fiddle with inline_constructor here
  __PACKAGE__->meta->make_immutable;

  my $vt = Term::VT102::NBased->new(x_base => 0, y_base => 0);

=head1 DESCRIPTION

=cut

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
        instance_metaclass_roles =>
            ['MooseX::InsideOut::Role::Meta::Instance'],
    );
    return Class::MOP::class_of($options{for_class});
}

=head1 AUTHOR

  Jesse Luehrs <doy at tozt dot net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Jesse Luehrs.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
