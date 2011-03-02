#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

{
    package NonMoose;
    sub create { bless {}, shift }
    sub DESTROY { }
}

{
    package Child;
    use Moose;
    use MooseX::NonMoose;
    extends 'NonMoose';
    {
        my $warning;
        local $SIG{__WARN__} = sub { $warning = $_[0] };
        __PACKAGE__->meta->make_immutable;
        ::like($warning, qr/Not inlining.*doesn't contain a 'new' method/,
            "warning when trying to make_immutable without a superclass 'new'");
    }
}

done_testing;
