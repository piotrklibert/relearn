use v6.d;

unit module Utils;


my @lorem-chars = [ |('a'..'z'), |('A'..'Z'), |('0'..'9') ];

our sub lorem-word(Int $max = 9, Int $min = 3) {
    my $span = $min .. $max;
    @lorem-chars.roll($span.pick).join("")
}

our sub bench(Int $rep, &block) {
    my $times = do for ^$rep {
        block();
        now - ENTER now;
    }
    my ($fst, *$rest) = $times;
    say "Calls: $rep / ", $fst, " / ", do .sum / .elems with $rest;
}
