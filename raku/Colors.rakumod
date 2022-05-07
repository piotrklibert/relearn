use v6.d;

use MONKEY; # 🙈 - because augmenting existing classes is very bad for
            # performance; which is strange, b/c Smalltalk - see note

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

    method in-color(Str $!style) {}

    method no-color() {
        $!string
    }

    method Str() { $!string.&colored($!style) }
}


augment class Str {
    method in-color(Str:D : Str $c) {
        Colored.new(self, $c)
    }

    method no-color(Str:D:) {
        colorstrip(self)
    }
}
