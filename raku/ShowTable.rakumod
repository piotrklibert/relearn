use v6.d;

unit module ShowTable;

use Utils;


our sub pad-right(Str $s, Int $limit --> Str) {
    given $limit - $s.chars {
        when * > 0 { $s ~ (" " x $_)                 }
        when * < 0 { $s.substr(0, $limit - 1) ~ "…"; }
        default    { $s                              }
    }
}


sub col-widths(@cols) {
    my @widths = $ xx @cols.elems;
    for 0 ..^ @widths.elems -> $c {
        @widths[$c] = @cols[$c]».chars.max;
    }
    @widths
}


sub pad-row-right($row, $cols, :$fill = "" --> List) {
    PRE $row.elems <= $cols;
    my @row = @$row;
    given @row {
        when .elems == $cols { @row }
        default {
            (|@row, |($fill for ^($cols - @row.elems)));
        }
    }
}
# my @row of Str = ["asd"];
# @row = pad-row-right(@row, 5, fill => "xxx");
# dd @row;
# @row = pad-row-right(["asd"], 5);
# dd @row;


our sub to-table(@seq, Int :$cols = 5) is export {
    my $t = @seq.batch($cols)».Array.Array;
    $t[*-1] = pad-row-right($t[*-1], $cols).Array;
    @$t
}


our sub mk-lorem-table(Int $rows, Int $cols, Int $max = 9) {
    do for ^$rows { (Utils::lorem-word($max) for ^$cols).Array }
}


our sub show-table(@table is copy, $separator-width = 5, :$widths?) is export {
    # length of each row has to be the same, otherwise [Z] won't work
    PRE [==] @table».elems;

    my $fill = " " x $separator-width;
    my @cols = [Z] @table;
    my $col-widths = do given $widths {
        when .isa(Int) { ($widths xx @cols.elems).Array }
        when .does(Iterable) { $widths }
        default { col-widths(@cols) }
    };
    for $col-widths.kv -> $col, $max {
        @cols[$col].=map:{ pad-right($_, $max) };
    }
    @table = [Z] @cols;
    .join($fill).say for @table;
}


our sub show-list-in-table(@coll, :$cols = 6, :$chars) is export {
    show-table(to-table(@coll, cols => $cols), widths => $chars);
}
