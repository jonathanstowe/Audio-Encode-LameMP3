use v6;
use NativeCall;
use AccessorFacade;

class Audio::Encode::LameMP3:ver<v0.0.1>:auth<github:jonathanstowe> {

    enum EncodeError ( Okay => 0, BuffTooSmall => -1, Malloc => -2, NotInit => -3, Psycho => -4 );

    class X::LameError is Exception {
        has Str $.message;
    }

    class X::EncodeError is X::LameError {
        has Str $.message;
        has EncodeError $.error;

        multi method message() {
            if not $!message.defined {
                $!message = do given $!error {
                    when BuffTooSmall {
                        "supplied buffer too small for encoded output";
                    }
                    when Malloc {
                        "unable to allocate enough memory to perform encoding";
                    }
                    when NotInit {
                        "global flags not initialised before encoding";
                    }
                    when Psycho {
                        "problem with psychoacoustic model";
                    }
                    default {
                        "unknown or not an error";
                    }
                }
            }
            $!message;
        }
    }

    enum VBR-Mode <Off MT RH ABR MTRH>;
    enum MPEG-Mode <Stereo JointStereo DualChannel Mono NotSet>;
    enum PaddingType <No All Adjust>;

    # Values returned by the encode functions

    class GlobalFlags is repr('CPointer') {

        sub lame_init() returns GlobalFlags is native('libmp3lame') { * }

        method new() {
            lame_init();
        }

        sub check(GlobalFlags $self, Int $rc, Str :$what = 'unknown method') {

        }

        # utilities
        sub copy-to-carray(@items, Mu $type) returns CArray {
            my $array = CArray[$type].new;
            $array[$_] = @items[$_] for ^@items.elems;
            $array;
        }

        sub get-buffer-size(Int $no-frames ) returns Int {
            my $num = ((1.25 * $no-frames) + 7200).Int;
            $num;
        }

        sub get-out-buffer(Int $size) returns CArray[uint8] {
            my $buff =  CArray[uint8].new;
            $buff[$size] = 0;
            $buff;
        }
        sub copy-carray-to-buf(CArray $array, Int $no-elems) returns Buf {
            my $buf = Buf.new;
            $buf[$_] = $array[$_] for ^$no-elems;
            $buf;
        }

        method encode-two(@left, @right, &encode-func, Mu $type ) returns Buf {
            if (@left.elems == @right.elems ) {

                my $left-in   = copy-to-carray(@left, $type);
                my $right-in  = copy-to-carray(@right, $type);
                my $frames    = @left.elems;
                my $buff-size = get-buffer-size($frames);
                my $buffer    = get-out-buffer($buff-size);

                my $bytes-out = &encode-func(self, $left-in, $right-in,  $frames, $buffer, $buff-size);

                if $bytes-out < 0 {
                    X::EncodeError.new(error => EncodeError($bytes-out)).throw;
                }
                copy-carray-to-buf($buffer, $bytes-out);
            }
            else {
                X::EncodeError.new(message => "not equal length frames in");
            }
        }

        # encode functions all return the number of bytes in the encoded output or a value less than 0
        # from the enum EncodeError above

        # Non-interleaved inputs are left, right. num_samples is actually number of frames.
        sub lame_encode_buffer(GlobalFlags, CArray[int16], CArray[int16], int32, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }

        multi method encode-short(@left, @right) returns Buf {
            self.encode-two(@left, @right, &lame_encode_buffer, int16);
        }

        sub lame_encode_buffer_interleaved(GlobalFlags, CArray[int16], int32, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }

        # not sure what this one is about. The include file comment suggests it is ints but the signature suggests otherwise
        sub lame_encode_buffer_float(GlobalFlags, CArray[num32], CArray[num32], int32, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }

        # seemed to be scaled to floats as we know them
        sub lame_encode_buffer_ieee_float(GlobalFlags, CArray[num32], CArray[num32], int32, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }

        multi method encode-float(@left, @right) returns Buf {
            self.encode-two(@left, @right, &lame_encode_buffer_ieee_float, num32);
        }

        sub lame_encode_buffer_interleaved_ieee_float(GlobalFlags, CArray[num32], int32, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }

        sub lame_encode_buffer_ieee_double(GlobalFlags, CArray[num64], CArray[num64], int32, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }

        multi method encode-double(@left, @right) returns Buf {
            self.encode-two(@left, @right, &lame_encode_buffer_ieee_float, num64);
        }

        sub lame_encode_buffer_interleaved_ieee_double(GlobalFlags, CArray[num64], int32, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }

        # ignoring the long variant as it appears to be a mistake
        # neither have an interleaved variant
        sub lame_encode_buffer_long2(GlobalFlags, CArray[int64], CArray[int64], int32, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }

        multi method encode-long(@left, @right) returns Buf {
            self.encode-two(@left, @right, &lame_encode_buffer_long2, int64);
        }

        # the include suggests that the scaling may be wonky on this.
        sub lame_encode_buffer_int(GlobalFlags, CArray[int32], CArray[int32], int32, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }

        multi method encode-int(@left, @right) returns Buf {
            self.encode-two(@left, @right, &lame_encode_buffer_int, int32);
        }

        # The nogap variant means the stream can be reused or something return number of bytes (and I guess <0 is an error
        sub lame_encode_flush(GlobalFlags, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }

        # allocate an overly long buffer to take the last bit
        method encode-flush() returns Buf {
            my $buffer = get-out-buffer(8192);
            my $bytes-out = lame_encode_flush(self, $buffer, 8192);

            if $bytes-out < 0 {
                X::EncodeError.new(error => EncodeError($bytes-out)).throw;
            }
            copy-carray-to-buf($buffer, $bytes-out);
        }

        # nogap allows you to continue using the same encoder - useful for streaming
        sub lame_encode_flush_nogap(GlobalFlags, CArray[uint8], int32) returns int32 is native('libmp3lame') { * }

        sub lame_set_in_samplerate(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_in_samplerate(GlobalFlags) returns int32 is native("libmp3lame") { * }

        method in-samplerate() returns Int is rw
            is accessor-facade(&lame_get_in_samplerate, &lame_set_in_samplerate, Code, &check) { }

        sub lame_set_num_channels(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_num_channels(GlobalFlags) returns int32 is native("libmp3lame") { * }

        method num-channels() returns Int
            is accessor-facade(&lame_get_num_channels, &lame_set_num_channels, Code, &check) { }

        sub lame_set_brate(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_brate(GlobalFlags) returns int32 is native("libmp3lame") { * }

        method bitrate() returns Int
            is accessor-facade(&lame_get_brate, &lame_set_brate, Code, &check) { }

        sub lame_set_quality(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_quality(GlobalFlags) returns int32 is native("libmp3lame") { * }

        method quality() returns Int
            is accessor-facade(&lame_get_quality, &lame_set_quality, Code, &check) { }


        sub lame_set_mode(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_mode(GlobalFlags) returns int32 is native("libmp3lame") { * }

        method mode() returns MPEG-Mode
            is accessor-facade(&lame_get_mode, &lame_set_mode, Code, &check ) { }


        # below less commonly used

        sub lame_set_num_samples(GlobalFlags, uint64) returns int32 is native("libmp3lame") { * }
        sub lame_get_num_samples(GlobalFlags) returns uint64 is native("libmp3lame") { * }

        method num-samples() returns Int is rw
            is accessor-facade(&lame_get_num_samples, &lame_set_num_samples, Code, &check ) { }


        sub lame_set_scale(GlobalFlags, num32) returns int32 is native("libmp3lame") { * }
        sub lame_get_scale(GlobalFlags) returns num32 is native("libmp3lame") { * }

        method scale() returns Num is rw
            is accessor-facade(&lame_get_scale, &lame_set_scale, Code, &check ) { }

        sub lame_set_scale_left(GlobalFlags, num32) returns int32 is native("libmp3lame") { * }
        sub lame_get_scale_left(GlobalFlags) returns num32 is native("libmp3lame") { * }

        method scale-left() returns Num is rw
            is accessor-facade(&lame_get_scale_left, &lame_set_scale_left, Code, &check ) { }

        sub lame_set_scale_right(GlobalFlags, Num) returns int32 is native("libmp3lame") { * }
        sub lame_get_scale_right(GlobalFlags) returns Num is native("libmp3lame") { * }

        method scale-right() returns Num is rw
            is accessor-facade(&lame_get_scale_right, &lame_set_scale_right, Code, &check ) { }

        sub lame_set_out_samplerate(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_out_samplerate(GlobalFlags) returns int32 is native("libmp3lame") { * }

        method out-samplerate() returns Int is rw
            is accessor-facade(&lame_get_out_samplerate, &lame_set_out_samplerate, Code, &check ) { }


        sub lame_set_analysis(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_analysis(GlobalFlags) returns int32 is native("libmp3lame") { * }

        method set-analysis() returns Bool is rw
            is accessor-facade(&lame_get_analysis, &lame_set_analysis, Code, &check ) { }


        sub lame_set_bWriteVbrTag(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_bWriteVbrTag(GlobalFlags) returns int32 is native("libmp3lame") { * }

        method write-vbr-tag() returns Bool is rw
            is accessor-facade(&lame_get_bWriteVbrTag, &lame_set_bWriteVbrTag, Code, &check ) { }

        sub lame_set_decode_only(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_decode_only(GlobalFlags) returns int32 is native("libmp3lame") { * }

        method decode-only() returns Bool is rw
            is accessor-facade(&lame_get_decode_only, &lame_set_decode_only, Code, &check ) { }


        sub lame_set_nogap_total(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_nogap_total(GlobalFlags) returns int32 is native("libmp3lame") { * }

        method nogap-total() returns Int is rw
            is accessor-facade(&lame_get_nogap_total, &lame_set_nogap_total, Code, &check ) { }

        sub lame_set_nogap_currentindex(GlobalFlags , int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_nogap_currentindex(GlobalFlags) returns int32 is native("libmp3lame") { * }


        sub lame_set_compression_ratio(GlobalFlags, Num) returns int32 is native("libmp3lame") { * }
        sub lame_get_compression_ratio(GlobalFlags) returns Num is native("libmp3lame") { * }
        sub lame_set_preset( GlobalFlags, int32 ) returns int32 is native("libmp3lame") { * }
        sub lame_set_asm_optimizations( GlobalFlags, int32, int32 ) returns int32 is native("libmp3lame") { * }
        sub lame_set_copyright(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_copyright(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_original(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_original(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_error_protection(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_error_protection(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_extension(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_extension(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_strict_ISO(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_strict_ISO(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_disable_reservoir(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_disable_reservoir(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_quant_comp(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_quant_comp(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_quant_comp_short(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_quant_comp_short(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_exp_nspsytune(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_exp_nspsytune(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_msfix(GlobalFlags, num64)  is native("libmp3lame") { * }
        sub lame_get_msfix(GlobalFlags) returns Num is native("libmp3lame") { * }
        sub lame_set_VBR(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_VBR(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_VBR_q(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_VBR_q(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_VBR_quality(GlobalFlags, Num) returns int32 is native("libmp3lame") { * }
        sub lame_get_VBR_quality(GlobalFlags) returns Num is native("libmp3lame") { * }
        sub lame_set_VBR_mean_bitrate_kbps(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_VBR_mean_bitrate_kbps(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_VBR_min_bitrate_kbps(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_VBR_min_bitrate_kbps(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_VBR_max_bitrate_kbps(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_VBR_max_bitrate_kbps(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_VBR_hard_min(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_VBR_hard_min(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_lowpassfreq(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_lowpassfreq(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_lowpasswidth(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_lowpasswidth(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_highpassfreq(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_highpassfreq(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_highpasswidth(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_highpasswidth(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_ATHonly(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_ATHonly(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_ATHshort(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_ATHshort(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_noATH(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_noATH(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_ATHtype(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_ATHtype(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_ATHlower(GlobalFlags, Num) returns int32 is native("libmp3lame") { * }
        sub lame_get_ATHlower(GlobalFlags) returns Num is native("libmp3lame") { * }
        sub lame_set_athaa_type( GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_athaa_type( GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_athaa_sensitivity( GlobalFlags, Num) returns int32 is native("libmp3lame") { * }
        sub lame_get_athaa_sensitivity( GlobalFlags ) returns Num is native("libmp3lame") { * }
        sub lame_set_useTemporal(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_useTemporal(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_interChRatio(GlobalFlags, Num) returns int32 is native("libmp3lame") { * }
        sub lame_get_interChRatio(GlobalFlags) returns Num is native("libmp3lame") { * }
        sub lame_set_no_short_blocks(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_no_short_blocks(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_force_short_blocks(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_force_short_blocks(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_emphasis(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_emphasis(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_get_version(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_get_encoder_delay(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_get_encoder_padding(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_get_framesize(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_get_mf_samples_to_encode( GlobalFlags  ) returns int32 is native("libmp3lame") { * }
        sub lame_get_size_mp3buffer( GlobalFlags  ) returns int32 is native("libmp3lame") { * }
        sub lame_get_frameNum(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_get_totalframes(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_get_RadioGain(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_get_AudiophileGain(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_get_PeakSample(GlobalFlags) returns Num is native("libmp3lame") { * }
        sub lame_get_noclipGainChange(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_get_noclipScale(GlobalFlags) returns Num is native("libmp3lame") { * }
        sub lame_get_id3v1_tag(GlobalFlags, CArray[uint8], int64) returns int64 is native("libmp3lame") { * }
        sub lame_get_id3v2_tag(GlobalFlags,CArray[uint8] , int64) returns int64 is native("libmp3lame") { * }
        sub lame_set_write_id3tag_automatic(GlobalFlags , int32)  is native("libmp3lame") { * }
        sub lame_get_write_id3tag_automatic(GlobalFlags) returns int32 is native("libmp3lame") { * }

        # Not the same interface
        sub lame_get_bitrate(int32, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_samplerate(int32, int32 ) returns int32 is native("libmp3lame") { * }

        # Not sure if these will work
        sub lame_set_errorf(GlobalFlags, &cb ( Str $fmt, *@args) ) returns int32 is native("libmp3lame") { * }
        sub lame_set_debugf(GlobalFlags, &cb ( Str $fmt, *@args)) returns int32 is native("libmp3lame") { * }
        sub lame_set_msgf  (GlobalFlags, &cb ( Str $fmt, *@args)) returns int32 is native("libmp3lame") { * }


        sub lame_init_params(GlobalFlags) returns int32 is native('libmp3lame') { * }

        method init() {
            my $rc = lame_init_params(self);

            if $rc != 0 {
                X::LameError.new(message => "Error initialising parameters").throw;
            }
        }

        # This is not necessary but using flush_nogap and this it is possible to reuse
        # the same encoder which may be useful for streaming
        sub lame_init_bitstream(GlobalFlags) returns int32 is native('libmp3lame') { * }

        method init-bitstream() {
            my $rc = lame_init_bitstream(self);

            if $rc != 0 {
                X::LameError.new(message => "Error (re)initialising bitstream").throw;
            }
        }

        # The API docs and the include differ in the necessity of calling this.
        # As we'll only be "streaming" I'll hedge.
        
        sub lame_mp3_tags_fid(GlobalFlags, Pointer) is native('libmp3lame') { * }

        method mp3-tags() {
            lame_mp3_tags_fid(self, Pointer);
        }


        sub lame_close(GlobalFlags) is native('libmp3lame') { * }

        method DESTROY() {
            lame_close(self);
        }
    }

    has GlobalFlags $!gfp handles <
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

    has Bool $!initialised = False;

    method init() {
        if not $!initialised {
            $!gfp.init;
            $!initialised = True;
        }
    }

    multi method encode-short(@left, @right) returns Buf {
        $!gfp.encode-short(@left, @right);
    }

    multi method encode-int(@left, @right) returns Buf {
        $!gfp.encode-int(@left, @right);
    }

    multi method encode-long(@left, @right) returns Buf {
        $!gfp.encode-long(@left, @right);
    }

    multi method encode-float(@left, @right) returns Buf {
        $!gfp.encode-float(@left, @right);
    }

    multi method encode-double(@left, @right) returns Buf {
        $!gfp.encode-double(@left, @right);
    }

    method encode-flush() returns Buf {
        $!gfp.encode-flush();
    }

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
