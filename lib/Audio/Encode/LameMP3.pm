use v6;
use NativeCall;

class Audio::Encode::LameMP3:ver<v0.0.1>:auth<github:jonathanstowe> {

    class X::LameError is Exception {
        has Str $.message;
    }

    enum VBR-Mode <Off MT RH ABR MTRH>;
    enum MPEG-Mode <Stereo JointStereo DualChannel Mono NotSet>;
    enum PaddingType <No All Adjust>;

    class GlobalFlags is repr('CPointer') {
        sub lame_init() returns GlobalFlags is native('libmp3lame') { * }
        method new() {
            lame_init();
        }

        sub lame_init_params(GlobalFlags) returns int32 is native('libmp3lame') { * }

        method init() {
            my $rc = lame_init_params(self);

            if $rc != 0 {
                X::LameError.new(message => "Error initialising parameters").throw;
            }
        }

    }

    has GlobalFlags $!gfp;

    sub get_lame_version() returns Str is native('libmp3lame') { * }

    method lame-version() returns Version {
        my $v = get_lame_version();
        Version.new($v);
    }

    submethod BUILD() {
        $!gfp = GlobalFlags.new;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
