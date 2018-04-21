local _G = _G
local _, RE = ...
local L = LibStub("AceLocale-3.0"):GetLocale("REPorter")
local TOAST = LibStub("LibToast-1.0")
local TIMER = LibStub("AceTimer-3.0")
_G.REPorter = RE

--GLOBALS: FACTION_ALLIANCE, FACTION_HORDE, HELP_LABEL, ATTACK, HEALTH, BLUE_GEM, RED_GEM, MAX_RAID_MEMBERS
local select, pairs, strsplit, gsub, tonumber, strfind, mod, print, ceil, strupper, next = _G.select, _G.pairs, _G.strsplit, _G.gsub, _G.tonumber, _G.strfind, _G.mod, _G.print, _G.ceil, _G.strupper, _G.next
local mfloor = _G.math.floor
local CreateFrame = _G.CreateFrame
local IsInInstance = _G.IsInInstance
local IsRatedBattleground = _G.IsRatedBattleground
local IsInGuild = _G.IsInGuild
local IsShiftKeyDown = _G.IsShiftKeyDown
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local IsInBrawl = _G.C_PvP.IsInBrawl
local GetMapNameByID = _G.GetMapNameByID
local GetScreenWidth = _G.GetScreenWidth
local GetScreenHeight = _G.GetScreenHeight
local GetNumberOfDetailTiles = _G.GetNumberOfDetailTiles
local GetMapLandmarkInfo = _G.C_WorldMap.GetMapLandmarkInfo
local GetBattlefieldInstanceRunTime = _G.GetBattlefieldInstanceRunTime
local GetMapInfo = _G.GetMapInfo
local SetMapToCurrentZone = _G.SetMapToCurrentZone
local GetWorldStateUIInfo = _G.GetWorldStateUIInfo
local GetNumBattlefieldFlagPositions = _G.GetNumBattlefieldFlagPositions
local GetBattlefieldFlagPosition = _G.GetBattlefieldFlagPosition
local GetSubZoneText = _G.GetSubZoneText
local GetClassColor = _G.GetClassColor
local GetRaidTargetIndex = _G.GetRaidTargetIndex
local GetNumBattlefieldVehicles = _G.GetNumBattlefieldVehicles
local GetBattlefieldVehicleInfo = _G.GetBattlefieldVehicleInfo
local GetNumMapLandmarks = _G.GetNumMapLandmarks
local GetNumMapOverlays = _G.GetNumMapOverlays
local GetMapOverlayInfo = _G.GetMapOverlayInfo
local GetPOITextureCoords = _G.GetPOITextureCoords
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
local SendAddonMessage = _G.SendAddonMessage
local SetMapTooltipPosition = _G.SetMapTooltipPosition
local WorldMap_GetVehicleTexture = _G.WorldMap_GetVehicleTexture
local RegisterAddonMessagePrefix = _G.RegisterAddonMessagePrefix

RE.POIIconSize = 30
RE.POINumber = 25
RE.MapUpdateRate = 0.05
RE.BGOverlayNum = 0
RE.LastMap = 0
RE.NeedRefresh = false
RE.BGVehicles = {}
RE.POINodes = {}
RE.PinTextures = {}
RE.CurrentMap = ""
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
RE.AddonVersionCheck = 200

RE.MapNames = {
	[GetMapNameByID(401)] = "AlteracValley",
	[GetMapNameByID(461)] = "ArathiBasin",
	[GetMapNameByID(935)] = "GoldRush",
	[GetMapNameByID(482)] = "NetherstormArena",
	[GetMapNameByID(540)] = "IsleofConquest",
	[GetMapNameByID(860)] = "STVDiamondMineBG",
	[GetMapNameByID(512)] = "StrandoftheAncients",
	[GetMapNameByID(856)] = "TempleofKotmogu",
	[GetMapNameByID(736)] = "GilneasBattleground2",
	[GetMapNameByID(626)] = "TwinPeaks",
	[GetMapNameByID(443)] = "WarsongGulch",
	[GetMapNameByID(1010)] = "HillsbradFoothillsBG",
	[GetMapNameByID(1186)] = "AzeriteBG"
}
RE.MapSettings = {
	["ArathiBasin"] = {["PointsToWin"] = 1500, ["WorldStateNum"] = 1, ["StartTimer"] = 120},
	["WarsongGulch"] = {["StartTimer"] = 120},
	["AlteracValley"] = {["StartTimer"] = 120},
	["NetherstormArena"] = {["PointsToWin"] = 1500, ["WorldStateNum"] = 2, ["StartTimer"] = 120},
	["StrandoftheAncients"] = {["StartTimer"] = 120},
	["IsleofConquest"] = {["StartTimer"] = 120},
	["GilneasBattleground2"] = {["PointsToWin"] = 1500, ["WorldStateNum"] = 1, ["StartTimer"] = 120},
	["TwinPeaks"] = {["StartTimer"] = 120},
	["TempleofKotmogu"] = {["PointsToWin"] = 1500, ["WorldStateNum"] = 1, ["StartTimer"] = 120},
	["STVDiamondMineBG"] = {["PointsToWin"] = 1500, ["WorldStateNum"] = 1, ["StartTimer"] = 120},
	["GoldRush"] = {["PointsToWin"] = 1500, ["WorldStateNum"] = 1, ["StartTimer"] = 120},
	["HillsbradFoothillsBG"] = {["VE"] = 80, ["StartTimer"] = 120},
	["AzeriteBG"] = {["StartTimer"] = 120}
}
RE.EstimatorSettings = {
	["ArathiBasin"] = { [0] = 0, [1] = 10/12, [2] = 10/9, [3] = 10/6, [4] = 10/3, [5] = 30},
	["NetherstormArena"] = { [0] = 0, [1] = 1, [2] = 2, [3] = 5, [4] = 10},
	["GilneasBattleground2"] = { [0] = 0, [1] = 10/9, [2] = 10/3, [3] = 30},
	["GoldRush"] = { [0] = 0, [1] = 1.6, [2] = 3.2, [3] = 6.4},
	["TempleofKotmogu"] = {["CenterP"] = 1, ["InnerP"] = 0.8, ["OuterP"] = 0.6},
	["STVDiamondMineBG"] = 150
}
RE.ZonesWithoutSubZones = {
	["GoldRush"] = true,
	["STVDiamondMineBG"] = true,
	["TempleofKotmogu"] = true,
	["HillsbradFoothillsBG"] = true
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
		{ text = "1", notCheckable = true, minWidth = 15, func = function() RE:SmallButton(1, true); _G.L_CloseDropDownMenus() end },
		{ text = "2", notCheckable = true, minWidth = 15, func = function() RE:SmallButton(2, true); _G.L_CloseDropDownMenus() end },
		{ text = "3", notCheckable = true, minWidth = 15, func = function() RE:SmallButton(3, true); _G.L_CloseDropDownMenus() end },
		{ text = "4", notCheckable = true, minWidth = 15, func = function() RE:SmallButton(4, true); _G.L_CloseDropDownMenus() end },
		{ text = "5", notCheckable = true, minWidth = 15, func = function() RE:SmallButton(5, true); _G.L_CloseDropDownMenus() end },
		{ text = "5+", notCheckable = true, minWidth = 15, func = function() RE:SmallButton(6, true); _G.L_CloseDropDownMenus() end }
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
	BarX = 250,
	BarY = 250,
	Locked = false,
	Opacity = 0.80,
	HideMinimap = false,
	DisplayMarks = false,
	Map = {
		["ArathiBasin"] = {["wx"] = 250, ["wy"] = 250, ["ww"] = 250, ["wh"] = 250, ["mx"] = 0, ["my"] = 0, ["ms"] = 1},
		["WarsongGulch"] = {["wx"] = 250, ["wy"] = 250, ["ww"] = 250, ["wh"] = 250, ["mx"] = 0, ["my"] = 0, ["ms"] = 1},
		["AlteracValley"] = {["wx"] = 250, ["wy"] = 250, ["ww"] = 250, ["wh"] = 250, ["mx"] = 0, ["my"] = 0, ["ms"] = 1},
		["NetherstormArena"] = {["wx"] = 250, ["wy"] = 250, ["ww"] = 250, ["wh"] = 250, ["mx"] = 0, ["my"] = 0, ["ms"] = 1},
		["StrandoftheAncients"] = {["wx"] = 250, ["wy"] = 250, ["ww"] = 250, ["wh"] = 250, ["mx"] = 0, ["my"] = 0, ["ms"] = 1},
		["IsleofConquest"] = {["wx"] = 250, ["wy"] = 250, ["ww"] = 250, ["wh"] = 250, ["mx"] = 0, ["my"] = 0, ["ms"] = 1},
		["GilneasBattleground2"] = {["wx"] = 250, ["wy"] = 250, ["ww"] = 250, ["wh"] = 250, ["mx"] = 0, ["my"] = 0, ["ms"] = 1},
		["TwinPeaks"] = {["wx"] = 250, ["wy"] = 250, ["ww"] = 250, ["wh"] = 250, ["mx"] = 0, ["my"] = 0, ["ms"] = 1},
		["TempleofKotmogu"] = {["wx"] = 250, ["wy"] = 250, ["ww"] = 250, ["wh"] = 250, ["mx"] = 0, ["my"] = 0, ["ms"] = 1},
		["STVDiamondMineBG"] = {["wx"] = 250, ["wy"] = 250, ["ww"] = 250, ["wh"] = 250, ["mx"] = 0, ["my"] = 0, ["ms"] = 1},
		["GoldRush"] = {["wx"] = 250, ["wy"] = 250, ["ww"] = 250, ["wh"] = 250, ["mx"] = 0, ["my"] = 0, ["ms"] = 1},
		["HillsbradFoothillsBG"] = {["wx"] = 250, ["wy"] = 250, ["ww"] = 250, ["wh"] = 250, ["mx"] = 0, ["my"] = 0, ["ms"] = 1},
		["AzeriteBG"] = {["wx"] = 250, ["wy"] = 250, ["ww"] = 250, ["wh"] = 250, ["mx"] = 0, ["my"] = 0, ["ms"] = 1}
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
			name = L["When the lock is disabled map can be moved by dragging.\nMap frame can be resized by using holder at the bottom right corner.\nHold SHIFT to move map inside the frame.\nScroll wheel control map zoom."],
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
				[401] = GetMapNameByID(401),
				[461] = GetMapNameByID(461),
				[935] = GetMapNameByID(935),
				[482] = GetMapNameByID(482),
				[540] = GetMapNameByID(540),
				[860] = GetMapNameByID(860),
				[512] = GetMapNameByID(512),
				[856] = GetMapNameByID(856),
				[736] = GetMapNameByID(736),
				[626] = GetMapNameByID(626),
				[443] = GetMapNameByID(443),
				[1010] = GetMapNameByID(1010),
				[1186] = GetMapNameByID(1186)
			},
			set = function(_, val) RE.LastMap = val; RE:ShowDummyMap(RE.MapNames[GetMapNameByID(val)]) end,
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

function RE:SOTAStartCheck()
	local startCheck = {GetMapLandmarkInfo(7)}
	local sideCheck = {GetMapLandmarkInfo(10)}
	return (startCheck[4] == 46 or startCheck[4] == 48), sideCheck[4] == 102
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

function RE:EstimatorFill(ATimeToWin, HTimeToWin, RefreshTimer, APointNum, HPointNum)
	local APointNum = APointNum or 0
	local HPointNum = HPointNum or 0
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
	elseif APointNum >= RE.MapSettings[RE.CurrentMap]["PointsToWin"] or HPointNum >= RE.MapSettings[RE.CurrentMap]["PointsToWin"] then
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
	if RE.CurrentMap ~= "" and BGTime > RE.MapSettings[RE.CurrentMap]["StartTimer"] then
		RE.PlayedFromStart = false
		if RE.CurrentMap == "StrandoftheAncients" or RE.CurrentMap == "IsleofConquest" then
			RE.GateSyncRequested = true
			SendAddonMessage("REPorter", "GateSyncRequest;", "INSTANCE_CHAT")
		end
	end
end

function RE:TimerBarHider()
	_G.REPorterBar:SetAlpha(0.25)
end

function RE:TimerDropDownHider()
	_G.L_CloseDropDownMenus()
end

function RE:HideTooltip()
	_G.GameTooltip:Hide()
end

function RE:GetMapInfo()
	local map = GetMapInfo()
	if map == "ArathiBasinWinter" then
		return "ArathiBasin"
	else
		return map
	end
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

function RE:OnEvent(_, event, ...)
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
	elseif event == "UPDATE_WORLD_STATES" and RE.MapSettings[RE.CurrentMap] and select(2, IsInInstance()) == "pvp" then
		if RE.CurrentMap == "TempleofKotmogu" then
			local AlliancePointsNeeded, AlliancePointsPerSec, AllianceTimeToWin, HordePointsNeeded, HordePointsPerSec, HordeTimeToWin = nil, 0, 0, nil, 0, 0
			local _, _, _, text = GetWorldStateUIInfo(RE.MapSettings["TempleofKotmogu"]["WorldStateNum"])
			if text ~= nil then
				local score = {strsplit("/", text)}
				if score[1] then
					score[1] = gsub(score[1], "：", " ")
					score = {strsplit(" ", score[1])}
					AlliancePointsNeeded = RE.MapSettings["TempleofKotmogu"]["PointsToWin"] - tonumber(score[#score])
				end
			end
			local _, _, _, text = GetWorldStateUIInfo(RE.MapSettings["TempleofKotmogu"]["WorldStateNum"]+1)
			if text ~= nil then
				local score = {strsplit("/", text)}
				if score[1] then
					score[1] = gsub(score[1], "：", " ")
					score = {strsplit(" ", score[1])}
					HordePointsNeeded = RE.MapSettings["TempleofKotmogu"]["PointsToWin"] - tonumber(score[#score])
				end
			end
			if AlliancePointsNeeded and HordePointsNeeded then
				local numFlags = GetNumBattlefieldFlagPositions()
				for i=1, 4 do
					if i <= numFlags then
						local flagX, flagY, flagToken = GetBattlefieldFlagPosition(i)
						if flagX > 0 and flagY > 0 then
							flagX, flagY = RE:GetRealCoords(flagX, flagY)
							if flagToken == "AllianceFlag" then
								if flagX < 420 and flagX > 350 and flagY < -255 and flagY > -305 then
									AlliancePointsPerSec = AlliancePointsPerSec + RE.EstimatorSettings["TempleofKotmogu"]["CenterP"]
								elseif flagX < 470 and flagX > 300 and flagY < -210 and flagY > -350 then
									AlliancePointsPerSec = AlliancePointsPerSec + RE.EstimatorSettings["TempleofKotmogu"]["InnerP"]
								else
									AlliancePointsPerSec = AlliancePointsPerSec + RE.EstimatorSettings["TempleofKotmogu"]["OuterP"]
								end
							else
								if flagX < 420 and flagX > 350 and flagY < -255 and flagY > -305 then
									HordePointsPerSec = HordePointsPerSec + RE.EstimatorSettings["TempleofKotmogu"]["CenterP"]
								elseif flagX < 470 and flagX > 300 and flagY < -210 and flagY > -350 then
									HordePointsPerSec = HordePointsPerSec + RE.EstimatorSettings["TempleofKotmogu"]["InnerP"]
								else
									HordePointsPerSec = HordePointsPerSec + RE.EstimatorSettings["TempleofKotmogu"]["OuterP"]
								end
							end
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
		elseif RE.CurrentMap == "STVDiamondMineBG" then
			local AlliancePointsNeeded, AllianceCartsNeeded, HordePointsNeeded, HordeCartsNeeded = nil, 10, nil, 10
			local _, _, _, text = GetWorldStateUIInfo(RE.MapSettings["STVDiamondMineBG"]["WorldStateNum"])
			if text ~= nil then
				local score = {strsplit("/", text)}
				if score[1] then
					score[1] = gsub(score[1], "：", " ")
					score = {strsplit(" ", score[1])}
					AlliancePointsNeeded = RE.MapSettings["STVDiamondMineBG"]["PointsToWin"] - tonumber(score[#score])
				end
			end
			local _, _, _, text = GetWorldStateUIInfo(RE.MapSettings["STVDiamondMineBG"]["WorldStateNum"]+1)
			if text ~= nil then
				local score = {strsplit("/", text)}
				if score[1] then
					score[1] = gsub(score[1], "：", " ")
					score = {strsplit(" ", score[1])}
					HordePointsNeeded = RE.MapSettings["STVDiamondMineBG"]["PointsToWin"] - tonumber(score[#score])
				end
			end
			if AlliancePointsNeeded and HordePointsNeeded then
				AllianceCartsNeeded = AlliancePointsNeeded / RE.EstimatorSettings["STVDiamondMineBG"]
				HordeCartsNeeded = HordePointsNeeded / RE.EstimatorSettings["STVDiamondMineBG"]
				RE.SMEstimatorText = "|cFF00A9FF"..RE:Round(AllianceCartsNeeded, 1).."|r\n|cFFFF141D"..RE:Round(HordeCartsNeeded, 1).."|r"
				RE.SMEstimatorReport = FACTION_ALLIANCE.." "..L["victory"]..": "..RE:Round(AllianceCartsNeeded, 1).." "..L["carts"].." - "..FACTION_HORDE.." "..L["victory"]..": "..RE:Round(HordeCartsNeeded, 1).." "..L["carts"]
			end
		else
			local WorldStateId = RE.MapSettings[RE.CurrentMap]["WorldStateNum"]
			-- Rated EotS hack
			if IsRatedBattleground() and RE.CurrentMap == "NetherstormArena" then
				WorldStateId = 1
			end
			local AllianceBaseNum, AlliancePointNum, HordeBaseNum, HordePointNum, AllianceTimeToWin, HordeTimeToWin = 0, nil, 0, nil, 0, 0
			local _, _, _, text = GetWorldStateUIInfo(WorldStateId)
			if text ~= nil then
				local score = {strsplit("/", text)}
				if score[2] then
					score[1] = gsub(score[1], "：", " ")
					local data = {strsplit(" ", score[1])}
					AlliancePointNum = tonumber(data[#data])
					for i=1, #data do
						if tonumber(data[i]) ~= nil then
							AllianceBaseNum = tonumber(data[i])
							break
						end
					end
				end
			end
			_, _, _, text = GetWorldStateUIInfo(WorldStateId+1)
			if text ~= nil then
				local score = {strsplit("/", text)}
				if score[2] then
					score[1] = gsub(score[1], "：", " ")
					local data = {strsplit(" ", score[1])}
					HordePointNum = tonumber(data[#data])
					for i=1, #data do
						if tonumber(data[i]) ~= nil then
							HordeBaseNum = tonumber(data[i])
							break
						end
					end
				end
			end
			if AlliancePointNum and HordePointNum and AllianceBaseNum and HordeBaseNum then
				if RE.EstimatorSettings[RE.CurrentMap][AllianceBaseNum] == 0 then
					AllianceTimeToWin = 10000
				else
					AllianceTimeToWin = (RE.MapSettings[RE.CurrentMap]["PointsToWin"] - AlliancePointNum) / RE.EstimatorSettings[RE.CurrentMap][AllianceBaseNum]
				end
				if RE.EstimatorSettings[RE.CurrentMap][HordeBaseNum] == 0 then
					HordeTimeToWin = 10000
				else
					HordeTimeToWin = (RE.MapSettings[RE.CurrentMap]["PointsToWin"] - HordePointNum) / RE.EstimatorSettings[RE.CurrentMap][HordeBaseNum]
				end
				RE:EstimatorFill(AllianceTimeToWin, HordeTimeToWin, 5, AlliancePointNum, HordePointNum)
			end
		end
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and select(2, ...) == "SPELL_BUILDING_DAMAGE" and next(RE.POINodes) ~= nil then
		local guid, gateName, _, _, _, _, _, damage = select(8, ...)
		if RE.CurrentMap ~= "IsleofConquest" then
			RE.POINodes[gateName]["health"] = RE.POINodes[gateName]["health"] - damage
		else
			local gateID = {strsplit("-", guid)}
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
		end
	elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
		if RE.CurrentMap ~= "" then
			RE:SaveMapSettings()
		end
		_G.REPorterFrame:Hide()
		_G.REPorterBar:Hide()
		_G.REPorterFrameEstimator:Hide()
		if select(2, IsInInstance()) == "pvp" and RE.CurrentMap == "" then
			SetMapToCurrentZone()
			local mapFileName = RE:GetMapInfo()
			if mapFileName and RE.MapSettings[mapFileName] then
				RE.CurrentMap = mapFileName
				RE:Startup()
			end
		elseif select(2, IsInInstance()) ~= "pvp" and RE.CurrentMap ~= "" then
			RE.CurrentMap = ""
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
	elseif event == "BATTLEGROUND_POINTS_UPDATE" then
		RE:CreateTimer(12)
	elseif event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" then
		-- SotA hack
		RE.NeedRefresh = true
		RE:Create(true)
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
		_G.REPorterFrameCoreUP:AddUnit("player", "Interface\\Minimap\\MinimapArrow", 50, 50, 1, 1, 1, 1, 7, true)
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
							_G.REPorterFrameCoreUP:AddUnit(unit, texture, 25, 25, 1, 1, 1, 1)
						elseif UnitGroupRolesAssigned(unit) == "HEALER" then
							texture = "Interface\\Addons\\REPorter\\Textures\\BlipHealer"
							_G.REPorterFrameCoreUP:AddUnit(unit, texture, 30, 30, r, g, b, 1)
						end
					else
						RE.IsOverlay = false
						if RE.Settings.DisplayMarks and raidMarker ~= nil then
							texture = "Interface\\Addons\\REPorter\\Textures\\RaidMarker"..raidMarker
							_G.REPorterFrameCoreUP:AddUnit(unit, texture, 25, 25, 1, 1, 1, 1)
						else
							_G.REPorterFrameCoreUP:AddUnit(unit, texture, 25, 25, r, g, b, 1)
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

		local numFlags = GetNumBattlefieldFlagPositions()
		for i=1, 4 do
			local flagFrame = _G["REPorterFrameCorePOIFlag"..i]
			if i <= numFlags and (RE.CurrentMap ~= "GoldRush" or RE.IsBrawl) then
				local flagX, flagY, flagToken = GetBattlefieldFlagPosition(i)
				if flagX == 0 and flagY == 0 then
					flagFrame:Hide()
				else
					flagX, flagY = RE:GetRealCoords(flagX, flagY)
					flagFrame.Texture:SetTexture("Interface\\WorldStateFrame\\"..flagToken)
					flagFrame:SetPoint("CENTER", "REPorterFrameCorePOI", "TOPLEFT", flagX, flagY)
					flagFrame:EnableMouse(false)
					flagFrame:SetFrameLevel(playerBlipFrameLevel - 1)
					flagFrame:Show()
				end
			else
				flagFrame:Hide()
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
			if RE.CurrentMap == "IsleofConquest" then
				RE.BGVehicles[i]:EnableMouse(true)
				RE.BGVehicles[i]:SetScript("OnEnter", function(self) RE:UnitOnEnterVehicle(self) end)
				RE.BGVehicles[i]:SetScript("OnLeave", RE.HideTooltip)
			else
				RE.BGVehicles[i]:EnableMouse(false)
				RE.BGVehicles[i]:SetScript("OnEnter", nil)
				RE.BGVehicles[i]:SetScript("OnLeave", nil)
			end
			local vehicleX, vehicleY, unitName, isPossessed, vehicleType, orientation, isPlayer = GetBattlefieldVehicleInfo(i)
			if vehicleX and not isPlayer and vehicleType ~= "Idle" then
				vehicleX, vehicleY = RE:GetRealCoords(vehicleX, vehicleY)
				RE.BGVehicles[i].texture:SetTexture(WorldMap_GetVehicleTexture(vehicleType, isPossessed))
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
		for i=1, GetNumMapLandmarks() do
			local battlefieldPOIName = "REPorterFrameCorePOI"..i
			local battlefieldPOI = _G[battlefieldPOIName]
			local _, name, description, textureIndex, x, y, _, showInBattleMap, _, _, poiID, _, atlasID = GetMapLandmarkInfo(i)
			local colorOverride = false
			if RE.CurrentMap == "AzeriteBG" and atlasID and not showInBattleMap then
				local xZ, yZ = RE:Round(x, 3), RE:Round(y, 3)
				if RE.AzeriteNodes[xZ] and RE.AzeriteNodes[xZ][yZ] then
					name = RE.AzeriteNodes[xZ][yZ]
				end
				if atlasID == "AzeriteReady" then
					textureIndex = 1002
				elseif atlasID == "AzeriteSpawning" then
					textureIndex = 1001
				end
				showInBattleMap = true
				description = ""
			end
			if name and showInBattleMap and textureIndex ~= nil and textureIndex ~= 0 then
				x, y = RE:GetRealCoords(x, y)
				local x1, x2, y1, y2 = GetPOITextureCoords(textureIndex)
				if RE.CurrentMap == "IsleofConquest" then
					if i == 9 then
						RE.IoCAllianceGateName = name
						name = name.." - "..L["East"]
						x = x + 15
					elseif i == 10 then
						name = name.." - "..L["West"]
						x = x - 13
					elseif i == 11 then
						name = name.." - "..L["Front"]
						y = y + 15
					elseif i == 6 then
						RE.IoCHordeGateName = name
						name = name.." - "..L["Front"]
						y = y - 15
					elseif i == 7 then
						name = name.." - "..L["East"]
						x = x + 10
					elseif i == 8 then
						name = name.." - "..L["West"]
						x = x - 10
						y = y - 1
					end
				elseif RE.CurrentMap == "AlteracValley" then
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
				elseif RE.CurrentMap == "TempleofKotmogu" then
					if poiID == 2774 then
						name = name.." - "..BLUE_GEM
						colorOverride = {0, 0, 1}
					elseif poiID == 2775 then
						name = name.." - "..L["Purple"]
						colorOverride = {0.5, 0, 0.5}
					elseif poiID == 2776 then
						name = name.." - "..RED_GEM
						colorOverride = {1, 0, 0}
					elseif poiID == 2777 then
						name = name.." - "..L["Green"]
						colorOverride = {0, 1, 0}
					end
				end
				if RE.POINodes[name] == nil then
					RE.POINodes[name] = {["id"] = i, ["name"] = name, ["status"] = description, ["x"] = x, ["y"] = y, ["texture"] = textureIndex}
					if RE.CurrentMap == "IsleofConquest" then
						if i == 6 or i == 7 or i == 8 or i == 9 or i == 10 or i == 11 then
							RE.POINodes[name]["health"] = 600000
							RE.POINodes[name]["maxHealth"] = 600000
						end
					elseif RE.CurrentMap == "StrandoftheAncients" then
						local isStarted, isAlliance = RE:SOTAStartCheck()
						if isStarted then
							if isAlliance then
								if i == 3 or i == 4 then
									RE.POINodes[name]["health"] = 11000
									RE.POINodes[name]["maxHealth"] = 11000
								elseif i == 1 or i == 2 then
									RE.POINodes[name]["health"] = 13000
									RE.POINodes[name]["maxHealth"] = 13000
								elseif i == 10 then
									RE.POINodes[name]["health"] = 14000
									RE.POINodes[name]["maxHealth"] = 14000
								elseif i == 11 then
									RE.POINodes[name]["health"] = 10000
									RE.POINodes[name]["maxHealth"] = 10000
								end
							else
								if i == 3 or i == 4 then
									RE.POINodes[name]["health"] = 11000
									RE.POINodes[name]["maxHealth"] = 11000
								elseif i == 1 or i == 2 then
									RE.POINodes[name]["health"] = 13000
									RE.POINodes[name]["maxHealth"] = 13000
								elseif i == 11 then
									RE.POINodes[name]["health"] = 14000
									RE.POINodes[name]["maxHealth"] = 14000
								elseif i == 12 then
									RE.POINodes[name]["health"] = 10000
									RE.POINodes[name]["maxHealth"] = 10000
								end
							end
						end
					elseif RE.CurrentMap == "AzeriteBG" and RE.PlayedFromStart then
						RE:NodeChange(textureIndex, name)
					end
				else
					RE.POINodes[name]["id"] = i
					RE.POINodes[name]["name"] = name
					RE.POINodes[name]["status"] = description
					RE.POINodes[name]["x"] = x
					RE.POINodes[name]["y"] = y
					if RE.CareAboutNodes and RE.POINodes[name]["texture"] and RE.POINodes[name]["texture"] ~= textureIndex then
						RE:NodeChange(textureIndex, name)
					end
					RE.POINodes[name]["texture"] = textureIndex
				end
				battlefieldPOI.name = name
				battlefieldPOI:SetPoint("CENTER", "REPorterFrameCorePOI", "TOPLEFT", x, y)
				battlefieldPOI:SetWidth(RE.POIIconSize)
				battlefieldPOI:SetHeight(RE.POIIconSize)
				if textureIndex > 1000 then
					_G[battlefieldPOIName.."Texture"]:SetAtlas(atlasID)
				else
					_G[battlefieldPOIName.."Texture"]:SetTexCoord(x1, x2, y1, y2)
				end
				if colorOverride then
					_G[battlefieldPOIName.."Texture"]:SetVertexColor(colorOverride[1], colorOverride[2], colorOverride[3], 1)
				else
					_G[battlefieldPOIName.."Texture"]:SetVertexColor(1, 1, 1, 1)
				end
				if TIMER:TimeLeft(RE.POINodes[name]["timer"]) == 0 then
					if strfind(description, FACTION_HORDE) then
						_G[battlefieldPOIName.."TextureBG"]:SetColorTexture(1,0,0,0.3)
					elseif strfind(description, FACTION_ALLIANCE) then
						_G[battlefieldPOIName.."TextureBG"]:SetColorTexture(0,0,1,0.3)
					else
						if RE.CurrentMap == "AzeriteBG" then
							_G[battlefieldPOIName.."TextureBG"]:SetColorTexture(0,1,0,0.3)
						else
							_G[battlefieldPOIName.."TextureBG"]:SetColorTexture(0,0,0,0.3)
						end
					end
					_G[battlefieldPOIName.."TextureBG"]:SetWidth(RE.POIIconSize)
					_G[battlefieldPOIName.."TextureBGofBG"]:Hide()
					if RE.CareAboutGates and RE.POINodes[name]["health"] and RE.POINodes[name]["health"] ~= 0 and textureIndex ~= 76 and textureIndex ~= 79 and textureIndex ~= 82 and textureIndex ~= 104 and textureIndex ~= 107 and textureIndex ~= 110 then
						_G[battlefieldPOIName.."TextureBGTop1"]:Hide()
						_G[battlefieldPOIName.."TextureBGTop2"]:Show()
						_G[battlefieldPOIName.."TextureBGTop2"]:SetWidth((RE.POINodes[name]["health"]/RE.POINodes[name]["maxHealth"]) * RE.POIIconSize)
						if RE.GateSyncRequested then
							_G[battlefieldPOIName.."TimerCaption"]:SetText("|cFFFF141D"..RE:Round((RE.POINodes[name]["health"]/RE.POINodes[name]["maxHealth"])*100, 0).."%|r")
						else
							_G[battlefieldPOIName.."TimerCaption"]:SetText(RE:Round((RE.POINodes[name]["health"]/RE.POINodes[name]["maxHealth"])*100, 0).."%")
						end
						_G[battlefieldPOIName.."Timer"]:Show()
					else
						_G[battlefieldPOIName.."TextureBGTop1"]:Hide()
						_G[battlefieldPOIName.."TextureBGTop2"]:Hide()
						_G[battlefieldPOIName.."Timer"]:Hide()
					end
				else
					local timeLeft = TIMER:TimeLeft(RE.POINodes[name]["timer"])
					_G[battlefieldPOIName.."TextureBG"]:SetWidth(RE.POIIconSize - ((timeLeft / RE.DefaultTimer) * RE.POIIconSize))
					_G[battlefieldPOIName.."TextureBGofBG"]:Show()
					_G[battlefieldPOIName.."TextureBGofBG"]:SetWidth((timeLeft / RE.DefaultTimer) * RE.POIIconSize)
					if RE.POINodes[name]["isCapturing"] == FACTION_HORDE or RE.CurrentMap == "AzeriteBG" then
						_G[battlefieldPOIName.."TextureBG"]:SetColorTexture(1,0,0,RE.BlinkPOIValue)
					elseif RE.POINodes[name]["isCapturing"] == FACTION_ALLIANCE then
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
					_G[battlefieldPOIName.."TimerCaption"]:SetText(RE:ShortTime(RE:Round(TIMER:TimeLeft(RE.POINodes[name]["timer"]), 0)))
				end
				battlefieldPOI:Show()
			end
		end

		if RE.CurrentMap == "STVDiamondMineBG" then
			local textureCount = 0
			local scale = 0.78
			for i=1, GetNumMapOverlays() do
				local textureName, textureWidth, textureHeight, offsetX, offsetY = GetMapOverlayInfo(i)
				if textureName ~= "" or textureWidth == 0 or textureHeight == 0 then
					local numTexturesWide = ceil(textureWidth / 256)
					local numTexturesTall = ceil(textureHeight / 256)
					local neededTextures = textureCount + (numTexturesWide * numTexturesTall)
					if neededTextures > RE.BGOverlayNum then
						for j=RE.BGOverlayNum + 1, neededTextures do
							_G.REPorterFrameCore:CreateTexture("REPorterFrameCoreMapOverlay"..j, "ARTWORK")
						end
						RE.BGOverlayNum = neededTextures
					end
					local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight
					for j=1, numTexturesTall do
						if j < numTexturesTall then
							texturePixelHeight = 256
							textureFileHeight = 256
						else
							texturePixelHeight = mod(textureHeight, 256)
							if texturePixelHeight == 0 then
								texturePixelHeight = 256
							end
							textureFileHeight = 16
							while textureFileHeight < texturePixelHeight do
								textureFileHeight = textureFileHeight * 2
							end
						end
						for k=1, numTexturesWide do
							textureCount = textureCount + 1
							local texture = _G["REPorterFrameCoreMapOverlay"..textureCount]
							if k < numTexturesWide then
								texturePixelWidth = 256
								textureFileWidth = 256
							else
								texturePixelWidth = mod(textureWidth, 256)
								if texturePixelWidth == 0 then
									texturePixelWidth = 256
								end
								textureFileWidth = 16
								while textureFileWidth < texturePixelWidth do
									textureFileWidth = textureFileWidth * 2
								end
							end
							texture:SetWidth(texturePixelWidth * scale)
							texture:SetHeight(texturePixelHeight * scale)
							texture:SetTexCoord(0, texturePixelWidth / textureFileWidth, 0, texturePixelHeight / textureFileHeight)
							texture:SetPoint("TOPLEFT", "REPorterFrameCore", "TOPLEFT", (offsetX + (256 * (k - 1))) * scale, -((offsetY + (256 * (j - 1))) * scale))
							texture:SetTexture(textureName..(((j - 1) * numTexturesWide) + k))
							texture:SetAlpha(RE.Settings.Opacity)
							texture:Show()
						end
					end
				end
			end
			for i=textureCount + 1, RE.BGOverlayNum do
				_G["REPorterFrameCoreMapOverlay"..i]:Hide()
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
		elseif RE.CurrentMap == "STVDiamondMineBG" then
			_G.REPorterFrameEstimatorText:SetText(RE.SMEstimatorText)
		elseif RE.CurrentMap == "IsleofConquest" and not RE.GateSyncRequested then
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
		SetMapTooltipPosition(tooltipFrame, self, true)
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
		SetMapTooltipPosition(_G.GameTooltip, self, true)
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
		if TIMER:TimeLeft(RE.POINodes[battlefieldPOI.name]["timer"]) == 0 then
			tooltipText = tooltipText..prefix..battlefieldPOI.name.."|cFFFFFFFF"..status.."|r"
		else
			tooltipText = tooltipText..prefix..battlefieldPOI.name.."|cFFFFFFFF ["..RE:ShortTime(RE:Round(TIMER:TimeLeft(RE.POINodes[battlefieldPOI.name]["timer"]), 0)).."]"..status.."|r"
		end
		prefix = "\n"
	end

	if tooltipText ~= "" then
		SetMapTooltipPosition(_G.GameTooltip, self, true)
		_G.GameTooltip:SetText(tooltipText)
		_G.GameTooltip:Show()
	elseif _G.GameTooltip:GetOwner() == self then
		_G.GameTooltip:ClearLines()
		_G.GameTooltip:Hide()
	end
end

function RE:OnClickPOI(self)
	_G.L_CloseDropDownMenus()
	RE.ClickedPOI = RE.POINodes[self.name]["name"]
	_G.L_EasyMenu(RE.POIDropDown, _G.REPorterReportDropDown, self, 0 , 0, "MENU")
end
---

-- *** Core functions
function RE:Startup()
	RE.PlayedFromStart = true
	RE.GateSyncRequested = false
	RE:Create(false)
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
	RE.POINodes = {}
	RE.IsWinning = ""
	RE.IsBrawl = false
	RE.CareAboutNodes = false
	RE.CareAboutPoints = false
	RE.CareAboutGates = false
	RE.CareAboutFlags = false
	RE.TimerOverride = false
	_G.REPorterFrame:UnregisterEvent("UPDATE_WORLD_STATES")
	_G.REPorterFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	_G.REPorterFrame:UnregisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
	_G.REPorterFrame:UnregisterEvent("BATTLEGROUND_POINTS_UPDATE")
	_G.REPorterFrameEstimatorText:SetText("")
	_G.L_CloseDropDownMenus()
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
	for i=1, 4 do
		local flagFrame = _G["REPorterFrameCorePOIFlag"..i]
		flagFrame:Hide()
	end
	if RE.NumVehicles then
		for i=1, RE.NumVehicles do
			RE.BGVehicles[i]:Hide()
		end
	end
	local numDetailTiles = GetNumberOfDetailTiles()
	for i=1, numDetailTiles do
		_G["REPorterFrameCoreMap"..i]:SetTexture(nil)
	end
	for i=1, RE.BGOverlayNum do
		_G["REPorterFrameCoreMapOverlay"..i]:SetTexture(nil)
	end
end

function RE:Create(isSecond)
	_G.REPorterFrameCore:SetScript("OnUpdate", nil)
	RE.IsBrawl = IsInBrawl()
	RE.POINodes = {}
	if RE.CurrentMap == "IsleofConquest" then
		RE.IoCGateEstimator = {}
		RE.IoCGateEstimator[FACTION_ALLIANCE] = 600000
		RE.IoCGateEstimator[FACTION_HORDE] = 600000
		RE.IoCGateEstimatorText = ""
	end
	if RE.CurrentMap == "STVDiamondMineBG" then
		RE.SMEstimatorText = ""
		RE.SMEstimatorReport = ""
	end
	if RE.CurrentMap == "AlteracValley" then
		RE.DefaultTimer = 240
	elseif RE.CurrentMap == "GoldRush" then
		RE.DefaultTimer = 61
	elseif RE.CurrentMap == "AzeriteBG" then
		RE.DefaultTimer = 30
	else
		RE.DefaultTimer = 60
	end
	if RE.CurrentMap == "AlteracValley" or RE.CurrentMap == "GilneasBattleground2" or RE.CurrentMap == "IsleofConquest" or RE.CurrentMap == "ArathiBasin" or RE.CurrentMap == "GoldRush" or RE.CurrentMap == "AzeriteBG" or (IsRatedBattleground() and RE.CurrentMap == "NetherstormArena") then
		RE.CareAboutNodes = true
	else
		RE.CareAboutNodes = false
	end
	if RE.CurrentMap == "GilneasBattleground2" or RE.CurrentMap == "NetherstormArena" or RE.CurrentMap == "ArathiBasin" or RE.CurrentMap == "GoldRush" or RE.CurrentMap == "STVDiamondMineBG" or RE.CurrentMap == "TempleofKotmogu" then
		RE.CareAboutPoints = true
		_G.REPorterFrame:RegisterEvent("UPDATE_WORLD_STATES")
	else
		RE.CareAboutPoints = false
	end
	if RE.CurrentMap == "StrandoftheAncients" or RE.CurrentMap == "IsleofConquest" then
		RE.CareAboutGates = true
		_G.REPorterFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	else
		RE.CareAboutGates = false
	end
	if RE.CurrentMap == "WarsongGulch" or RE.CurrentMap == "TwinPeaks" then
		RE.CareAboutFlags = true
		_G.REPorterFrame:RegisterEvent("BATTLEGROUND_POINTS_UPDATE")
	else
		RE.CareAboutFlags = false
	end
	if RE.CurrentMap == "StrandoftheAncients" then
		_G.REPorterFrame:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
	end
	if not isSecond then
		RE:LoadMapSettings()
		RE:SetupReportBar()
		TIMER:ScheduleTimer(RE.TimerJoinCheck, 5)
	end
	_G.REPorterFrameCore:SetScript("OnUpdate", RE.OnUpdate)
end

function RE:NodeChange(newTexture, nodeName)
	TIMER:CancelTimer(RE.POINodes[nodeName]["timer"])
	if RE.CurrentMap == "AlteracValley" then
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
	elseif RE.CurrentMap == "NetherstormArena" then
		if newTexture == 9 then -- Tower Ally
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE
		elseif newTexture == 12 then -- Tower Horde
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE
		end
	elseif RE.CurrentMap == "GilneasBattleground2" then
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
	elseif RE.CurrentMap == "IsleofConquest" then
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
	elseif RE.CurrentMap == "ArathiBasin" then
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
	elseif RE.CurrentMap == "GoldRush" then
		if newTexture == 17 then -- Mine Ally
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE
		elseif newTexture == 19 then -- Mine Horde
			RE.POINodes[nodeName]["timer"] = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE
		end
	elseif RE.CurrentMap == "AzeriteBG" then
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
	elseif RE.CurrentMap == "STVDiamondMineBG" and RE.SMEstimatorReport ~= "" then
		SendChatMessage(RE.SMEstimatorReport, "INSTANCE_CHAT")
	elseif RE.CurrentMap == "IsleofConquest" and not RE.GateSyncRequested then
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

	_G.REPorterBar:ClearAllPoints()
	if handle < 15 and not RE.ZonesWithoutSubZones[RE.CurrentMap] then
		_G.REPorterBar:SetAlpha(0.25)
		_G.REPorterBarB1:SetPoint("TOPLEFT", "REPorterBar", "TOPLEFT", 10, -10)
		if handle < 7 or handle == 13 then
			if handle == 13 then
				_G.REPorterBar:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", RE.Settings.BarX, RE.Settings.BarY)
			elseif handle > 3 then
				_G.REPorterBar:SetPoint(RE.ReportBarAnchor[handle][1], _G.REPorterFrameBorder, RE.ReportBarAnchor[handle][2], 1, 0)
			else
				_G.REPorterBar:SetPoint(RE.ReportBarAnchor[handle][1], _G.REPorterFrameBorder, RE.ReportBarAnchor[handle][2], -1, 0)
			end
			_G.REPorterBar:SetHeight(220)
			_G.REPorterBar:SetWidth(45)
			for _, i in pairs({"B2", "B3", "B4", "B5", "B6", "B7", "B8"}) do
				_G["REPorterBar"..i]:ClearAllPoints()
				_G["REPorterBar"..i]:SetPoint("TOP", "REPorterBar"..previousButton, "BOTTOM")
				previousButton = i
			end
		else
			if handle == 14 then
				_G.REPorterBar:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", RE.Settings.BarX, RE.Settings.BarY)
			elseif handle > 9 then
				_G.REPorterBar:SetPoint(RE.ReportBarAnchor[handle][1], _G.REPorterFrameBorder, RE.ReportBarAnchor[handle][2], 0, -1)
			else
				_G.REPorterBar:SetPoint(RE.ReportBarAnchor[handle][1], _G.REPorterFrameBorder, RE.ReportBarAnchor[handle][2], 0, 1)
			end
			_G.REPorterBar:SetHeight(45)
			_G.REPorterBar:SetWidth(220)
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
	if RE.CurrentMap ~= "" then
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

		local texName
		local numDetailTiles = GetNumberOfDetailTiles()
		for i=1, numDetailTiles do
			if RE.CurrentMap == "STVDiamondMineBG" then
				texName = "Interface\\WorldMap\\"..RE.CurrentMap.."\\"..RE.CurrentMap.."1_"..i
			elseif RE.IsBrawl and RE.CurrentMap == "ArathiBasin" then
				texName = "Interface\\WorldMap\\ArathiBasinWinter\\ArathiBasinWinter"..i
			else
				texName = "Interface\\WorldMap\\"..RE.CurrentMap.."\\"..RE.CurrentMap..i
			end
			_G["REPorterFrameCoreMap"..i]:SetTexture(texName)
		end
	end
end

function RE:SaveMapSettings()
	if RE.CurrentMap ~= "" then
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

function RE:ShowDummyMap(mapFileName)
	if _G.REPorterFrame:IsShown() and RE.CurrentMap ~= "" then
		RE:SaveMapSettings()
	end

	RE.CurrentMap = mapFileName
	RE:LoadMapSettings()
	RE:SetupReportBar()
	_G.REPorterFrame:Show()
	_G.InterfaceOptionsFrame:SetFrameStrata("LOW")
end

function RE:HideDummyMap()
	if _G.REPorterFrame:IsShown() and select(2, IsInInstance()) ~= "pvp" then
		RE:SaveMapSettings()
		RE.CurrentMap = ""
		RE.LastMap = 0
		_G.REPorterFrame:Hide()
		_G.REPorterBar:Hide()
		_G.InterfaceOptionsFrame:SetFrameStrata("HIGH")
	end
end
--
