#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  Highlight.gi
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


BindGlobal("PB_HighlightPrinter", rec());

PB_HighlightPrinter.dimensions := function(process, options)
	return options.printer.dimensions(process, options.printer_options);
end;

PB_HighlightPrinter.LastProcess := fail;
PB_HighlightPrinter.Complete := false;

PB_HighlightPrinter.print := function(process, id, options, doGenerate)
    local value;
    # reset globals after completetion of root process
    if PB_HighlightPrinter.Complete = true and ProgressPrinter.RootProcess.status <> "complete" then
        PB_HighlightPrinter.LastProcess := fail;
        PB_HighlightPrinter.Complete := false;
    fi;
    if ProgressPrinter.CurProcess = process then
        if PB_HighlightPrinter.LastProcess <> fail and PB_HighlightPrinter.LastProcess <> process then
            PB_PrintProcess(PB_HighlightPrinter.LastProcess, true);
            PB_HighlightPrinter.LastProcess := process;
            if not doGenerate then
                return false;
            fi;
        fi;
        PB_HighlightPrinter.LastProcess := process;
        PB_SetStyle(options.highlightStyle);
        PB_SetForegroundColor(options.highlightColor);
        # print last step in default again
        if ProgressPrinter.RootProcess = process and process.status = "complete" then
            PB_ResetStyleAndColor();
            if PB_HighlightPrinter.Complete = false then
                PB_HighlightPrinter.Complete := true;
                if not doGenerate then
                    return false;
                fi;
            fi;
        fi;
    fi;
    if doGenerate then
	    options.printer.generate(process, id, options.printer_options);
    else
        value := options.printer.update(process, id, options.printer_options);
    fi;
    if ProgressPrinter.CurProcess = process then
        PB_ResetStyleAndColor();
    fi;
    if IsBound(value) then
        return value;
    fi;
end;

PB_HighlightPrinter.generate := function(process, id, options)
    PB_HighlightPrinter.print(process, id, options, true);
end;

PB_HighlightPrinter.update := function(process, id, options)
	return PB_HighlightPrinter.print(process, id, options, false);
end;
