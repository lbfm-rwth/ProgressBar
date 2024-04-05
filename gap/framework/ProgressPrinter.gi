#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  ProgressPrinter.gi
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
## Progress Printer
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


InstallValue(ProgressPrinter, rec(
	Layout := fail,
	RootProcess := fail,
	Dimensions := fail,
	Cursor := fail,
	Timestamp := fail,
	Options := fail,
	Pattern := fail,
	InitialConfiguration := fail,
	CurProcess := fail,
	IsActive := true,
));

InstallGlobalFunction("SetLayout", function(layout)
	ProgressPrinter.Layout := layout;
	ProgressPrinter.Options := ShallowCopy(ProgressPrinter.Layout.DefaultOptions);
end);

SetLayout(StandardLayout);

InstallGlobalFunction("PB_StartProgressPrinter", function(process)
	ProgressPrinter.RootProcess := process;
	ProgressPrinter.Dimensions := rec(
		h := 1,
		w := SizeScreen()[1] - 1,
	);
	ProgressPrinter.Cursor := rec(
		x := 1,
		y := 1
	);
	ProgressPrinter.TimeStamp := fail;
	ProgressPrinter.Layout.Setup(ProgressPrinter.Options);
	ProgressPrinter.CurProcess := fail;
end);

#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Options
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


BindGlobal("PB_SetOptions",
function(optionsBase, optionsUpdate)
    local r;
    for r in RecNames(optionsUpdate) do
        if not IsBound(optionsBase.(r)) then
            ErrorNoReturn("Invalid option: ", r);
        fi;
		optionsBase.(r) := optionsUpdate.(r);
    od;
end);

InstallGlobalFunction(LayoutOptions,
function()
    Display(ProgressPrinter.Options);
end);

InstallGlobalFunction(SetLayoutOptions,
function(options)
    PB_SetOptions(ProgressPrinter.Options, options);
	ProgressPrinter.Layout.Setup(ProgressPrinter.Options);
	if ProgressPrinter.RootProcess <> fail then
		PB_Perform(ProgressPrinter.RootProcess, function(proc)
			proc.blocks := rec();
		end);
	fi;
end);

InstallGlobalFunction(ResetLayoutOptions,
function()
	SetLayoutOptions(ProgressPrinter.Layout.DefaultOptions);
end);


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Allocation of Blocks
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


InstallGlobalFunction("PB_SetupBlocks", function(process, pattern)
	local block, child;
	if pattern.isIsActive(process) then
		if not IsBound(process.blocks.(pattern.id)) then
			process.blocks.(pattern.id) := rec();
		fi;
		block := process.blocks.(pattern.id);
		block.x := fail;
		block.y := fail;
		block.w := fail;
		block.h := fail;
	else
		if IsBound(process.blocks.(pattern.id)) then
			Unbind(process.blocks.(pattern.id));
		fi;
	fi;
	for child in pattern.children do
		PB_SetupBlocks(process, child);
	od;
end);

# get bounding box of block
BindGlobal("PB_GetBounds", function(process, pattern)
	return process.blocks.(pattern.id);;
end);

# set bounding box of block
InstallGlobalFunction("PB_SetBounds", function(process, pattern, values)
	local bounds, param, i, child;
	if not pattern.isIsActive(process) then
		return;
	fi;
	bounds := PB_GetBounds(process, pattern);
	for param in ["x", "y", "w", "h"] do
		i := Position(ProgressPrinter.Variables, rec(id := pattern.id, param := param));
		bounds.(param) := values[i];
	od;
	if not IsEmpty(pattern.children) then
		for child in pattern.children do
			PB_SetBounds(process, child, values);
		od;
	fi;
end);

InstallGlobalFunction("PB_InitializeParent", function(pattern, parent)
	local child;
	pattern.parent := parent;
	if not IsEmpty(pattern.children) then
		for child in pattern.children do
			PB_InitializeParent(child, pattern);
		od;
	fi;
end);

# node sets dimensions of itself
InstallGlobalFunction("PB_SetupDimensionsConfiguration", function(process, pattern)
	local bounds, proc, children, child, dim, dir, value, desyncronized;
	desyncronized := false;
	# inner node
	if not IsEmpty(pattern.children) then
		children := Filtered(pattern.children, child -> child.isIsActive(process));
		for child in children do
			desyncronized := desyncronized or PB_SetupDimensionsConfiguration(process, child);
		od;
	# leaf node
	else
		dim := pattern.printer.dimensions(process, pattern.printer_options);
		bounds := PB_GetBounds(process, pattern);
		for dir in ["w", "h"] do
			if dir in pattern.sync then
				proc := PB_First(ProgressPrinter.RootProcess, proc -> proc <> process and IsBound(proc.blocks.(pattern.id)));
				if proc <> fail then
					value := proc.blocks.(pattern.id).(dir);
				else
					value := dim.(dir);
				fi;
				if value < dim.(dir) then
					value := dim.(dir);
					PB_Perform(ProgressPrinter.RootProcess, function(proc)
						local pos;
						if proc <> process then
							pos := Position(proc.configuration, [1, rec(id := pattern.id, param := dir), PB_GetBounds(proc, pattern).(dir)]);
							proc.configuration[pos] := [1, rec(id := pattern.id, param := dir), value];
							proc.configurationSystem.b[pos] := value;
						fi;
					end);
					desyncronized := true;
				fi;
			else
				value := dim.(dir);
			fi;
			bounds.(dir) := value;
			if bounds.(dir) <> fail then
				Add(process.configuration, [1, rec(id := pattern.id, param := dir), bounds.(dir)]);
			fi;
		od;
	fi;
	return desyncronized;
end);

InstallGlobalFunction("PB_SetupVariables", function(pattern)
	local param, child;
	for param in ["x", "y", "w", "h"] do
		Add(ProgressPrinter.Variables, rec(id := pattern.id, param := param));
	od;
	if not IsEmpty(pattern.children) then
		for child in pattern.children do
			PB_SetupVariables(child);
		od;
	fi;
end);

BindGlobal("PB_SetupConfigurationSystem", function(process)
	local M, b, n, c, column, m, i, j;
	M := [];
	b := [];
	n := Length(ProgressPrinter.Variables);
	for c in process.configuration do
		column := ListWithIdenticalEntries(n, 0);
		m := Length(c);
		for i in [1 .. (m - 1) / 2] do
			j := Position(ProgressPrinter.Variables, c[2 * i]);
			column[j] := c[2 * i - 1];
		od;
		Add(M, column);
		Add(b, c[m]);
	od;
	TransposedMatDestructive(M);
	process.configurationSystem := rec(M := M, b := b);
end);

InstallGlobalFunction("PB_SetupAlignmentConfiguration", function(process, pattern)
	local c, children, child, i, coord, dir;
	if not pattern.isIsActive(process) then
		return;
	fi;
	# inner node
	if not IsEmpty(pattern.children) then
		children := Filtered(pattern.children, child -> child.isIsActive(process));
		# child dimensions sum up to node dimension for dir
		if pattern.alignment = "horizontal" then
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
		Add(process.configuration, c);
		# child dimensions are equal to node dimension for dir
		if pattern.alignment = "horizontal" then
			dir := "h";
		else # vertical
			dir := "w";
		fi;
		for child in children do
			c := [];
			Append(c, [1, rec(id := child.id, param := dir)]);
			Append(c, [-1, rec(id := pattern.id, param := dir)]);
			Add(c, 0);
			Add(process.configuration, c);
		od;
		# child coordinate are shifted for coord
		if pattern.alignment = "horizontal" then
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
		Add(process.configuration, c);
		for i in [1 .. Length(children) - 1] do
			c := [];
			Append(c, [1, rec(id := children[i].id, param := coord)]);
			Append(c, [1, rec(id := children[i].id, param := dir)]);
			Append(c, [-1, rec(id := children[i + 1].id, param := coord)]);
			Add(c, 0);
			Add(process.configuration, c);
		od;
		# child coordinate are equal to node coordinate for coord
		if pattern.alignment = "horizontal" then
			coord := "y";
		else # vertical
			coord := "x";
		fi;
		for child in children do
			c := [];
			Append(c, [1, rec(id := child.id, param := coord)]);
			Append(c, [-1, rec(id := pattern.id, param := coord)]);
			Add(c, 0);
			Add(process.configuration, c);
		od;
		# recursion
		for child in children do
			PB_SetupAlignmentConfiguration(process, child);
		od;
	fi;
end);

BindGlobal("PB_AllocateBlockBounds", function(process)
	local pattern, bounds, param, data, configuration, procs, proc, M, b, values, desyncronized;
	# initalize process pattern
	pattern := ProgressPrinter.Pattern;
	PB_SetupBlocks(process, pattern);
	# initialize variables for bounds
	if not IsBound(ProgressPrinter.Variables) then
		ProgressPrinter.Variables := [];
		PB_SetupVariables(pattern);
	fi;
	# initialize configuration with process block bounds
	process.configuration := [];
	bounds := PB_GetBounds(process, pattern);
	bounds.x := 1;
	bounds.y := Sum(PB_Upper(process), upper -> upper.blocks.(pattern.id).h) + 1;
	bounds.w := ProgressPrinter.Dimensions.w;
	for param in ["x", "y", "w"] do
		Add(process.configuration, [1, rec(id := pattern.id, param := param), bounds.(param)]);
	od;
	# add configurations via alignment
	Append(process.configuration, ProgressPrinter.InitialConfiguration);
	PB_SetupAlignmentConfiguration(process, pattern);
	# add configurations via dimensions of the printer blocks,
	# where some might still be set to fail, if they are dynamic.
	desyncronized := PB_SetupDimensionsConfiguration(process, pattern);
	# compute configuration system for process
	PB_SetupConfigurationSystem(process);
	# solve linear system and set all bounds
	if desyncronized = false then
		procs := [process];
	elif desyncronized = true then
		procs := PB_List(ProgressPrinter.RootProcess);
	fi;
	for proc in procs do
		M := proc.configurationSystem.M;
		b := proc.configurationSystem.b;
		values := SolutionIntMat(M, b);
		PB_SetBounds(proc, pattern, values);
	od;
	return desyncronized;
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
	# activity has changed
	if pattern.isIsActive(process) then
		if not IsBound(process.blocks.(pattern.id)) then
			return false;
		fi;
	else
		if IsBound(process.blocks.(pattern.id)) then
			return false;
		fi;
	fi;

	if not pattern.isIsActive(process) then
		return true;
	fi;

	# composition block (inner node)
	if not IsEmpty(pattern.children) then
		for child in pattern.children do
			if PB_PrintBlock(process, child, doGenerate) = false then
				return false;
			fi;
		od;
		return true;
	fi;

	# printer block (leaf node)
	if doGenerate then
		pattern.printer.generate(process, pattern.id, pattern.printer_options);
		return true;
	else
		return pattern.printer.update(process, pattern.id, pattern.printer_options);
	fi;
end);

InstallGlobalFunction("PB_PrintProcess", function(process, doGenerate)
	local desyncronized;

	desyncronized := false;

	if process.blocks = rec() then
		desyncronized := desyncronized or PB_AllocateBlockBounds(process);
		doGenerate := true;
	fi;

	if process.completedSteps < 0 then
		doGenerate := true;
	fi;

	if doGenerate then
		PB_ClearProcess(process);
	fi;

	if PB_PrintBlock(process, ProgressPrinter.Pattern, doGenerate) = false then
		# printing of blocks had a failure -> reallocate blocks
		desyncronized := desyncronized or PB_AllocateBlockBounds(process);
		PB_ClearProcess(process);
		PB_PrintBlock(process, ProgressPrinter.Pattern, true);
	fi;

	return desyncronized;
end);

InstallGlobalFunction("PB_PrintProgress", function(process)
	local proc, child, root, desyncronized;

	root := ProgressPrinter.RootProcess;
	desyncronized := false;

	# Did root process start?
	if process = root and process.completedSteps <= 0 then
		PB_HideCursor();
	fi;

	# Print current process
	ProgressPrinter.CurProcess := process;
	desyncronized := desyncronized or PB_PrintProcess(process, false);

	# Print all descendants
	for child in process.children do
		PB_Perform(child, function(proc)
			desyncronized := desyncronized or PB_PrintProcess(proc, false);
		end);
	od;

	# Print all predecessors
	proc := process.parent;
	while proc <> fail do
		desyncronized := desyncronized or PB_PrintProcess(proc, false);
		proc := proc.parent;
	od;

	if desyncronized = true then
		PB_ClearScreen();
		PB_Perform(root, function(proc)
			PB_PrintProcess(proc, true);
		end);
	fi;

	# Move cursor to end
	PB_MoveCursorToProcessEnd();

	# Did root process terminate?
	if process = root and process.status = "complete" then
		PB_ResetStyleAndColor();
		PB_ShowCursor();
	fi;
end);
