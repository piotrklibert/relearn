use v6.d;

unit module ShowTable;

use Utils;
use Colors :types;


#| All of the constrained subtypes below are checked dynamically, on run-time. I
#| honestly have no idea how expensive these are. I hope they get inlined
#| properly, at least. In any case, run-time impact of contracts like this is
#| always an issue, traditionally solved by disabling checking of assertions in
#| release mode. I'm not sure if it's possible to easily do this in Raku: in the
#| worst case I'd have to edit the definitions below manually to comment out all
#| the `where` clauses, effectively transforming `subset` into a `typedef`.
subset Positive of Int where * > 0;
subset Character of Str where { .chars == 1 }; # NOTE: made a mistake, wrote .elem instead of .chars, postcondition caught it

subset MaybeColoredStr where Str | Colored;
subset ColumnSpec where Iterable | Int | Nil;

#| There are some advantages to the use of enums... and then there's Raku which
#| eliminates almost all of them. No exhaustiveness checking, no distinct
#| identity (like in C, unlike in ML) for cases, just a little nicer syntax for
#| a subset of literal values + declaring global identifiers for each case.
enum JustifyType is export <None Left Right Center>;
#| BTW, see this: ^^^^ ? I wasn't intending on having this as an option, but
#| then discovered that my first enum has a value of 0, which is false. That
#| means I'd need to check for definitedness when using JustifyType with
#| optional arguments! I should probably just explicitly assign values to enums,
#| but adding `None` kind-of-sort-of makes sense too.


# These checks are expensive, and they may have unintended cosequences for some
# of the Iterable sybtypes. On the other hand, not having to worry about the
# shape of the data at all within this module is too convenient to give up, and
# my use case does not involve large input sizes.
subset StrList of Iterable where { .cache.all ~~ MaybeColoredStr };
subset IntList of Iterable where { .cache.all ~~ Int };
subset StrTable of Iterable where { .cache.all ~~ StrList };

#| I have to wonder, didn't NPM and left-pad fiasco teach us all that having no
#| padding function in stdlib is a bad thing? Some examples:
#|   - Python has str.ljust, str.rjust, and str.center
#|   - Elixir has String.pad_leading, String.pad_trailing (no centering though)
#|   - Nim has strutils.{alignRight, alignLeft, center}
#|   - Haxe has StringTools.{rpad, lpad}
#|   - Ruby has String.{center, ljust, rjust}
#|   - Smalltalk (ST/X) has CharArray>>{#paddedTo:, #leftPaddedTo:, #centerPaddedTo:}
#|   - Groovy has {.padLeft, .padRight, .center} added to java.lang.String
#| and so on... yet here Raku makes me code this by hand? Even Scala has at
#| least `String.padTo`! Or maybe I'm supposed to install a module just for
#| this? I'm still not quite sure what kinds of packages are there. I'll search
#| for one later; for now, coding it here seems like a better idea, because it
#| gives me a chance to demonstrate some of the Raku's safety features.
sub str-justify(
    MaybeColoredStr $s,
    Positive $limit,
    JustifyType $type,
    Character $pad = " ",
    --> Str(MaybeColoredStr)
) {
    PRE $s.chars <= $limit;
    POST $_✔{ .no-color.chars == $limit } # NOTE: caught the problem with Character

    my $diff := $limit - $s.chars;
    given $type {
        when Left  { $s ~ ($pad x $diff); }
        when Right { ($pad x $diff) ~ $s; }
        when * { warn "Type {$type} not implemented yet!"; $s }
    }
}


#| Make sure the returned string has exactly $limit characters, clipping or
#| padding as needed. If it grows any larger than this, we should probably
#| introduce
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


sub get-col-widths(@cols where { .all ~~ StrList  } --> IntList) is export(:tests) {
    POST $_✔{ .elems == @cols.elems };
    my @widths = $ xx @cols.elems;
    @widths[$_] = @cols[$_]».chars.max for @widths.keys;
    @widths
}


sub list-justify(
    Iterable $row,
    Int $cols,
    Str :$fill = "",
    JustifyType :justify(:$type) = Left,
    --> List
) is export(:tests) {
    PRE $row.elems <= $cols;
    POST $_✔{ .elems == $cols };

    return $row if .elems == $cols;
    my $diff := $cols - $row.elems;
    given $type {
        when Left  { $row ⊕ ($fill xx $diff) }
        when Right { ($fill xx $diff) ⊕ $row }
        when * { warn "Type {$type} not implemented yet!"; $row }
    }
}


our sub to-table(StrList $seq, Int :$cols = 5 --> StrTable) is export {
    my $table := $seq.batch($cols)».Array.Array;
    $table.tail = list-justify($table.tail, $cols);
    $table
}

sub make-lorem-table(Int :r(:$rows), Int :$cols, Int :$max = 9 --> StrTable) is export(:tests) {
    to-table :$cols, (Utils::lorem-word($max) xx ($rows × $cols))
}

#| In this routine, we make sure we're dealing with data of one shape only: a
#| list of rows of equal length with each row being a list of strings. This
#| assumption is expressed succintly, simply mentioning StrTable in a type
#| position. This assumption is costly to enforce, but frees this routine from
#| most edge cases. The zip-reduce idiom, written as a special [Z] operator in
#| Raku, can be used for transposing the table, from list of rows to list of
#| columns.
our sub show-table(
    StrTable $table is copy,
    Str :$col-separator = " ",
    Positive :$col-separator-width = 5,
    ColumnSpec :w(:chars(:$col-widths)) = Nil,
    Character :$cell-padding = " ",
    JustifyType :justify(:$cell-justify-type) = Left,
) is export {
    # length of each row has to be the same - we can transpose the table with
    # [Z] only in that case
    PRE [==] $table».elems;
    PRE $col-widths ~~ Iterable ?? $col-widths.elems == $table[0].elems !! True;

    my @table = $table.list;
    my $fill := $col-separator x $col-separator-width;
    my @cols = [Z] @table;
    my $computed-widths = do given $col-widths {
        when Int      { $col-widths xx @cols.elems }
        when Iterable { $col-widths }
        default       { get-col-widths(@cols) }
    }
    for $computed-widths.kv -> $col, $max {
        @cols[$col].=map:{ format-cell($_, $max, :$cell-padding)  }
    }
    @table = [Z] @cols;
    # for @table { .join($fill).comb.raku.say }
    .join($fill).say for @table;
}



our sub show-list-in-table(
    StrList $seq, :$cols = 6, :$row-padding = " ", *%kwargs
) is export {
    $seq
    ==> to-table(:$cols)
    ==> show-table(|%kwargs);
}
