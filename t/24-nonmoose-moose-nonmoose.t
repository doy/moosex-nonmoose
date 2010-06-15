#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 32;

package Foo;

sub new {
    my $class = shift;
    bless {@_}, $class;
}

sub foo { shift->{name} }

package Foo::Moose;
use Moose;
use MooseX::NonMoose;
extends 'Foo';

has foo2 => (
    is => 'rw',
    isa => 'Str',
);

package Foo::Moose::Sub;
use base 'Foo::Moose';

package Bar;

sub new {
    my $class = shift;
    bless {name => $_[0]}, $class;
}

sub bar { shift->{name} }

package Bar::Moose;
use Moose;
use MooseX::NonMoose;
extends 'Bar';

has bar2 => (
    is  => 'rw',
    isa => 'Str',
);

sub FOREIGNBUILDARGS {
    my $class = shift;
    my %args = @_;
    return $args{name};
}

package Bar::Moose::Sub;
use base 'Bar::Moose';

package main;
my $foo = Foo::Moose::Sub->new(name => 'foomoosesub', foo2 => 'FOO2');
isa_ok($foo, 'Foo');
isa_ok($foo, 'Foo::Moose');
is($foo->foo, 'foomoosesub', 'got name from nonmoose constructor');
is($foo->foo2, 'FOO2', 'got attribute value from moose constructor');
$foo = Foo::Moose->new(name => 'foomoosesub', foo2 => 'FOO2');
isa_ok($foo, 'Foo');
isa_ok($foo, 'Foo::Moose');
is($foo->foo, 'foomoosesub', 'got name from nonmoose constructor');
is($foo->foo2, 'FOO2', 'got attribute value from moose constructor');
Foo::Moose->meta->make_immutable;
$foo = Foo::Moose::Sub->new(name => 'foomoosesub', foo2 => 'FOO2');
isa_ok($foo, 'Foo');
isa_ok($foo, 'Foo::Moose');
TODO: {
local $TODO = 'nonmoose-moose-nonmoose inheritance doesn\'t quite work';
is($foo->foo, 'foomoosesub', 'got name from nonmoose constructor (immutable)');
}
is($foo->foo2, 'FOO2', 'got attribute value from moose constructor (immutable)');
$foo = Foo::Moose->new(name => 'foomoosesub', foo2 => 'FOO2');
isa_ok($foo, 'Foo');
isa_ok($foo, 'Foo::Moose');
is($foo->foo, 'foomoosesub', 'got name from nonmoose constructor (immutable)');
is($foo->foo2, 'FOO2', 'got attribute value from moose constructor (immutable)');

my $bar = Bar::Moose::Sub->new(name => 'barmoosesub', bar2 => 'BAR2');
isa_ok($bar, 'Bar');
isa_ok($bar, 'Bar::Moose');
is($bar->bar, 'barmoosesub', 'got name from nonmoose constructor');
is($bar->bar2, 'BAR2', 'got attribute value from moose constructor');
$bar = Bar::Moose->new(name => 'barmoosesub', bar2 => 'BAR2');
isa_ok($bar, 'Bar');
isa_ok($bar, 'Bar::Moose');
is($bar->bar, 'barmoosesub', 'got name from nonmoose constructor');
is($bar->bar2, 'BAR2', 'got attribute value from moose constructor');
Bar::Moose->meta->make_immutable;
$bar = Bar::Moose::Sub->new(name => 'barmoosesub', bar2 => 'BAR2');
isa_ok($bar, 'Bar');
isa_ok($bar, 'Bar::Moose');
TODO: {
local $TODO = 'nonmoose-moose-nonmoose inheritance doesn\'t quite work';
is($bar->bar, 'barmoosesub', 'got name from nonmoose constructor (immutable)');
}
is($bar->bar2, 'BAR2', 'got attribute value from moose constructor (immutable)');
$bar = Bar::Moose->new(name => 'barmoosesub', bar2 => 'BAR2');
isa_ok($bar, 'Bar');
isa_ok($bar, 'Bar::Moose');
is($bar->bar, 'barmoosesub', 'got name from nonmoose constructor (immutable)');
is($bar->bar2, 'BAR2', 'got attribute value from moose constructor (immutable)');
