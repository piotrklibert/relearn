use v6.d;

use ShowTable;
use Reading;
use Utils;


sub show-section-sep () {
    print "\n" ~ "=" x 10 ~ "\n" x 2;
}
my ($sections, $versions) = True, False;


if $versions {
    my %vers = extract-versions();
    my $keys = %vers.keys.sort.map:{
        %vers{$_}.starts-with("file") ?? "[C] " ~ $_ !! $_
    };
    show-list-in-table $keys, :15chars
}

if $sections {
    my ($deps, $dev-deps) = extract-sections();
    show-section-sep;

    Utils::bench 5, {
        show-list-in-table($dev-deps.sort, :5cols, :15chars);
    };
    # show-list-in-table($deps.sort, :4cols);
    # show-section-sep;
}
