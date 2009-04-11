#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 14;

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
ok(!Foo::Sub->meta->has_method('new'),
   'Foo::Sub doesn\'t have its own new method');

$_->meta->make_immutable for qw(Foo Foo::Sub);

$foo_sub = Foo::Sub->new;
isa_ok $foo_sub, 'Foo';
is $foo_sub->foo, 'FOO', 'inheritance works (immutable)';
ok(!Foo::Sub->meta->has_method('new'),
   'Foo::Sub doesn\'t have its own new method (immutable)');

package Foo::OtherSub;
use Moose;
use MooseX::NonMoose;
extends 'Foo';

package main;
my $foo_othersub = Foo::OtherSub->new;
isa_ok $foo_othersub, 'Foo';
is $foo_othersub->foo, 'FOO', 'inheritance works (immutable when extending)';
ok(Foo::OtherSub->meta->has_method('new'),
   'Foo::OtherSub has its own inlined constructor (immutable when extending)');
ok(!(Foo::OtherSub->meta->get_method('new')->can('does_role')
  && Foo::OtherSub->meta->get_method('new')->does_role('MooseX::NonMoose::Meta::Role::Constructor')),
   'Foo::OtherSub\'s inlined constructor is from Moose, not MooseX::NonMoose (immutable when extending)');

Foo::OtherSub->meta->make_immutable;
$foo_othersub = Foo::OtherSub->new;
isa_ok $foo_othersub, 'Foo';
is $foo_othersub->foo, 'FOO', 'inheritance works (all immutable)';
ok(Foo::OtherSub->meta->has_method('new'),
   'Foo::OtherSub has its own inlined constructor (immutable when extending)');
ok(!(Foo::OtherSub->meta->get_method('new')->can('does_role')
  && Foo::OtherSub->meta->get_method('new')->does_role('MooseX::NonMoose::Meta::Role::Constructor')),
   'Foo::OtherSub\'s inlined constructor is from Moose, not MooseX::NonMoose (immutable when extending)');
