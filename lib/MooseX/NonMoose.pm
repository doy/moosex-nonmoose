package MooseX::NonMoose;
use Moose ();
use Moose::Exporter;

=head1 NAME

MooseX::NonMoose - easy subclassing of non-Moose classes

=head1 SYNOPSIS

  package Term::VT102::NBased;
  use Moose;
  use MooseX::NonMoose;
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
    );
    return Class::MOP::class_of($options{for_class});
}

=head1 AUTHOR

  Jesse Luehrs <doy at tozt dot net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Jesse Luehrs.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

=head1 TODO

=over 4

=item * Provide some way to manipulate the argument list that gets passed to the
superclass constructor, to support setting attributes in the constructor for a
subclass of a class whose constructor does strict argument checking.

=item * Allow for constructors with names other than C<new>.

=back

=head1 BUGS/CAVEATS

=over 4

=item * The reference that the non-Moose class uses as its instance type B<must>
match the instance type that Moose is using (currently, Moose only supports
hashref based instances).

=item * Arguments passed to the constructor will be passed as-is to the
superclass constructor - there is currently no BUILDARGS-like munging available
for this step (BUILDARGS is still available to munge the argument list that
Moose sees).

=item * Completely overriding the constructor in a class using
C<MooseX::NonMoose> (i.e. using C<sub new { ... }>) currently doesn't work,
although using method modifiers on the constructor should work identically to
normal Moose classes.

=item * C<MooseX::NonMoose> currently assumes in several places that the
superclass constructor will be called C<new>. This may be made configurable
in the future.

=back

Please report any bugs through RT: email
C<bug-moosex-nonmoose at rt.cpan.org>, or browse to
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MooseX-NonMoose>.

=head1 SEE ALSO

L<Moose::Cookbook::FAQ/How do I make non-Moose constructors work with Moose?>

L<MooseX::Alien> - serves the same purpose, but with a radically different (and
far more hackish and worse) implementation.

=head1 SUPPORT

You can find this documentation for this module with the perldoc command.

    perldoc MooseX::NonMoose

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MooseX-NonMoose>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MooseX-NonMoose>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MooseX-NonMoose>

=item * Search CPAN

L<http://search.cpan.org/dist/MooseX-NonMoose>

=back

=cut

1;
