#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 4;

our $foo_constructed = 0;

package Foo;

sub new {
    my $class = shift;
    bless {}, $class;
}

package Foo::Moose;
use Moose;
use MooseX::NonMoose;
extends 'Foo';

after new => sub {
    $main::foo_constructed = 1;
};

package main;
my $method = Foo::Moose->meta->get_method('new');
isa_ok($method, 'Class::MOP::Method::Wrapped');
my $foo = Foo::Moose->new;
ok($foo_constructed, 'method modifier called for the constructor');
$foo_constructed = 0;
Foo::Moose->meta->make_immutable;
is($method, Foo::Moose->meta->get_method('new'),
   'make_immutable doesn\'t overwrite constructor with method modifiers');
$foo = Foo::Moose->new;
ok($foo_constructed, 'method modifier called for the constructor (immutable)');
