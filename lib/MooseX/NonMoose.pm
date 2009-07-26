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
  # no need to fiddle with inline_constructor here
  __PACKAGE__->meta->make_immutable;

  my $vt = Term::VT102::NBased->new(x_base => 0, y_base => 0);

=head1 DESCRIPTION

C<MooseX::NonMoose> allows for easily subclassing non-Moose classes with Moose,
taking care of the annoying details connected with doing this, such as setting
up proper inheritance from L<Moose::Object> and installing (and inlining, at
C<make_immutable> time) a constructor that makes sure things like C<BUILD>
methods are called. It tries to be as non-intrusive as possible - when this
module is used, inheriting from non-Moose classes and inheriting from Moose
classes should work identically, aside from the few caveats mentioned below.
One of the goals of this module is that including it in a
L<Moose::Exporter>-based package used across an entire application should be
possible, without interfering with classes that only inherit from Moose
modules, or even classes that don't inherit from anything at all.

There are several ways to use this module. The most straightforward is to just
C<use MooseX::NonMoose;> in your class; this should set up everything necessary
for extending non-Moose modules. L<MooseX::NonMoose::Meta::Role::Class> and
L<MooseX::NonMoose::Meta::Role::Constructor> can also be applied to your
metaclasses manually, either by passing a C<-traits> option to your C<use
Moose;> line, or by applying them using L<Moose::Util::MetaRole> in a
L<Moose::Exporter>-based package. L<MooseX::NonMoose::Meta::Role::Class> is the
part that provides the main functionality of this module; if you don't care
about inlining, this is all you need to worry about. Applying
L<MooseX::NonMoose::Meta::Role::Constructor> as well will provide an inlined
constructor when you immutabilize your class.

C<MooseX::NonMoose> allows you to manipulate the argument list that gets passed
to the superclass constructor by defining a C<FOREIGNBUILDARGS> method. This is
called with the same argument list as the C<BUILDARGS> method, but should
return a list of arguments to pass to the superclass constructor. This allows
C<MooseX::NonMoose> to support superclasses whose constructors would get
confused by the extra arguments that Moose requires (for attributes, etc.)

=cut

Moose::Exporter->setup_import_methods;

sub init_meta {
    shift;
    my %options = @_;
    Carp::cluck('Roles have no use for MooseX::NonMoose')
        if Class::MOP::class_of($options{for_class})->isa('Moose::Meta::Role');
    Moose::Util::MetaRole::apply_metaclass_roles(
        for_class               => $options{for_class},
        metaclass_roles         => ['MooseX::NonMoose::Meta::Role::Class'],
        constructor_class_roles =>
            ['MooseX::NonMoose::Meta::Role::Constructor'],
    );
    return Class::MOP::class_of($options{for_class});
}

=head1 TODO

=over 4

=item * Allow for constructors with names other than C<new>.

=back

=head1 BUGS/CAVEATS

=over 4

=item * The reference that the non-Moose class uses as its instance type
B<must> match the instance type that Moose is using. Moose's default instance
type is a hashref, but other modules exist to make Moose use other instance
types. L<MooseX::InsideOut> is the most general solution - it should work with
any class. For globref-based classes in particular, L<MooseX::GlobRef> will
also allow Moose to work. For more information, see the C<032-moosex-insideout>
and C<033-moosex-globref> tests bundled with this dist.

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
far more hackish) implementation.

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

=head1 AUTHOR

  Jesse Luehrs <doy at tozt dot net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Jesse Luehrs.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
