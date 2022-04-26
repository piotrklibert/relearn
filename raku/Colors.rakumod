use v6.d;
use MONKEY;

unit module Colors;

use Terminal::ANSIColor;


our class Colored is export(:types) {
    has Str $.style;
    has Str $.string handles ("chars");

    method new($str, $style) {
        self.bless(style => $style, string => $str)
    }
    method substr(::?CLASS:D: |args) {
        $!string.=substr(|args);
        self.Str;
    }
    method Str() { $!string.&colored($!style) }
}


augment class Str {
    method color(Str:D : Str $c) {
        Colored.new(self, $c)
    }

    method no-color(Str:D:) {
        colorstrip(self)
    }
}
