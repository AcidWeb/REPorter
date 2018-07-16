local _G = _G
local _, RE = ...
local L = LibStub("AceLocale-3.0"):GetLocale("REPorter")
local TOAST = LibStub("LibToast-1.0")
local TIMER = LibStub("AceTimer-3.0")
local BUCKET = LibStub("AceBucket-3.0")
_G.REPorter = RE

-- UIDropDownMenu taint workaround by foxlit
if (UIDROPDOWNMENU_VALUE_PATCH_VERSION or 0) < 2 then
	UIDROPDOWNMENU_VALUE_PATCH_VERSION = 2
	hooksecurefunc("UIDropDownMenu_InitializeHelper", function()
		if UIDROPDOWNMENU_VALUE_PATCH_VERSION ~= 2 then
			return
		end
		for i=1, UIDROPDOWNMENU_MAXLEVELS do
			for j=1, UIDROPDOWNMENU_MAXBUTTONS do
				local b = _G["DropDownList" .. i .. "Button" .. j]
				if not (issecurevariable(b, "value") or b:IsShown()) then
					b.value = nil
					repeat
						j, b["fx" .. j] = j+1
					until issecurevariable(b, "value")
				end
			end
		end
	end)
end
if (UIDROPDOWNMENU_OPEN_PATCH_VERSION or 0) < 1 then
	UIDROPDOWNMENU_OPEN_PATCH_VERSION = 1
	hooksecurefunc("UIDropDownMenu_InitializeHelper", function(frame)
		if UIDROPDOWNMENU_OPEN_PATCH_VERSION ~= 1 then
			return
		end
		if UIDROPDOWNMENU_OPEN_MENU and UIDROPDOWNMENU_OPEN_MENU ~= frame
		   and not issecurevariable(UIDROPDOWNMENU_OPEN_MENU, "displayMode") then
			UIDROPDOWNMENU_OPEN_MENU = nil
			local t, f, prefix, i = _G, issecurevariable, " \0", 1
			repeat
				i, t[prefix .. i] = i + 1
			until f("UIDROPDOWNMENU_OPEN_MENU")
		end
	end)
end

--GLOBALS: FACTION_ALLIANCE, FACTION_HORDE, HELP_LABEL, ATTACK, HEALTH, BLUE_GEM, RED_GEM, MAX_RAID_MEMBERS, UIDROPDOWNMENU_VALUE_PATCH_VERSION, UIDROPDOWNMENU_MAXLEVELS, UIDROPDOWNMENU_MAXBUTTONS, UIDROPDOWNMENU_OPEN_PATCH_VERSION, UIDROPDOWNMENU_OPEN_MENU, issecurevariable
local select, pairs, strsplit, tonumber, strfind, print, strupper, next, strmatch = _G.select, _G.pairs, _G.strsplit, _G.tonumber, _G.strfind, _G.print, _G.strupper, _G.next, _G.strmatch
local mfloor = _G.math.floor
local CreateFrame = _G.CreateFrame
local CreateFramePool = _G.CreateFramePool
local IsInInstance = _G.IsInInstance
local IsRatedBattleground = _G.IsRatedBattleground
local IsInGuild = _G.IsInGuild
local IsShiftKeyDown = _G.IsShiftKeyDown
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local IsInBrawl = _G.C_PvP.IsInBrawl
local IsAddOnLoaded = _G.IsAddOnLoaded
local GetBattlefieldInstanceRunTime = _G.GetBattlefieldInstanceRunTime
local GetMapInfo = _G.C_Map.GetMapInfo
local GetMapArtLayerTextures = _G.C_Map.GetMapArtLayerTextures
local GetBestMapForUnit = _G.C_Map.GetBestMapForUnit
local GetAreaPOIForMap = _G.C_AreaPoiInfo.GetAreaPOIForMap
local GetAreaPOIInfo = _G.C_AreaPoiInfo.GetAreaPOIInfo
local GetPOITextureCoords = _G.GetPOITextureCoords
local GetVignettes = _G.C_VignetteInfo.GetVignettes
local GetVignetteInfo = _G.C_VignetteInfo.GetVignetteInfo
local GetVignettePosition = _G.C_VignetteInfo.GetVignettePosition
local GetNumBattlefieldFlagPositions = _G.GetNumBattlefieldFlagPositions
local GetBattlefieldFlagPosition = _G.GetBattlefieldFlagPosition
local GetNumBattlefieldVehicles = _G.GetNumBattlefieldVehicles
local GetBattlefieldVehicleInfo = _G.GetBattlefieldVehicleInfo
local GetVehicleTexture = _G.VehicleUtil.GetVehicleTexture
local GetSubZoneText = _G.GetSubZoneText
local GetClassColor = _G.GetClassColor
local GetRaidTargetIndex = _G.GetRaidTargetIndex
local GetTopCenterWidgetSetID = _G.C_UIWidgetManager.GetTopCenterWidgetSetID
local GetAllWidgetsBySetID = _G.C_UIWidgetManager.GetAllWidgetsBySetID
local GetIconAndTextWidgetVisualizationInfo = _G.C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo
local UnitName = _G.UnitName
local UnitClass = _G.UnitClass
local UnitExists = _G.UnitExists
local UnitIsUnit = _G.UnitIsUnit
local UnitAffectingCombat = _G.UnitAffectingCombat
local UnitHealth = _G.UnitHealth
local UnitHealthMax = _G.UnitHealthMax
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local SendChatMessage = _G.SendChatMessage
local SendAddonMessage = _G.C_ChatInfo.SendAddonMessage
local CombatLogGetCurrentEventInfo = _G.CombatLogGetCurrentEventInfo
local RegisterAddonMessagePrefix = _G.C_ChatInfo.RegisterAddonMessagePrefix
local ElvUI = _G.ElvUI

local AV = 91
local WG = 92
local AB = 93
local EOTS = 112
local IOC = 169
local TP = 206
local BFG = 275
local TOK = 417
local SM = 423
local DG = 519
local TMVS = 623
local ABW = 837
local SS = 907

RE.POIIconSize = 30
RE.POINumber = 25
RE.MapUpdateRate = 0.05
RE.LastMap = 0
RE.CurrentMap = -1
RE.NeedRefresh = false
RE.BGVehicles = {}
RE.POINodes = {}
RE.PinTextures = {}
RE.ClickedPOI = ""

RE.DefaultTimer = 60
RE.CareAboutNodes = false
RE.CareAboutPoints = false
RE.CareAboutGates = false
RE.CareAboutFlags = false
RE.PlayedFromStart = true
RE.GateSyncRequested = false
RE.IoCAllianceGateName = ""
RE.IoCHordeGateName = ""
RE.IoCGateEstimator = {}
RE.IoCGateEstimatorText = ""
RE.SMEstimatorText = ""
RE.SMEstimatorReport = ""
RE.IsWinning = ""
RE.IsBrawl = false
RE.IsOverlay = false

RE.BlipOffsetT = 0.5
RE.BlinkPOIMin = 0.3
RE.BlinkPOIMax = 0.6
RE.BlinkPOIValue = 0.3
RE.BlinkPOIUp = true

RE.FoundNewVersion = false
RE.AddonVersionCheck = 210
RE.ScreenHeight, RE.ScreenWidth = _G.UIParent:GetCenter()
RE.ElvUI = IsAddOnLoaded("ElvUI") and IsAddOnLoaded("AddOnSkins")

RE.MapSettings = {
	[AB] = {["PointsToWin"] = 1500, ["StartTimer"] = 120},
	[WG] = {["StartTimer"] = 120},
	[AV] = {["StartTimer"] = 120},
	[EOTS] = {["PointsToWin"] = 1500, ["StartTimer"] = 120},
	[IOC] = {["StartTimer"] = 120},
	[BFG] = {["PointsToWin"] = 1500, ["StartTimer"] = 120},
	[TP] = {["StartTimer"] = 120},
	[TOK] = {["PointsToWin"] = 1500, ["StartTimer"] = 120},
	[SM] = {["PointsToWin"] = 1500, ["StartTimer"] = 120},
	[DG] = {["PointsToWin"] = 1500, ["StartTimer"] = 120},
	[TMVS] = {["StartTimer"] = 120},
	[SS] = {["StartTimer"] = 120}
}
RE.EstimatorSettings = {
	[AB] = { [0] = 0, [1] = 10/12, [2] = 10/9, [3] = 10/6, [4] = 10/3, [5] = 30},
	[EOTS] = { [0] = 0, [1] = 1, [2] = 2, [3] = 5, [4] = 10},
	[BFG] = { [0] = 0, [1] = 10/9, [2] = 10/3, [3] = 30},
	[DG] = { [0] = 0, [1] = 1.6, [2] = 3.2, [3] = 6.4},
	[TOK] = {["CenterP"] = 1, ["InnerP"] = 0.8, ["OuterP"] = 0.6},
	[SM] = 150
}
RE.ZonesWithoutSubZones = {
	[DG] = true,
	[SM] = true,
	[TOK] = true,
	[TMVS] = true
}
RE.AzeriteNodes = {
	[0.391] = {[0.750] = L["Overlook"]},
	[0.286] = {[0.769] = L["Crash Site"]},
	[0.599] = {[0.358] = L["Tide Pools"], [0.553] = L["Shipwreck"]},
	[0.252] = {[0.423] = L["Ruins"]},
	[0.290] = {[0.556] = L["Waterfall"]},
	[0.450] = {[0.577] = L["Ridge"]},
	[0.527] = {[0.401] = L["Bonfire"]},
	[0.471] = {[0.283] = L["Tar Pits"]},
	[0.572] = {[0.263] = L["Temple"]},
	[0.386] = {[0.433] = L["Plunge"]},
	[0.349] = {[0.252] = L["Tower"]}
}

RE.POIDropDown = {
	{ text = L["Incoming"], hasArrow = true, notCheckable = true,
	menuList = {
		{ text = "1", notCheckable = true, minWidth = 15, func = function() RE:SmallButton(1, true); _G.CloseDropDownMenus() end },
		{ text = "2", notCheckable = true, minWidth = 15, func = function() RE:SmallButton(2, true); _G.CloseDropDownMenus() end },
		{ text = "3", notCheckable = true, minWidth = 15, func = function() RE:SmallButton(3, true); _G.CloseDropDownMenus() end },
		{ text = "4", notCheckable = true, minWidth = 15, func = function() RE:SmallButton(4, true); _G.CloseDropDownMenus() end },
		{ text = "5", notCheckable = true, minWidth = 15, func = function() RE:SmallButton(5, true); _G.CloseDropDownMenus() end },
		{ text = "5+", notCheckable = true, minWidth = 15, func = function() RE:SmallButton(6, true); _G.CloseDropDownMenus() end }
	} },
	{ text = HELP_LABEL, notCheckable = true, func = function() RE:BigButton(true, true) end },
	{ text = L["Clear"], notCheckable = true, func = function() RE:BigButton(false, true) end },
	{ text = "", notCheckable = true, disabled = true },
	{ text = ATTACK, notCheckable = true, func = function() RE:ReportDropDownClick(ATTACK) end },
	{ text = L["Guard"], notCheckable = true, func = function() RE:ReportDropDownClick(L["Guard"]) end },
	{ text = L["Heavily defended"], notCheckable = true, func = function() RE:ReportDropDownClick(L["Heavily defended"]) end },
	{ text = L["Losing"], notCheckable = true, func = function() RE:ReportDropDownClick(L["Losing"]) end },
	{ text = "", notCheckable = true, disabled = true },
	{ text = L["On my way"], notCheckable = true, func = function() RE:ReportDropDownClick(L["On my way"]) end },
	{ text = L["Report status"], notCheckable = true, func = function() RE:ReportDropDownClick("") end }
}

RE.DefaultConfig = {
	BarHandle = 11,
	BarX = RE.ScreenHeight,
	BarY = RE.ScreenWidth,
	Locked = false,
	Opacity = 0.75,
	HideMinimap = false,
	DisplayMarks = false,
	Map = {
		[AB] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 325, ["wh"] = 325, ["mx"] = 16, ["my"] = -77, ["ms"] = 1},
		[WG] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 280, ["wh"] = 460, ["mx"] = -5, ["my"] = -38, ["ms"] = 1},
		[AV] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 185, ["wh"] = 450, ["mx"] = 32, ["my"] = -36, ["ms"] = 1},
		[EOTS] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 220, ["wh"] = 360, ["mx"] = 23, ["my"] = -41, ["ms"] = 1},
		[IOC] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 290, ["wh"] = 375, ["mx"] = 13, ["my"] = -23, ["ms"] = 1},
		[BFG] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 340, ["wh"] = 370, ["mx"] = 6, ["my"] = -28, ["ms"] = 1},
		[TP] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 245, ["wh"] = 460, ["mx"] = 1, ["my"] = -33, ["ms"] = 1},
		[SM] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 390, ["wh"] = 250, ["mx"] = 19, ["my"] = -21, ["ms"] = 1},
		[TOK] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 460, ["wh"] = 350, ["mx"] = 7, ["my"] = -43, ["ms"] = 1},
		[DG] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 520, ["wh"] = 385, ["mx"] = -10, ["my"] = -45, ["ms"] = 1},
		[TMVS] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 220, ["wh"] = 370, ["mx"] = -2, ["my"] = -22, ["ms"] = 1},
		[SS] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 360, ["wh"] = 385, ["mx"] = 66, ["my"] = -63, ["ms"] = 1}
	}
}
RE.ReportBarAnchor = {
	[1] = {"BOTTOMLEFT", "BOTTOMRIGHT"},
	[2] = {"LEFT", "RIGHT"},
	[3] = {"TOPLEFT", "TOPRIGHT"},
	[4] = {"BOTTOMRIGHT", "BOTTOMLEFT"},
	[5] = {"RIGHT", "LEFT"},
	[6] = {"TOPRIGHT", "TOPLEFT"},
	[7] = {"BOTTOMLEFT", "TOPLEFT"},
	[8] = {"BOTTOM", "TOP"},
	[9] = {"BOTTOMRIGHT", "TOPRIGHT"},
	[10] = {"TOPLEFT", "BOTTOMLEFT"},
	[11] = {"TOP", "BOTTOM"},
	[12] = {"TOPRIGHT", "BOTTOMRIGHT"}
}
RE.AceConfig = {
	type = "group",
	args = {
		Locked = {
			name = L["Lock map"],
			desc = L["When checked map and report bar is locked in place."],
			type = "toggle",
			width = "full",
			order = 1,
			set = function(_, val) RE.Settings.Locked = val; RE:UpdateConfig() end,
			get = function(_) return RE.Settings.Locked end
		},
		Description = {
			type = "description",
			name = L["When the lock is disabled map can be moved by dragging.\nDragging + SHIFT will move map inside the frame.\nMap frame can be resized by using holder at the bottom right corner.\nScroll wheel control map zoom."],
			order = 2,
		},
		HideMinimap = {
			name = L["Hide minimap on battlegrounds"],
			desc = L["When checked minimap will be hidden when a player is on the battleground."],
			type = "toggle",
			width = "full",
			order = 3,
			set = function(_, val) RE.Settings.HideMinimap = val; RE:UpdateConfig() end,
			get = function(_) return RE.Settings.HideMinimap end
		},
		DisplayMarks = {
			name = L["Always display raid markers"],
			desc = L["When checked player pins will be always replaced with raid markers."],
			type = "toggle",
			width = "full",
			order = 4,
			set = function(_, val) RE.Settings.DisplayMarks = val; RE:UpdateConfig() end,
			get = function(_) return RE.Settings.DisplayMarks end
		},
		BarHandle = {
			name = L["Report bar location"],
			desc = L["Anchor point of a bar with quick report buttons."],
			type = "select",
			width = "double",
			order = 5,
			values = {
				[1] = L["Right bottom"],
				[2] = L["Right"],
				[3] = L["Right top"],
				[4] = L["Left bottom"],
				[5] = L["Left"],
				[6] = L["Left top"],
				[7] = L["Top left"],
				[8] = L["Top"],
				[9] = L["Top right"],
				[10] = L["Bottom left"],
				[11] = L["Bottom"],
				[12] = L["Bottom right"],
				[13] = L["Standalone - Horizontal"],
				[14] = L["Standalone - Vertical"],
				[15] = L["Hidden"]
			},
			set = function(_, val) RE.Settings.BarHandle = val; RE.Settings.BarX, RE.Settings.BarY = _G.REPorterBar:GetCenter(); RE:UpdateConfig() end,
			get = function(_) return RE.Settings.BarHandle end
		},
		MapSettings = {
			name = BATTLEGROUND,
			desc = L["Map position is saved separately for each battleground."],
			type = "select",
			width = "double",
			order = 6,
			disabled = function(_) if select(2, IsInInstance()) == "pvp" then return true else return false end end,
			values = {
				[AB] = GetMapInfo(AB).name,
				[WG] = GetMapInfo(WG).name,
				[AV] = GetMapInfo(AV).name,
				[EOTS] = GetMapInfo(EOTS).name,
				[IOC] = GetMapInfo(IOC).name,
				[BFG] = GetMapInfo(BFG).name,
				[TP] = GetMapInfo(TP).name,
				[SM] = GetMapInfo(SM).name,
				[TOK] = GetMapInfo(TOK).name,
				[DG] = GetMapInfo(DG).name,
				[TMVS] = GetMapInfo(TMVS).name,
				[SS] = GetMapInfo(SS).name,
			},
			set = function(_, val) RE.LastMap = val; RE:ShowDummyMap(val) end,
			get = function(_) return RE.LastMap end
		},
		Scale = {
			name = L["Map scale"],
			desc = L["This option control map size."],
			type = "range",
			width = "double",
			order = 7,
			min = 0.5,
			max = 1.5,
			step = 0.05,
			set = function(_, val) RE:UpdateScaleConfig(_, val) end,
			get = function(_) return RE:UpdateScaleConfig() end
		},
		Opacity = {
			name = L["Map alpha"],
			desc = L["This option control map transparency."],
			type = "range",
			width = "double",
			order = 8,
			isPercent = true,
			min = 0.1,
			max = 1,
			step = 0.01,
			set = function(_, val) RE.Settings.Opacity = val; RE:UpdateConfig() end,
			get = function(_) return RE.Settings.Opacity end
		},
	}
}

local function ElvUISwag(sender)
  if sender == "Livarax-BurningLegion" then
    return [[|TInterface\PvPRankBadges\PvPRank09:0|t ]]
  end
  return nil
end

-- *** Pre-hook section
RE.TimerOverride = false
RE.TimerOriginal = StartTimer_BigNumberOnUpdate
_G.StartTimer_BigNumberOnUpdate = function(...)
	if RE.TimerOverride then
		_G.StartTimer_BarOnlyOnUpdate(...)
	else
		RE.TimerOriginal(...)
	end
end
--

-- *** Auxiliary functions
function RE:BlinkPOI()
	if RE.BlinkPOIValue + 0.03 <= RE.BlinkPOIMax and RE.BlinkPOIUp then
		RE.BlinkPOIValue = RE.BlinkPOIValue + 0.03
	else
		if RE.BlinkPOIUp then
			RE.BlinkPOIUp = false
			RE.BlinkPOIValue = RE.BlinkPOIValue - 0.03
		elseif RE.BlinkPOIValue - 0.03 <= RE.BlinkPOIMin then
			RE.BlinkPOIUp = true
			RE.BlinkPOIValue = RE.BlinkPOIValue - 0.03
		else
			RE.BlinkPOIValue = RE.BlinkPOIValue - 0.03
		end
	end
end

function RE:ShortTime(TimeRaw)
	local TimeSec = mfloor(TimeRaw % 60)
	local TimeMin = mfloor(TimeRaw / 60)
	if TimeSec < 10 then
		TimeSec = "0" .. TimeSec
	end
	return TimeMin .. ":" .. TimeSec
end

function RE:Round(num, idp)
	local mult = 10^(idp or 0)
	return mfloor(num * mult + 0.5) / mult
end

function RE:GetRealCoords(rawX, rawY)
	-- X -17 Y -78
	return rawX * 783, -rawY * 522
end

function RE:FramesOverlap(frameA, frameB)
	local sA, sB = frameA:GetEffectiveScale(), frameB:GetEffectiveScale()
	return (frameA:GetLeft() * sA) < (frameB:GetRight() * sB)
	and (frameB:GetLeft() * sB) < (frameA:GetRight() * sA)
	and (frameA:GetBottom() * sA) < (frameB:GetTop() * sB)
	and (frameB:GetBottom() * sB) < (frameA:GetTop() * sA)
end

function RE:CreatePOI(index)
	local frameMain = CreateFrame("Frame", "REPorterFrameCorePOI"..index, _G.REPorterFrameCorePOI)
	frameMain:SetFrameLevel(10)
	frameMain:SetWidth(RE.POIIconSize)
	frameMain:SetHeight(RE.POIIconSize)
	frameMain:SetScript("OnEnter", function(self) RE:UnitOnEnterPOI(self) end)
	frameMain:SetScript("OnLeave", RE.HideTooltip)
	frameMain:SetScript("OnMouseDown", function(self) RE:OnClickPOI(self) end)
	local texture = frameMain:CreateTexture(frameMain:GetName().."Texture", "BORDER")
	texture:SetPoint("CENTER", frameMain, "CENTER")
	texture:SetWidth(RE.POIIconSize - 13)
	texture:SetHeight(RE.POIIconSize - 13)
	texture:SetTexture("Interface\\Minimap\\POIIcons")
	local texture = frameMain:CreateTexture(frameMain:GetName().."TextureBG", "BACKGROUND")
	texture:SetPoint("TOPLEFT", frameMain, "TOPLEFT")
	texture:SetPoint("BOTTOMLEFT", frameMain, "BOTTOMLEFT")
	texture:SetWidth(RE.POIIconSize)
	texture:SetColorTexture(0,0,0,0.3)
	local texture = frameMain:CreateTexture(frameMain:GetName().."TextureBGofBG", "BACKGROUND")
	texture:SetPoint("TOPRIGHT", frameMain, "TOPRIGHT")
	texture:SetPoint("BOTTOMRIGHT", frameMain, "BOTTOMRIGHT")
	texture:SetWidth(RE.POIIconSize)
	texture:SetColorTexture(0,0,0,0.3)
	texture:Hide()
	local texture = frameMain:CreateTexture(frameMain:GetName().."TextureBGTop1", "BORDER")
	texture:SetPoint("TOPLEFT", frameMain, "TOPLEFT")
	texture:SetWidth(RE.POIIconSize)
	texture:SetHeight(2)
	texture:SetColorTexture(0,1,0,1)
	local texture = frameMain:CreateTexture(frameMain:GetName().."TextureBGTop2", "BORDER")
	texture:SetPoint("BOTTOMLEFT", frameMain, "BOTTOMLEFT")
	texture:SetWidth(RE.POIIconSize)
	texture:SetHeight(2)
	texture:SetColorTexture(0,1,0,1)
	local frame = CreateFrame("Frame", "REPorterFrameCorePOI"..index.."Timer", _G.REPorterFrameCorePOITimers, "REPorterPOITimerTemplate")
	frame:SetFrameLevel(11)
	frame:SetPoint("CENTER", frameMain, "CENTER")
end

function RE:UpdateIoCEstimator()
	if RE.IoCGateEstimator[FACTION_HORDE] < RE.IoCGateEstimator[FACTION_ALLIANCE] then
		RE.IoCGateEstimatorText = "|cFF00A9FF"..RE:Round((RE.IoCGateEstimator[FACTION_HORDE]/600000)*100, 0).."%|r"
	elseif RE.IoCGateEstimator[FACTION_HORDE] > RE.IoCGateEstimator[FACTION_ALLIANCE] then
		RE.IoCGateEstimatorText = "|cFFFF141D"..RE:Round((RE.IoCGateEstimator[FACTION_ALLIANCE]/600000)*100, 0).."%|r"
	else
		RE.IoCGateEstimatorText = ""
	end
end

function RE:PointParse(custom, id)
	local PointsNeeded, BaseNum = 0, 0
	if custom then
		local text = GetIconAndTextWidgetVisualizationInfo(GetAllWidgetsBySetID(GetTopCenterWidgetSetID())[id].widgetID).text
		if text ~= nil then
			PointsNeeded = RE.MapSettings[RE.CurrentMap]["PointsToWin"] - tonumber(strmatch(text, "(%d+)/%d+"))
		end
	else
		local text = GetIconAndTextWidgetVisualizationInfo(GetAllWidgetsBySetID(GetTopCenterWidgetSetID())[id].widgetID).text
		if text ~= nil then
			BaseNum = tonumber(strmatch(text, "(%d+)"))
			PointsNeeded = RE.MapSettings[RE.CurrentMap]["PointsToWin"] - tonumber(strmatch(text, "(%d+)/%d+"))
		end
	end
	return PointsNeeded, BaseNum
end

function RE:EstimatorFill(ATimeToWin, HTimeToWin, RefreshTimer)
	local TimeLeft = TIMER:TimeLeft(RE.EstimatorTimer)
	if ATimeToWin > 1 and HTimeToWin > 1 then
		if ATimeToWin < HTimeToWin then
			if RE.IsWinning ~= FACTION_ALLIANCE or (TimeLeft - ATimeToWin > RefreshTimer) or (TimeLeft - ATimeToWin < -RefreshTimer) then
				TIMER:CancelTimer(RE.EstimatorTimer)
				RE.IsWinning = FACTION_ALLIANCE
				RE.EstimatorTimer = TIMER:ScheduleTimer(RE.TimerNull, RE:Round(ATimeToWin, 0))
			end
		elseif ATimeToWin > HTimeToWin then
			if RE.IsWinning ~= FACTION_HORDE or (TimeLeft - HTimeToWin > RefreshTimer) or (TimeLeft - HTimeToWin < -RefreshTimer) then
				TIMER:CancelTimer(RE.EstimatorTimer)
				RE.IsWinning = FACTION_HORDE
				RE.EstimatorTimer = TIMER:ScheduleTimer(RE.TimerNull, RE:Round(HTimeToWin, 0))
			end
		else
			RE.IsWinning = ""
		end
	else
		TIMER:CancelTimer(RE.EstimatorTimer)
		RE.IsWinning = ""
	end
end

function RE:CreateTimer(time)
	RE.TimerOverride = true
	_G.TimerTracker_OnEvent(_G.TimerTracker, "START_TIMER", 1, time, time)
end

function RE:TimerNull()
	-- And Now His Watch is Ended
end

function RE:TimerJoinCheck()
	local BGTime = GetBattlefieldInstanceRunTime()/1000
	if RE.CurrentMap ~= -1 and BGTime > RE.MapSettings[RE.CurrentMap]["StartTimer"] then
		RE.PlayedFromStart = false
		if RE.CurrentMap == IOC then
			RE.GateSyncRequested = true
			SendAddonMessage("REPorter", "GateSyncRequest;", "INSTANCE_CHAT")
		end
	end
end

function RE:TimerBarHider()
	_G.REPorterBar:SetAlpha(0.25)
end

function RE:TimerDropDownHider()
	_G.CloseDropDownMenus()
end

function RE:HideTooltip()
	_G.GameTooltip:Hide()
end
--

-- *** Event functions
function RE:OnLoad(self)
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("CHAT_MSG_ADDON")
	self:RegisterEvent("MODIFIER_STATE_CHANGED")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	RE.FlagsPool = CreateFramePool("FRAME", _G.REPorterFrameCore, "REPorterFlagTemplate")
end

function RE:OnEnterBar(_)
	TIMER:CancelTimer(RE.TimerBar)
	_G.REPorterBar:SetAlpha(RE.Settings.Opacity)
end

function RE:OnLeaveBar(_)
	if not _G.REPorterBar:IsMouseOver() then
		TIMER:CancelTimer(RE.TimerBar)
		RE.TimerBar = TIMER:ScheduleTimer(RE.TimerBarHider, 0.5)
	end
end

function RE:OnLeave(_)
	TIMER:CancelTimer(RE.TimerDropDown)
	RE.TimerDropDown = TIMER:ScheduleTimer(RE.TimerDropDownHider, 3)
end

function RE:OnDragStart(_)
	_G.REPorterFrameCore:ClearAllPoints()
	_G.REPorterFrameCore:SetPoint("CENTER", _G.REPorterFrameCoreAnchor, "CENTER")
	if IsShiftKeyDown() then
		_G.REPorterFrameCoreAnchor:StartMoving()
	else
		local x1, y1 = _G.REPorterFrameClip:GetCenter()
		local x2, y2 = _G.REPorterFrameCoreAnchor:GetCenter()
		_G.REPorterFrameCoreAnchor:ClearAllPoints()
		_G.REPorterFrameCoreAnchor:SetPoint("CENTER", _G.REPorterFrameClip, "CENTER", x2-x1, y2-y1)
		_G.REPorterFrame:StartMoving()
	end
end

function RE:OnDragStop(_)
	_G.REPorterFrameCore:ClearAllPoints()
	_G.REPorterFrameCore:SetPoint("CENTER", _G.REPorterFrameCoreAnchor, "CENTER")
	if not RE:FramesOverlap(_G.REPorterFrameClip, _G.REPorterFrameCore) then
		_G.REPorterFrameCoreAnchor:ClearAllPoints()
		_G.REPorterFrameCoreAnchor:SetPoint("CENTER", _G.REPorterFrameClip, "CENTER", 9, -39)
	end
end

function RE:OnMouseWheel(delta)
	local newscale = _G.REPorterFrameCore:GetScale() + (delta * 0.05)
	if newscale > 1.5 then
		newscale = 1.5
	elseif newscale < 0.5 then
		newscale = 0.5
	end
	newscale = RE:Round(newscale, 2)
	_G.REPorterFrameCore:SetScale(newscale)
	if _G.InterfaceOptionsFrame:IsShown() then
		RE.ConfigFrame.obj.children[1].children[7]:SetValue(newscale)
	end
end

function RE:OnEvent(self, event, ...)
	if event == "ADDON_LOADED" and ... == "REPorter" then
		RE.UpdateTimer = 0
		if not _G.REPorterSettings then
			_G.REPorterSettings = RE.DefaultConfig
		end
		RE.Settings = _G.REPorterSettings
		for key, value in pairs(RE.DefaultConfig) do
			if RE.Settings[key] == nil then
				RE.Settings[key] = value
			end
		end
		_G.LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("REPorter", RE.AceConfig)
		RE.ConfigFrame = _G.LibStub("AceConfigDialog-3.0"):AddToBlizOptions("REPorter", "REPorter")
		_G.InterfaceOptionsFrame:HookScript("OnHide", RE.HideDummyMap)
		RE:UpdateConfig()

		RegisterAddonMessagePrefix("REPorter")
		_G.BINDING_HEADER_REPORTERB = "REPorter"
		_G.BINDING_NAME_REPORTERINC1 = L["Incoming"].." 1"
		_G.BINDING_NAME_REPORTERINC2 = L["Incoming"].." 2"
		_G.BINDING_NAME_REPORTERINC3 = L["Incoming"].." 3"
		_G.BINDING_NAME_REPORTERINC4 = L["Incoming"].." 4"
		_G.BINDING_NAME_REPORTERINC5 = L["Incoming"].." 5"
		_G.BINDING_NAME_REPORTERINC6 = L["Incoming"].." 5+"
		_G.BINDING_NAME_REPORTERHELP = HELP_LABEL
		_G.BINDING_NAME_REPORTERCLEAR = L["Clear"]
		_G.REPorterBar:SetHitRectInsets(-5, -5, -5, -5)
		_G.REPorterFrameClip:SetClipsChildren(true)
		_G.REPorterFrameCoreUP.excludedMouseOverUnits = {}
		_G.REPorterFrameCoreUP:SetMouseOverUnitExcluded("player", true)
		_G.REPorterFrameCoreUP.UpdateUnitTooltips = function(self, tooltipFrame) RE:UnitOnEnterPlayer(self, tooltipFrame) end
		_G.REPorterFrameCoreUP:SetFrameLevel(15)

		for i=1, RE.POINumber do
			RE:CreatePOI(i)
		end

		TOAST:Register("REPorterToastInfo", function(toast, ...)
			toast:SetFormattedTitle("|cFF74D06CRE|r|cFFFFFFFFPorter|r")
			toast:SetFormattedText(...)
			toast:SetIconTexture([[Interface\Challenges\ChallengeMode_Medal_Bronze]])
		end)

		if ElvUI then
			ElvUI[1]:GetModule("Chat"):AddPluginIcons(ElvUISwag)
		end

		self:UnregisterEvent("ADDON_LOADED")
	elseif event == "CHAT_MSG_ADDON" and ... == "REPorter" then
		local _, REMessage = ...
		local REMessageEx = {strsplit(";", REMessage)}

		if REMessageEx[1] == "Version" then
			if not RE.FoundNewVersion and tonumber(REMessageEx[2]) > RE.AddonVersionCheck then
				TOAST:Spawn("REPorterToastInfo", L["New version released!"])
				RE.FoundNewVersion = true
			end
		elseif REMessageEx[1] == "GateSyncRequest" and RE.PlayedFromStart then
			local message = "GateSync;"
			for k, _ in pairs(RE.POINodes) do
				if RE.POINodes[k]["health"] then
					message = message..RE.POINodes[k]["id"]..";"..RE.POINodes[k]["health"]..";"
				end
			end
			SendAddonMessage("REPorter", message, "INSTANCE_CHAT")
		elseif RE.GateSyncRequested and REMessageEx[1] == "GateSync" then
			RE.GateSyncRequested = false
			for key, _ in pairs(RE.POINodes) do
				for k=2, #REMessageEx do
					if REMessageEx[k] == RE.POINodes[key]["id"] then
						RE.POINodes[key]["health"] = REMessageEx[k+1]
					end
				end
			end
		end
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and next(RE.POINodes) ~= nil then
		local _, event, _, _, _, _, _, guid, _, _, _, _, _, _, damage = CombatLogGetCurrentEventInfo()
		if event ~= "SPELL_BUILDING_DAMAGE" then return end
		local gateID = {strsplit("-", guid)}
		--TODO check GUID
		if gateID[6] == "195496" then -- Horde East
			RE.POINodes[RE.IoCHordeGateName.." - "..L["East"]]["health"] = RE.POINodes[RE.IoCHordeGateName.." - "..L["East"]]["health"] - damage
			if RE.POINodes[RE.IoCHordeGateName.." - "..L["East"]]["health"] < RE.IoCGateEstimator[FACTION_HORDE] then
				RE.IoCGateEstimator[FACTION_HORDE] = RE.POINodes[RE.IoCHordeGateName.." - "..L["East"]]["health"]
			end
		elseif gateID[6] == "195494" then -- Horde Central
			RE.POINodes[RE.IoCHordeGateName.." - "..L["Front"]]["health"] = RE.POINodes[RE.IoCHordeGateName.." - "..L["Front"]]["health"] - damage
			if RE.POINodes[RE.IoCHordeGateName.." - "..L["Front"]]["health"] < RE.IoCGateEstimator[FACTION_HORDE] then
				RE.IoCGateEstimator[FACTION_HORDE] = RE.POINodes[RE.IoCHordeGateName.." - "..L["Front"]]["health"]
			end
		elseif gateID[6] == "195495" then -- Horde West
			RE.POINodes[RE.IoCHordeGateName.." - "..L["West"]]["health"] = RE.POINodes[RE.IoCHordeGateName.." - "..L["West"]]["health"] - damage
			if RE.POINodes[RE.IoCHordeGateName.." - "..L["West"]]["health"] < RE.IoCGateEstimator[FACTION_HORDE] then
				RE.IoCGateEstimator[FACTION_HORDE] = RE.POINodes[RE.IoCHordeGateName.." - "..L["West"]]["health"]
			end
		elseif gateID[6] == "195700" then -- Alliance East
			RE.POINodes[RE.IoCAllianceGateName.." - "..L["East"]]["health"] = RE.POINodes[RE.IoCAllianceGateName.." - "..L["East"]]["health"] - damage
			if RE.POINodes[RE.IoCAllianceGateName.." - "..L["East"]]["health"] < RE.IoCGateEstimator[FACTION_ALLIANCE] then
				RE.IoCGateEstimator[FACTION_ALLIANCE] = RE.POINodes[RE.IoCAllianceGateName.." - "..L["East"]]["health"]
			end
		elseif gateID[6] == "195698" then -- Alliance Center
			RE.POINodes[RE.IoCAllianceGateName.." - "..L["Front"]]["health"] = RE.POINodes[RE.IoCAllianceGateName.." - "..L["Front"]]["health"] - damage
			if RE.POINodes[RE.IoCAllianceGateName.." - "..L["Front"]]["health"] < RE.IoCGateEstimator[FACTION_ALLIANCE] then
				RE.IoCGateEstimator[FACTION_ALLIANCE] = RE.POINodes[RE.IoCAllianceGateName.." - "..L["Front"]]["health"]
			end
		elseif gateID[6] == "195699" then -- Alliance West
			RE.POINodes[RE.IoCAllianceGateName.." - "..L["West"]]["health"] = RE.POINodes[RE.IoCAllianceGateName.." - "..L["West"]]["health"] - damage
			if RE.POINodes[RE.IoCAllianceGateName.." - "..L["West"]]["health"] < RE.IoCGateEstimator[FACTION_ALLIANCE] then
				RE.IoCGateEstimator[FACTION_ALLIANCE] = RE.POINodes[RE.IoCAllianceGateName.." - "..L["West"]]["health"]
			end
		end
		RE:UpdateIoCEstimator()
	elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
		if RE.CurrentMap ~= -1 then
			RE:SaveMapSettings()
		end
		_G.REPorterFrame:Hide()
		_G.REPorterBar:Hide()
		_G.REPorterFrameEstimator:Hide()
		if select(2, IsInInstance()) == "pvp" and RE.CurrentMap == -1 then
			local mapID = GetBestMapForUnit("player")
			if mapID == ABW then mapID = AB end
			if mapID and RE.MapSettings[mapID] then
				RE.CurrentMap = mapID
				RE:Startup()
			end
		elseif select(2, IsInInstance()) ~= "pvp" and RE.CurrentMap ~= -1 then
			RE.CurrentMap = -1
			RE:Shutdown()
		end
	elseif event == "MODIFIER_STATE_CHANGED" and _G.REPorterFrame:IsShown() then
		if IsShiftKeyDown() and IsAltKeyDown() then
			RE.NeedRefresh = true
			_G.REPorterFrameCoreUP:Hide()
			_G.REPorterFrameCorePOITimers:Show()
		elseif IsShiftKeyDown() and IsControlKeyDown() then
			RE.NeedRefresh = true
		elseif _G.REPorterFrameCorePOITimers:IsShown() then
			RE.NeedRefresh = true
			_G.REPorterFrameCoreUP:Show()
			_G.REPorterFrameCorePOITimers:Hide()
		elseif RE.IsOverlay then
			RE.NeedRefresh = true
		end
	elseif event == "GROUP_ROSTER_UPDATE" and _G.REPorterFrame:IsShown() then
		RE.NeedRefresh = true
	end
end

function RE:OnPointsUpdate()
	if RE.MapSettings[RE.CurrentMap] and select(2, IsInInstance()) == "pvp" then
		if RE.CurrentMap == TOK then
			local AlliancePointsPerSec, AllianceTimeToWin, HordePointsPerSec, HordeTimeToWin = 0, 0, 0, 0
			local AlliancePointsNeeded = RE:PointParse(true, 2)
			local HordePointsNeeded = RE:PointParse(true, 3)
			for i=1, 4 do
				if i <= GetNumBattlefieldFlagPositions() then
					local flagX, flagY, flagTexture = GetBattlefieldFlagPosition(i)
					if flagX then
						local location
						flagX, flagY = RE:GetRealCoords(flagX, flagY)
						if flagX < 420 and flagX > 350 and flagY < -255 and flagY > -305 then
							location = "CenterP"
						elseif flagX < 470 and flagX > 300 and flagY < -210 and flagY > -350 then
							location = "InnerP"
						else
							location = "OuterP"
						end
						if flagTexture == 137200 then
							AlliancePointsPerSec = AlliancePointsPerSec + RE.EstimatorSettings[TOK][location]
						else
							HordePointsPerSec = HordePointsPerSec + RE.EstimatorSettings[TOK][location]
						end
					end
				end
				if AlliancePointsPerSec > 0 then
					AllianceTimeToWin = AlliancePointsNeeded / AlliancePointsPerSec
				else
					AllianceTimeToWin = 10000
				end
				if HordePointsPerSec > 0 then
					HordeTimeToWin = HordePointsNeeded / HordePointsPerSec
				else
					HordeTimeToWin = 10000
				end
				RE:EstimatorFill(AllianceTimeToWin, HordeTimeToWin, 2)
			end
		elseif RE.CurrentMap == SM then
			local AllianceCartsNeeded, HordeCartsNeeded = 10, 10
			local AlliancePointsNeeded = RE:PointParse(true, 2)
			local HordePointsNeeded = RE:PointParse(true, 3)
			AllianceCartsNeeded = AlliancePointsNeeded / RE.EstimatorSettings[SM]
			HordeCartsNeeded = HordePointsNeeded / RE.EstimatorSettings[SM]
			RE.SMEstimatorText = "|cFF00A9FF"..RE:Round(AllianceCartsNeeded, 1).."|r\n|cFFFF141D"..RE:Round(HordeCartsNeeded, 1).."|r"
			RE.SMEstimatorReport = FACTION_ALLIANCE.." "..L["victory"]..": "..RE:Round(AllianceCartsNeeded, 1).." "..L["carts"].." - "..FACTION_HORDE.." "..L["victory"]..": "..RE:Round(HordeCartsNeeded, 1).." "..L["carts"]
		elseif RE.CareAboutFlags then
			RE:CreateTimer(13)
		else
			local AllianceTimeToWin, HordeTimeToWin = 0, 0
			local AlliancePointsNeeded, AllianceBaseNum = RE:PointParse(false, 2)
			local HordePointsNeeded, HordeBaseNum = RE:PointParse(false, 3)
			if RE.EstimatorSettings[RE.CurrentMap][AllianceBaseNum] == 0 then
				AllianceTimeToWin = 10000
			else
				AllianceTimeToWin = AlliancePointsNeeded / RE.EstimatorSettings[RE.CurrentMap][AllianceBaseNum]
			end
			if RE.EstimatorSettings[RE.CurrentMap][HordeBaseNum] == 0 then
				HordeTimeToWin = 10000
			else
				HordeTimeToWin = HordePointsNeeded / RE.EstimatorSettings[RE.CurrentMap][HordeBaseNum]
			end
			RE:EstimatorFill(AllianceTimeToWin, HordeTimeToWin, 5)
		end
	end
end

function RE:OnUpdate(elapsed)
	if RE.UpdateTimer < 0 then
		RE:BlinkPOI()
		if not RE.ZonesWithoutSubZones[RE.CurrentMap] then
			local subZoneName = GetSubZoneText()
			if subZoneName and subZoneName ~= "" then
				for _, i in pairs({"B1", "B2", "B3", "B4", "B5", "B6", "B7", "B8"}) do
					_G["REPorterBar"..i]:Enable()
				end
			else
				for _, i in pairs({"B1", "B2", "B3", "B4", "B5", "B6", "B7", "B8"}) do
					_G["REPorterBar"..i]:Disable()
				end
			end
		end

		if RE.NeedRefresh then
			RE.NeedRefresh = false
			_G.REPorterFrameCoreUP:ClearUnits()
		end
		_G.REPorterFrameCoreUP:AddUnit("player", "Interface\\Minimap\\MinimapArrow", 40, 40, 1, 1, 1, 1, 1, true)
		if not (IsShiftKeyDown() and IsAltKeyDown()) then
			for i = 1, MAX_RAID_MEMBERS do
				local unit = "raid"..i
				local texture = ""
				if UnitExists(unit) and not UnitIsUnit(unit, "player") then
					texture = "Interface\\Addons\\REPorter\\Textures\\BlipNormal"
					local r, g, b = GetClassColor(select(2, UnitClass(unit)))
					if UnitAffectingCombat(unit) then
						if (UnitHealth(unit) / UnitHealthMax(unit)) * 100 < 26 then
							texture = "Interface\\Addons\\REPorter\\Textures\\BlipDying"
						else
							texture = "Interface\\Addons\\REPorter\\Textures\\BlipCombat"
						end
					elseif UnitIsDeadOrGhost(unit) then
						texture = "Interface\\Addons\\REPorter\\Textures\\BlipDead"
						r, g, b = r * 0.35, g * 0.35, b * 0.35
					end
					local raidMarker = GetRaidTargetIndex(unit)
					if IsShiftKeyDown() and IsControlKeyDown() then
						RE.IsOverlay = true
						if raidMarker ~= nil then
							texture = "Interface\\Addons\\REPorter\\Textures\\RaidMarker"..raidMarker
							_G.REPorterFrameCoreUP:AddUnit(unit, texture, 25, 25, 1, 1, 1, 1, 0, false)
						elseif UnitGroupRolesAssigned(unit) == "HEALER" then
							texture = "Interface\\Addons\\REPorter\\Textures\\BlipHealer"
							_G.REPorterFrameCoreUP:AddUnit(unit, texture, 30, 30, r, g, b, 1, 0, false)
						end
					else
						RE.IsOverlay = false
						if RE.Settings.DisplayMarks and raidMarker ~= nil then
							texture = "Interface\\Addons\\REPorter\\Textures\\RaidMarker"..raidMarker
							_G.REPorterFrameCoreUP:AddUnit(unit, texture, 25, 25, 1, 1, 1, 1, 0, false)
						else
							_G.REPorterFrameCoreUP:AddUnit(unit, texture, 25, 25, r, g, b, 1, 0, false)
						end
					end
				end
				if RE.PinTextures[unit] and RE.PinTextures[unit] ~= texture then
					RE.NeedRefresh = true
				end
				RE.PinTextures[unit] = texture
			end
		end
		_G.REPorterFrameCoreUP:FinalizeUnits()
		_G.REPorterFrameCoreUP:UpdateTooltips(_G.GameTooltip)
		local playerBlipFrameLevel = _G.REPorterFrameCoreUP:GetFrameLevel()

		RE.FlagsPool:ReleaseAll()
		for i = 1, GetNumBattlefieldFlagPositions() do
			local flagX, flagY, flagTexture = GetBattlefieldFlagPosition(i)
			if flagX then
				local flagFrame = RE.FlagsPool:Acquire()
				flagX, flagY = RE:GetRealCoords(flagX, flagY)
				flagFrame.Texture:SetTexture(flagTexture)
				flagFrame:SetPoint("CENTER", "REPorterFrameCorePOI", "TOPLEFT", flagX, flagY)
				flagFrame:SetFrameLevel(playerBlipFrameLevel - 1)
				flagFrame:Show()
			end
		end

		RE.NumVehicles = GetNumBattlefieldVehicles()
		local totalVehicles = #RE.BGVehicles
		local index = 0
		for i=1, RE.NumVehicles do
			if i > totalVehicles then
				local vehicleName = "REPorterFrameCorePOIVehicle"..i
				RE.BGVehicles[i] = CreateFrame("FRAME", vehicleName, _G.REPorterFrameCorePOI, "REPorterVehicleTemplate")
				RE.BGVehicles[i].texture = _G[vehicleName.."Texture"]
			end
			if RE.CurrentMap == IOC then
				RE.BGVehicles[i]:EnableMouse(true)
				RE.BGVehicles[i]:SetScript("OnEnter", function(self) RE:UnitOnEnterVehicle(self) end)
				RE.BGVehicles[i]:SetScript("OnLeave", RE.HideTooltip)
			else
				RE.BGVehicles[i]:EnableMouse(false)
				RE.BGVehicles[i]:SetScript("OnEnter", nil)
				RE.BGVehicles[i]:SetScript("OnLeave", nil)
			end
			local vehicleX, vehicleY, unitName, isPossessed, vehicleType, orientation, isPlayer, isAlive = GetBattlefieldVehicleInfo(i, RE.CurrentMap)
			if vehicleX and isAlive and not isPlayer then
				vehicleX, vehicleY = RE:GetRealCoords(vehicleX, vehicleY)
				RE.BGVehicles[i].texture:SetTexture(GetVehicleTexture(vehicleType, isPossessed))
				RE.BGVehicles[i].texture:SetRotation(orientation)
				RE.BGVehicles[i].name = unitName
				RE.BGVehicles[i]:SetPoint("CENTER", "REPorterFrameCorePOI", "TOPLEFT", vehicleX, vehicleY)
				RE.BGVehicles[i]:SetFrameLevel(playerBlipFrameLevel - 1)
				RE.BGVehicles[i]:Show()
				index = i
			else
				RE.BGVehicles[i]:Hide()
			end
		end
		if index < totalVehicles then
			for i=index+1, totalVehicles do
				RE.BGVehicles[i]:Hide()
			end
		end

		for i=1, RE.POINumber do
			_G["REPorterFrameCorePOI"..i]:Hide()
			_G["REPorterFrameCorePOI"..i.."Timer"]:Hide()
		end
		local poiList
		if RE.CurrentMap == SS then
			poiList = GetVignettes()
		else
			poiList = GetAreaPOIForMap(RE.CurrentMap)
		end
		for i=1, #poiList do
			local battlefieldPOIName = "REPorterFrameCorePOI"..i
			local battlefieldPOI = _G[battlefieldPOIName]
			local colorOverride = false
			local poiInfo
			if RE.CurrentMap == SS then
				local vignetteInfo = GetVignetteInfo(poiList[i])
				local vignettePosition = GetVignettePosition(poiList[i], RE.CurrentMap)
				local xZ, yZ = RE:Round(vignettePosition.x, 3), RE:Round(vignettePosition.y, 3)
				poiInfo = {["areaPoiID"] = vignetteInfo.vignetteID, ["name"] = vignetteInfo.name, ["description"] = "", ["position"] = {["x"] = vignettePosition.x, ["y"] = vignettePosition.y}, ["textureIndex"] = 0, ["atlasID"] = vignetteInfo.atlasName}
				if RE.AzeriteNodes[xZ] and RE.AzeriteNodes[xZ][yZ] then
					poiInfo.name = RE.AzeriteNodes[xZ][yZ]
				end
				if vignetteInfo.atlasName == "AzeriteReady" then
					poiInfo.textureIndex = 1002
				elseif vignetteInfo.atlasName == "AzeriteSpawning" then
					poiInfo.textureIndex = 1001
				end
			else
				poiInfo = GetAreaPOIInfo(RE.CurrentMap, poiList[i])
			end
			if poiInfo.name and poiInfo.textureIndex ~= nil and poiInfo.textureIndex ~= 0 then
				local x, y = RE:GetRealCoords(poiInfo.position.x, poiInfo.position.y)
				local x1, x2, y1, y2 = GetPOITextureCoords(poiInfo.textureIndex)
				if RE.CurrentMap == IOC then
					--TODO nodes id and placement
					if i == 9 then
						RE.IoCAllianceGateName = poiInfo.name
						poiInfo.name = poiInfo.name.." - "..L["East"]
						--x = x + 15
					elseif i == 10 then
						poiInfo.name = poiInfo.name.." - "..L["West"]
						--x = x - 13
					elseif i == 11 then
						poiInfo.name = poiInfo.name.." - "..L["Front"]
						--y = y + 15
					elseif i == 6 then
						RE.IoCHordeGateName = poiInfo.name
						poiInfo.name = poiInfo.name.." - "..L["Front"]
						--y = y - 15
					elseif i == 7 then
						poiInfo.name = poiInfo.name.." - "..L["East"]
						--x = x + 10
					elseif i == 8 then
						poiInfo.name = poiInfo.name.." - "..L["West"]
						--x = x - 10
						--y = y - 1
					end
				elseif RE.CurrentMap == AV then
					--[[TODO nodes placement
					if x > 343 and x < 346 then
						x = 350
						y = -108
					elseif x > 330 and x < 343 then
						x = 318
					elseif x > 402 and x < 405 then
						x = 412
					elseif x > 383 and x < 387 and y > -80 then
						x = 388
						y = -85
					elseif y < -186 and y > -189 then
						y = -192
					elseif y < -398 and y > -402 then
						x = 398
					elseif y < -441 and y > -444 and x > 385 and x < 388 then
						x = 410
						y = -440
					elseif y < -460 then
						y = -472
					end
					]]
				elseif RE.CurrentMap == TOK then
					if poiInfo.areaPoiID == 2774 then
						poiInfo.name = poiInfo.name.." - "..BLUE_GEM
						colorOverride = {0, 0, 1}
					elseif poiInfo.areaPoiID == 2775 then
						poiInfo.name = poiInfo.name.." - "..L["Purple"]
						colorOverride = {0.5, 0, 0.5}
					elseif poiInfo.areaPoiID == 2776 then
						poiInfo.name = poiInfo.name.." - "..RED_GEM
						colorOverride = {1, 0, 0}
					elseif poiInfo.areaPoiID == 2777 then
						poiInfo.name = poiInfo.name.." - "..L["Green"]
						colorOverride = {0, 1, 0}
					end
				end
				if RE.POINodes[poiInfo.name] == nil then
					RE.POINodes[poiInfo.name] = {["id"] = i, ["poiID"] = poiInfo.areaPoiID, ["name"] = poiInfo.name, ["status"] = poiInfo.description, ["x"] = x, ["y"] = y, ["texture"] = poiInfo.textureIndex}
					if RE.CurrentMap == IOC then
						--TODO gate IDs
						if i == 6 or i == 7 or i == 8 or i == 9 or i == 10 or i == 11 then
							RE.POINodes[poiInfo.name]["health"] = 600000
							RE.POINodes[poiInfo.name]["maxHealth"] = 600000
						end
					elseif RE.CurrentMap == SS and RE.PlayedFromStart then
						RE:NodeChange(poiInfo.textureIndex, poiInfo.name)
					end
				else
					RE.POINodes[poiInfo.name]["id"] = i
					RE.POINodes[poiInfo.name]["poiID"] = poiInfo.areaPoiID
					RE.POINodes[poiInfo.name]["name"] = poiInfo.name
					RE.POINodes[poiInfo.name]["status"] = poiInfo.description
					RE.POINodes[poiInfo.name]["x"] = x
					RE.POINodes[poiInfo.name]["y"] = y
					if RE.CareAboutNodes and RE.POINodes[poiInfo.name]["texture"] and RE.POINodes[poiInfo.name]["texture"] ~= poiInfo.textureIndex then
						RE:NodeChange(poiInfo.textureIndex, poiInfo.name)
					end
					RE.POINodes[poiInfo.name]["texture"] = poiInfo.textureIndex
				end
				battlefieldPOI.name = poiInfo.name
				battlefieldPOI:SetPoint("CENTER", "REPorterFrameCorePOI", "TOPLEFT", x, y)
				battlefieldPOI:SetWidth(RE.POIIconSize)
				battlefieldPOI:SetHeight(RE.POIIconSize)
				if poiInfo.textureIndex > 1000 then
					_G[battlefieldPOIName.."Texture"]:SetAtlas(poiInfo.atlasID)
				else
					_G[battlefieldPOIName.."Texture"]:SetTexCoord(x1, x2, y1, y2)
				end
				if colorOverride then
					_G[battlefieldPOIName.."Texture"]:SetVertexColor(colorOverride[1], colorOverride[2], colorOverride[3], 1)
				else
					_G[battlefieldPOIName.."Texture"]:SetVertexColor(1, 1, 1, 1)
				end
				if TIMER:TimeLeft(RE.POINodes[poiInfo.name]["timer"]) == 0 then
					if strfind(poiInfo.description, FACTION_HORDE) then
						_G[battlefieldPOIName.."TextureBG"]:SetColorTexture(1,0,0,0.3)
					elseif strfind(poiInfo.description, FACTION_ALLIANCE) then
						_G[battlefieldPOIName.."TextureBG"]:SetColorTexture(0,0,1,0.3)
					else
						if RE.CurrentMap == SS then
							_G[battlefieldPOIName.."TextureBG"]:SetColorTexture(0,1,0,0.3)
						else
							_G[battlefieldPOIName.."TextureBG"]:SetColorTexture(0,0,0,0.3)
						end
					end
					_G[battlefieldPOIName.."TextureBG"]:SetWidth(RE.POIIconSize)
					_G[battlefieldPOIName.."TextureBGofBG"]:Hide()
					if RE.CareAboutGates and RE.POINodes[poiInfo.name]["health"] and RE.POINodes[poiInfo.name]["health"] ~= 0 and poiInfo.textureIndex ~= 76 and poiInfo.textureIndex ~= 79 and poiInfo.textureIndex ~= 82 and poiInfo.textureIndex ~= 104 and poiInfo.textureIndex ~= 107 and poiInfo.textureIndex ~= 110 then
						_G[battlefieldPOIName.."TextureBGTop1"]:Hide()
						_G[battlefieldPOIName.."TextureBGTop2"]:Show()
						_G[battlefieldPOIName.."TextureBGTop2"]:SetWidth((RE.POINodes[poiInfo.name]["health"]/RE.POINodes[poiInfo.name]["maxHealth"]) * RE.POIIconSize)
						if RE.GateSyncRequested then
							_G[battlefieldPOIName.."TimerCaption"]:SetText("|cFFFF141D"..RE:Round((RE.POINodes[poiInfo.name]["health"]/RE.POINodes[poiInfo.name]["maxHealth"])*100, 0).."%|r")
						else
							_G[battlefieldPOIName.."TimerCaption"]:SetText(RE:Round((RE.POINodes[poiInfo.name]["health"]/RE.POINodes[poiInfo.name]["maxHealth"])*100, 0).."%")
						end
						_G[battlefieldPOIName.."Timer"]:Show()
					else
						_G[battlefieldPOIName.."TextureBGTop1"]:Hide()
						_G[battlefieldPOIName.."TextureBGTop2"]:Hide()
						_G[battlefieldPOIName.."Timer"]:Hide()
					end
				else
					local timeLeft = TIMER:TimeLeft(RE.POINodes[poiInfo.name]["timer"])
					_G[battlefieldPOIName.."TextureBG"]:SetWidth(RE.POIIconSize - ((timeLeft / RE.DefaultTimer) * RE.POIIconSize))
					_G[battlefieldPOIName.."TextureBGofBG"]:Show()
					_G[battlefieldPOIName.."TextureBGofBG"]:SetWidth((timeLeft / RE.DefaultTimer) * RE.POIIconSize)
					if RE.POINodes[poiInfo.name]["isCapturing"] == FACTION_HORDE or RE.CurrentMap == SS then
						_G[battlefieldPOIName.."TextureBG"]:SetColorTexture(1,0,0,RE.BlinkPOIValue)
					elseif RE.POINodes[poiInfo.name]["isCapturing"] == FACTION_ALLIANCE then
						_G[battlefieldPOIName.."TextureBG"]:SetColorTexture(0,0,1,RE.BlinkPOIValue)
					end
					if timeLeft <= 10 then
						_G[battlefieldPOIName.."TextureBGTop1"]:Show()
						_G[battlefieldPOIName.."TextureBGTop2"]:Show()
						_G[battlefieldPOIName.."TextureBGTop1"]:SetWidth((timeLeft / 10) * RE.POIIconSize)
						_G[battlefieldPOIName.."TextureBGTop2"]:SetWidth((timeLeft / 10) * RE.POIIconSize)
					else
						_G[battlefieldPOIName.."TextureBGTop1"]:Hide()
						_G[battlefieldPOIName.."TextureBGTop2"]:Hide()
					end
					_G[battlefieldPOIName.."Timer"]:Show()
					_G[battlefieldPOIName.."TimerCaption"]:SetText(RE:ShortTime(RE:Round(TIMER:TimeLeft(RE.POINodes[poiInfo.name]["timer"]), 0)))
				end
				battlefieldPOI:Show()
			end
		end

		if TIMER:TimeLeft(RE.EstimatorTimer) > 0 then
			if RE.IsWinning == FACTION_ALLIANCE then
				_G.REPorterFrameEstimatorText:SetText("|cFF00A9FF"..RE:ShortTime(RE:Round(TIMER:TimeLeft(RE.EstimatorTimer), 0)).."|r")
			elseif RE.IsWinning == FACTION_HORDE then
				_G.REPorterFrameEstimatorText:SetText("|cFFFF141D"..RE:ShortTime(RE:Round(TIMER:TimeLeft(RE.EstimatorTimer), 0)).."|r")
			else
				_G.REPorterFrameEstimatorText:SetText("")
			end
		elseif RE.CurrentMap == SM then
			_G.REPorterFrameEstimatorText:SetText(RE.SMEstimatorText)
		elseif RE.CurrentMap == IOC and not RE.GateSyncRequested then
			_G.REPorterFrameEstimatorText:SetText(RE.IoCGateEstimatorText)
		else
			_G.REPorterFrameEstimatorText:SetText("")
		end
		RE.UpdateTimer = RE.MapUpdateRate
	else
		RE.UpdateTimer = RE.UpdateTimer - elapsed
	end
end

function RE:UnitOnEnterPlayer(self, tooltipFrame)
	local tooltipText = ""
	local prefix = ""

	for unit in pairs(self.currentMouseOverUnits) do
		if not self:IsMouseOverUnitExcluded(unit) then
			local unitName = UnitName(unit)
			local unitHealth = (UnitHealth(unit) / UnitHealthMax(unit)) * 100
			local _, _, _, unitColor = GetClassColor(select(2, UnitClass(unit)))
			tooltipText = tooltipText..prefix.."|c"..unitColor..unitName.."|r |cFFFFFFFF["..RE:Round(unitHealth, 0).."%]|r"
			prefix = "\n"
		end
	end

	if tooltipText ~= "" then
		tooltipFrame:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
		tooltipFrame:SetText(tooltipText)
	elseif tooltipFrame:GetOwner() == self then
		tooltipFrame:ClearLines()
		tooltipFrame:Hide()
	end
end

function RE:UnitOnEnterVehicle(self)
	local tooltipText = ""
	local prefix = ""
	local vehicleGroup = {}

	for i=1, #RE.BGVehicles do
		local unitButton = RE.BGVehicles[i]
		if unitButton:IsVisible() and unitButton:IsMouseOver() then
			if RE.BGVehicles[i].name and RE.BGVehicles[i].name ~= "" then
				if vehicleGroup[RE.BGVehicles[i].name] then
					vehicleGroup[RE.BGVehicles[i].name] = vehicleGroup[RE.BGVehicles[i].name] + 1
				else
					vehicleGroup[RE.BGVehicles[i].name] = 1
				end
			end
		end
	end
	for k, _ in pairs(vehicleGroup) do
		if vehicleGroup[k] == 1 then
			tooltipText = tooltipText..prefix..k
		else
			tooltipText = tooltipText..prefix.."|cFFFFFFFF"..vehicleGroup[k].."x|r "..k
		end
		prefix = "\n"
	end

	if tooltipText ~= "" then
		_G.GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
		_G.GameTooltip:SetText(tooltipText)
		_G.GameTooltip:Show()
	elseif _G.GameTooltip:GetOwner() == self then
		_G.GameTooltip:ClearLines()
		_G.GameTooltip:Hide()
	end
end

function RE:UnitOnEnterPOI(self)
	local tooltipText = ""
	local prefix = ""
	local battlefieldPOIName = self:GetName()
	local battlefieldPOI = _G[battlefieldPOIName]

	if battlefieldPOI:IsMouseOver() and battlefieldPOI.name ~= "" then
		local status = ""
		if RE.POINodes[battlefieldPOI.name]["status"] and RE.POINodes[battlefieldPOI.name]["status"] ~= "" then
			status = "\n"..RE.POINodes[battlefieldPOI.name]["status"]
		end
		if RE.POINodes[battlefieldPOI.name]["health"] then
			if RE.GateSyncRequested then
				status = "\n[|r|cFFFF141D"..RE:Round((RE.POINodes[battlefieldPOI.name]["health"]/RE.POINodes[battlefieldPOI.name]["maxHealth"])*100, 0).."%|r|cFFFFFFFF]"
			else
				status = "\n["..RE:Round((RE.POINodes[battlefieldPOI.name]["health"]/RE.POINodes[battlefieldPOI.name]["maxHealth"])*100, 0).."%]"
			end
		end
		-- TODO poiID
		if TIMER:TimeLeft(RE.POINodes[battlefieldPOI.name]["timer"]) == 0 then
			tooltipText = tooltipText..prefix..battlefieldPOI.name.." "..RE.POINodes[battlefieldPOI.name].poiID.."|cFFFFFFFF"..status.."|r"
		else
			tooltipText = tooltipText..prefix..battlefieldPOI.name.." "..RE.POINodes[battlefieldPOI.name].poiID.."|cFFFFFFFF ["..RE:ShortTime(RE:Round(TIMER:TimeLeft(RE.POINodes[battlefieldPOI.name]["timer"]), 0)).."]"..status.."|r"
		end
		prefix = "\n"
	end

	if tooltipText ~= "" then
		_G.GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
		_G.GameTooltip:SetText(tooltipText)
		_G.GameTooltip:Show()
	elseif _G.GameTooltip:GetOwner() == self then
		_G.GameTooltip:ClearLines()
		_G.GameTooltip:Hide()
	end
end

function RE:OnClickPOI(self)
	_G.CloseDropDownMenus()
	RE.ClickedPOI = RE.POINodes[self.name]["name"]
	_G.EasyMenu(RE.POIDropDown, _G.REPorterReportDropDown, self, 0 , 0, "MENU")
end
---

-- *** Core functions
function RE:Startup()
	RE.PlayedFromStart = true
	RE.GateSyncRequested = false
	RE:Create()
	_G.REPorterFrameCoreUP:ResetCurrentMouseOverUnits()
	_G.REPorterFrame:Show()
	_G.REPorterFrameEstimator:Show()
	if RE.Settings.HideMinimap then
		_G.MinimapCluster:Hide()
	end
	SendAddonMessage("REPorter", "Version;"..RE.AddonVersionCheck, "INSTANCE_CHAT")
	if IsInGuild() then
		SendAddonMessage("REPorter", "Version;"..RE.AddonVersionCheck, "GUILD")
	end
end

function RE:Shutdown()
	_G.REPorterFrameCore:SetScript("OnUpdate", nil)
	TIMER:CancelTimer(RE.EstimatorTimer)
	RE.FlagsPool:ReleaseAll()
	RE.POINodes = {}
	RE.IsWinning = ""
	RE.IsBrawl = false
	RE.CareAboutNodes = false
	RE.CareAboutPoints = false
	RE.CareAboutGates = false
	RE.CareAboutFlags = false
	RE.TimerOverride = false
	_G.REPorterFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	_G.REPorterFrameEstimatorText:SetText("")
	_G.REPorterFrameCoreUP:ResetCurrentMouseOverUnits()
	_G.CloseDropDownMenus()
	BUCKET:UnregisterBucket(RE.PointBucket)
	if not _G.MinimapCluster:IsShown() and RE.Settings.HideMinimap then
		_G.MinimapCluster:Show()
	end
	for i=1, RE.POINumber do
		_G["REPorterFrameCorePOI"..i]:Hide()
		_G["REPorterFrameCorePOI"..i.."Timer"]:Hide()
		_G["REPorterFrameCorePOI"..i.."Texture"]:SetTexture("Interface\\Minimap\\POIIcons")
		_G["REPorterFrameCorePOI"..i.."Texture"]:SetTexCoord(0, 1, 0, 1)
		for k, _ in pairs(RE.POINodes) do
			TIMER:CancelTimer(RE.POINodes[k]["timer"])
		end
	end
	if RE.NumVehicles then
		for i=1, RE.NumVehicles do
			RE.BGVehicles[i]:Hide()
		end
	end
	for i=1, 12 do
		_G["REPorterFrameCoreMap"..i]:SetTexture(nil)
	end
end

function RE:Create()
	_G.REPorterFrameCore:SetScript("OnUpdate", nil)
	RE.IsBrawl = IsInBrawl()
	RE.POINodes = {}
	if RE.CurrentMap == IOC then
		RE.IoCGateEstimator = {}
		RE.IoCGateEstimator[FACTION_ALLIANCE] = 600000
		RE.IoCGateEstimator[FACTION_HORDE] = 600000
		RE.IoCGateEstimatorText = ""
	end
	if RE.CurrentMap == SM then
		RE.SMEstimatorText = ""
		RE.SMEstimatorReport = ""
	end
	if RE.CurrentMap == AV then
		RE.DefaultTimer = 240
	elseif RE.CurrentMap == DG then
		RE.DefaultTimer = 61
	elseif RE.CurrentMap == SS then
		RE.DefaultTimer = 30
	else
		RE.DefaultTimer = 60
	end
	if RE.CurrentMap == AV or RE.CurrentMap == BFG or RE.CurrentMap == IOC or RE.CurrentMap == AB or RE.CurrentMap == DG or RE.CurrentMap == SS or (IsRatedBattleground() and RE.CurrentMap == EOTS) then
		RE.CareAboutNodes = true
	else
		RE.CareAboutNodes = false
	end
	if RE.CurrentMap == BFG or RE.CurrentMap == EOTS or RE.CurrentMap == AB or RE.CurrentMap == DG or RE.CurrentMap == SM or RE.CurrentMap == TOK then
		RE.CareAboutPoints = true
		RE.PointBucket = BUCKET:RegisterBucketEvent({"BATTLEGROUND_POINTS_UPDATE", "UPDATE_UI_WIDGET"}, 2, RE.OnPointsUpdate)
	else
		RE.CareAboutPoints = false
	end
	if RE.CurrentMap == IOC then
		RE.CareAboutGates = true
		_G.REPorterFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	else
		RE.CareAboutGates = false
	end
	if RE.CurrentMap == WG or RE.CurrentMap == TP then
		RE.CareAboutFlags = true
		RE.PointBucket = BUCKET:RegisterBucketEvent({"BATTLEGROUND_POINTS_UPDATE", "UPDATE_UI_WIDGET"}, 2, RE.OnPointsUpdate)
	else
		RE.CareAboutFlags = false
	end
	RE:LoadMapSettings()
	RE:SetupReportBar()
	TIMER:ScheduleTimer(RE.TimerJoinCheck, 5)
	_G.REPorterFrameCore:SetScript("OnUpdate", RE.OnUpdate)
end

function RE:NodeChange(newTexture, nodeName)
	TIMER:CancelTimer(RE.POINodes[nodeName]["timer"])
	if RE.CurrentMap == AV then
		if newTexture == 9 then -- Tower Ally
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE
		elseif newTexture == 12 then -- Tower Horde
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE
		elseif newTexture == 4 then -- GY Ally
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE
		elseif newTexture == 14 then -- GY Horde
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE
		end
	elseif RE.CurrentMap == EOTS then
		if newTexture == 9 then -- Tower Ally
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE
		elseif newTexture == 12 then -- Tower Horde
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE
		end
	elseif RE.CurrentMap == BFG then
		if newTexture == 9 then -- Lighthouse Ally
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE
		elseif newTexture == 12 then -- Lighthouse Horde
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE
		elseif newTexture == 27 then -- Waterworks Ally
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE
		elseif newTexture == 29 then -- Waterworks Horde
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE
		elseif newTexture == 17 then -- Mine Ally
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE
		elseif newTexture == 19 then -- Mine Horde
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE
		end
	elseif RE.CurrentMap == IOC then
		if newTexture == 9 then -- Keep Ally
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE
		elseif newTexture == 12 then -- Keep Horde
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE
		elseif newTexture == 152 then -- Oil Ally
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE
		elseif newTexture == 154 then -- Oil Horde
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE
		elseif newTexture == 147 then -- Dock Ally
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE
		elseif newTexture == 149 then -- Dock Horde
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE
		elseif newTexture == 137 then -- Workshop Ally
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE
		elseif newTexture == 139 then -- Workshop Horde
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE
		elseif newTexture == 142 then -- Air Ally
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE
		elseif newTexture == 144 then -- Air Horde
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE
		elseif newTexture == 17 then -- Quary Ally
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE
		elseif newTexture == 19 then -- Quary Horde
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE
		end
	elseif RE.CurrentMap == AB then
		if newTexture == 32 then -- Farm Ally
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE
		elseif newTexture == 34 then -- Farm Horde
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE
		elseif newTexture == 17 then -- Mine Ally
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE
		elseif newTexture == 19 then -- Mine Horde
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE
		elseif newTexture == 37 then -- Stables Ally
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE
		elseif newTexture == 39 then -- Stables Horde
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE
		elseif newTexture == 27 then -- Blacksmith Ally
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE
		elseif newTexture == 29 then -- Blacksmith Horde
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE
		elseif newTexture == 22 then -- Lumbermill Ally
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE
		elseif newTexture == 24 then -- Lumbermill Horde
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE
		end
	elseif RE.CurrentMap == DG then
		if newTexture == 17 then -- Mine Ally
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE
		elseif newTexture == 19 then -- Mine Horde
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE
		end
	elseif RE.CurrentMap == SS then
		if newTexture == 1001 then
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = ""
		end
	end
end

function RE:POIStatus(POIName)
	if RE.POINodes[POIName]then
		if TIMER:TimeLeft(RE.POINodes[POIName]["timer"]) == 0 then
			if RE.POINodes[POIName]["health"] and not RE.GateSyncRequested then
				local gateHealth = RE:Round((RE.POINodes[POIName]["health"] / RE.POINodes[POIName]["maxHealth"]) * 100, 0)
				return " - "..HEALTH..": "..gateHealth.."%"
			end
			return ""
		else
			local timeLeft = RE:ShortTime(RE:Round(TIMER:TimeLeft(RE.POINodes[POIName]["timer"]), 0))
			return " - "..timeLeft
		end
	end
	return ""
end

function RE:POIOwner(POIName, isReport)
	local prefix = " - "
	if isReport then
		prefix = ""
	end
	if RE.POINodes[POIName] then
		if strfind(RE.POINodes[POIName]["status"], FACTION_HORDE) then
			return prefix..POIName.." ("..FACTION_HORDE..")"
		elseif strfind(RE.POINodes[POIName]["status"], FACTION_ALLIANCE) then
			return prefix..POIName.." ("..FACTION_ALLIANCE..")"
		else
			if RE.POINodes[POIName]["isCapturing"] == FACTION_HORDE and TIMER:TimeLeft(RE.POINodes[POIName]["timer"]) ~= 0 then
				return prefix..POIName.." ("..FACTION_HORDE..")"
			elseif RE.POINodes[POIName]["isCapturing"] == FACTION_ALLIANCE and TIMER:TimeLeft(RE.POINodes[POIName]["timer"]) ~= 0 then
				return prefix..POIName.." ("..FACTION_ALLIANCE..")"
			else
				return prefix..POIName
			end
		end
	end
	return prefix..POIName
end

function RE:SmallButton(number, otherNode)
	if select(2, IsInInstance()) == "pvp" then
		local name = ""
		if otherNode then
			name = RE.ClickedPOI
		elseif RE.ZonesWithoutSubZones[RE.CurrentMap] then
			name = ""
		else
			name = GetSubZoneText()
		end
		local message = ""
		if name and name ~= "" then
			if number < 6 then
				message = strupper(L["Incoming"]).." "..number
			else
				message = strupper(L["Incoming"]).." 5+"
			end
			SendChatMessage(message..RE:POIOwner(name)..RE:POIStatus(name), "INSTANCE_CHAT")
		else
			print("\124cFF74D06C[REPorter]\124r "..L["This location don't have name. Action canceled."])
		end
	else
		print("\124cFF74D06C[REPorter]\124r "..L["This addon work only on battlegrounds."])
	end
end

function RE:BigButton(isHelp, otherNode)
	if select(2, IsInInstance()) == "pvp" then
		local name = ""
		if otherNode then
			name = RE.ClickedPOI
		elseif RE.ZonesWithoutSubZones[RE.CurrentMap] then
			name = ""
		else
			name = GetSubZoneText()
		end
		if name and name ~= "" then
			if isHelp then
				SendChatMessage(strupper(HELP_LABEL)..RE:POIOwner(name)..RE:POIStatus(name), "INSTANCE_CHAT")
			else
				SendChatMessage(strupper(L["Clear"])..RE:POIOwner(name)..RE:POIStatus(name), "INSTANCE_CHAT")
			end
		else
			print("\124cFF74D06C[REPorter]\124r "..L["This location don't have name. Action canceled."])
		end
	else
		print("\124cFF74D06C[REPorter]\124r "..L["This addon work only on battlegrounds."])
	end
end

function RE:ReportEstimator()
	if TIMER:TimeLeft(RE.EstimatorTimer) > 0 then
		SendChatMessage(RE.IsWinning.." "..L["victory"]..": "..RE:ShortTime(RE:Round(TIMER:TimeLeft(RE.EstimatorTimer), 0)), "INSTANCE_CHAT")
	elseif RE.CurrentMap == SM and RE.SMEstimatorReport ~= "" then
		SendChatMessage(RE.SMEstimatorReport, "INSTANCE_CHAT")
	elseif RE.CurrentMap == IOC and not RE.GateSyncRequested then
		SendChatMessage(FACTION_ALLIANCE.." "..L["gate"]..": "..RE:Round((RE.IoCGateEstimator[FACTION_ALLIANCE] / 600000) * 100, 0).."% - "..FACTION_HORDE.." "..L["gate"]..": "..RE:Round((RE.IoCGateEstimator[FACTION_HORDE] / 600000) * 100, 0).."%", "INSTANCE_CHAT")
	end
end

function RE:ReportDropDownClick(reportType)
	if reportType ~= "" then
		SendChatMessage(strupper(reportType)..RE:POIOwner(RE.ClickedPOI)..RE:POIStatus(RE.ClickedPOI), "INSTANCE_CHAT")
	else
		SendChatMessage(RE:POIOwner(RE.ClickedPOI, true)..RE:POIStatus(RE.ClickedPOI), "INSTANCE_CHAT")
	end
end
--

-- *** Config functions
function RE:UpdateConfig()
	_G.REPorterFrame:SetAlpha(RE.Settings.Opacity)
	_G.REPorterBar:SetAlpha(0.25)
	_G.REPorterFrameBorderResize:SetShown(not RE.Settings.Locked)
	RE:SetupReportBar()
	if select(2, IsInInstance()) == "pvp" then
		_G.MinimapCluster:SetShown(not RE.Settings.HideMinimap)
	end
end

function RE:UpdateScaleConfig(_, val)
	if RE.Settings.Map[RE.CurrentMap] then
		if val then
			local scale = RE:Round(val, 2)
			_G.REPorterFrameCore:SetScale(scale)
			RE.Settings.Map[RE.CurrentMap].ms = scale
			_G.REPorterFrameCore:ClearAllPoints()
			_G.REPorterFrameCore:SetPoint("CENTER", _G.REPorterFrameCoreAnchor, "CENTER")
		end
		return RE:Round(_G.REPorterFrameCore:GetScale(), 2)
	else
		return 1.0
	end
end

function RE:SetupReportBar()
	local previousButton = "B1"
	local handle = RE.Settings.BarHandle
	local offset = 0

	if RE.ElvUI then
		if handle == 3 or handle == 6 or handle == 9 or handle == 12 then
			offset = -2
		elseif handle == 1 or handle == 4 or handle == 7 or handle == 10 then
			offset = 2
		end
	end

	_G.REPorterBar:ClearAllPoints()
	if handle < 15 and not RE.ZonesWithoutSubZones[RE.CurrentMap] then
		_G.REPorterBar:SetAlpha(0.25)
		if RE.ElvUI then
			_G.REPorterBarB1:SetPoint("TOPLEFT", "REPorterBar", "TOPLEFT", 5, -5)
		else
			_G.REPorterBarB1:SetPoint("TOPLEFT", "REPorterBar", "TOPLEFT", 10, -10)
		end
		if handle < 7 or handle == 13 then
			if handle == 13 then
				_G.REPorterBar:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", RE.Settings.BarX, RE.Settings.BarY)
			elseif handle > 3 then
				_G.REPorterBar:SetPoint(RE.ReportBarAnchor[handle][1], _G.REPorterFrameBorder, RE.ReportBarAnchor[handle][2], 1, offset)
			else
				_G.REPorterBar:SetPoint(RE.ReportBarAnchor[handle][1], _G.REPorterFrameBorder, RE.ReportBarAnchor[handle][2], -1, offset)
			end
			if RE.ElvUI then
				_G.REPorterBar:SetHeight(210)
				_G.REPorterBar:SetWidth(35)
			else
				_G.REPorterBar:SetHeight(220)
				_G.REPorterBar:SetWidth(45)
			end
			for _, i in pairs({"B2", "B3", "B4", "B5", "B6", "B7", "B8"}) do
				_G["REPorterBar"..i]:ClearAllPoints()
				_G["REPorterBar"..i]:SetPoint("TOP", "REPorterBar"..previousButton, "BOTTOM")
				previousButton = i
			end
		else
			if handle == 14 then
				_G.REPorterBar:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", RE.Settings.BarX, RE.Settings.BarY)
			elseif handle > 9 then
				_G.REPorterBar:SetPoint(RE.ReportBarAnchor[handle][1], _G.REPorterFrameBorder, RE.ReportBarAnchor[handle][2], offset, -1)
			else
				_G.REPorterBar:SetPoint(RE.ReportBarAnchor[handle][1], _G.REPorterFrameBorder, RE.ReportBarAnchor[handle][2], offset, 1)
			end
			if RE.ElvUI then
				_G.REPorterBar:SetHeight(35)
				_G.REPorterBar:SetWidth(210)
			else
				_G.REPorterBar:SetHeight(45)
				_G.REPorterBar:SetWidth(220)
			end
			for _, i in pairs({"B2", "B3", "B4", "B5", "B6", "B7", "B8"}) do
				_G["REPorterBar"..i]:ClearAllPoints()
				_G["REPorterBar"..i]:SetPoint("LEFT", "REPorterBar"..previousButton, "RIGHT")
				previousButton = i
			end
		end
		_G.REPorterBar:Show()
	else
		_G.REPorterBar:Hide()
	end
end

function RE:LoadMapSettings()
	if RE.CurrentMap ~= -1 then
		local wx, wy = RE.Settings.Map[RE.CurrentMap].wx, RE.Settings.Map[RE.CurrentMap].wy
		local ww = RE.Settings.Map[RE.CurrentMap].ww
		local wh = RE.Settings.Map[RE.CurrentMap].wh
		local mx, my = RE.Settings.Map[RE.CurrentMap].mx, RE.Settings.Map[RE.CurrentMap].my
		local ms = RE.Settings.Map[RE.CurrentMap].ms

		_G.REPorterFrame:ClearAllPoints()
		_G.REPorterFrameCore:ClearAllPoints()
		_G.REPorterFrameCoreAnchor:ClearAllPoints()
		_G.REPorterFrame:SetWidth(ww)
		_G.REPorterFrame:SetHeight(wh)
		_G.REPorterFrame:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", wx, wy)
		_G.REPorterFrameCore:SetScale(ms)
		_G.REPorterFrameCore:SetPoint("CENTER", _G.REPorterFrameCoreAnchor, "CENTER")
		_G.REPorterFrameCoreAnchor:SetPoint("CENTER", _G.REPorterFrameClip, "CENTER", mx, my)
		_G.REPorterFrame:SetAlpha(RE.Settings.Opacity)

		local textures = GetMapArtLayerTextures(RE.CurrentMap, 1)
		for i=1, #textures do
			_G["REPorterFrameCoreMap"..i]:SetTexture(textures[i])
		end
	end
end

function RE:SaveMapSettings()
	if RE.CurrentMap ~= -1 then
		local wx, wy = _G.REPorterFrame:GetCenter()
		local ww = _G.REPorterFrame:GetWidth()
		local wh = _G.REPorterFrame:GetHeight()
		local x1, y1 = _G.REPorterFrameClip:GetCenter()
		local x2, y2 = _G.REPorterFrameCoreAnchor:GetCenter()
		local mx, my = x2-x1, y2-y1
		local ms = RE:Round(_G.REPorterFrameCore:GetScale(), 2)

		RE.Settings.Map[RE.CurrentMap] = {["wx"] = RE:Round(wx, 0), ["wy"] = RE:Round(wy, 0), ["ww"] = RE:Round(ww, 0), ["wh"] = RE:Round(wh, 0), ["mx"] = RE:Round(mx, 0), ["my"] = RE:Round(my, 0), ["ms"] = RE:Round(ms, 2)}
	end
end

function RE:ShowDummyMap(mapID)
	if _G.REPorterFrame:IsShown() and RE.CurrentMap ~= -1 then
		RE:SaveMapSettings()
	end

	RE.CurrentMap = mapID
	RE:LoadMapSettings()
	RE:SetupReportBar()
	_G.REPorterFrame:Show()
	_G.InterfaceOptionsFrame:SetFrameStrata("LOW")
end

function RE:HideDummyMap()
	if _G.REPorterFrame:IsShown() and select(2, IsInInstance()) ~= "pvp" then
		RE:SaveMapSettings()
		RE.CurrentMap = -1
		RE.LastMap = 0
		_G.REPorterFrame:Hide()
		_G.REPorterBar:Hide()
		_G.InterfaceOptionsFrame:SetFrameStrata("HIGH")
	end
end
--
