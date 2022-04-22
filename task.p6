# my $split-version = { .split(/'=='|'@'/)».trim.pairup }
# my @toml = "script.toml".IO.lines.grep(none "" | /^'#'/).map:{S/'=' .* $ //.trim};
# my ($s1, $s2, $s3, $s4) = @toml.grep(/^ '[' .* ']' $/, :k);
# my ($toml-deps, $toml-dev-deps) = [@toml[$s2^..^$s3], @toml[$s3^..^$s4]];
# my %vers = "script.txt".IO.lines.map($split-version).flat;
# sub print-deps(@deps) {
#     do for @deps -> $n {
#         given %vers{$n} {
#             when .defined and not .starts-with("file") { "$n==$_" }
#             default { $n }
#         }
#     }
# }

# .say for print-deps($toml-dev-deps).sort

use Test;
use MONKEY;


sub intersperse(&func, @seq, :$end = False) {
    gather for @seq -> $a, $b {
        take ($a, func($a, $b), $b).Slip;
        LAST if $end { take func($b, $end); };
    }
}
sub connect( ($a1, $a2), ($b1, $b2) ) { $($a2, $b1) }

multi show( $kind, $obj where $kind ~~ 'keys' ){
    say "\nKeys of " ~ $obj.^name;
    dd $obj.keys
}
multi show( $kind, %sections where $kind ~~ /'section'.*/ ){
    say "\n$kind\n";
    for %sections.kv -> $k, $v {
        say "$k = \n{$v.join("\n").indent(4)}"
    };
}

# sub into-sections(@lst, $re) {
#     my @headers = @lst.grep($re, :k).batch(2);
#     # @haders is something like this now: ((0, 5), (40, 67));
#     my $ranges = intersperse &connect, @headers, :end($(+@lst, *));
#     # @haders is now: ((0, 5), (5, 40), (40, 67), (67, end-of-file));
#     $ranges.map(-> ($a, $b) { @lst[$a] => @lst[$a^..^$b] });
# }
use ShowTable;

# sub read-txt(Str $fname --> List of Int)

sub read-toml() {
    "script.toml".IO.lines
        .grep(none "" | /^'#'/)
        .map(*.subst(/'='.*$/, "").trim);
}

my @toml-lines = read-toml();
my @headers = @toml-lines.grep(/^'['.*']'$/, :k);
my @ranges = (@headers Z (|@headers[1..*], +@toml-lines)).flatmap(*.list);
my %sections = do for @ranges { @toml-lines[$^a] => @toml-lines[$^a^..^$^b] };
my ($deps-dev, $deps) =
    do (.first(/'.dev'/), .first(/'.dep'/)) with %sections.keys.cache;

# say %sections{$deps}.sort.join("\n").indent(4);
dd %sections{$deps-dev};
say "";
# ;

sub pad-row-right($row, $cols, :$fill = "", --> List) {
    PRE $row.elems <= $cols;
    my @row = @$row;
    @row[0] = "sadasdasd";
    given @row {
        when .elems == $cols { @row }
        default {
            (|@row, |($fill for ^($cols - @row.elems)));
        }
    }
}


my @row of Str = ["asd"];
@row = pad-row-right(@row, 5, fill => "xxx");
dd @row;
@row = pad-row-right(@row, 5);
dd @row;

sub to-table(@seq, Int :$cols = 5) {
    my @t = @seq.Array;
    @t = @t.flat.batch(5)».Array;
    my @l = |@t[*-1];
    if @l.elems < 5 {
        @l.push("") for ^(5-@l.elems);
    }
    @t[*-1] = @l;
    @t
}

# dd $_ for to-table %sections{$deps-dev}.Seq, :5cols;

# show-table to-table %sections{$deps-dev}.Seq, :5cols;
# my @t = %sections{$deps-dev}.flat;
# @t = @t.flat.batch(5)».Array;
# my @l = |@t[*-1];
# dd @t;
# dd @l;
# if @l.elems < 5 {
#     @l.push("") for ^(5-@l.elems);
# }
# @t[*-1] = @l;
# dd @t;
# if @tail.elems < @t[0].elems {
#     @tail.push: "" for
# }
# dd @t;
# say "----";
# dd [Z] @t;

# show-table @t;
# dd $ranges.duckmap(*.List);
# show(q|keys|,  %sections);
# my %s = .{ .keys.grep: /'dependencies'/ }:kv with %sections;

# "([tool.poetry.dependencies] [tool.poetry.dev-dependencies])"
# say %s.keys;
# my %s = do with %sections {
#     .{ .keys.grep: /'dependencies'/ }:kv
# };
# show q/section 2/, %s;
# say
