use v6;
use NativeCall;

class Audio::Encode::LameMP3:ver<v0.0.1>:auth<github:jonathanstowe> {
   class GlobalFlags is repr('CPointer') {
      sub lame_init() returns GlobalFlags is native('libmp3lame') { * }
      method new() {
         lame_init();
      }

   }

   has GlobalFlags $!gfp;

   submethod BUILD() {
       $!gfp = GlobalFlags.new;
   }

}

# vim: expandtab shiftwidth=4 ft=perl6
