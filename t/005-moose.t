#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 6;

package Foo;
use Moose;

has foo => (
    is      => 'ro',
    default => 'FOO',
);

package Foo::Sub;
use Moose;
use MooseX::NonMoose;
extends 'Foo';

package main;
my $foo_sub = Foo::Sub->new;
isa_ok $foo_sub, 'Foo';
is $foo_sub->foo, 'FOO', 'inheritance works';
is(Foo::Sub->meta->get_method('new'), undef,
   'Foo::Sub doesn\'t have its own new method');

$_->meta->make_immutable for qw(Foo Foo::Sub);

$foo_sub = Foo::Sub->new;
isa_ok $foo_sub, 'Foo';
is $foo_sub->foo, 'FOO', 'inheritance works';
is(Foo::Sub->meta->get_method('new'), undef,
   'Foo::Sub doesn\'t have its own new method');
