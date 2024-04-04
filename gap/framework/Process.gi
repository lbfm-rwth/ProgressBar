#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  Process.gi
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
##  Iterator
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


InstallGlobalFunction("ProcessIterator", function(args...)
	local iter, totalSteps, processArgs, process, processIter;
	if IsListOrCollection(args[1]) then
		iter := Iterator(args[1]);
		totalSteps := Size(args[1]);
	elif IsIterator(args[1]) then
		iter := args[1];
		totalSteps := infinity;
	elif IsRecord(args[1]) then
		if not (IsBound(args[1].iter) and IsBound(args[1].totalSteps)) then
			Error("iterator-like object is given as record and therefore must contain the entries iter and totalSteps");
		fi;
		iter := args[1].iter;
		totalSteps := args[1].totalSteps;
		if not IsIterator(iter) then
			Error("iter entry is not an iterator");
		fi;
	else
		Error("Unknown type of iterator-like object");
	fi;
	processArgs := [totalSteps];
	Append(processArgs, args{[2 .. Length(args)]});
	process := CallFuncList(SetProcess, processArgs);
	processIter := rec(process := process, iter := iter);
	processIter.NextIterator := function(procIter)
		process.value := NextIterator(procIter!.iter);
		UpdateProcess(procIter!.process);
		return process.value;
	end;
	processIter.IsDoneIterator := function(procIter)
		local isDone;
		isDone := IsDoneIterator(procIter!.iter);
		if isDone then
			TerminateProcess(procIter!.process, false);
			UpdateProcess(procIter!.process);
		fi;
		return isDone;
	end;
	processIter.ShallowCopy := function(procIter)
		return ProcessIterator(
			rec(
				iter := ShallowCopy(procIter!.iter),
				totalSteps := procIter!.process.totalSteps
			),
			procIter!.process.id,
			procIter!.process.parent,
			procIter!.process.content
		);
	end;
	processIter.PrintObj := function(procIter)
		PrintObj(procIter!.iter);
	end;
	processIter.ViewObj := function(procIter)
		ViewObj(procIter!.iter);
	end;
	return IteratorByFunctions(processIter);
end);


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  Set & Reset
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


BindGlobal("PB_GetProcess", function(procObj)
	local process;
	if IsString(procObj) then
		process := PB_First(ProgressPrinter.RootProcess, proc -> proc.id = procObj);
		if process = fail then
			Error("Cannot find process");
		fi;
	elif IsIterator(procObj) then
		process := procObj!.process;
	else
		process := procObj;
	fi;
	return process;
end);

# args can be one of the following:
# totalSteps
# totalSteps, content
# totalSteps, id
# totalSteps, id, content
# totalSteps, id, parent
# totalSteps, id, parent, content
InstallGlobalFunction("SetProcess", function(args...)
	local totalSteps, n, r, id, parent, autoParent, content, process, child, pos;

	# process arguments
	totalSteps := args[1];
	if not (IsPosInt(totalSteps) or IsInfinity(totalSteps)) then
		Error("totalSteps is not a positive integer or infinity");
	fi;

	# check if last argument is content
	n := Length(args);
	r := args[n];
	# we need to check that is not a process record
	if IsRecord(r) and not IsBound(r.totalTime) then
		content := r;
		n := n - 1;
	else
		content := rec();
	fi;

	# now before content, there might be an id, or an id and a parent
	if n >= 2 then
		id := args[2];
		if not IsString(id) then
			Error("id must be a string");
		fi;
	else
		id := List([1 .. 16], i -> PseudoRandom("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"));
	fi;
	if n >= 3 then
		parent := PB_GetProcess(args[3]);
		autoParent := false;
	else
		parent := ProgressPrinter.CurProcess;
		while parent <> fail and parent.status = "complete" do
			parent := parent.parent;
		od;
		autoParent := true;
	fi;

	# create process
	process := rec(
		id := id,
		parent := parent,
		children := [],
		depth := 0,
		totalTime := 0,
		status := "inactive",
		completedSteps := -1,
		totalSteps := totalSteps,
		content := content,
		blocks := rec(),
	);

	# add process to tree
	if parent = fail then
		PB_StartProgressPrinter(process);
	else
		pos := PositionProperty(parent.children, proc -> proc.id = id);
		if autoParent and pos = fail then
			pos := PositionProperty(parent.children, proc -> proc.completedSteps = -1);
		fi;
		if pos = fail then
			process.depth := parent.depth + 1;
			Add(parent.children, process);
		else
			process := parent.children[pos];
			ResetProcess(process, false);
			process.totalSteps := totalSteps;
			process.content := content;
		fi;
	fi;

	return process;
end);

InstallGlobalFunction("ResetProcess", function(args...)
	local process, doRefresh;

	# arguments
	process := PB_GetProcess(args[1]);
	if Length(args) >= 2 then
		doRefresh := args[2];
	else
		doRefresh := true;
	fi;

	PB_Perform(process, function(proc)
		proc.totalTime := 0;
		proc.completedSteps := -1;
		proc.status := "inactive";
		if IsBound(proc.value) then
			Unbind(proc.value);
		fi;
	end);

	if doRefresh then
		RefreshProcess(process);
	fi;
end);


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  Progression
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


# returns time in milliseconds after 1.1.1970, 0:00 GMT
BindGlobal("PB_TimeStamp", function()
	local r;
	r := IO_gettimeofday(); # time in microseconds
	return r.tv_sec * 1000 + Int(r.tv_usec * 0.001);
end);

InstallGlobalFunction("RefreshProcess", function(procObj)
	local process, t, dt;

	# arguments
	process := PB_GetProcess(procObj);

	# update timers
	t := PB_TimeStamp();
	if ProgressPrinter.TimeStamp <> fail then
		dt := t - ProgressPrinter.TimeStamp;
		PB_Perform(ProgressPrinter.RootProcess, function(proc)
			if proc.status = "active" then
				proc.totalTime := proc.totalTime + dt;
			elif proc.status = "stopped" then
				proc.totalTime := proc.totalTime + dt;
				proc.status := "inactive";
			elif proc.status = "started" then
				proc.status := "active";
			elif proc.status = "terminated" then
				proc.totalTime := proc.totalTime + dt;
				proc.status := "complete";
			fi;
		end);
	fi;
	ProgressPrinter.TimeStamp := t;

	# print
	PB_PrintProgress(process);
end);

InstallGlobalFunction("UpdateProcess", function(args...)
	local process, content, doRefresh, r, child;

	# arguments
	process := PB_GetProcess(args[1]);
	if Length(args) >= 2 then
		content := args[2];
	else
		content := rec();
	fi;
	if Length(args) >= 3 then
		doRefresh := args[3];
	else
		doRefresh := true;
	fi;

	# update content
	for r in RecNames(content) do
		process.content.(r) := content.(r);
	od;

	# increment step
	process.completedSteps := process.completedSteps + 1;
	if process.completedSteps = 0 then
		StartProcess(process, false);
	elif process.completedSteps = process.totalSteps then
		TerminateProcess(process, false);
	elif process.completedSteps > process.totalSteps then
		process.totalSteps := infinity;
		process.blocks := rec();
		PB_HideCursor();
		StartProcess(process, false);
	fi;

	# reset children if necessary
	if not process.status in ["terminated", "complete"] then
		for child in process.children do
			ResetProcess(child, false);
		od;
	fi;

	if doRefresh then
		RefreshProcess(process);
	fi;
end);

BindGlobal("PB_SetStatus", function(fromStatus, toStatus, args)
	local process, doRefresh;

	# arguments
	process := PB_GetProcess(args[1]);
	if Length(args) >= 2 then
		doRefresh := args[2];
	else
		doRefresh := true;
	fi;

	PB_Perform(process, function(proc)
		if proc.status = fromStatus then
			proc.status := toStatus;
		fi;
	end);

	if doRefresh then
		RefreshProcess(process);
	fi;
end);

InstallGlobalFunction("StopProcess", function(args...)
	PB_SetStatus("active", "stopped", args);
end);

InstallGlobalFunction("StartProcess", function(args...)
	PB_SetStatus("complete", "started", [args[1], false]);
	PB_SetStatus("inactive", "started", args);
end);

InstallGlobalFunction("TerminateProcess", function(args...)
	if Length(args) = 0 then
		args := [ProgressPrinter.RootProcess];
	fi;
	PB_SetStatus("inactive", "complete", [args[1], false]);
	PB_SetStatus("active", "terminated", args);
end);
