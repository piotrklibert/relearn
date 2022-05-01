use v6.d;

use Terminal::ANSIColor;

use ShowTable;
use Utils;
use Meta;

my $obj = PseudoStash;

# show-section { ns($obj); }
# show-section { cls($obj); }
# show-section { meths($obj); }
# show-section { doc($obj); }


# special: <default reset inverse on_default>
my @colors = < bold italic underline black red green yellow blue magenta cyan white >;
my @backgrounds = < on_black on_red on_green on_yellow on_blue on_magenta on_cyan on_white >;

sub maybe-colorize(Str $s) { (0, 1).pick() ?? $s.in-color(@colors.pick()) !! $s }
my $p = (&maybe-colorize o { lorem-word(15) } ... ∞)[^15];

say "here";

show-section 1, {
    show-list-in-table(
        :col-separator("."),
        $p, :3cols,
        :cell-padding("_")
    );
}

show-section 0, { show-table ShowTable::make-lorem-table(3, 3); }


show-section 0, {
    my $it = lazy gather for ^10 { say "Here: $_"; .take };
    my $todo = $it.iterator();

    for ^5 { $todo.pull-one }
    say "2"; $todo.pull-one;
    say "3"; $todo.pull-one;
}

module PostCondition {
    sub post($s where Str --> Str) {
        PRE $s.chars < 10;
        POST $_ ✔{ .chars == $s.chars };
        $s.comb.reverse.join;
    }
    if False {
        dd post(3);
        dd post("asd" x 3);
        dd post("asd" x 32);
    }
}

show-section 0, {
    use nqp;
    say nqp::chars("asdasd");
}


use JSON::Fast;

sub dt(Str $s --> Str) {
    with $s.DateTime {
        (.day.fmt('%02d'), "-", .month.fmt('%02d'), "-", .year).join
    }
}


show-section 1, {
    my constant $fields := <name updated eco likes desc>;
    my constant $widths := [25,  10,     5,  3,    60];

    for "raku.pkgs".IO.lines -> $line {
        my $p := $line.&from-json()>>.{ $fields };
        next unless $p;
        my $cols := [Z] $p;
        $cols[1].=map(&dt);
        [Z] $cols ==> show-table(:col-widths($widths));
        exit;
    }
}
