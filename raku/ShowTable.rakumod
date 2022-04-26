use v6.d;

unit module ShowTable;

use Utils;
use Colors :types;


our enum JustifyType < None Left Right Center >;

subset StrOrColored where Str | Colored;

subset StrList where { .cache.all ~~ StrOrColored };
subset StrTable where { .cache.all ~~ StrList };

subset ColSpec where Iterable | Int | Nil;

# (True...∞)
sub str-justify(StrOrColored $s, Int $limit, JustifyType $type, Str $pad = " ") {
    my $diff := $limit - $s.chars;
    given $type {
        when Left  { $s ~ ($pad x $diff); }
        when Right { ($pad x $diff) ~ $s; }
        when * { warn 'Not implemented yet!'; $s }
    }
}


#| Make sure the returned string has exactly $limit characters, clipping or
#| padding as needed.
our sub format-cell(
    StrOrColored $text,
    Int $cell-width,
    JustifyType :$cell-justify-type = Left,
    Str :$cell-padding = " ",
    --> Str
) {
    do {
        POST .no-color.chars == $cell-width; # NOTE: 11

        my Int $char-num := $text.chars;
        if $char-num > $cell-width {
            $text.substr(0, $cell-width - 1) ~ "…";
        }
        elsif $char-num < $cell-width && ?$cell-justify-type {
            str-justify($text, $cell-width, $cell-justify-type, $cell-padding);
        }
        else {
            $text.Str;
        }
    }
}


subset IntList of List where { .all ~~ Int };


sub get-col-widths(@cols where { .all ~~ List  } --> IntList) is export {
    POST .elems == @cols.elems;
    my @widths = $ xx @cols.elems;
    @widths[$_] = @cols[$_]».chars.max for @widths.keys;
    @widths
}




our sub show-table(
    StrTable $table is copy,
    Str :$col-separator = " ",
    Int :$col-separator-width = 5,
    ColSpec :w(:chars(:$col-width)) = Nil,
    Str :$cell-padding = " ",
    JustifyType :justify(:$cell-justify-type) = Left,
) is export {
    # length of each row has to be the same, otherwise [Z] won't work
    PRE [==] $table».elems;
    PRE $col-width ~~ Iterable ?? $col-width.elems == $table[0].elems !! True;

    my @table := $table.list;
    my $fill = $col-separator x $col-separator-width;
    my @cols = [Z] @table;
    my $col-widths = do given $col-width {
        when Int      { $col-width xx @cols.elems }
        when Iterable { $col-width }
        default       { get-col-widths(@cols) }
    }
    for $col-widths.kv -> $col, $max {
        @cols[$col].=map:{ format-cell($_, $max, )  }
    }
    @table = [Z] @cols;
    # for @table { .join($fill).comb.raku.say }
    .join($fill).say for @table;
}


sub pad-row(StrList $row, Int $cols, Str :$fill = "" --> List) {
    PRE $row.elems <= $cols;
    POST .elems == $cols;
    return $row if .elems == $cols;
    $row.append: $fill xx ($cols - $row.elems);
}


our sub to-table(StrList $seq, Int :$cols = 5 --> StrTable) is export {
    my $table := $seq.batch($cols)».Array.Array;
    $table.tail = pad-row($table.tail, $cols);
    $table
}


our sub make-lorem-table(Int $rows, Int $cols, Int $max = 9 --> StrTable) {
    to-table :$cols, (Utils::lorem-word($max) xx ($rows × $cols))
}

our sub show-list-in-table(
    StrList $coll, :$cols = 6, :$row-padding = " ", *%kwargs
) is export {
    $coll ==> to-table(cols => $cols) ==> show-table(|%kwargs);
}
