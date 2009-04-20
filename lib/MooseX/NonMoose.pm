package MooseX::NonMoose;
use Moose ();
use Moose::Exporter;

=head1 NAME

MooseX::NonMoose - easy subclassing of non-Moose classes

=head1 SYNOPSIS

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

=head1 SEE ALSO

L<Moose>

L<MooseX::Alien>

=head1 BUGS/CAVEATS

No known bugs.

Please report any bugs through RT: email
C<bug-moosex-nonmoose at rt.cpan.org>, or browse to
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MooseX-NonMoose>.

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
