#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  Tree.gi
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


BindGlobal("TreeLayout", rec());


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Default Options
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


TreeLayout.DefaultOptions := Immutable(rec(
	# pattern encoding
	pattern_encoding := [
        ["Root", "time"],
        ["All", "bar", "ratio"],
    ],
    # print bool options
    highlightCurStep := false,
	highlightColor := "red",
	highlightStyle := "default",
    # print symbols
    inf := "oo",
	separator := " | ",
	branch := "|  ",
    header_prefix := "| ",
	bar_prefix := "[",
	bar_symbol_full := "=",
	bar_symbol_empty := "-",
	bar_suffix := "]",
	bar_indefinite_update_rate := 500,
    bar_period_empty := 2,
    bar_period_full := 2,
));


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Setup
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


TreeLayout.Setup := function(options)
    local main, i, j, line, code, name, pattern, sep;

    main := rec(
        id := "main",
        alignment := "vertical",
        sync := [],
        isActive := ReturnTrue,
        children := []
    );

    for i in [1 .. Length(options.pattern_encoding)] do
        line := rec(
            id := Concatenation("line ", String(i)),
            alignment := "horizontal",
            sync := [],
            children := []
        );
        if options.pattern_encoding[i][1] = "Root" then
            line.isActive := PB_IsRootProcess;
        else
            line.isActive := ReturnTrue;
        fi;
        for j in [2 .. Length(options.pattern_encoding[i])] do
            name := options.pattern_encoding[i][j];
            pattern := rec(
                alignment := "horizontal",
                sync := [],
                isActive := ReturnTrue,
                children := [],
            );
            pattern.id := Concatenation(name, " at (", String(i), ", ", String(j), ")");
            PB_PrinterPattern(pattern, options, name);
            Add(line.children, pattern);
            if j < Length(options.pattern_encoding[i]) then
                sep := rec(
                    alignment := "horizontal",
                    sync := [],
                    isActive := ReturnTrue,
                    children := [],
                );
                sep.id := Concatenation("sep at (", String(i), ", ", String(j), ")");
                PB_PrinterPattern(sep, options, "sep");
                Add(line.children, sep);
            fi;
        od;
        Add(main.children, line);
    od;

    ProgressPrinter.Pattern := rec(
        id := "process",
        alignment := "horizontal",
        sync := [],
        isActive := ReturnTrue,
        children := [
        rec(
            id := "branches",
            alignment := "horizontal",
            sync := [],
            isActive := ReturnTrue,
            children := [],
            printer := PB_TreeBranchesPrinter,
            printer_options := rec(
                branch := options.branch
            ),
        ),
        main
        ]
    );

    PB_InitializeParent(ProgressPrinter.Pattern, fail);

    ProgressPrinter.InitialConfiguration := [];
end;
