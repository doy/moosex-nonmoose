#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 8;

package Foo;

sub new {
    my $class = shift;
    bless { foo_base => $_[0] }, $class;
}

sub foo_base { shift->{foo_base} }

package Foo::Moose;
use Moose;
use MooseX::NonMoose;
extends 'Foo';

has foo => (
    is => 'rw',
);

sub FOREIGNBUILDARGS {
    my $class = shift;
    my %args = @_;
    return "$args{foo}_base";
}

package Bar::Moose;
use Moose;
use MooseX::NonMoose;
extends 'Foo';

has bar => (
    is => 'rw',
);

sub FOREIGNBUILDARGS {
    my $class = shift;
    return "$_[0]_base";
}

sub BUILDARGS {
    my $class = shift;
    return { bar => shift };
}

package main;

my $foo = Foo::Moose->new(foo => 'bar');
is($foo->foo,  'bar', 'subclass constructor gets the right args');
is($foo->foo_base,  'bar_base', 'subclass constructor gets the right args');
my $bar = Bar::Moose->new('baz');
is($bar->bar, 'baz', 'subclass constructor gets the right args');
is($bar->foo_base, 'baz_base', 'subclass constructor gets the right args');
Foo::Moose->meta->make_immutable;
Bar::Moose->meta->make_immutable;
$foo = Foo::Moose->new(foo => 'bar');
$bar = Bar::Moose->new('baz');
is($foo->foo,  'bar', 'subclass constructor gets the right args (immutable)');
is($foo->foo_base,  'bar_base', 'subclass constructor gets the right args (immutable)');
is($bar->bar, 'baz', 'subclass constructor gets the right args (immutable)');
is($bar->foo_base, 'baz_base', 'subclass constructor gets the right args (immutable)');
