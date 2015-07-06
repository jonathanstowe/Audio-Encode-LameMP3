use v6;
use NativeCall;
use AccessorFacade;

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

        sub check(Str $what, Int $rc) {

        }

        sub lame_set_num_samples(GlobalFlags, uint64) returns int32 is native("libmp3lame") { * }
        sub lame_get_num_samples(GlobalFlags) returns uint64 is native("libmp3lame") { * }

        method num-samples() returns Int is accessor-facade(&lame_get_num_samples, &lame_set_num_samples, Code, &check.assuming('num-samples')) { }

        sub lame_set_in_samplerate(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_in_samplerate(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_num_channels(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_num_channels(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_scale(GlobalFlags, Num) returns int32 is native("libmp3lame") { * }
        sub lame_get_scale(GlobalFlags) returns Num is native("libmp3lame") { * }
        sub lame_set_scale_left(GlobalFlags, Num) returns int32 is native("libmp3lame") { * }
        sub lame_get_scale_left(GlobalFlags) returns Num is native("libmp3lame") { * }
        sub lame_set_scale_right(GlobalFlags, Num) returns int32 is native("libmp3lame") { * }
        sub lame_get_scale_right(GlobalFlags) returns Num is native("libmp3lame") { * }
        sub lame_set_out_samplerate(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_out_samplerate(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_analysis(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_analysis(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_bWriteVbrTag(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_bWriteVbrTag(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_decode_only(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_decode_only(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_quality(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_quality(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_mode(GlobalFlags, MPEG-Mode) returns int32 is native("libmp3lame") { * }
        sub lame_get_mode(GlobalFlags) returns MPEG-Mode is native("libmp3lame") { * }
        sub lame_set_mode_automs(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_mode_automs(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_force_ms(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_force_ms(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_free_format(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_free_format(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_findReplayGain(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_findReplayGain(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_decode_on_the_fly(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_decode_on_the_fly(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_ReplayGain_input(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_ReplayGain_input(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_ReplayGain_decode(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_ReplayGain_decode(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_findPeakSample(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_findPeakSample(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_nogap_total(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_nogap_total(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_nogap_currentindex(GlobalFlags , int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_nogap_currentindex(GlobalFlags) returns int32 is native("libmp3lame") { * }
        # Not sure if these will work
        sub lame_set_errorf(GlobalFlags, &cb ( Str $fmt, *@args) ) returns int32 is native("libmp3lame") { * }
        sub lame_set_debugf(GlobalFlags, &cb ( Str $fmt, *@args)) returns int32 is native("libmp3lame") { * }
        sub lame_set_msgf  (GlobalFlags, &cb ( Str $fmt, *@args)) returns int32 is native("libmp3lame") { * }
        sub lame_set_brate(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_brate(GlobalFlags) returns int32 is native("libmp3lame") { * }
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
        sub lame_set_padding_type(GlobalFlags, PaddingType) returns int32 is native("libmp3lame") { * }
        sub lame_get_padding_type(GlobalFlags) returns PaddingType is native("libmp3lame") { * }
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
        sub lame_set_preset_expopts(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
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
        sub lame_set_athaa_loudapprox( GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_athaa_loudapprox( GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_athaa_sensitivity( GlobalFlags, Num) returns int32 is native("libmp3lame") { * }
        sub lame_get_athaa_sensitivity( GlobalFlags ) returns Num is native("libmp3lame") { * }
        sub lame_set_cwlimit(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_cwlimit(GlobalFlags) returns int32 is native("libmp3lame") { * }
        sub lame_set_allow_diff_short(GlobalFlags, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_allow_diff_short(GlobalFlags) returns int32 is native("libmp3lame") { * }
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

        sub lame_get_bitrate(int32, int32) returns int32 is native("libmp3lame") { * }
        sub lame_get_samplerate(int32, int32 ) returns int32 is native("libmp3lame") { * }

        sub lame_init_params(GlobalFlags) returns int32 is native('libmp3lame') { * }

        method init() {
            my $rc = lame_init_params(self);

            if $rc != 0 {
                X::LameError.new(message => "Error initialising parameters").throw;
            }
        }

        sub lame_close(GlobalFlags) is native('libmp3lame') { * }

        method DESTROY() {
            lame_close(self);
        }
    }

    has GlobalFlags $!gfp;

    has Bool $!initialised = False;

    method !init() {
        if not $!initialised {
            $!gfp.init;
            $!initialised = True;
        }
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
