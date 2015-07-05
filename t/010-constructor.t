#!perl6
use v6;
use lib 'lib';
use Test;

use Audio::Encode::LameMP3;

my $obj;

lives-ok { $obj = Audio::Encode::LameMP3.new }, "create a new Audio::Encode::LameMP3";
isa-ok($obj, Audio::Encode::LameMP3, 'and it is the right sort of object');

done;

# vim: expandtab shiftwidth=4 ft=perl6
