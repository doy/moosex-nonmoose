#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Fatal;

{
    $INC{'Foo.pm'} = __FILE__;
    package Foo;
    our $VERSION = '0.02';
    sub new { bless {}, shift }
}

{
    package Bar;
    use Moose;
    use MooseX::NonMoose;
    ::is(::exception { extends 'Foo' => { -version => '0.02' } }, undef,
         "specifying arguments to superclasses doesn't break");
}

done_testing;
