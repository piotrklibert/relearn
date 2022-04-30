use v6.d;

use Test;
use ShowTable;
use Utils;
use Meta;

show-section-sep;

my $lst = CORE::.keys.sort[^20];
show-list-in-table $lst;

show-section-sep;

my $p = ( ("asd", "asdasdasd"), ("233", "2") );
say col-widths($p);
show-list-in-table $p.flat, :5chars;

show-section-sep;

try ShowTable::format-cell("asdasd", 4, :!clip);
is $!.payload, q[Unexpected named argument 'clip' passed], 'bad named argument';

show-section-sep;

say ShowTable::format-cell("asdasd", 10, justify => ShowTable::Right);
