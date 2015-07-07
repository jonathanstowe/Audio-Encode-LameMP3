#!perl6

use v6;
use Test;

use Audio::Encode::LameMP3;

my @params = <
               in-samplerate
               num-channels
               bitrate
               quality
               mode
               num-samples
               scale
               scale-left
               scale-right
               out-samplerate
               set-analysis
               write-vbr-tag
               decode-only
               nogap-total
             >;

my $obj;

lives-ok { $obj = Audio::Encode::LameMP3.new },"new Audio::Encode::LameMP3";

for @params -> $param {
    can-ok($obj, $param);
    my $val;
    lives-ok { $val = $obj."$param"() }, "can call $param";
    ok($val.defined, "and got some value back");
}



# vim: expandtab shiftwidth=4 ft=perl6
