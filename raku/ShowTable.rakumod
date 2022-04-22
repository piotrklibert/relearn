use v6.d;

unit module ShowTable;

our sub pad-right(Str $s, Int $limit) {
    given $limit - $s.chars {
        when * > 0 { $s ~ (" " x $_)                 }
        when * < 0 { $s.substr(0, $limit - 1) ~ "…"; }
        default    { $s                              }
    }
}


my @lorem-chars = [ |('a'..'z'), |('A'..'Z'), |('0'..'9') ];
our sub lorem-word(Int $max = 9, Int $min = 3) {
    my $span = $min .. $max;
    @lorem-chars.roll($span.pick).join("")
}


our sub mk-table(Int $rows, Int $cols, Int $max = 9) {
    do for ^$rows { (lorem-word($max) for ^$cols).Array }
}


sub col-widths(@cols) {
    my @widths = $ xx @cols.elems;
    for 0 ..^ @widths.elems -> $c {
        @widths[$c] = @cols[$c]».chars.max;
    }
    @widths
}


our sub show-table(@table is copy, @widths?, $separator-width = 5) is export {
    dd @table;
    my $fill = " " x $separator-width;
    my @cols = [Z] @table;
    dd @cols;
    @widths = @widths ?? @widths !! col-widths(@cols);
    for @widths.kv -> $col, $max {
        @cols[$col].=map:{ pad-right($_, $max) };
    }
    @table = [Z] @cols;
    .join($fill).say for @table;
}
