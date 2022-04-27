use v6.d;

unit module Dirs;

our sub join-paths($base, $other --> IO::Path) is export(:all) { "$base/$other".IO }

our sub list-dir($init where Str | IO::Path --> Seq) is export(:all) {
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
