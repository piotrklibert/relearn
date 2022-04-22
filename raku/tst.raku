use v6.d;
use lib <raku .>;
use ShowTable;

dd ShowTable::mk-table(10,10);

my @table = ShowTable::mk-table(15, 5);
{
    show-table(@table, (7 xx 5).Array);
    say now - INIT now;
}
say (" " x 5) ~ ('=' x 10);
{
    show-table(@table);
    say now - INIT now;
}
