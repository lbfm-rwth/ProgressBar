#
# ProgressBar: The GAP package ProgressBar displays the progression of an iteration in the terminal.
#
# This file is a script which compiles the package manual.
#
if fail = LoadPackage("AutoDoc", "2018.02.14") then
    Error("AutoDoc version 2018.02.14 or newer is required.");
fi;


AutoDoc( rec( scaffold := rec(
        includes := [
            "intro.xml",
            ],
        ),
        autodoc := true ) );
