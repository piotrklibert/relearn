use v6.d;

# use ShowTable;
# constant base-file := "/home/cji/priv/klibert_pl/build/templates/base.html".IO;

# my $lines = base-file.lines.grep: *.contains: 'cache_busting_cookie';
my regex cookie-re { <?after 'cache_busting_cookie='>( \d+ ) }
.say for $*IN.lines».subst(&cookie-re, { $0 + (1..9).pick });

# .put for @$lines.grep(/cache/);

sub show-section-sep () {
    print "\n" ~ "=" x 10 ~ "\n" x 2;
}

# subset A where Array[Int] | Array[Str];

# sub fun(A @arg where *.elems < 3) {
#     say @arg.^name;
#     say @arg.raku;
# }

# fun Array[Int].new: [1,2];

# show-section-sep;

# fun (Array[Str].new: <3 4>);

# show-section-sep;

# fun ([3, 4]);
