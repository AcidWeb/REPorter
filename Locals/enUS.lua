local L = {
	["Clear"] = true,
	["Help"] = true,
	["Incoming"] = true,
	["Attack"] = true,
	["Guard"] = true,
	["Heavily defended"] = true,
	["Losing"] = true,
	["Report status"] = true,

	["To cap"] = true,
	["players in area"] = true,
	["victory"] = true,

	["Map alpha"] = true,
	["Map scale"] = true,
	["Lock map"] = true,
	["Show report bar above map"] = true,
	["Add \"[REPorter]\" to end of each report"] = true,

	["West"] = true,
	["East"] = true,
	["Front"] = true,

	["New version released!"] = true,
		
	["This addon work only on battlegrounds."] = true,
	["This location don't have name. Action canceled."] = true
}

REPorterLocale = L
function L:CreateLocaleTable(t)
	for k, v in pairs(t) do
		self[k] = (v == true and k) or v
	end
end

L:CreateLocaleTable(L);
