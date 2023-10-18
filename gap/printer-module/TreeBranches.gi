#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  TreeBranches.gi
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


BindGlobal("PB_TreeBranchesPrinter", rec());

PB_TreeBranchesPrinter.dimensions := function(process, options)
	return rec(
		w := Length(options.branch) * process.depth,
		h := fail
	);
end;

PB_TreeBranchesPrinter.print := function(process, id, options)
	local block, indent, i, j;
	block := process.blocks.(id);
	indent := Concatenation(ListWithIdenticalEntries(Length(options.branch), " "));
	indent := ListWithIdenticalEntries(process.depth, indent);
	for i in block.branches do
		indent[i + 1] := options.branch;
	od;
	indent := Concatenation(indent);
	for j in [block.y .. block.y + block.h - 1] do
		PB_MoveCursorToCoordinate(block.x, j);
		PB_Print(indent);
	od;
end;

PB_TreeBranchesPrinter.generate := function(process, id, options)
	local block, parent, child, grandchild, branch;
	block := process.blocks.(id);
	block.branches := [];
	parent := process.parent;
	if parent = fail then
		return;
	fi;
	for branch in parent.blocks.(id).branches do
		AddSet(block.branches, branch);
	od;
	# Situation: We need to update the children of all (upper) siblings
	# | parent
	#    | parent.child
	#       | parent.child.child
	#    | process
	for child in PB_Siblings(process, "upper") do
		for grandchild in child.children do
			PB_Perform(grandchild, function(proc)
				AddSet(proc.blocks.(id).branches, process.depth);
				PB_TreeBranchesPrinter.print(proc, id, options);
			end);
		od;
	od;
	# Situation: We need to update ourselves
	# | parent.parent
	#    | parent
	#       | process
	#    | parent.parent.child
	if parent.parent <> fail then
		if PositionProperty(parent.parent.children, child -> child.id = parent.id) < Length(parent.parent.children) then
			AddSet(block.branches, parent.depth);
		fi;
	fi;
	PB_TreeBranchesPrinter.print(process, id, options);
end;

PB_TreeBranchesPrinter.update := function(process, id, options)
	return true;
end;
