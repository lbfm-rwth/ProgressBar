#
# ProgressBar: The GAP package ProgressBar displays the progression of a process in the terminal.
#
# This file is a script which compiles the package manual.
#
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

AutoDoc( rec( scaffold := rec(
        includes := [
            "intro.xml",
            "functions.xml",
            "developer.xml"
            ],
        ),
        autodoc := true ) );
