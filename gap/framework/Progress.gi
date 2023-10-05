#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  Progress.gi
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
## Allocation of Blocks
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


BindGlobal("PB_ResetBounds", function(process)
	local id, block;
	for id in RecNames(process.blocks) do
		block := process.blocks.(id);
		block.x := fail;
		block.y := fail;
		block.w := fail;
		block.h := fail;
	od;
end);

# get bounding box of block
BindGlobal("PB_GetBounds", function(process, pattern)
	local bounds;
	if IsBound(process.blocks.(pattern.id)) then
		bounds := process.blocks.(pattern.id);
	else
		process.blocks.(pattern.id) := rec(x := fail, y := fail, w := fail, h := fail);
		bounds := process.blocks.(pattern.id);
	fi;
	return bounds;
end);

# get bounding box of block
InstallGlobalFunction("PB_SetBounds", function(process, pattern, values)
	local bounds, param, i, children, child;
	bounds := PB_GetBounds(process, pattern);
	for param in ["x", "y", "w", "h"] do
		i := Position(PB_Global.ProgressPrinter.Variables, rec(id := pattern.id, param := param));
		bounds.(param) := values[i];
	od;
	if IsBound(pattern.children) then
		children := Filtered(pattern.children, child -> child.isActive(process));
		for child in children do
			PB_SetBounds(process, child, values);
		od;
	fi;
end);

InstallGlobalFunction("PB_InitializeParent", function(pattern, parent)
	local child;
	pattern.parent := parent;
	if IsBound(pattern.children) then
		for child in pattern.children do
			PB_InitializeParent(child, pattern);
		od;
	fi;
end);

# node sets dimensions of itself
InstallGlobalFunction("PB_InitializeDimension", function(process, pattern)
	local bounds, children, child, dim, dir, value, layout_options, state;
	state := PB_State.Success;
	# inner node
	if IsBound(pattern.children) then
		children := Filtered(pattern.children, child -> child.isActive(process));
		for child in children do
			state := PB_CombineStates(state, PB_InitializeDimension(process, child));
		od;
	# leaf node
	else
		layout_options := ShallowCopy(PB_Global.ProgressPrinter.LayoutOptionsDefault);
		PB_SetOptions(layout_options, pattern.layout_options);
		dim := pattern.printer.dimensions(process, pattern.printer_options);
		bounds := PB_GetBounds(process, pattern);
		for dir in ["w", "h"] do
			if dir in layout_options.sync and process <> PB_Global.Process then
				value := PB_Global.Process.blocks.(pattern.id).(dir);
				if value < dim.(dir) then
					value := dim.(dir);
					PB_Perform(PB_Global.Process, function(proc)
						local pos;
						if proc <> process then
							pos := Position(proc.configurationRecord, [1, rec(id := pattern.id, param := dir), PB_GetBounds(proc, pattern).(dir)]);
							proc.configurationRecord[pos] := [1, rec(id := pattern.id, param := dir), value];
							proc.configurationSystem.b[pos] := value;
						fi;
					end);
					state := PB_CombineStates(state, PB_State.Desyncronized);
				fi;
			else
				value := dim.(dir);
			fi;
			bounds.(dir) := value;
			if bounds.(dir) <> fail then
				Add(process.configurationRecord, [1, rec(id := pattern.id, param := dir), bounds.(dir)]);
			fi;
		od;
	fi;
	return state;
end);

InstallGlobalFunction("PB_InitializeVariables", function(pattern)
	local param, child;
	for param in ["x", "y", "w", "h"] do
		Add(PB_Global.ProgressPrinter.Variables, rec(id := pattern.id, param := param));
	od;
	if IsBound(pattern.children) then
		for child in pattern.children do
			PB_InitializeVariables(child);
		od;
	fi;
end);

BindGlobal("PB_ConfigurationSystem", function(configuration)
	local M, b, n, c, column, m, i, j;
	M := [];
	b := [];
	n := Length(PB_Global.ProgressPrinter.Variables);
	for c in configuration do
		column := ListWithIdenticalEntries(n, 0);
		m := Length(c);
		for i in [1 .. (m - 1) / 2] do
			j := Position(PB_Global.ProgressPrinter.Variables, c[2 * i]);
			column[j] := c[2 * i - 1];
		od;
		Add(M, column);
		Add(b, c[m]);
	od;
	TransposedMatDestructive(M);
	return rec(M := M, b := b);
end);

InstallGlobalFunction("PB_AlignBlock", function(process, pattern)
	local layout_options, c, children, child, i, coord, dir;
	if not pattern.isActive(process) then
		return;
	fi;
	layout_options := ShallowCopy(PB_Global.ProgressPrinter.LayoutOptionsDefault);
	PB_SetOptions(layout_options, pattern.layout_options);
	# inner node
	if IsBound(pattern.children) then
		children := Filtered(pattern.children, child -> child.isActive(process));
		# child dimensions sum up to node dimension for dir
		if layout_options.alignment = "horizontal" then
			dir := "w";
		else # vertical
			dir := "h";
		fi;
		c := [];
		for child in children do
			Append(c, [1, rec(id := child.id, param := dir)]);
		od;
		Append(c, [-1, rec(id := pattern.id, param := dir)]);
		Add(c, 0);
		Add(process.configurationRecord, c);
		# child dimensions are equal to node dimension for dir
		if layout_options.alignment = "horizontal" then
			dir := "h";
		else # vertical
			dir := "w";
		fi;
		for child in children do
			c := [];
			Append(c, [1, rec(id := child.id, param := dir)]);
			Append(c, [-1, rec(id := pattern.id, param := dir)]);
			Add(c, 0);
			Add(process.configurationRecord, c);
		od;
		# child coordinate are shifted for coord
		if layout_options.alignment = "horizontal" then
			coord := "x";
			dir := "w";
		else # vertical
			coord := "y";
			dir := "h";
		fi;
		c := [];
		Append(c, [1, rec(id := children[1].id, param := coord)]);
		Append(c, [-1, rec(id := pattern.id, param := coord)]);
		Add(c, 0);
		Add(process.configurationRecord, c);
		for i in [1 .. Length(children) - 1] do
			c := [];
			Append(c, [1, rec(id := children[i].id, param := coord)]);
			Append(c, [1, rec(id := children[i].id, param := dir)]);
			Append(c, [-1, rec(id := children[i + 1].id, param := coord)]);
			Add(c, 0);
			Add(process.configurationRecord, c);
		od;
		# child coordinate are equal to node coordinate for coord
		if layout_options.alignment = "horizontal" then
			coord := "y";
		else # vertical
			coord := "x";
		fi;
		for child in children do
			c := [];
			Append(c, [1, rec(id := child.id, param := coord)]);
			Append(c, [-1, rec(id := pattern.id, param := coord)]);
			Add(c, 0);
			Add(process.configurationRecord, c);
		od;
		# recursion
		for child in children do
			PB_AlignBlock(process, child);
		od;
	fi;
end);

BindGlobal("PB_AllocateBlocks", function(process)
	local pattern, bounds, param, data, configuration, state, procs, proc, M, b, values;
	# initalize process pattern
	PB_ResetBounds(process);
	pattern := PB_Global.ProgressPrinter.Layout;
	bounds := PB_GetBounds(process, pattern);
	bounds.x := 1;
	bounds.y := Sum(PB_Upper(process), upper -> upper.blocks.(pattern.id).h) + 1;
	bounds.w := PB_Global.Terminal.screenWidth;
	# initialize parents
	if not IsBound(pattern.parent) then
		PB_InitializeParent(pattern, fail);
	fi;
	# initialize variables for bounds
	if not IsBound(PB_Global.ProgressPrinter.Variables) then
		PB_Global.ProgressPrinter.Variables := [];
		PB_InitializeVariables(pattern);
	fi;
	# initialize configuration record with root pattern bounds
	process.configurationRecord := [];
	for param in ["x", "y", "w"] do
		Add(process.configurationRecord, [1, rec(id := pattern.id, param := param), bounds.(param)]);
	od;
	# add configurations via alignment
	Append(process.configurationRecord, PB_Global.ProgressPrinter.InitialConfigurationRecord);
	PB_AlignBlock(process, pattern);
	# add configurations via dimensions of the printer blocks,
	# where some might still be set to fail, if they are dynamic.
	state := PB_InitializeDimension(process, pattern);
	# compute configuration system for process
	process.configurationSystem := PB_ConfigurationSystem(process.configurationRecord);
	# solve linear system and set all bounds
	if state = PB_State.Success then
		procs := [process];
	elif state = PB_State.Desyncronized then
		procs := PB_AllProcesses();
	else # TODO
		Error();
	fi;
	for proc in procs do
		M := proc.configurationSystem.M;
		b := proc.configurationSystem.b;
		values := SolutionIntMat(M, b);
		PB_SetBounds(proc, pattern, values);
	od;
	return state;
end);


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Printing
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


InstallGlobalFunction("PB_PrintBlock", function(process, pattern, doGenerate)
	local child;
	# TODO: activity has changed
	if pattern.isActive(process) then
		if not IsBound(process.blocks.(pattern.id)) then
			Error();
		fi;
	else
		if IsBound(process.blocks.(pattern.id)) then
			Error();
		fi;
	fi;

	# composition block (inner node)
	if IsBound(pattern.children) then
		for child in pattern.children do
			if PB_PrintBlock(process, child, doGenerate) = PB_State.Failure then
				return PB_State.Failure;
			fi;
		od;
		return PB_State.Success;
	fi;

	# printer block (leaf node)
	if doGenerate then
		pattern.printer.generate(process, pattern.id, pattern.printer_options);
		return PB_State.Success;
	else
		return pattern.printer.refresh(process, pattern.id, pattern.printer_options);
	fi;
end);

BindGlobal("PB_PrintProcess", function(process, doGenerate)
	local state;

	state := PB_State.Success;

	if process.blocks = rec() then
		state := PB_CombineStates(state, PB_AllocateBlocks(process));
		doGenerate := true;
	fi;

	if process.curStep < 0 then
		doGenerate := true;
	fi;

	if doGenerate then
		PB_ClearProcess(process);
	fi;

	if PB_PrintBlock(process, PB_Global.ProgressPrinter.Layout, doGenerate) = PB_State.Failure then
		# refresh had a failure, i.e. information doesn't fit the block anymore.
		state := PB_CombineStates(state, PB_AllocateBlocks(process));
		PB_ClearProcess(process);
		PB_PrintBlock(process, PB_Global.ProgressPrinter.Layout, true);
	fi;

	return state;
end);

InstallGlobalFunction("PB_PrintProgress", function(process)
	local proc, child, root, state, procs;

	state := PB_State.Success;

	# Did root process start?
	root := PB_Global.Process;
	if process = root and process.curStep = 0 then
		PB_ResetTerminal();
		PB_HideCursor();
	fi;

	# Is current process different to last time?
	if IsBound(PB_Global.ProgressPrinter.CurProcess) and PB_Global.ProgressPrinter.CurProcess.id <> process.id then
		proc := PB_Global.ProgressPrinter.CurProcess;
		PB_Global.ProgressPrinter.CurProcess := process;
		PB_PrintProcess(proc, true);
	else
		PB_Global.ProgressPrinter.CurProcess := process;
	fi;

	# Print current process
	state := PB_CombineStates(state, PB_PrintProcess(process, false));

	# Print all descendants
	for child in process.children do
		PB_Perform(child, function(proc)
			state := PB_CombineStates(state, PB_PrintProcess(proc, true));
		end);
	od;

	if state = PB_State.Desyncronized then
		PB_ClearScreen();
		PB_Perform(root, function(proc)
			PB_PrintProcess(proc, true);
		end);
	fi;

	# Did root process terminate?
	if process = root and process.terminated then
		PB_MoveCursorToLine(PB_Global.Terminal.usedLines);
		PB_PrintNewLine();
		PB_ResetStyleAndColor();
		PB_ShowCursor();
	fi;
end);
