use v6.d;

unit module Reading;


sub read-toml() {
    "script.toml".IO.lines
        .grep(none "" | /^'#'/)
        .map(*.subst(/'='.*$/, "").trim);
}

sub extract-sections() is export {
    my @toml-lines = read-toml();
    my @headers = @toml-lines.grep(/^'['.*']'$/, :k);
    my @ranges = (@headers Z (|@headers[1..*], +@toml-lines)).flatmap(*.list);
    my %sections = do for @ranges { @toml-lines[$^a] => @toml-lines[$^a^..^$^b] };
    my ($deps-dev, $deps) =
        do (.first(/'.dev'/), .first(/'.dep'/)) with %sections.keys.cache;
    %sections{$deps}, %sections{$deps-dev};
}


sub extract-versions() is export {
    my regex splitter { \s* ('=='|'@') \s* }
    my $lines = "script.txt".IO.lines;
    my %vers = $lines».split(&splitter).flat;
    %vers
}
