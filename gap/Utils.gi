#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
##  Utils.gi
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
## Tree Traversal
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


InstallGlobalFunction("PB_First", function(node, func)
	local child, res;
	if func(node) then
		return node;
	fi;
	for child in node.children do
		res := PB_First(child, func);
		if res <> fail then
			return res;
		fi;
	od;
	return fail;
end);

InstallGlobalFunction("PB_Last", function(node)
	if IsEmpty(node.children) then
		return node;
	else
		return PB_Last(Last(node.children));
	fi;
end);

InstallGlobalFunction("PB_Reduce", function(node, func, init)
	local value, child;
	value := func(init, node);
	for child in node.children do
		value := PB_Reduce(child, func, value);
	od;
	return value;
end);

InstallGlobalFunction("PB_Perform", function(node, func)
	local child;
	func(node);
	for child in node.children do
		PB_Perform(child, func);
	od;
end);

# args: node[, mode]
# mode in ["all", "upper", "lower"]
InstallGlobalFunction("PB_Siblings", function(args...)
	local node, mode, parent, pos, n, L;
	node := args[1];
	mode := "all";
	if Length(args) > 1 then
		mode := args[2];
	fi;
	parent := node.parent;
	if parent = fail then
		return [];
	else
		pos := PositionProperty(parent.children, child -> child.id = node.id);
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

InstallGlobalFunction("PB_List", function(node)
	local L;
	L := [];
	PB_Perform(node, function(n) Add(L, n); end);
	return L;
end);

InstallGlobalFunction("PB_Successors", function(node)
    local L, child;
	L := [];
    for child in node.children do
	    PB_Perform(child, function(n) Add(L, n); end);
    od;
	return L;
end);

InstallGlobalFunction("PB_Predecessors", function(node)
    local L, n;
    L := [];
    n := node.parent;
    while n <> fail do
        Add(L, n);
        n := n.parent;
    od;
	return L;
end);

InstallGlobalFunction("PB_ChildrenAndSelf", function(node)
	local L, child;
	L := [node];
	for child in node.children do
		Append(L, PB_ChildrenAndSelf(child));
	od;
	return L;
end);

InstallGlobalFunction("PB_Lower", function(node)
	local L, child, sibling;
	L := [];
	for child in node.children do
		Append(L, PB_ChildrenAndSelf(child));
	od;
	for sibling in PB_Siblings(node, "lower") do
		Append(L, PB_ChildrenAndSelf(sibling));
	od;
	return L;
end);

InstallGlobalFunction("PB_UpperUntilCaller", function(node, caller, L)
	local child;
	if node.id = caller.id then
		return true;
	fi;
	Add(L, node);
	for child in node.children do
		if PB_UpperUntilCaller(child, caller, L) then
			return true;
		fi;
	od;
	return false;
end);

InstallGlobalFunction("PB_Upper", function(node)
	local L;
	L := [];
	PB_UpperUntilCaller(ProgressPrinter.RootProcess, node, L);
	return L;
end);


#############################################################################
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
##                                                                         ##
## Strings
##                                                                         ##
##-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-##
#############################################################################


# returns number of digits
BindGlobal("PB_NrDigits", function(x)
	if x = 0 then
		return 1;
	else
		return LogInt(x, 10) + 1;
	fi;
end);

# returns string representation of length n
# by appending leading zeros to the digit x if necessary
BindGlobal("PB_StrNum", function(x, n)
	local nr_digits;
	nr_digits := PB_NrDigits(x);
	return Concatenation(Concatenation(ListWithIdenticalEntries(n - nr_digits, "0")), String(x));
end);

# returns record rec(d, h, min, s, ms) encoding the time period t given in milliseconds.
BindGlobal("PB_TimeRecord", function(t)
	local quorem, d, h, min, s, ms;
	# convert ms to time format
	# 1 d = 24 h
	# 1 h = 60 min
	# 1 min = 60 s
	# 1 s = 10^3 ms
	quorem := QuotientRemainder(t, 86400000);
	d := quorem[1];
	t := quorem[2];
	quorem := QuotientRemainder(t, 3600000);
	h := quorem[1];
	t := quorem[2];
	quorem := QuotientRemainder(t, 60000);
	min := quorem[1];
	t := quorem[2];
	quorem := QuotientRemainder(t, 1000);
	s := quorem[1];
	ms := quorem[2];
	return rec(d := d, h := h, min := min, s := s, ms := ms);
end);
