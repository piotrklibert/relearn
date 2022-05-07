use v6.d;

unit module ShowTable;

use Utils;
use Colors :types;

subset Positive of Int where * > 0;            # same as { $_ > 0 }
subset Character of Str where { .chars == 1 }; # same as { $_.chars == 1 }
                                               # or as *.chars == 1

subset MaybeColoredStr where Str | Colored;
subset ColumnSpec where Iterable | Int | Nil;

subset StrList of Iterable where { .cache.all ~~ MaybeColoredStr };
subset IntList of Iterable where { .cache.all ~~ Int };
subset StrTable of Iterable where { .cache.all ~~ StrList };

enum JustifyType is export <None Left Right Center>;

#| Pads given string with a given character up to a limit. Can pad on both
#| sides.
our sub str-justify(
    MaybeColoredStr $s,
    Positive $limit,
    JustifyType $type,
    Character $pad = " ",
    --> Str(MaybeColoredStr)
) is export(:tests) {
    PRE $s.chars <= $limit;
    POST $_✔{ .no-color.chars == $limit } # NOTE: caught the problem with Character

    my $diff := $limit - $s.chars;
    given $type {
        when Left  { $s ~ ($pad x $diff); }
        when Right { ($pad x $diff) ~ $s; }
        when * { warn "Type {$type} not implemented yet!"; $s } # a bug here would be caught by the postcondition, too
    }
}

sub list-justify(
    Iterable $row,
    Positive $cols,
    Any :$fill = "",
    JustifyType :justify(:$type) = Left,
    --> List
) is export(:tests) {
    PRE $row.elems <= $cols; # TODO: description/extended name for the contract, { "jgvjv"; ...} or maybe  #= ?
    POST $_✔{ .elems == $cols };  

    return $row if .elems == $cols;
    my $diff := $cols - $row.elems;
    my $fill-list := (1..$diff).map:{ my $ = $fill }; # any other way?
    given $type {
        when Left  { $row ⊕ $fill-list }
        when Right { $fill-list ⊕ $row }
        when * { warn "Type {$type} not implemented yet!"; $row  }
    }
}

#| Make sure the returned string has exactly $limit characters, clipping or
#| padding as needed.
our sub format-cell(
    MaybeColoredStr $text,
    Positive $cell-width,
    JustifyType :justify(:$cell-justify-type) = Left,
    Character :$cell-padding = " ",
    --> Str(MaybeColoredStr)
) {
    POST $_✔{ .no-color.chars == $cell-width };

    my Int $char-num := $text.chars;
    if $char-num > $cell-width {
        $text.substr(0, $cell-width - 1) ~ "…";
    }
    elsif $char-num < $cell-width && ?$cell-justify-type { 
        str-justify($text, $cell-width, $cell-justify-type, $cell-padding);
    }
    else {
        $text;
    }
}

#| Create a multi-line string with values from $table aligned into columns.
#| Passed $table cannot be empty.
our sub format-table(
    StrTable $table is copy,
    Str :$col-separator = " ",
    Positive :$col-separator-width = 5,
    ColumnSpec :w(:chars(:$col-widths)) = Nil,
    Character :$cell-padding = " ",
    JustifyType :justify(:$cell-justify-type) = Left,
    --> Str
) is export {
    PRE $table.elems > 0 && [==] $table».elems; # NOTE
    PRE ($col-widths ~~ Iterable)⁈{ $col-widths.elems == $table[0].elems };

    my Str $fill := $col-separator x $col-separator-width;
    my @table = @$table;
    # NOTE: the [Z] @table doesn't work when there's only one row
    my $cols := @table.elems == 1 ?? @table[0].map(*.list) !! [Z] @table;

    for get-col-widths($col-widths, $cols).kv -> $col, $max {
        $cols[$col].=map: { format-cell($_, $max, :$cell-padding) }
    }
    # for @table { .join($fill).comb.raku.say }
    join "\n", (.join($fill) for @table);
}

our sub show-table(|args) is export {
    put format-table(|args);
}

multi get-col-widths(Int $width, @cols --> IntList) { $width xx @cols.elems }
multi get-col-widths(Iterable $widths, @cols --> IntList) { $widths }
multi get-col-widths($ where ?*.not, @cols --> IntList) { samewith(@cols) }

multi get-col-widths(@cols where { .all ~~ StrList  } --> IntList) {
    POST $_✔{ .elems == @cols.elems };
    my @widths[@cols.elems];
    @widths[$_] = (@cols[$_]».chars.max or 1) for @widths.keys;
    @widths
}

use Terminal::Width; # TODO: be smarter about cols number/width if not specified

our sub to-table(StrList $seq, Int :$cols = 5 --> StrTable) is export {
    my $table := $seq.batch($cols)».Array.Array;
    $table.tail.=&list-justify($cols);
    $table
}

sub make-lorem-table(Int :r(:$rows), Int :$cols, Int :$max = 9 --> StrTable) is export(:tests) {
    to-table :$cols, (Utils::lorem-word($max) xx ($rows × $cols))
}

our sub show-list-in-table(
    StrList $seq, :$cols = 6, :$row-padding = " ", *%kwargs
) is export {
    $seq ==> to-table(:$cols) ==> show-table(|%kwargs);
}
