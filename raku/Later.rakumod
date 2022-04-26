use v6.d;

unit module Later;


sub pairwise(&func, @seq, :$end = False) {
    gather for @seq -> $a, $b {
        take ($a, func($a, $b), $b).Slip;
        LAST if $end { take func($b, $end); };
    }
}

sub connect( ($a1, $a2), ($b1, $b2) ) { $($a2, $b1) }

sub into-sections(@lst, $re) {
    my @headers = @lst.grep($re, :k).batch(2);
    # @haders is something like this now: ((0, 5), (40, 67));
    my $ranges = pairwise &connect, @headers, end => $(@lst.elems, *);
    # $ranges is now: ((0, 5), (5, 40), (40, 67), (67, end-of-file));
    $ranges.map(-> ($a, $b) { @lst[$a] => @lst[$a^..^$b] });
}


# my @t = %sections{$deps-dev}.flat;
# @t = @t.flat.batch(5)».Array;

# dd $ranges.duckmap(*.List);

# my %s = .{ .keys.grep: /'dependencies'/ }:kv with %sections;
# say ~%s.keys == "([tool.poetry.dependencies] [tool.poetry.dev-dependencies])";

# =========== augmenting and type coertion

use MONKEY;

class Fuck {
    has $!p;

    method new($p) {
        self.bless(|%{p => $p})
    }

    submethod BUILD(*%h) {
        say %h;
        $!p = %h<p>;
    }
}

augment class Any {
    method Fuck() { Fuck.new: self.Str; }
}

"as3das".IO.Fuck.raku.say;

sub f(Fuck() $f) {
    say "fuck";
}
