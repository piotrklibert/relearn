use v6.d;

use Terminal::ANSIColor;

use Dirs;
use ShowTable;

my constant Change = IO::Notification::Change;
# apparently, selective import is something that needs to be delegated to the
# ecosystem. There are some modules available, but for the simple case of
# shortening package-qualified names this construct suffices. BTW, the defaults
# for the module system are really bad in Raku. Well, better than Ruby, but
# still.

sub re-run(Change $ch, Str $cmd) {
    say "{$ch.path} changed, running command:";
    say colored("\n$cmd\n".indent(4), "bold");
    my $status = shell($cmd).exitcode;
    my $color = $status ?? "red" !! "green";
    say colored("==========\n", $color);
    my $elapsed = now - ENTER now;
    say "   Elapsed: ", $elapsed;
    if $status == 0 {  qqx[ noti -m "$elapsed" -t "OK" ];    }
    else            {  qqx[ noti -m "$elapsed" -t "ERROR" ]; }
}


sub get-files-to-watch(@paths where {.all ~~ IO::Path}) {
    gather for @paths -> $path {
        unless $path.d { take $path; next; }
        for Dirs::list-dir($path) -> ($dir, $subdirs, $files) {
            $files.map({"$dir/$_"}).map(*.take)
        }
    }
}

my constant $base-re := /'/home/cji/projects/trusted-checkin/backend/checkin/'/;

sub MAIN($run, *@args where {.elems > 0}) {
    say "Base paths:"; @args.map({"- $_".indent(4)})».say;
    my @files = get-files-to-watch @args».IO;
    @files = @files.grep(none /migrations/|/pycache/).grep(/'.py'$/|/'.raku'.*$/).map(*.IO);
    # say "Watching: "; show-list-in-table :3cols, :45chars, @files.map(*.Str.subst($base-re, './'));
    say +@files;
    loop {
        my $supply = @files».watch.reduce({ $^a.merge($^b) });
        react {
            whenever $supply { re-run($_, $run); done }
            whenever signal(SIGINT) | $?FILE.IO.watch { exit } # ie. got Ctrl+C or source changed
        }
        $supply = Nil;
    }
}
