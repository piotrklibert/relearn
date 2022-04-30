use v6.d;


# sub MAIN(
#   Str $arg? where { (.defined && .chars > 10) || True }, #= a path string longer than 10 chars
# ) {
#     !!!
# }


# #| Just a random desc of nvm
# sub MAIN(
#     *@files,    #= list of existing paths
# ) {
#     for @files.grep({ .IO.absolute.IO.e.not }) {
#         FIRST say "\nWarning - non-existent files:\n";
#         ('- ' ~ $_).indent(4).say;
#         LAST show-section-sep;
#     }
# }
