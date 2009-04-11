#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 4;

package Foo;

sub new {
    my $class = shift;
    bless { _class => $class }, $class;
}

package Foo::Moose;
use Moose;
use MooseX::NonMoose;
extends 'Foo';

package main;
my $foo = Foo->new;
my $foo_moose = Foo::Moose->new;
isa_ok $foo, 'Foo';
is $foo->{_class}, 'Foo', 'Foo gets the correct class';
isa_ok $foo_moose, 'Foo::Moose';
is $foo_moose->{_class}, 'Foo::Moose', 'Foo::Moose gets the correct class';
