use v6.d;

use Terminal::ANSIColor;

my constant Change = IO::Notification::Change;


sub re-run(Change $ch, Str $cmd) {
    say "{$ch.path} changed, running command:";
    say colored("\n$cmd".indent(4), "bold"), "\n";
    my $res = shell($cmd);
    say colored("=" x 10, $res.exitcode == 0 ?? "green" !! "red") ~ "\n";
    say now - ENTER now;
}

sub MAIN($run, *@args where {.elems > 0}) {
    say "Watching: "; @args.map({"- $_".indent(4)})».say;
    my @files = @args».IO;
    loop {
        my $supply = @files».watch.reduce({ $^a.merge($^b) });
        react {
            whenever $supply { re-run($_, $run); done }
            whenever signal(SIGINT) | $?FILE.IO.watch { exit } # ie. got Ctrl+C or source changed
        }
    }
}
