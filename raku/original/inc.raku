use v6.d;

my regex cookie-re { <?after 'cache_busting_cookie='>( \d+ ) }
.say for $*IN.lines».subst(&cookie-re, { $0 + (1..9).pick });
