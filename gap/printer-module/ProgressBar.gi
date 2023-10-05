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
    if process.terminated then
        PB_Print(options.bar_prefix);
        PB_Print(Concatenation(ListWithIdenticalEntries(block.bar_length, options.bar_symbol_full)));
        PB_Print(options.bar_suffix);
    else
        if not IsBound(block.timeStamp) then
            block.toggle := 0;
            block.timeStamp := process.timeStamp;
        fi;
        if process.timeStamp - block.timeStamp > options.dt then
            block.toggle := (block.toggle + 1) mod 2;
            block.timeStamp := process.timeStamp;
        fi;
        i := block.toggle;
        l := 1;
        PB_Print(options.bar_prefix);
        while l <= block.bar_length do
            if i = 0 then
                PB_Print(options.bar_symbol_full);
            else
                PB_Print(options.bar_symbol_empty);
            fi;
            i := (i + 1) mod 2;
            l := l + 1;
        od;
        PB_Print(options.bar_suffix);
    fi;
end;

PB_ProgressBarPrinter.generate := function(process, id, options)
    local block, curStep, r, bar_length, bar_length_full, bar_length_empty;
    block := process.blocks.(id);
    # save data
    bar_length := block.w - Length(options.bar_prefix) - Length(options.bar_suffix);
    block.bar_length := bar_length;
    if IsInfinity(process.nrSteps) then
        # print progress bar
        PB_ProgressBarPrinter.printIndefinite(process, id, options);
    else
        # progress bar length
        curStep := Maximum(0, process.curStep);
        r := curStep / process.nrSteps;
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

PB_ProgressBarPrinter.refresh := function(process, id, options)
    local block, curStep, r, bar_length_full, l;
    block := process.blocks.(id);
    curStep := Maximum(0, process.curStep);
    if IsInfinity(process.nrSteps) then
        # print progress bar
        PB_ProgressBarPrinter.printIndefinite(process, id, options);
    else
        # progress bar length
        r := curStep / process.nrSteps;
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
    return PB_State.Success;
end;
