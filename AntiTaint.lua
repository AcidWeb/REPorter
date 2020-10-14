local _G = _G
local GetBuildInfo = _G.GetBuildInfo
local hooksecurefunc = _G.hooksecurefunc
local issecurevariable = _G.issecurevariable

-- This is pack of taint fixes by foxlit.

if (_G.UIDROPDOWNMENU_OPEN_PATCH_VERSION or 0) < 1 then
	_G.UIDROPDOWNMENU_OPEN_PATCH_VERSION = 1
	hooksecurefunc("UIDropDownMenu_InitializeHelper", function(frame)
		if _G.UIDROPDOWNMENU_OPEN_PATCH_VERSION ~= 1 then
			return
		end
		if _G.UIDROPDOWNMENU_OPEN_MENU and _G.UIDROPDOWNMENU_OPEN_MENU ~= frame
		   and not issecurevariable(_G.UIDROPDOWNMENU_OPEN_MENU, "displayMode") then
			_G.UIDROPDOWNMENU_OPEN_MENU = nil
			local t, f, prefix, i = _G, issecurevariable, " \0", 1
			repeat
				i, t[prefix .. i] = i + 1
			until f("UIDROPDOWNMENU_OPEN_MENU")
		end
	end)
end

if (_G.COMMUNITY_UIDD_REFRESH_PATCH_VERSION or 0) < 2 then
	_G.COMMUNITY_UIDD_REFRESH_PATCH_VERSION = 2
	if select(4, GetBuildInfo()) > 8e4 then
		local function CleanDropdowns()
			if _G.COMMUNITY_UIDD_REFRESH_PATCH_VERSION ~= 2 then
				return
			end
			local f, f2 = _G.FriendsFrame, _G.FriendsTabHeader
			local s = f:IsShown()
			f:Hide()
			f:Show()
			if not f2:IsShown() then
				f2:Show()
				f2:Hide()
			end
			if not s then
				f:Hide()
			end
		end
		hooksecurefunc("Communities_LoadUI", CleanDropdowns)
		hooksecurefunc("SetCVar", function(n)
			if n == "lastSelectedClubId" then
				CleanDropdowns()
			end
		end)
	end
end

if (_G.UIDD_REFRESH_OVERREAD_PATCH_VERSION or 0) < 1 then
	_G.UIDD_REFRESH_OVERREAD_PATCH_VERSION = 1
	local function drop(t, k)
		local c = 42
		t[k] = nil
		while not issecurevariable(t, k) do
			if t[c] == nil then
				t[c] = nil
			end
			c = c + 1
		end
	end
	hooksecurefunc("UIDropDownMenu_InitializeHelper", function()
		if _G.UIDD_REFRESH_OVERREAD_PATCH_VERSION ~= 1 then
			return
		end
		for i=1,_G.UIDROPDOWNMENU_MAXLEVELS do
			for j=1,_G.UIDROPDOWNMENU_MAXBUTTONS do
				local b, _ = _G["DropDownList" .. i .. "Button" .. j]
				_ = issecurevariable(b, "checked")      or drop(b, "checked")
				_ = issecurevariable(b, "notCheckable") or drop(b, "notCheckable")
			end
		end
	end)
end

if (tonumber(_G.IOFRAME_SELECTION_PATCH_VERSION) or 0) < 1 then
	_G.IOFRAME_SELECTION_PATCH_VERSION = 1
	_G.InterfaceOptionsFrame:HookScript("OnHide", function()
		if _G.IOFRAME_SELECTION_PATCH_VERSION == 1 then
			_G.InterfaceOptionsFrameCategories.selection = nil
		end
	end)
end