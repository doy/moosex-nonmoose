#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 7;

package Foo;

sub new {
    my $class = shift;
    bless { foo => 'FOO' }, $class;
}

sub foo { shift->{foo} }

package Foo::Moose;
use Moose;
use MooseX::NonMoose;
extends 'Foo';

has bar => (
    is      => 'ro',
    default => 'BAR',
);

package Foo::Moose::Sub;
use Moose;
use MooseX::NonMoose;
extends 'Foo::Moose';

has baz => (
    is      => 'ro',
    default => 'BAZ',
);

package main;
my $foo_moose = Foo::Moose->new;
is $foo_moose->foo, 'FOO', 'Foo::Moose::foo';
is $foo_moose->bar, 'BAR', 'Foo::Moose::bar';
isnt(Foo::Moose->meta->get_method('new'), undef,
     'Foo::Moose gets its own constructor');

my $foo_moose_sub = Foo::Moose::Sub->new;
is $foo_moose_sub->foo, 'FOO', 'Foo::Moose::foo';
is $foo_moose_sub->bar, 'BAR', 'Foo::Moose::bar';
is $foo_moose_sub->baz, 'BAZ', 'Foo::Moose::baz';
is(Foo::Moose::Sub->meta->get_method('new'), undef,
   'Foo::Moose::Sub just uses the constructor for Foo::Moose');
