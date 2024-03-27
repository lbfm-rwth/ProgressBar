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
        ["HasTitle", "value"],
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
## Printer Pattern
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


TreeLayout.Pattern := function(pattern, options, name)
	local printer, printer_options;
	if name = "bar" then
		printer := PB_ProgressBarPrinter;
		printer_options := rec(
			prefix := options.bar_prefix,
			symbol_full := options.bar_symbol_full,
			symbol_empty := options.bar_symbol_empty,
			suffix := options.bar_suffix,
			dt := options.bar_indefinite_update_rate,
			period_empty := options.bar_period_empty,
			period_full := options.bar_period_full,
		);
	elif name = "time" then
		printer := PB_TotalTimeHeaderPrinter;
		printer_options := rec(
			prefix := options.header_prefix,
		);
    elif name = "value" then
        printer := PB_ValuePrinter;
        printer_options := rec(
            id := "title",
            prefix := options.header_prefix,
        );
	elif name = "ratio" then
		pattern.sync := ["w"];
		printer := PB_ProgressRatioPrinter;
		printer_options := rec(
			inf := options.inf,
		);
	elif name = "sep" then
		printer := PB_StaticInlinePrinter;
		printer_options := rec(
			text := options.separator,
		);
	fi;
	if options.highlightCurStep and name in ["bar", "ratio", "sep"] then
		pattern.printer := PB_HighlightPrinter;
		pattern.printer_options := rec(
			highlightColor := options.highlightColor,
			highlightStyle := options.highlightStyle,
			printer := printer,
			printer_options := printer_options,
		);
	else
		pattern.printer := printer;
		pattern.printer_options := printer_options;
	fi;
end;


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Setup
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


TreeLayout.Setup := function(options)
    local isRoot, hasTitle, main, i, j, line, code, name, pattern, sep;

    isRoot := {process} -> process = ProgressPrinter.RootProcess;
    hasTitle := {process} -> IsBound(process.content.title);

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
            line.isActive := isRoot;
        elif options.pattern_encoding[i][1] = "HasTitle" then
            line.isActive := hasTitle;
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
            TreeLayout.Pattern(pattern, options, name);
            Add(line.children, pattern);
            if j < Length(options.pattern_encoding[i]) then
                sep := rec(
                    alignment := "horizontal",
                    sync := [],
                    isActive := ReturnTrue,
                    children := [],
                );
                sep.id := Concatenation("sep at (", String(i), ", ", String(j), ")");
                TreeLayout.Pattern(sep, options, "sep");
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
