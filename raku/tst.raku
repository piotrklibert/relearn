use v6.d;

# use ShowTable;

sub show-section-sep () {
    print "\n" ~ "=" x 10 ~ "\n" x 2;
}

subset Indent of Int where { $_ %% 4 && $_ >= 0};

my Indent $*indent  = 0;

sub indent($s) { $s.indent($*indent) }

# NOTE: you can't do: sub do-with-indent(Indent $i = 4, &block) - can't put
# required positional argument after optional positional argument. But you can
# easily have multiple signatures for the same method using multi:
multi do-with-indent(&block) { samewith(4, &block); }
multi do-with-indent(Indent $i, &block) {
    temp $*indent += $i;
    block();
}

multi sub walk(IO::Path $p where *.d) {
    say indent($p);
    do-with-indent { samewith($_) for $p.dir; }
}
multi sub walk(IO::Path $p where *.d.not) {
    say indent $p;
}

walk "./raku/".IO;

constant Ux = IO::Spec::Unix;

sub join-paths($base, $other --> IO::Path) { "$base/$other".IO }

sub list-dir($init where Str | IO::Path --> Seq) {
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



my $s = lazy list-dir("./raku/".IO);
.[0].say for $s[^5];
show-section-sep;
# .[0].say for $s[4..^8];
# show-section-sep;
