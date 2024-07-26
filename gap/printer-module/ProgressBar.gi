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
        PB_Print(options.prefix);
        PB_Print(Concatenation(ListWithIdenticalEntries(block.length_total, options.symbol_full)));
        PB_Print(options.suffix);
    else
        if not IsBound(block.totalTime) then
            block.toggle := 0;
            block.totalTime := 0;
        fi;
        if process.totalTime - block.totalTime > options.dt then
            block.toggle := (block.toggle - 1) mod (options.period_full + options.period_empty);
            block.totalTime := process.totalTime;
        fi;
        i := block.toggle;
        l := 1;
        PB_Print(options.prefix);
        while l <= block.length_total do
            if i < options.period_full then
                PB_Print(options.symbol_full);
            else
                PB_Print(options.symbol_empty);
            fi;
            i := (i + 1) mod (options.period_full + options.period_empty);
            l := l + 1;
        od;
        PB_Print(options.suffix);
    fi;
end;

PB_ProgressBarPrinter.generate := function(process, id, options)
    local block, completedSteps, r, length_total, length_full, length_empty;
    block := process.blocks.(id);
    # save data
    length_total := block.w - Length(options.prefix) - Length(options.suffix);
    block.length_total := length_total;
    if IsInfinity(process.totalSteps) then
        # print progress bar
        PB_ProgressBarPrinter.printIndefinite(process, id, options);
    else
        # progress bar length_total
        completedSteps := Maximum(0, process.completedSteps);
        if process.totalSteps = 0 then
            r := 1;
        else
            r := completedSteps / process.totalSteps;
        fi;
        length_full := Int(length_total * r);
        length_empty := length_total - length_full;
        # print progress bar
        PB_MoveCursorToCoordinate(block.x, block.y);
        PB_Print(options.prefix);
        if length_full > 0 then
            PB_Print(Concatenation(ListWithIdenticalEntries(length_full, options.symbol_full)));
        fi;
        if length_empty > 0 then
            PB_Print(Concatenation(ListWithIdenticalEntries(length_empty, options.symbol_empty)));
        fi;
        PB_Print(options.suffix);
        # save data
        block.length_full := length_full;
    fi;
end;

PB_ProgressBarPrinter.update := function(process, id, options)
    local block, completedSteps, r, length_full, l;
    block := process.blocks.(id);
    completedSteps := Maximum(0, process.completedSteps);
    if IsInfinity(process.totalSteps) then
        # print progress bar
        PB_ProgressBarPrinter.printIndefinite(process, id, options);
    else
        # progress bar length_total
        if process.totalSteps = 0 then
            r := 1;
        else
            r := completedSteps / process.totalSteps;
        fi;
        length_full := Int(block.length_total * r);
        # print progress bar
        l := length_full - block.length_full;
        if l > 0 then
            PB_MoveCursorToCoordinate(block.x + Length(options.prefix) + block.length_full, block.y);
            PB_Print(Concatenation(ListWithIdenticalEntries(l, options.symbol_full)));
        fi;
        # save data
        block.length_full := length_full;
    fi;
    return true;
end;
