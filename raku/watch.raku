use v6.d;

use Utils;
use Colors;
use ShowTable;

constant Change = IO::Notification::Change;


constant $command = "raku -Iraku raku/run.raku";


sub re-run(Change $change) {
    my $path := $change.path;
    put "$path changed, running command:\n\t$command";
    my $status = shell($command).exitcode;
    my $color = $status ?? "red" !! "green";
    put "\n==========\n".indent(4).in-color($color);
    my $elapsed = now - ENTER now;
    put "Elapsed: $elapsed".indent(4).in-color($color);
    if $status == 0 {  qqx[ noti -m "$elapsed" -t "OK" ];    }
    else            {  qqx[ noti -m "$elapsed" -t "ERROR" ]; }
}


# sub get-files-to-watch(@paths where {.all ~~ IO::Path}) {
#     gather for @paths -> $path {
#         unless $path.d { take $path; next; }
#         for list-dir($path) -> ($dir, $subdirs, $files) {
#             $files.map({"$dir/$_"}).map(*.take)
#         }
#     }
# }

sub MAIN(Str $base) {
    my @files = dir($base).grep(/ '.raku'('mod')? $/).grep(none /watch/);
    say "Watching: "; @files».absolute.map(*.indent(4).say); say "";
    loop {
        my $supply = @files».watch.reduce({ $^a.merge($^b) });
        react {
            whenever $supply { re-run($_); done }
            # ie. either got Ctrl+C or this file changed
            whenever signal(SIGINT) | $?FILE.IO.watch { exit }
        }
        $supply = Nil;
    }
}
