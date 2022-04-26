use v6.d;

use Terminal::ANSIColor;

use Test;
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

sub maybe-colorize($s) { (0, 1).pick() ?? $s.color(@colors.pick()) !! $s }
my $p = (&maybe-colorize o { lorem-word(15) } ... ∞)[^15];

# show-section {

#     show-table ShowTable::make-lorem-table(3, 3);
# }

show-section {
    show-list-in-table(
        :col-separator("."),
        $p, :3cols,
        :cell-padding("_")
    );
}
