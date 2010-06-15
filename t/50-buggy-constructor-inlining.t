#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 6;

my ($Foo, $Bar, $Baz) = (0, 0, 0);
{
    package Foo;
    sub new { $Foo++; bless {}, shift }
}

{
    package Bar;
    use Moose;
    use MooseX::NonMoose;
    extends 'Foo';
    sub BUILD { $Bar++ }
    __PACKAGE__->meta->make_immutable;
}

{
    package Baz;
    use Moose;
    extends 'Bar';
    sub BUILD { $Baz++ }
}

Baz->new;
{ local $TODO = "need to call custom constructor for other classes, not Moose::Object->new";
is($Foo, 1, "Foo->new is called");
}
{ local $TODO = "need to call non-Moose constructor, not superclass constructor";
is($Bar, 0, "Bar->new is not called");
}
is($Baz, 1, "Baz->new is called");

Baz->meta->make_immutable;
($Foo, $Bar, $Baz) = (0, 0, 0);

Baz->new;
is($Foo, 1, "Foo->new is called");
{ local $TODO = "need to call non-Moose constructor, not superclass constructor";
is($Bar, 0, "Bar->new is not called");
}
is($Baz, 1, "Baz->new is called");
