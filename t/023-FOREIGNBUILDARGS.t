#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 2;

package Foo;

sub new {
    my $class = shift;
    bless { foo => $_[0] }, $class;
}

sub foo { shift->{foo} }

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
    return $args{foo};
}

package main;

my $foo = Foo::Moose->new(foo => 'bar');
is($foo->foo,  'bar', 'subclass constructor gets the right args');
Foo::Moose->meta->make_immutable;
$foo = Foo::Moose->new(foo => 'bar');
is($foo->foo,  'bar', 'subclass constructor gets the right args (immutable)');
