use v6.d;

use JSON::Fast;

use Colors;
use ShowTable;
use Utils;


sub dt(Str $s --> Str) {
    with $s.DateTime {
        (.year, "-", .month.fmt('%02d'), "-", .day.fmt('%02d') ).join
    }
}


show-section 1, {
    my constant $fields := <name updated eco likes desc>;
    my constant $widths := [25,  10,     5,  3,    60];

    my @table = [];

    for "raku.pkgs".IO.lines -> $line {
        my $rows := $line.&from-json()>>.{ $fields };
        next unless $rows;
        my $cols := [Z] $rows;
        $cols[1].=map(&dt);     # Why is it working? What made $cols mutable?
        $rows := [Z] $cols;
        @table.append($rows);
    }
    @table.=squish(as => { .[0].lc });
    @table.=grep({ (.[0] | .[4]) ~~ rx:i/term/ });
    dd @table;
    show-table(@table, :col-widths($widths));
}
