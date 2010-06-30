#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Exception;

{
    package Foo;
    our $VERSION = '0.02';
    sub new { bless {}, shift }
}

{
    package Bar;
    use Moose;
    use MooseX::NonMoose;
    ::lives_ok { extends 'Foo' => { -version => '0.02' } }
               "specifying arguments to superclasses doesn't break";
}

done_testing;
