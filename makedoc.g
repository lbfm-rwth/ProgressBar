#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  makedoc.g
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##
##  This file is part of the ProgressBar package.
##
##  This file's authors include Friedrich Rober.
##
##  Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


if fail = LoadPackage("AutoDoc", "2018.02.14") then
    Error("AutoDoc version 2018.02.14 or newer is required.");
fi;

# https://github.com/mbadolato/iTerm2-Color-Schemes/blob/master/windowsterminal/Ubuntu.json
Append(GAPDoc2LaTeXProcs.DefaultOptions.LateExtraPreamble, Concatenation([
    "\\usepackage{xcolor}\n",
    "\\definecolor{myblack}{HTML}{2e3436}\n",
    "\\definecolor{myred}{HTML}{cc0000}\n",
    "\\definecolor{mygreen}{HTML}{4e9a06}\n",
    "\\definecolor{myyellow}{HTML}{c4a000}\n",
    "\\definecolor{myblue}{HTML}{3465a4}\n",
    "\\definecolor{mymagenta}{HTML}{75507b}\n",
    "\\definecolor{mycyan}{HTML}{06989a}\n",
    "\\definecolor{mywhite}{HTML}{d3d7cf}\n",
]));

Append(GAPDoc2HTMLProcs.Head2, Concatenation([
    "<link rel=\"stylesheet\" type=\"text/css\" href=\"style/style.css\" />\n"
]));

AutoDoc(rec(
    scaffold := rec(
        includes := [
            "intro.xml",
            "functions.xml",
            "layouts.xml",
            "developer.xml",
            "modules.xml",
            ],
        ),
    autodoc := true )
);
