#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  Standard.gi
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


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Default Options
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##

# Default options, immutable entries
BindGlobal("StandardLayout", rec());

StandardLayout.DefaultOptions := Immutable(rec(
	# print bool options
	printID := false,
    printTotalTime := false,
	printTotalTimeOnlyForRoot := true,
	printETA := false,
	printETAOnlyForRoot := true,
	highlightCurStep := false,
	highlightColor := "red",
	highlightStyle := "default",
	# print symbols
	separator := " | ",
	branch := "|  ",
	bar_prefix := "[",
	bar_symbol_full := "=",
	bar_symbol_empty := "-",
	bar_suffix := "]",
	inf := "oo",
	bar_indefinite_update_rate := 500,
));

StandardLayout.Setup := function()
    local options;

    options := ProgressPrinter.Options;

    ProgressPrinter.Pattern := rec(
        id := "process",
        alignment := "horizontal",
        sync := [],
        isActive := ReturnTrue,
        children := [
        rec(
            id := "left",
            alignment := "horizontal",
            sync := [],
            isActive := ReturnTrue,
            children := [],
            printer := PB_IndentPrinter,
            printer_options := rec(
                branch := options.branch
            ),
        ),
        rec(
            id := "right",
            alignment := "vertical",
            sync := [],
            isActive := ReturnTrue,
            children := [
            rec(
                id := "total time header",
                alignment := "vertical",
                sync := [],
                isActive := function(proc)
                    if options.printTotalTime then
                        if options.printTotalTimeOnlyForRoot then
                            if proc = ProgressPrinter.RootProcess then
                                return true;
                            else
                                return false;
                            fi;
                        else
                            return true;
                        fi;
                    else
                        return false;
                    fi;
                end,
                children := [],
                printer := PB_TotalTimeHeaderPrinter,
                printer_options := rec(
                    prefix := "| ",
                ),
            ),
            rec(
                id := "bottom line",
                alignment := "horizontal",
                sync := [],
                isActive := ReturnTrue,
                children := [
                rec(
                    id := "progress bar",
                    alignment := "horizontal",
                    sync := [],
                    isActive := ReturnTrue,
                    children := [],
                    printer := PB_ProgressBarPrinter,
                    printer_options := rec(
                        bar_prefix := options.bar_prefix,
                        bar_suffix := options.bar_suffix,
                        bar_symbol_empty := options.bar_symbol_empty,
                        bar_symbol_full := options.bar_symbol_full,
                        dt := options.bar_indefinite_update_rate,
                        period := 4,
                        full_length := 2,
                    ),
                ),
                rec(
                    id := "separator 1",
                    alignment := "horizontal",
                    sync := [],
                    isActive := ReturnTrue,
                    children := [],
                    printer := PB_TextPrinter,
                    printer_options := rec(
                        text := options.separator
                    ),
                ),
                rec(
                    id := "progress ratio",
                    alignment := "horizontal",
                    sync := ["w"],
                    isActive := ReturnTrue,
                    children := [],
                    printer := PB_ProgressRatioPrinter,
                    printer_options := rec(
                        inf := options.inf,
                    ),
                )
                ]
            )
            ]
        )
        ]
    );

    PB_InitializeParent(ProgressPrinter.Pattern, fail);

    ProgressPrinter.InitialConfiguration := [];
end;