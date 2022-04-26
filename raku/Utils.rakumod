use v6.d;

unit module Utils;

sub show-section-sep() is export { print "\n" ~ "=" x 10 ~ "\n" x 2; }
sub show-subsection-sep() is export { print "\n" ~ "-" x 10 ~ "\n\n"; }

sub show-section(&block) is export {
    show-section-sep;
    block();
    show-section-sep;
}

my @lorem-chars = [ |('a'..'z'), |('A'..'Z'), |('0'..'9') ];

our sub lorem-word(Int $max = 9, Int $min = 3) is export {
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
