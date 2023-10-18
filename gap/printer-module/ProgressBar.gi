#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  ProgressBar.gi
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


BindGlobal("PB_ProgressBarPrinter", rec());

PB_ProgressBarPrinter.dimensions := function(process, options)
    return rec(
        w := fail,
        h := 1
    );
end;

PB_ProgressBarPrinter.printIndefinite := function(process, id, options)
    local block, i, l;
    block := process.blocks.(id);
    PB_MoveCursorToCoordinate(block.x, block.y);
    if process.status = "complete" then
        PB_Print(options.bar_prefix);
        PB_Print(Concatenation(ListWithIdenticalEntries(block.bar_length, options.bar_symbol_full)));
        PB_Print(options.bar_suffix);
    else
        if not IsBound(block.totalTime) then
            block.toggle := 0;
            block.totalTime := 0;
        fi;
        if process.totalTime - block.totalTime > options.dt then
            block.toggle := (block.toggle - 1) mod options.period;
            block.totalTime := process.totalTime;
        fi;
        i := block.toggle;
        l := 1;
        PB_Print(options.bar_prefix);
        while l <= block.bar_length do
            if i < options.full_length then
                PB_Print(options.bar_symbol_full);
            else
                PB_Print(options.bar_symbol_empty);
            fi;
            i := (i + 1) mod options.period;
            l := l + 1;
        od;
        PB_Print(options.bar_suffix);
    fi;
end;

PB_ProgressBarPrinter.generate := function(process, id, options)
    local block, completedSteps, r, bar_length, bar_length_full, bar_length_empty;
    block := process.blocks.(id);
    # save data
    bar_length := block.w - Length(options.bar_prefix) - Length(options.bar_suffix);
    block.bar_length := bar_length;
    if IsInfinity(process.totalSteps) then
        # print progress bar
        PB_ProgressBarPrinter.printIndefinite(process, id, options);
    else
        # progress bar length
        completedSteps := Maximum(0, process.completedSteps);
        r := completedSteps / process.totalSteps;
        bar_length_full := Int(bar_length * r);
        bar_length_empty := bar_length - bar_length_full;
        # print progress bar
        PB_MoveCursorToCoordinate(block.x, block.y);
        PB_Print(options.bar_prefix);
        if bar_length_full > 0 then
            PB_Print(Concatenation(ListWithIdenticalEntries(bar_length_full, options.bar_symbol_full)));
        fi;
        if bar_length_empty > 0 then
            PB_Print(Concatenation(ListWithIdenticalEntries(bar_length_empty, options.bar_symbol_empty)));
        fi;
        PB_Print(options.bar_suffix);
        # save data
        block.bar_length_full := bar_length_full;
    fi;
end;

PB_ProgressBarPrinter.update := function(process, id, options)
    local block, completedSteps, r, bar_length_full, l;
    block := process.blocks.(id);
    completedSteps := Maximum(0, process.completedSteps);
    if IsInfinity(process.totalSteps) then
        # print progress bar
        PB_ProgressBarPrinter.printIndefinite(process, id, options);
    else
        # progress bar length
        r := completedSteps / process.totalSteps;
        bar_length_full := Int(block.bar_length * r);
        # print progress bar
        l := bar_length_full - block.bar_length_full;
        if l > 0 then
            PB_MoveCursorToCoordinate(block.x + Length(options.bar_prefix) + block.bar_length_full, block.y);
            PB_Print(Concatenation(ListWithIdenticalEntries(l, options.bar_symbol_full)));
        fi;
        # save data
        block.bar_length_full := bar_length_full;
    fi;
    return true;
end;
