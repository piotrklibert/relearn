use v6.d;

unit module ShowTable;
# unit not highlighted normally

use Utils;
use Colors :types;  # todo: what for / terminals & colors & chars


# not like i had these all from the beginning...

# All of the constrained subtypes below are checked dynamically, at run-time. I
# honestly have no idea how expensive these are. I hope they get inlined
# properly, at least. In any case, run-time impact of contracts like this is
# always an issue, traditionally solved by disabling checking of assertions in
# release mode. I'm not sure if it's possible to easily do this in Raku: in the
# worst case I'd have to edit the definitions below manually to comment out all
# the `where` clauses, effectively transforming `subset` into a C-like
# `typedef`.
subset Positive of Int where * > 0;
subset Character of Str where { .chars == 1 }; # NOTE: made a mistake, wrote .elem here instead of .chars, postcondition caught it!

# TODO: junctions, how they work, union types
subset MaybeColoredStr where Str | Colored;
subset ColumnSpec where Iterable | Int | Nil;

# There are some advantages to the use of enums... and then there's Raku which
# eliminates almost all of them. No exhaustiveness checking, no distinct
# identity (like in C, unlike in ML) for cases, no parametrization (obviously),
# just a little nicer syntax for a subset of literal values + declaring global
# identifiers for each case.
enum JustifyType is export <None Left Right Center>;
# BTW, see this:             👆 ?

# I wasn't intending on having this as an option, but then discovered that my
# first enum has a value of 0, which is false. That means I'd need to check for
# definitedness when using JustifyType with optional arguments! I should
# probably just explicitly assign values to enums, but adding `None` that would
# be 0/False kind-of-sort-of makes sense in this case, too.


# These checks are expensive, and they may have unintended cosequences for some
# of the Iterable sybtypes (eg. the lazy ones). On the other hand, not having to
# worry about the shape of the data *at all* within this module is too
# convenient to give up, and my use case does not involve large input sizes.
subset StrList of Iterable where { .cache.all ~~ MaybeColoredStr };
subset IntList of Iterable where { .cache.all ~~ Int };
subset StrTable of Iterable where { .cache.all ~~ StrList };

# I have to wonder, didn't NPM and left-pad fiasco teach us all that having no
# padding function in stdlib is a bad thing? Some examples:
#   - Python has str.ljust, str.rjust, and str.center
#   - Elixir has String.pad_leading, String.pad_trailing (no centering though)
#   - Nim has strutils.{alignRight, alignLeft, center}
#   - Haxe has StringTools.{rpad, lpad}
#   - Ruby has String.{center, ljust, rjust}
#   - Smalltalk (ST/X) has CharArray>>{#paddedTo:, #leftPaddedTo:, #centerPaddedTo:}
#   - Groovy has {.padLeft, .padRight, .center} added to java.lang.String
# and so on... yet here Raku makes me code this by hand? Even Scala has at
# least `String.padTo`! Or maybe I'm supposed to install a module just for
# this? I'm still not quite sure what kinds of packages are there. I'll search
# for one later; for now, coding it here seems like a better idea, because it
# gives me a chance to demonstrate some of the Raku's safety features.
sub str-justify(
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

# TODO: our and is export explanation

# BTW: I think the module systems gives WAY too much to the module author. It's
# a module's user that should decide which identifiers they wish to have
# injected into often top-level module scope.

# These two look too similar to be left alone without DRYing them. To abstract
# over the kind of a thing we're padding/justifying we need to take a bunch of
# functions/operators, namely: getting length of the thing, multiplying a
# thing, and concatenating the thing. It would be {.chars}, &infix:<~>,
# &infix:<x>, respectively, for strings
sub list-justify(
    Iterable $row,
    Positive $cols,
    Any :$fill = "",
    JustifyType :justify(:$type) = Left,
    --> List
) is export(:tests) {
    PRE $row.elems <= $cols; # descr of c0ntract, { "jgvjv"; ...} or #= ?
    PRE $row.map({ .WHAT }).all ~~ $fill.WHAT;
    POST $_✔{ .elems == $cols };

    return $row if .elems == $cols;
    my $diff := $cols - $row.elems;
    my $fill-list := (1..$diff).map:{ my $ = $fill }; # any other way?
    given $type {
        when Left  { $row ⊕ $fill-list }
        when Right { $fill-list ⊕ $row }
        when * { warn "Type {$type} not implemented yet!"; $row }
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
    elsif $char-num < $cell-width && ?$cell-justify-type { # "Some people would have paused here and started making jokes about how Raku can't have a "normal else if"... Whoever you are, please, don't be one of people like *that*...""
        str-justify($text, $cell-width, $cell-justify-type, $cell-padding);
    }
    else {
        $text;
    }
}


our sub to-table(StrList $seq, Int :$cols = 5 --> StrTable) is export {
    my $table := $seq.batch($cols)».Array.Array;
    $table.tail.=&list-justify($cols);
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
    # [Z] only in that case without worrying about lost elements
    PRE [==] $table».elems;
    PRE $col-widths ~~ Iterable ?? $col-widths.elems == $table[0].elems !! True;

    my Str $fill := $col-separator x $col-separator-width;
    my @table = @$table;
    my $cols := [Z] @table;
    dd $cols;
    for get-col-widths($col-widths, $cols).kv -> $col, $max {
        $cols[$col].=map:{ format-cell($_, $max, :$cell-padding)  }
    }
    # for @table { .join($fill).comb.raku.say }
    my $res = join "\n", (.join($fill) for @table);
    put $res;
}

multi get-col-widths(Int $width, @cols --> IntList) { $width xx @cols.elems }
multi get-col-widths(Iterable $widths, @cols --> IntList) { $widths }
multi get-col-widths($ where ?*.not, @cols --> IntList) { samewith(@cols) }

multi get-col-widths(@cols where { .all ~~ StrList  } --> IntList) {
    POST $_✔{ .elems == @cols.elems };
    my @widths[@cols.elems];
    @widths[$_] = @cols[$_]».chars.max for @widths.keys;
    @widths
}


use Terminal::Width;            # TODO, obviously

our sub show-list-in-table(
    StrList $seq, :$cols = 6, :$row-padding = " ", *%kwargs
) is export {
    $seq
    ==> to-table(:$cols)
    ==> show-table(|%kwargs);
}
