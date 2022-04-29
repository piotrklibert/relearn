use v6.d;

unit module Meta;

use Terminal::ANSIColor;

use Utils;
use ShowTable;


my $package-names = (
    "MY", "OUR", "CORE", "GLOBAL", "PROCESS", "CALLER", "CALLERS",
    "DYNAMIC", "OUTER", "OUTERS", "LEXICAL", "UNIT", "SETTING", "PARENT",
    "CLIENT"
);

# change my -> our to make all the functions available at once when testing
module Priv {
    sub all-caps(Str $s --> Bool()) is export {
        $s.match: / ^(<upper>|<[-&$@_%!]>)+$ /;
    }

    sub show-class-header(Mu \obj) is export {
        say (
            "Class",
            colored(obj.^name, "green"),
            "is:",
            colored(obj.^mro.raku, "yellow"),
            "does:",
            colored((try obj.^roles.raku) || "<ERROR>", "bold")
        ).join(' ');
    }

    sub natural-ordering(Str $a, Str $b) is export {
        my ($caps-a, $caps-b) = (all-caps($a), all-caps($b));
        # dd $caps-a, $caps-b, $a, $b;
        my Order $ret = do {
            when $caps-a  && $caps-b  { $a cmp $b }
            when $caps-a  && !$caps-b { Less }
            when !$caps-a && $caps-b  { More }
            default                   { $a cmp $b }
        }
        # dd $ret;
        $ret
    }

    sub sort-by-name(Iterable $seq) is export {
        $seq.sort({ natural-ordering($^a.name, $^b.name) })
    }


    sub classify-symbols($seq) is export {
        $seq.classify: {
            when all-caps(.name) { 'caps' }
            when .name.match(/^<upper>/) { 'upper' }
            default { 'lower' }
        }
    }
}

import Priv;


# ==============================================================================


our sub meths(Mu \obj) is export {
    show-section-sep;
    show-class-header(obj);
    print "\n";

    my $rows = sort-by-name(obj.^methods.unique(:as(*.name))).map: {
        (colored(.name, "yellow"), .signature.raku, (try "{.file} : {.line}") || "<BUILT-IN>")
    };
    show-table($rows, :widths(15, 40, 40));
}


our sub doc($query, :l(:$lines) = 15) is export {
    my $res = qqx[ rakudoc '$query' ];
    if $res {
        say $res.lines[^$lines].join("\n")
    };
    "";
}


our sub cls(Mu \obj) is export {
    my $m = obj.^methods.unique(:as(*.name));
    my %m = classify-symbols($m);
    show-section-sep;
    show-class-header(obj);
    for <caps upper lower> {
        FIRST show-subsection-sep;
        sort-by-name(%m{$_})>>.name ==> show-list-in-table(:5cols) if %m{$_}:exists;
        show-subsection-sep;
    }
}


our sub ns($pkg) is export {
    # EXPORT::ALL::.keys
    my $fuck = 3;
    say $pkg.^name;
    # say ::("CALLER")::EXPORT::ALL::.keys;
    # $package-names.map({ "- " ~ (try { $_ ~ " " ~ ::("$_")::.keys.raku } || $_ )})>>.say;
}
