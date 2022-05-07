use v6.d;

unit module Utils;

sub show-section-sep() is export { print "\n" ~ "=" x 10 ~ "\n" x 2; }
sub show-subsection-sep() is export { print "\n" ~ "-" x 10 ~ "\n\n"; }

multi sub show-section($enabled, &block) { samewith(&block) if $enabled; }
multi sub show-section(&block) is export {
    show-section-sep;
    block();
    show-section-sep;
}

my @lorem-chars = [ |('a'..'z'), |('A'..'Z'), |('0'..'9') ];

our sub lorem-word(Int $max = 9, Int $min = 3) is export {
    my $span = $min .. $max;
    @lorem-chars.roll($span.pick).join("")
}


our sub bench(Int $rep, &block) {
    my $times = do for ^$rep {
        block();
        now - ENTER now;
    }
    my ($fst, *$rest) = $times;
    say "Calls: $rep / ", $fst, " / ", do .sum / .elems with $rest;
}


our sub defined-and(Mu $x, &block) is export {
    return True unless $x.defined;
    block($x);
}

multi sub infix:<✔>(Mu $x, &block) is export {
    return True unless $x.defined;
    block($x);
}

multi sub infix:<⁈>(Mu $x, &block) is export {
    return True unless $x.so;
    block($x);
}


# https://github.com/ajs/perl6-Operator-Listcat/blob/master/lib/Operator/Listcat.pm6
multi sub infix:<listcat>(@a, @b) is equiv(&infix:<~>) is export { |@a, |@b }
multi sub infix:<⊕>(Iterable $a, Iterable $b) is looser(&infix:<xx>) is export {
    |$a, |$b
}


our sub join-paths($base, $other --> IO::Path) is export { "$base/$other".IO }

our sub list-dir($init where Str | IO::Path --> Seq) is export {
    my IO::Path @subdirs = [$init.IO.absolute.IO];
    gather while @subdirs {
        my $cur = @subdirs.shift(); # say $cur;
        my $seq := $cur.dir.cache;
        my ($, $dirs, $files) =
            take ($cur, $seq.grep(*.d)».basename, $seq.grep(*.d.not)».basename);
        my &absolutize := { join-paths($cur, $_) }
        @subdirs.prepend: $dirs».&absolutize;
    }
}
