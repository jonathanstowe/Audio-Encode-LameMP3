#!perl6

use v6;
use lib 'lib';
use Test;

use Audio::Encode::LameMP3;
# simplify by reading PCM data from file
use Audio::Sndfile;



my IO::Path $test-data = "t/data".IO;

my $sndfile;

my $test-file = $test-data.child('cw_glitch_noise15.wav').Str;

lives-ok { $sndfile = Audio::Sndfile.new(filename => $test-file, :r) }, "open a soundfile to get data";

my $encoder;

lives-ok { $encoder = Audio::Encode::LameMP3.new }, "create an encoder";

lives-ok { $encoder.in-samplerate = $sndfile.samplerate }, "set samplerate";
lives-ok { $encoder.mode = Audio::Encode::LameMP3::JointStereo }, "set mode";
lives-ok { $encoder.bitrate = 320 }, "set bitrate";
lives-ok { $encoder.quality = 2 }, "set quality";
lives-ok { $encoder.write-vbr-tag = False }, "turn off write vbr tag";

lives-ok { $encoder.init }, "init";

my $buf;

my $out-file = $test-data.child("tt.mp3");
my $out-fh = $out-file.open(:w, :bin);
loop {
        my @in-frames = $sndfile.read-short(4192);
        my ($left, $right) = uninterleave(@in-frames);
        lives-ok { $buf = $encoder.encode-short($left, $right) }, "encode { @in-frames / $sndfile.channels } frames";
        ok($buf ~~ Buf , "returned buffer is a Buf");
        ok($buf.elems > 0, "and there are some elements");
        $out-fh.write($buf);
        last if ( @in-frames / $sndfile.channels ) != 4192;
}

$sndfile.close();


lives-ok { $buf = $encoder.encode-flush() }, "encode-flush";
ok($buf ~~ Buf , "returned buffer is a Buf");
ok($buf.elems > 0, "and there are some elements");
$out-fh.write($buf);
$out-fh.close;

if ( "/usr/bin/file".IO.x ) {
    like qqx/file $out-file }/, rx/MPEG/, "and it's a MP3 file";
}

$out-file.unlink;

sub uninterleave(@a) {
    my ( $b, $c);
    ($++ %% 2 ?? $b !! $c).push: $_ for @a;
    return $b, $c ;
}

done;
# vim: expandtab shiftwidth=4 ft=perl6
