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
## Helper Functions : Manipulating Process Tree
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


InstallGlobalFunction("PB_First", function(process, func)
	local child, res;
	if func(process) then
		return process;
	fi;
	for child in process.children do
		res := PB_First(child, func);
		if res <> fail then
			return res;
		fi;
	od;
	return fail;
end);

InstallGlobalFunction("PB_Reduce", function(process, func, init)
	local value, child;
	value := func(init, process);
	for child in process.children do
		value := PB_Reduce(child, func, value);
	od;
	return value;
end);

InstallGlobalFunction("PB_Perform", function(process, func)
	local child;
	func(process);
	for child in process.children do
		PB_Perform(child, func);
	od;
end);

BindGlobal("PB_AllProcesses", function()
	local L;
	L := [];
	PB_Perform(PB_Global.Process, function(proc) Add(L, proc); end);
	return L;
end);

# args: process[, mode]
# mode in ["all", "upper", "lower"]
BindGlobal("PB_Siblings", function(args...)
	local process, mode, parent, pos, n, L;
	process := args[1];
	mode := "all";
	if Length(args) > 1 then
		mode := args[2];
	fi;
	parent := process.parent;
	if parent = fail then
		return [];
	else
		pos := PositionProperty(parent.children, child -> child.id = process.id);
		n := Length(parent.children);
		if mode = "all" then
			L := [1 .. n];
			Remove(L, pos);
		elif mode = "upper" then
			L := [1 .. pos - 1];
		elif mode = "lower" then
			L := [pos + 1 .. n];
		else
			Error("unknown mode");
		fi;
		return parent.children{L};
	fi;
end);

InstallGlobalFunction("PB_ChildrenAndSelf", function(process)
	local L, child;
	L := [process];
	for child in process.children do
		Append(L, PB_ChildrenAndSelf(child));
	od;
	return L;
end);

BindGlobal("PB_Lower", function(process)
	local L, child, sibling;
	L := [];
	for child in process.children do
		Append(L, PB_ChildrenAndSelf(child));
	od;
	for sibling in PB_Siblings(process, "lower") do
		Append(L, PB_ChildrenAndSelf(sibling));
	od;
	return L;
end);

InstallGlobalFunction("PB_UpperUntilCaller", function(process, caller, L)
	local child;
	if process.id = caller.id then
		return true;
	fi;
	Add(L, process);
	for child in process.children do
		if PB_UpperUntilCaller(child, caller, L) then
			return true;
		fi;
	od;
	return false;
end);

BindGlobal("PB_Upper", function(process)
	local L;
	L := [];
	PB_UpperUntilCaller(PB_Global.Process, process, L);
	return L;
end);


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  Iterator
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


InstallGlobalFunction("ProcessIterator", function(args...)
	local iter, nrSteps, processArgs, process, processIter;
	if IsListOrCollection(args[1]) then
		iter := Iterator(args[1]);
		nrSteps := Size(args[1]);
	elif IsIterator(args[1]) then
		iter := args[1];
		nrSteps := infinity;
	elif IsRecord(args[1]) then
		if not (IsBound(args[1].iter) and IsBound(args[1].nrSteps)) then
			Error("iterator-like object is given as record and therefore must contain the entries iter and nrSteps");
		fi;
		iter := args[1].iter;
		nrSteps := args[1].nrSteps;
		if not IsIterator(iter) then
			Error("iter entry is not an iterator");
		fi;
	else
		Error("Unknown type of iterator-like object");
	fi;
	processArgs := [nrSteps];
	Append(processArgs, args{[2 .. Length(args)]});
	process := CallFuncList(SetProcess, processArgs);
	processIter := rec(process := process, iter := iter);
	processIter.NextIterator := function(procIter)
		UpdateProcess(procIter!.process);
		return NextIterator(procIter!.iter);
	end;
	processIter.IsDoneIterator := function(procIter)
		local isDone;
		isDone := IsDoneIterator(procIter!.iter);
		if isDone then
			UpdateProcess(procIter!.process);
		fi;
		return isDone;
	end;
	processIter.ShallowCopy := function(procIter)
		return ProcessIterator(
			rec(
				iter := ShallowCopy(procIter!.iter),
				nrSteps := procIter!.process.nrSteps
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
		process := PB_First(PB_Global.Process, proc -> proc.id = procObj);
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

InstallGlobalFunction("SetProcess", function(args...)
	local nrSteps, id, parent, content, process, child, pos;

	# process arguments
	nrSteps := args[1];
	if not (IsPosInt(nrSteps) or IsInfinity(nrSteps)) then
		Error("nrSteps is not a positive integer or infinity");
	fi;
	if Length(args) >= 2 then
		id := args[2];
		if not IsString(id) then
			Error("id must be a string");
		fi;
	else
		id := List([1 .. 100], i -> PseudoRandom(PB_Global.Alphabet));
	fi;
	if Length(args) >= 3 then
		parent := PB_GetProcess(args[3]);
	else
		parent := fail;
	fi;
	if Length(args) >= 4 then
		content := args[4];
	else
		content := rec();
	fi;

	# create process
	process := rec(
		id := id,
		parent := parent,
		children := [],
		depth := 0,
		totalTime := 0,
		timeStamp := fail,
		curStep := -1,
		nrSteps := nrSteps,
		content := content,
		blocks := rec(),
	);

	# add process to tree
	if parent = fail then
		PB_Global.Process := process;
	else
		pos := PositionProperty(parent.children, proc -> proc.id = id);
		if pos = fail then
			process.depth := parent.depth + 1;
			Add(parent.children, process);
		else
			process := parent.children[pos];
			ResetProcess(process);
			process.nrSteps := nrSteps;
			process.content := content;
		fi;
	fi;

	return process;
end);

InstallGlobalFunction("ResetProcess", function(procObj)
	local process;
	process := PB_GetProcess(procObj);
	PB_Perform(process, function(proc)
		process.totalTime := 0;
		process.timeStamp := fail;
		process.curStep := -1;
	end);
end);


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  Progression
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


InstallGlobalFunction("UpdateProcess", function(args...)
	local process, content, r, child;

	# arguments
	process := PB_GetProcess(args[1]);
	if Length(args) >= 2 then
		content := args[2];
	else
		content := rec();
	fi;

	# update content
	for r in RecNames(content) do
		process.content.(r) := content.(r);
	od;

	# increment step
	process.curStep := process.curStep + 1;
	# TODO: deal with this case in a nicer way
	if process.curStep > process.nrSteps then
		process.nrSteps := infinity;
	fi;

	# reset children if necessary
	if process.curStep < process.nrSteps then
		for child in process.children do
			ResetProcess(child);
		od;
	fi;

	RefreshProcess(process);
end);

InstallGlobalFunction("RefreshProcess", function(procObj)
	local process, t, dt, child;

	# arguments
	process := PB_GetProcess(procObj);

	# set timers
	t := PB_TimeStamp();
	if process.timeStamp <> fail then
		dt := t - process.timeStamp;
		process.totalTime := process.totalTime + dt;
	fi;
	process.timeStamp := t;

	# print
	PB_PrintProgress(process);
end);
