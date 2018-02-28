local _G = _G
local _, RE = ...
local L = LibStub("AceLocale-3.0"):GetLocale("REPorter")
local TOAST = LibStub("LibToast-1.0")
local TIMER = LibStub("AceTimer-3.0")
_G.REPorter = RE

--GLOBALS: FACTION_ALLIANCE, FACTION_HORDE, MAX_RAID_MEMBERS
local select, pairs, strsplit, gsub, tonumber, strfind, mod, print, ceil, strupper = _G.select, _G.pairs, _G.strsplit, _G.gsub, _G.tonumber, _G.strfind, _G.mod, _G.print, _G.ceil, _G.strupper
local mfloor = _G.math.floor
local tinsert = _G.table.insert
local CreateFrame = _G.CreateFrame
local IsInInstance = _G.IsInInstance
local IsRatedBattleground = _G.IsRatedBattleground
local IsInGuild = _G.IsInGuild
local IsShiftKeyDown = _G.IsShiftKeyDown
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local IsInBrawl = _G.C_PvP.IsInBrawl
local IsAddOnLoaded = _G.IsAddOnLoaded
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
local WorldMap_GetVehicleTexture = _G.WorldMap_GetVehicleTexture
local SetMapTooltipPosition = _G.SetMapTooltipPosition
local SendChatMessage = _G.SendChatMessage
local SendAddonMessage = _G.SendAddonMessage
local RegisterAddonMessagePrefix = _G.RegisterAddonMessagePrefix

RE.POIIconSize = 30
RE.POINumber = 25
RE.MapUpdateRate = 0.05
RE.NeedRefresh = false
RE.BGVehicles = {}
RE.POINodes = {}
RE.BGOverlayNum = 0
RE.ScaleDisabled = true
RE.LastMap = 0

RE.DefaultTimer = 60
RE.DoIEvenCareAboutNodes = false
RE.DoIEvenCareAboutPoints = false
RE.DoIEvenCareAboutGates = false
RE.DoIEvenCareAboutFlags = false
RE.PlayedFromStart = true
RE.IoCAllianceGateName = ""
RE.IoCHordeGateName = ""
RE.IoCGateEstimator = {}
RE.IoCGateEstimatorText = ""
RE.SMEstimatorText = ""
RE.SMEstimatorReport = ""
RE.GateSyncRequested = false
RE.PinTextures = {}
RE.IsWinning = ""
RE.IsBrawl = false
RE.IsOverlay = false

RE.BlipOffsetT = 0.5
RE.BlinkPOIMin = 0.3
RE.BlinkPOIMax = 0.6
RE.BlinkPOIValue = 0.3
RE.BlinkPOIUp = true

RE.CurrentMap = ""
RE.ClickedPOI = ""

RE.FoundNewVersion = false
RE.AddonVersionCheck = 140

RE.MapSettings = {
	["ArathiBasin"] = {["HE"] = 340, ["WI"] = 340, ["HO"] = 210, ["VE"] = 50, ["pointsToWin"] = 1500, ["WorldStateNum"] = 1, ["StartTimer"] = 120},
	["WarsongGulch"] = {["HE"] = 460, ["WI"] = 275, ["HO"] = 270, ["VE"] = 40, ["StartTimer"] = 120},
	["AlteracValley"] = {["HE"] = 460, ["WI"] = 200, ["HO"] = 270, ["VE"] = 35, ["StartTimer"] = 120},
	["NetherstormArena"] = {["HE"] = 340, ["WI"] = 200, ["HO"] = 275, ["VE"] = 90, ["pointsToWin"] = 1500, ["WorldStateNum"] = 2, ["StartTimer"] = 120},
	["StrandoftheAncients"] = {["HE"] = 410, ["WI"] = 275, ["HO"] = 240, ["VE"] = 100, ["StartTimer"] = 120},
	["IsleofConquest"] = {["HE"] = 370, ["WI"] = 325, ["HO"] = 230, ["VE"] = 90, ["StartTimer"] = 120},
	["GilneasBattleground2"] = {["HE"] = 360, ["WI"] = 325, ["HO"] = 230, ["VE"] = 90, ["pointsToWin"] = 1500, ["WorldStateNum"] = 1, ["StartTimer"] = 120},
	["TwinPeaks"] = {["HE"] = 435, ["WI"] = 250, ["HO"] = 280, ["VE"] = 40, ["StartTimer"] = 120},
	["TempleofKotmogu"] = {["HE"] = 250, ["WI"] = 400, ["HO"] = 185, ["VE"] = 155, ["pointsToWin"] = 1500, ["WorldStateNum"] = 1, ["StartTimer"] = 120},
	["STVDiamondMineBG"] = {["HE"] = 325, ["WI"] = 435, ["HO"] = 175, ["VE"] = 95, ["pointsToWin"] = 1500, ["WorldStateNum"] = 1, ["StartTimer"] = 120},
	["GoldRush"] = {["HE"] = 410, ["WI"] = 510, ["HO"] = 155, ["VE"] = 50, ["pointsToWin"] = 1500, ["WorldStateNum"] = 1, ["StartTimer"] = 120},
	["HillsbradFoothillsBG"] = {["HE"] = 360, ["WI"] = 240, ["HO"] = 280, ["VE"] = 80, ["StartTimer"] = 120},
	["AzeriteBG"] = {["HE"] = 330, ["WI"] = 355, ["HO"] = 155, ["VE"] = 85, ["StartTimer"] = 120}
}
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
RE.EstimatorSettings = {
	["ArathiBasin"] = { [0] = 0, [1] = 10/12, [2] = 10/9, [3] = 10/6, [4] = 10/3, [5] = 30},
	["NetherstormArena"] = { [0] = 0, [1] = 1, [2] = 2, [3] = 5, [4] = 10},
	["GilneasBattleground2"] = { [0] = 0, [1] = 10/9, [2] = 10/3, [3] = 30},
	["GoldRush"] = { [0] = 0, [1] = 1.6, [2] = 3.2, [3] = 6.4},
	["TempleofKotmogu"] = {["CenterP"] = 1, ["InnerP"] = 0.8, ["OuterP"] = 0.6},
	["STVDiamondMineBG"] = 150
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
	{ text = _G.ATTACK, notCheckable = true, func = function() RE:ReportDropDownClick(_G.ATTACK) end },
	{ text = L["Guard"], notCheckable = true, func = function() RE:ReportDropDownClick(L["Guard"]) end },
	{ text = L["Heavily defended"], notCheckable = true, func = function() RE:ReportDropDownClick(L["Heavily defended"]) end },
	{ text = L["Losing"], notCheckable = true, func = function() RE:ReportDropDownClick(L["Losing"]) end },
	{ text = "", notCheckable = true, disabled = true },
	{ text = L["On my way"], notCheckable = true, func = function() RE:ReportDropDownClick(L["On my way"]) end },
	{ text = L["Report status"], notCheckable = true, func = function() RE:ReportDropDownClick("") end }
}
RE.DefaultConfig = {
	barHandle = 1,
	locked = false,
	nameAdvert = false,
	opacity = 0.80,
	hideMinimap = false,
	displayMarks = false,
	configVersion = RE.AddonVersionCheck,
	["ArathiBasin"] = {["scale"] = 1.0, ["x"] = GetScreenWidth()/2, ["y"] = GetScreenHeight()/2},
	["WarsongGulch"] = {["scale"] = 1.0, ["x"] = GetScreenWidth()/2, ["y"] = GetScreenHeight()/2},
	["AlteracValley"] = {["scale"] = 1.0, ["x"] = GetScreenWidth()/2, ["y"] = GetScreenHeight()/2},
	["NetherstormArena"] = {["scale"] = 1.0, ["x"] = GetScreenWidth()/2, ["y"] = GetScreenHeight()/2},
	["StrandoftheAncients"] = {["scale"] = 1.0, ["x"] = GetScreenWidth()/2, ["y"] = GetScreenHeight()/2},
	["IsleofConquest"] = {["scale"] = 1.0, ["x"] = GetScreenWidth()/2, ["y"] = GetScreenHeight()/2},
	["GilneasBattleground2"] = {["scale"] = 1.0, ["x"] = GetScreenWidth()/2, ["y"] = GetScreenHeight()/2},
	["TwinPeaks"] = {["scale"] = 1.0, ["x"] = GetScreenWidth()/2, ["y"] = GetScreenHeight()/2},
	["TempleofKotmogu"] = {["scale"] = 1.0, ["x"] = GetScreenWidth()/2, ["y"] = GetScreenHeight()/2},
	["STVDiamondMineBG"] = {["scale"] = 1.0, ["x"] = GetScreenWidth()/2, ["y"] = GetScreenHeight()/2},
	["GoldRush"] = {["scale"] = 1.0, ["x"] = GetScreenWidth()/2, ["y"] = GetScreenHeight()/2},
	["HillsbradFoothillsBG"] = {["scale"] = 1.0, ["x"] = GetScreenWidth()/2, ["y"] = GetScreenHeight()/2},
	["AzeriteBG"] = {["scale"] = 1.0, ["x"] = GetScreenWidth()/2, ["y"] = GetScreenHeight()/2}
}
RE.ReportBarAnchor = {
	[1] = {"BOTTOMLEFT", "BOTTOMRIGHT"},
	[2] = {"LEFT", "RIGHT"},
	[3] = {"TOPLEFT", "TOPRIGHT"},
	[4] = {"BOTTOMRIGHT", "BOTTOMLEFT"},
	[5] = {"RIGHT", "LEFT"},
	[6] = {"TOPRIGHT", "TOPLEFT"}
}
RE.AceConfig = {
	type = "group",
	args = {
		locked = {
			name = L["Lock map"],
			desc = L["When checked map is locked in place."],
			type = "toggle",
			width = "full",
			order = 1,
			set = function(_, val) RE.Settings.locked = val end,
			get = function(_) return RE.Settings.locked end
		},
		nameAdvert = {
			name = L["Add \"[REPorter]\" to end of each report"],
			desc = L["When checked shameless advert is added to each battleground report."],
			type = "toggle",
			width = "full",
			order = 2,
			set = function(_, val) RE.Settings.nameAdvert = val; RE:UpdateConfig() end,
			get = function(_) return RE.Settings.nameAdvert end
		},
		hideMinimap = {
			name = L["Hide minimap on battlegrounds"],
			desc = L["When checked minimap will be hidden when player is on battleground."],
			type = "toggle",
			width = "full",
			order = 3,
			set = function(_, val) RE.Settings.hideMinimap = val; RE:UpdateConfig() end,
			get = function(_) return RE.Settings.hideMinimap end
		},
		displayMarks = {
			name = L["Always display raid markers"],
			desc = L["When checked player pins will be always replaced with raid markers."],
			type = "toggle",
			width = "full",
			order = 4,
			set = function(_, val) RE.Settings.displayMarks = val; RE:UpdateConfig() end,
			get = function(_) return RE.Settings.displayMarks end
		},
		barHandle = {
			name = L["Report bar location"],
			desc = L["Anchor point of bar with quick report buttons."],
			type = "select",
			width = "double",
			order = 5,
			values = {
				[1] = L["Bottom right"],
				[2] = L["Right"],
				[3] = L["Top right"],
				[4] = L["Bottom left"],
				[5] = L["Left"],
				[6] = L["Top left"]
			},
			set = function(_, val) RE.Settings.barHandle = val; RE:UpdateConfig() end,
			get = function(_) return RE.Settings.barHandle end
		},
		mapSettings = {
			name = BATTLEGROUND,
			desc = L["Map position and scale is saved separately for each battleground."],
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
		scale = {
			name = L["Map scale"],
			desc = L["This option control map size."],
			type = "range",
			width = "double",
			order = 7,
			disabled = function(_) if select(2, IsInInstance()) == "pvp" then return false else return RE.ScaleDisabled end end,
			min = 0.5,
			max = 1.5,
			step = 0.05,
			set = function(_, val) RE:UpdateScaleConfig(_, val) end,
			get = function(_) return RE:UpdateScaleConfig() end
		},
		opacity = {
			name = L["Map alpha"],
			desc = L["This option control map transparency."],
			type = "range",
			width = "double",
			order = 8,
			isPercent = true,
			min = 0.1,
			max = 1,
			step = 0.01,
			set = function(_, val) RE.Settings.opacity = val; RE:UpdateConfig() end,
			get = function(_) return RE.Settings.opacity end
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
	local realX, realY = 0, 0
	-- X -17
	-- Y -78
	realX = rawX * 783
	realY = -rawY * 522
	return realX, realY
end

function RE:TableCount(Table)
	local RENum = 0
	local RETable = {}
	for k,_ in pairs(Table) do
		RENum = RENum + 1
		tinsert(RETable, k)
	end
	return RENum, RETable
end

function RE:ClearTextures()
	TIMER:CancelTimer(RE.EstimatorTimer)
	for i=1, RE.POINumber do
		_G["REPorterFramePOI"..i]:Hide()
		_G["REPorterFramePOI"..i.."Timer"]:Hide()
		_G["REPorterFramePOI"..i.."Texture"]:SetTexture("Interface\\Minimap\\POIIcons")
		_G["REPorterFramePOI"..i.."Texture"]:SetTexCoord(0, 1, 0, 1)
		local tableCount, tableInternal = RE:TableCount(RE.POINodes)
		for i=1, tableCount do
			TIMER:CancelTimer(RE.POINodes[tableInternal[i]]["timer"])
		end
	end
	for i=1, 4 do
		local flagFrameName = "REPorterFrameFlag"..i
		local flagFrame = _G[flagFrameName]
		flagFrame:Hide()
	end
	if RE.numVehicles then
		for i=1, RE.numVehicles do
			RE.BGVehicles[i]:Hide()
		end
	end
	local numDetailTiles = GetNumberOfDetailTiles()
	for i=1, numDetailTiles do
		_G["REPorterFrame"..i]:SetTexture(nil)
	end
	for i=1, RE.BGOverlayNum do
		_G["REPorterFrameMapOverlay"..i]:SetTexture(nil)
	end
	RE.POINodes = {}
end

function RE:CreatePOI(index)
	local frameMain = CreateFrame("Frame", "REPorterFramePOI"..index, _G.REPorterFrame)
	frameMain:SetFrameLevel(10 + index)
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
	texture:SetHeight(3)
	texture:SetColorTexture(0,1,0,1)
	local texture = frameMain:CreateTexture(frameMain:GetName().."TextureBGTop2", "BORDER")
	texture:SetPoint("BOTTOMLEFT", frameMain, "BOTTOMLEFT")
	texture:SetWidth(RE.POIIconSize)
	texture:SetHeight(3)
	texture:SetColorTexture(0,1,0,1)
	local frame = CreateFrame("Frame", "REPorterFramePOI"..index.."Timer", _G.REPorterFrameTimerOverlay, "REPorter_POITimerTemplate")
	frame:SetFrameLevel(11 + index)
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

function RE:HideTooltip()
	_G.GameTooltip:Hide()
end

function RE:SOTAStartCheck()
	local startCheck = {GetMapLandmarkInfo(7)}
	local sideCheck = {GetMapLandmarkInfo(10)}
	return (startCheck[4] == 46 or startCheck[4] == 48), sideCheck[4] == 102
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
	elseif APointNum >= RE.MapSettings[RE.CurrentMap]["pointsToWin"] or HPointNum >= RE.MapSettings[RE.CurrentMap]["pointsToWin"] then
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

function RE:TimerTabHider()
	_G.REPorterFrameTab:SetAlpha(0.25)
end

function RE:GetMapInfo()
	if GetMapInfo() == "ArathiBasinWinter" then
		return "ArathiBasin"
	else
		return GetMapInfo()
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
	self:RegisterForDrag("LeftButton")
	_G.InterfaceOptionsFrame:HookScript("OnHide", RE.HideDummyMap)
	RE.updateTimer = 0
end

function RE:OnShow(_)
	if RE.CurrentMap ~= RE:GetMapInfo() then
		SetMapToCurrentZone()
		_G.REPorterFrameEstimator:Show()
		_G.REPorterFrameExternal:SetScrollChild(_G.REPorterFrame)
		_G.REPorterFrameTab:SetAlpha(0.25)
		if RE.Settings.hideMinimap then
			_G.MinimapCluster:Hide()
		end
	end
end

function RE:OnHide(_)
	if RE.CurrentMap ~= RE:GetMapInfo() then
		_G.REPorterFrameUnitPosition:SetScript("OnUpdate", nil)
		RE.CurrentMap = ""
		RE.IsBrawl = false
		RE.DoIEvenCareAboutNodes = false
		RE.DoIEvenCareAboutPoints = false
		RE.DoIEvenCareAboutGates = false
		RE.DoIEvenCareAboutFlags = false
		_G.REPorterFrameExternal:UnregisterEvent("UPDATE_WORLD_STATES")
		_G.REPorterFrameExternal:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		_G.REPorterFrameExternal:UnregisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
		_G.REPorterFrameExternal:UnregisterEvent("BATTLEGROUND_POINTS_UPDATE")
		RE.IsWinning = ""
		RE:ClearTextures()
		_G.L_CloseDropDownMenus()
		_G.REPorterFrameEstimator_Text:SetText("")
		_G.REPorterFrameEstimator:Hide()
		RE.TimerOverride = false
		if not _G.MinimapCluster:IsShown() and RE.Settings.hideMinimap then
			_G.MinimapCluster:Show()
		end
	end
end

function RE:OnEnter(_)
	TIMER:CancelTimer(RE.TabHiderTimer)
	_G.REPorterFrameTab:SetAlpha(RE.Settings.opacity)
end

function RE:OnLeave(_)
	if not _G.REPorterFrameTab:IsMouseOver() then
		TIMER:CancelTimer(RE.TabHiderTimer)
		RE.TabHiderTimer = TIMER:ScheduleTimer(RE.TimerTabHider, 0.5)
	end
end

function RE:OnEvent(_, event, ...)
	if event == "ADDON_LOADED" and ... == "REPorter" then
		RE:PrepareConfig()
		_G.REPorterFrameTab:SetHitRectInsets(-5, -5, -5, -5)
		RegisterAddonMessagePrefix("REPorter")
		_G.BINDING_HEADER_REPORTERB = "REPorter"
		_G.BINDING_NAME_REPORTERINC1 = L["Incoming"].." 1"
		_G.BINDING_NAME_REPORTERINC2 = L["Incoming"].." 2"
		_G.BINDING_NAME_REPORTERINC3 = L["Incoming"].." 3"
		_G.BINDING_NAME_REPORTERINC4 = L["Incoming"].." 4"
		_G.BINDING_NAME_REPORTERINC5 = L["Incoming"].." 5"
		_G.BINDING_NAME_REPORTERINC6 = L["Incoming"].." 5+"
		_G.BINDING_NAME_REPORTERHELP = _G.HELP_LABEL
		_G.BINDING_NAME_REPORTERCLEAR = L["Clear"]
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
			local tableCount, tableInternal = RE:TableCount(RE.POINodes)
			for i=1, tableCount do
				if RE.POINodes[tableInternal[i]]["health"] then
					message = message..RE.POINodes[tableInternal[i]]["id"]..";"..RE.POINodes[tableInternal[i]]["health"]..";"
				end
			end
			SendAddonMessage("REPorter", message, "INSTANCE_CHAT")
		elseif RE.GateSyncRequested and REMessageEx[1] == "GateSync" then
			RE.GateSyncRequested = false
			local tableCount, tableInternal = RE:TableCount(RE.POINodes)
			for i=1, tableCount do
				for k=2, #REMessageEx do
					if REMessageEx[k] == RE.POINodes[tableInternal[i]]["id"] then
						RE.POINodes[tableInternal[i]]["health"] = REMessageEx[k+1]
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
					AlliancePointsNeeded = RE.MapSettings["TempleofKotmogu"]["pointsToWin"] - tonumber(score[#score])
				end
			end
			local _, _, _, text = GetWorldStateUIInfo(RE.MapSettings["TempleofKotmogu"]["WorldStateNum"]+1)
			if text ~= nil then
				local score = {strsplit("/", text)}
				if score[1] then
					score[1] = gsub(score[1], "：", " ")
					score = {strsplit(" ", score[1])}
					HordePointsNeeded = RE.MapSettings["TempleofKotmogu"]["pointsToWin"] - tonumber(score[#score])
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
					AlliancePointsNeeded = RE.MapSettings["STVDiamondMineBG"]["pointsToWin"] - tonumber(score[#score])
				end
			end
			local _, _, _, text = GetWorldStateUIInfo(RE.MapSettings["STVDiamondMineBG"]["WorldStateNum"]+1)
			if text ~= nil then
				local score = {strsplit("/", text)}
				if score[1] then
					score[1] = gsub(score[1], "：", " ")
					score = {strsplit(" ", score[1])}
					HordePointsNeeded = RE.MapSettings["STVDiamondMineBG"]["pointsToWin"] - tonumber(score[#score])
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
					AllianceTimeToWin = (RE.MapSettings[RE.CurrentMap]["pointsToWin"] - AlliancePointNum) / RE.EstimatorSettings[RE.CurrentMap][AllianceBaseNum]
				end
				if RE.EstimatorSettings[RE.CurrentMap][HordeBaseNum] == 0 then
					HordeTimeToWin = 10000
				else
					HordeTimeToWin = (RE.MapSettings[RE.CurrentMap]["pointsToWin"] - HordePointNum) / RE.EstimatorSettings[RE.CurrentMap][HordeBaseNum]
				end
				RE:EstimatorFill(AllianceTimeToWin, HordeTimeToWin, 5, AlliancePointNum, HordePointNum)
			end
		end
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and select(2, ...) == "SPELL_BUILDING_DAMAGE" and RE:TableCount(RE.POINodes) > 0 then
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
		local _, instanceType = IsInInstance()
		_G.REPorterFrameExternal:Hide()
		if instanceType == "pvp" then
			_G.REPorterFrameExternal:Show()
			RE.PlayedFromStart = true
			RE.GateSyncRequested = false
			RE:Create(false)
			SendAddonMessage("REPorter", "Version;"..RE.AddonVersionCheck, "INSTANCE_CHAT")
			if IsInGuild() then
				SendAddonMessage("REPorter", "Version;"..RE.AddonVersionCheck, "GUILD")
			end
		elseif RE.CurrentMap ~= "" then
			RE.CurrentMap = ""
			RE:OnHide()
		end
	elseif event == "MODIFIER_STATE_CHANGED" and _G.REPorterFrameExternal:IsShown() then
		if IsShiftKeyDown() and IsAltKeyDown() then
			RE.NeedRefresh = true
			_G.REPorterFrameExternalOverlay:Hide()
			_G.REPorterFrameTimerOverlay:Show()
		elseif IsShiftKeyDown() and IsControlKeyDown() then
			RE.NeedRefresh = true
		elseif _G.REPorterFrameTimerOverlay:IsShown() then
			RE.NeedRefresh = true
			_G.REPorterFrameExternalOverlay:Show()
			_G.REPorterFrameTimerOverlay:Hide()
		elseif RE.IsOverlay then
			RE.NeedRefresh = true
		end
	elseif event == "GROUP_ROSTER_UPDATE" and _G.REPorterFrameExternal:IsShown() then
		RE.NeedRefresh = true
	elseif event == "BATTLEGROUND_POINTS_UPDATE" then
		RE.TimerOverride = true
		RE:CreateTimer(12)
	elseif event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" then
		-- SotA hack
		RE.NeedRefresh = true
		RE:Create(true)
	end
end

function RE:OnUpdate(elapsed)
	if RE.updateTimer < 0 then
		RE:BlinkPOI()
		local subZoneName = GetSubZoneText()
		if subZoneName and subZoneName ~= "" and RE.CurrentMap ~= "GoldRush" and RE.CurrentMap ~= "STVDiamondMineBG" and RE.CurrentMap ~= "TempleofKotmogu" and RE.CurrentMap ~= "HillsbradFoothillsBG" then
			for _, i in pairs({"SB1", "SB2", "SB3", "SB4", "SB5", "SB6", "BB1", "BB2"}) do
				_G["REPorterFrameTab_"..i]:Enable()
			end
		else
			for _, i in pairs({"SB1", "SB2", "SB3", "SB4", "SB5", "SB6", "BB1", "BB2"}) do
				_G["REPorterFrameTab_"..i]:Disable()
			end
		end

		if RE.NeedRefresh then
			RE.NeedRefresh = false
			_G.REPorterFrameUnitPosition:ClearUnits()
		end
		_G.REPorterFrameUnitPosition:AddUnit("player", "Interface\\Minimap\\MinimapArrow", 50, 50, 1, 1, 1, 1, 7, true)
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
							_G.REPorterFrameUnitPosition:AddUnit(unit, texture, 25, 25, 1, 1, 1, 1)
						elseif UnitGroupRolesAssigned(unit) == "HEALER" then
							texture = "Interface\\Addons\\REPorter\\Textures\\BlipHealer"
							_G.REPorterFrameUnitPosition:AddUnit(unit, texture, 30, 30, r, g, b, 1)
						end
					else
						RE.IsOverlay = false
						if RE.Settings.displayMarks and raidMarker ~= nil then
							texture = "Interface\\Addons\\REPorter\\Textures\\RaidMarker"..raidMarker
							_G.REPorterFrameUnitPosition:AddUnit(unit, texture, 25, 25, 1, 1, 1, 1)
						else
							_G.REPorterFrameUnitPosition:AddUnit(unit, texture, 25, 25, r, g, b, 1)
						end
					end
				end
				if RE.PinTextures[unit] and RE.PinTextures[unit] ~= texture then
					RE.NeedRefresh = true
				end
				RE.PinTextures[unit] = texture
			end
		end
		_G.REPorterFrameUnitPosition:FinalizeUnits()
		_G.REPorterFrameUnitPosition:UpdateTooltips(_G.GameTooltip)
		local playerBlipFrameLevel = _G.REPorterFrameUnitPosition:GetFrameLevel()

		local numFlags = GetNumBattlefieldFlagPositions()
		for i=1, 4 do
			local flagFrameName = "REPorterFrameFlag"..i
			local flagFrame = _G[flagFrameName]
			if i <= numFlags and (RE.CurrentMap ~= "GoldRush" or RE.IsBrawl) then
				local flagX, flagY, flagToken = GetBattlefieldFlagPosition(i)
				if flagX == 0 and flagY == 0 then
					flagFrame:Hide()
				else
					flagX, flagY = RE:GetRealCoords(flagX, flagY)
					flagFrame.Texture:SetTexture("Interface\\WorldStateFrame\\"..flagToken)
					flagFrame:SetPoint("CENTER", "REPorterFrameOverlay", "TOPLEFT", flagX, flagY)
					flagFrame:EnableMouse(false)
					flagFrame:SetFrameLevel(playerBlipFrameLevel - 1)
					flagFrame:Show()
				end
			else
				flagFrame:Hide()
			end
		end

		RE.numVehicles = GetNumBattlefieldVehicles()
		local totalVehicles = #RE.BGVehicles
		local index = 0
		for i=1, RE.numVehicles do
			if i > totalVehicles then
				local vehicleName = "REPorterFrame"..i
				RE.BGVehicles[i] = CreateFrame("FRAME", vehicleName, _G.REPorterFrameOverlay, "REPorter_VehicleTemplate")
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
				RE.BGVehicles[i]:SetPoint("CENTER", "REPorterFrameOverlay", "TOPLEFT", vehicleX, vehicleY)
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
			_G["REPorterFramePOI"..i]:Hide()
			_G["REPorterFramePOI"..i.."Timer"]:Hide()
		end
		for i=1, GetNumMapLandmarks() do
			local battlefieldPOIName = "REPorterFramePOI"..i
			local battlefieldPOI = _G[battlefieldPOIName]
			local _, name, description, textureIndex, x, y, _, showInBattleMap, _, _, poiID, _, atlasID = GetMapLandmarkInfo(i)
			local colorOverride = false
			if RE.CurrentMap == "AzeriteBG" and atlasID and not showInBattleMap then
				showInBattleMap = true
				description = ""
				textureIndex = -1
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
						name = name.." - "..L["Blue"]
						colorOverride = {0, 0, 1}
					elseif poiID == 2775 then
						name = name.." - "..L["Purple"]
						colorOverride = {0.5, 0, 0.5}
					elseif poiID == 2776 then
						name = name.." - "..L["Red"]
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
					end
				else
					RE.POINodes[name]["id"] = i
					RE.POINodes[name]["name"] = name
					RE.POINodes[name]["status"] = description
					RE.POINodes[name]["x"] = x
					RE.POINodes[name]["y"] = y
					if RE.DoIEvenCareAboutNodes and RE.POINodes[name]["texture"] and RE.POINodes[name]["texture"] ~= textureIndex then
						RE:NodeChange(textureIndex, name)
					end
					RE.POINodes[name]["texture"] = textureIndex
				end
				battlefieldPOI.name = name
				battlefieldPOI:SetPoint("CENTER", "REPorterFrame", "TOPLEFT", x, y)
				battlefieldPOI:SetWidth(RE.POIIconSize)
				battlefieldPOI:SetHeight(RE.POIIconSize)
				if textureIndex == -1 then
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
							if atlasID == "AzeriteReady" then
								_G[battlefieldPOIName.."TextureBG"]:SetColorTexture(0,1,0,0.3)
							elseif atlasID == "AzeriteSpawning" then
								_G[battlefieldPOIName.."TextureBG"]:SetColorTexture(1,0,0,0.3)
							end
						else
							_G[battlefieldPOIName.."TextureBG"]:SetColorTexture(0,0,0,0.3)
						end
					end
					_G[battlefieldPOIName.."TextureBG"]:SetWidth(RE.POIIconSize)
					_G[battlefieldPOIName.."TextureBGofBG"]:Hide()
					if RE.DoIEvenCareAboutGates and RE.POINodes[name]["health"] and RE.POINodes[name]["health"] ~= 0 and textureIndex ~= 76 and textureIndex ~= 79 and textureIndex ~= 82 and textureIndex ~= 104 and textureIndex ~= 107 and textureIndex ~= 110 then
						_G[battlefieldPOIName.."TextureBGTop1"]:Hide()
						_G[battlefieldPOIName.."TextureBGTop2"]:Show()
						_G[battlefieldPOIName.."TextureBGTop2"]:SetWidth((RE.POINodes[name]["health"]/RE.POINodes[name]["maxHealth"]) * RE.POIIconSize)
						if RE.GateSyncRequested then
							_G[battlefieldPOIName.."Timer_Caption"]:SetText("|cFFFF141D"..RE:Round((RE.POINodes[name]["health"]/RE.POINodes[name]["maxHealth"])*100, 0).."%|r")
						else
							_G[battlefieldPOIName.."Timer_Caption"]:SetText(RE:Round((RE.POINodes[name]["health"]/RE.POINodes[name]["maxHealth"])*100, 0).."%")
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
					if RE.POINodes[name]["isCapturing"] == FACTION_HORDE then
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
					_G[battlefieldPOIName.."Timer_Caption"]:SetText(RE:ShortTime(RE:Round(TIMER:TimeLeft(RE.POINodes[name]["timer"]), 0)))
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
							_G.REPorterFrame:CreateTexture("REPorterFrameMapOverlay"..j, "ARTWORK")
						end
						RE.BGOverlayNum = neededTextures
					end
					local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight
					for j=1, numTexturesTall do
						if ( j < numTexturesTall ) then
							texturePixelHeight = 256
							textureFileHeight = 256
						else
							texturePixelHeight = mod(textureHeight, 256)
							if ( texturePixelHeight == 0 ) then
								texturePixelHeight = 256
							end
							textureFileHeight = 16
							while(textureFileHeight < texturePixelHeight) do
								textureFileHeight = textureFileHeight * 2
							end
						end
						for k=1, numTexturesWide do
							textureCount = textureCount + 1
							local texture = _G["REPorterFrameMapOverlay"..textureCount]
							if ( k < numTexturesWide ) then
								texturePixelWidth = 256
								textureFileWidth = 256
							else
								texturePixelWidth = mod(textureWidth, 256)
								if ( texturePixelWidth == 0 ) then
									texturePixelWidth = 256
								end
								textureFileWidth = 16
								while(textureFileWidth < texturePixelWidth) do
									textureFileWidth = textureFileWidth * 2
								end
							end
							texture:SetWidth(texturePixelWidth * scale)
							texture:SetHeight(texturePixelHeight * scale)
							texture:SetTexCoord(0, texturePixelWidth / textureFileWidth, 0, texturePixelHeight / textureFileHeight)
							texture:SetPoint("TOPLEFT", "REPorterFrame", "TOPLEFT", (offsetX + (256 * (k - 1))) * scale, -((offsetY + (256 * (j - 1))) * scale))
							texture:SetTexture(textureName..(((j - 1) * numTexturesWide) + k))
							texture:SetAlpha(RE.Settings.opacity)
							texture:Show()
						end
					end
				end
			end
			for i=textureCount + 1, RE.BGOverlayNum do
				_G["REPorterFrameMapOverlay"..i]:Hide()
			end
		end

		if TIMER:TimeLeft(RE.EstimatorTimer) > 0 then
			if RE.IsWinning == FACTION_ALLIANCE then
				_G.REPorterFrameEstimator_Text:SetText("|cFF00A9FF"..RE:ShortTime(RE:Round(TIMER:TimeLeft(RE.EstimatorTimer), 0)).."|r")
			elseif RE.IsWinning == FACTION_HORDE then
				_G.REPorterFrameEstimator_Text:SetText("|cFFFF141D"..RE:ShortTime(RE:Round(TIMER:TimeLeft(RE.EstimatorTimer), 0)).."|r")
			else
				_G.REPorterFrameEstimator_Text:SetText("")
			end
		elseif RE.CurrentMap == "STVDiamondMineBG" then
			_G.REPorterFrameEstimator_Text:SetText(RE.SMEstimatorText)
		elseif RE.CurrentMap == "IsleofConquest" and not RE.GateSyncRequested then
			_G.REPorterFrameEstimator_Text:SetText(RE.IoCGateEstimatorText)
		else
			_G.REPorterFrameEstimator_Text:SetText("")
		end
		RE.updateTimer = RE.MapUpdateRate
	else
		RE.updateTimer = RE.updateTimer - elapsed
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
	local tableNum, tableInternal = RE:TableCount(vehicleGroup)
	for i=1, tableNum do
		if vehicleGroup[tableInternal[i]] == 1 then
			tooltipText = tooltipText..prefix..tableInternal[i]
		else
			tooltipText = tooltipText..prefix.."|cFFFFFFFF"..vehicleGroup[tableInternal[i]].."x|r "..tableInternal[i]
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
function RE:Create(isSecond)
	_G.REPorterFrameUnitPosition:SetScript("OnUpdate", nil)
	local mapFileName = RE:GetMapInfo()
	if mapFileName and RE.MapSettings[mapFileName] then
		RE.CurrentMap = mapFileName
		RE.IsBrawl = IsInBrawl()
		RE.POINodes = {}
		_G.REPorterFrameExternal:ClearAllPoints()
		_G.REPorterFrameExternal:SetScale(RE.Settings[mapFileName]["scale"])
		_G.REPorterFrameExternal:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", RE.Settings[mapFileName]["x"], RE.Settings[mapFileName]["y"])
		_G.REPorterFrameTimerOverlay:Hide()
		_G.REPorterFrameExternal:SetHeight(RE.MapSettings[mapFileName]["HE"])
		_G.REPorterFrameExternalOverlay:SetHeight(RE.MapSettings[mapFileName]["HE"])
		_G.REPorterFrameExternalUnitPosition:SetHeight(RE.MapSettings[mapFileName]["HE"])
		_G.REPorterFrameBorder:SetHeight(RE.MapSettings[mapFileName]["HE"] + 5)
		_G.REPorterFrameExternal:SetWidth(RE.MapSettings[mapFileName]["WI"])
		_G.REPorterFrameExternalOverlay:SetWidth(RE.MapSettings[mapFileName]["WI"])
		_G.REPorterFrameExternalUnitPosition:SetWidth(RE.MapSettings[mapFileName]["WI"])
		_G.REPorterFrameBorder:SetWidth(RE.MapSettings[mapFileName]["WI"] + 5)
		_G.REPorterFrameExternal:SetHorizontalScroll(RE.MapSettings[mapFileName]["HO"])
		_G.REPorterFrameExternal:SetVerticalScroll(RE.MapSettings[mapFileName]["VE"])
		_G.REPorterFrameExternalOverlay:SetHorizontalScroll(RE.MapSettings[mapFileName]["HO"])
		_G.REPorterFrameExternalOverlay:SetVerticalScroll(RE.MapSettings[mapFileName]["VE"])
		_G.REPorterFrameExternalOverlay:SetPoint("TOPLEFT", _G.REPorterFrameExternal, "TOPLEFT")
		_G.REPorterFrameExternalUnitPosition:SetHorizontalScroll(RE.MapSettings[mapFileName]["HO"])
		_G.REPorterFrameExternalUnitPosition:SetVerticalScroll(RE.MapSettings[mapFileName]["VE"])
		_G.REPorterFrameExternalUnitPosition:SetPoint("TOPLEFT", _G.REPorterFrameExternal, "TOPLEFT")
		_G.REPorterFrameUnitPosition:SetMouseOverUnitExcluded("player", true)
		_G.REPorterFrameUnitPosition.UpdateUnitTooltips = function(self, tooltipFrame) RE:UnitOnEnterPlayer(self, tooltipFrame) end
		_G.REPorterFrameUnitPosition:SetFrameLevel(4)
		_G.REPorterFrameTab:Show()
		local texName
		local numDetailTiles = GetNumberOfDetailTiles()
		for i=1, numDetailTiles do
			if mapFileName == "STVDiamondMineBG" then
				texName = "Interface\\WorldMap\\"..mapFileName.."\\"..mapFileName.."1_"..i
			elseif RE.IsBrawl and mapFileName == "ArathiBasin" then
				texName = "Interface\\WorldMap\\ArathiBasinWinter\\ArathiBasinWinter"..i
			else
				texName = "Interface\\WorldMap\\"..mapFileName.."\\"..mapFileName..i
			end
			_G["REPorterFrame"..i]:SetTexture(texName)
		end
		if mapFileName == "IsleofConquest" then
			RE.IoCGateEstimator = {}
			RE.IoCGateEstimator[FACTION_ALLIANCE] = 600000
			RE.IoCGateEstimator[FACTION_HORDE] = 600000
			RE.IoCGateEstimatorText = ""
		end
		if mapFileName == "STVDiamondMineBG" then
			RE.SMEstimatorText = ""
			RE.SMEstimatorReport = ""
		end
		if mapFileName == "AlteracValley" then
			RE.DefaultTimer = 240
		elseif mapFileName == "GoldRush" then
			RE.DefaultTimer = 61
		else
			RE.DefaultTimer = 60
		end
		if mapFileName == "AlteracValley" or mapFileName == "GilneasBattleground2" or mapFileName == "IsleofConquest" or mapFileName == "ArathiBasin" or mapFileName == "GoldRush" or (IsRatedBattleground() and mapFileName == "NetherstormArena") then
			RE.DoIEvenCareAboutNodes = true
		else
			RE.DoIEvenCareAboutNodes = false
		end
		if mapFileName == "GilneasBattleground2" or mapFileName == "NetherstormArena" or mapFileName == "ArathiBasin" or mapFileName == "GoldRush" or mapFileName == "STVDiamondMineBG" or mapFileName == "TempleofKotmogu" then
			RE.DoIEvenCareAboutPoints = true
			_G.REPorterFrameExternal:RegisterEvent("UPDATE_WORLD_STATES")
		else
			RE.DoIEvenCareAboutPoints = false
		end
		if mapFileName == "StrandoftheAncients" or mapFileName == "IsleofConquest" then
			RE.DoIEvenCareAboutGates = true
			_G.REPorterFrameExternal:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		else
			RE.DoIEvenCareAboutGates = false
		end
		if mapFileName == "WarsongGulch" or mapFileName == "TwinPeaks" then
			RE.DoIEvenCareAboutFlags = true
			_G.REPorterFrameExternal:RegisterEvent("BATTLEGROUND_POINTS_UPDATE")
		else
			RE.DoIEvenCareAboutFlags = false
		end
		if mapFileName == "StrandoftheAncients" then
			_G.REPorterFrameExternal:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
		end
		if not isSecond then
			TIMER:ScheduleTimer(RE.TimerJoinCheck, 5)
		end
		_G.REPorterFrameUnitPosition:SetScript("OnUpdate", RE.OnUpdate)
	end
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
	end
end

function RE:POIStatus(POIName)
	if RE.POINodes[POIName]then
		if TIMER:TimeLeft(RE.POINodes[POIName]["timer"]) == 0 then
			if RE.POINodes[POIName]["health"] and not RE.GateSyncRequested then
				local gateHealth = RE:Round((RE.POINodes[POIName]["health"]/RE.POINodes[POIName]["maxHealth"])*100, 0)
				return " - ".._G.HEALTH..": "..gateHealth.."%"
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
	local _, instanceType = IsInInstance()
	if instanceType == "pvp" then
		local name = ""
		if otherNode then
			name = RE.ClickedPOI
		elseif RE.CurrentMap == "TempleofKotmogu" or RE.CurrentMap == "GoldRush" or RE.CurrentMap == "STVDiamondMineBG" or RE.CurrentMap == "HillsbradFoothillsBG" then
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
			SendChatMessage(message..RE:POIOwner(name)..RE:POIStatus(name)..RE.ReportPrefix, "INSTANCE_CHAT")
		else
			print("\124cFF74D06C[REPorter]\124r "..L["This location don't have name. Action canceled."])
		end
	else
		print("\124cFF74D06C[REPorter]\124r "..L["This addon work only on battlegrounds."])
	end
end

function RE:BigButton(isHelp, otherNode)
	local _, instanceType = IsInInstance()
	if instanceType == "pvp" then
		local name = ""
		if otherNode then
			name = RE.ClickedPOI
		elseif RE.CurrentMap == "TempleofKotmogu" or RE.CurrentMap == "GoldRush" or RE.CurrentMap == "STVDiamondMineBG" or RE.CurrentMap == "HillsbradFoothillsBG" then
			name = ""
		else
			name = GetSubZoneText()
		end
		if name and name ~= "" then
			if isHelp then
				SendChatMessage(strupper(_G.HELP_LABEL)..RE:POIOwner(name)..RE:POIStatus(name)..RE.ReportPrefix, "INSTANCE_CHAT")
			else
				SendChatMessage(strupper(L["Clear"])..RE:POIOwner(name)..RE:POIStatus(name)..RE.ReportPrefix, "INSTANCE_CHAT")
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
		SendChatMessage(RE.IsWinning.." "..L["victory"]..": "..RE:ShortTime(RE:Round(TIMER:TimeLeft(RE.EstimatorTimer), 0))..RE.ReportPrefix, "INSTANCE_CHAT")
	elseif RE.CurrentMap == "STVDiamondMineBG" and RE.SMEstimatorReport ~= "" then
		SendChatMessage(RE.SMEstimatorReport, "INSTANCE_CHAT")
	elseif RE.CurrentMap == "IsleofConquest" and not RE.GateSyncRequested then
		SendChatMessage(FACTION_ALLIANCE.." "..L["gate"]..": "..RE:Round((RE.IoCGateEstimator[FACTION_ALLIANCE]/600000)*100, 0).."% - "..FACTION_HORDE.." "..L["gate"]..": "..RE:Round((RE.IoCGateEstimator[FACTION_HORDE]/600000)*100, 0).."%"..RE.ReportPrefix, "INSTANCE_CHAT")
	end
end

function RE:ReportDropDownClick(reportType)
	if reportType ~= "" then
		SendChatMessage(strupper(reportType)..RE:POIOwner(RE.ClickedPOI)..RE:POIStatus(RE.ClickedPOI)..RE.ReportPrefix, "INSTANCE_CHAT")
	else
		SendChatMessage(RE:POIOwner(RE.ClickedPOI, true)..RE:POIStatus(RE.ClickedPOI)..RE.ReportPrefix, "INSTANCE_CHAT")
	end
end
--

-- *** Config functions
function RE:UpdateConfig()
	local x, y = 0, 0
	_G.REPorterFrameExternal:SetAlpha(RE.Settings["opacity"])
	if RE.Settings[RE.CurrentMap] then
		_G.REPorterFrameExternal:SetScale(RE.Settings[RE.CurrentMap]["scale"])
	end
	if RE.Settings.nameAdvert then
		RE.ReportPrefix = " - [REPorter]"
	else
		RE.ReportPrefix = ""
	end
	_G.REPorterFrameTab:ClearAllPoints()
	if IsAddOnLoaded("ElvUI") and IsAddOnLoaded("AddOnSkins") then
		if RE.Settings.barHandle > 3 then
			x, y = -2, 0
		else
			x, y = 2, 0
		end
	else
		if RE.Settings.barHandle > 3 then
			x, y = 2, 0
		else
			x, y = -2, 0
		end
	end
	_G.REPorterFrameTab:SetPoint(RE.ReportBarAnchor[RE.Settings.barHandle][1], _G.REPorterFrameBorder, RE.ReportBarAnchor[RE.Settings.barHandle][2], x, y)
	local _, instanceType = IsInInstance()
	if instanceType == "pvp" then
		_G.MinimapCluster:SetShown(not RE.Settings.hideMinimap)
	end
end

function RE:UpdateScaleConfig(_, val)
	if RE.Settings[RE.CurrentMap] then
		if val then
			RE.Settings[RE.CurrentMap]["scale"] = val
			RE:UpdateConfig()
		else
			return RE.Settings[RE.CurrentMap]["scale"]
		end
	else
		return 1.0
	end
end

function RE:PrepareConfig()
	if not _G.REPorterSettings or not _G.REPorterSettings["configVersion"] then
		_G.REPorterSettings = RE.DefaultConfig
	end
	RE.Settings = _G.REPorterSettings
	for key, value in pairs(RE.DefaultConfig) do
		if RE.Settings[key] == nil then
			RE.Settings[key] = value
		end
	end
	_G.LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("REPorter", RE.AceConfig)
	_G.LibStub("AceConfigDialog-3.0"):AddToBlizOptions("REPorter", "REPorter")
	RE:UpdateConfig()
end

function RE:ShowDummyMap(mapFileName)
	RE.ScaleDisabled = false
	RE.CurrentMap = mapFileName
	_G.REPorterFrameExternal:ClearAllPoints()
	_G.REPorterFrameExternal:SetScale(RE.Settings[mapFileName]["scale"])
	_G.REPorterFrameExternal:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", RE.Settings[mapFileName]["x"], RE.Settings[mapFileName]["y"])
	_G.REPorterFrameExternal:SetHeight(RE.MapSettings[mapFileName]["HE"])
	_G.REPorterFrameExternal:SetWidth(RE.MapSettings[mapFileName]["WI"])
	_G.REPorterFrameExternal:SetHorizontalScroll(RE.MapSettings[mapFileName]["HO"])
	_G.REPorterFrameExternal:SetVerticalScroll(RE.MapSettings[mapFileName]["VE"])
	_G.REPorterFrameBorder:SetHeight(RE.MapSettings[mapFileName]["HE"] + 5)
	_G.REPorterFrameBorder:SetWidth(RE.MapSettings[mapFileName]["WI"] + 5)
	local texName
	local numDetailTiles = GetNumberOfDetailTiles()
	for i=1, numDetailTiles do
		if mapFileName == "STVDiamondMineBG" then
			texName = "Interface\\WorldMap\\"..mapFileName.."\\"..mapFileName.."1_"..i
		else
			texName = "Interface\\WorldMap\\"..mapFileName.."\\"..mapFileName..i
		end
		_G["REPorterFrame"..i]:SetTexture(texName)
	end
	_G.REPorterFrameExternal:Show()
	_G.REPorterFrameTab:Show()
	_G.InterfaceOptionsFrame:SetFrameStrata("LOW")
	_G.REPorterFrameExternal:SetFrameStrata("MEDIUM")
end

function RE:HideDummyMap()
	if select(2, IsInInstance()) ~= "pvp" then
		RE.ScaleDisabled = true
		RE.CurrentMap = ""
		RE.LastMap = 0
		_G.REPorterFrameExternal:Hide()
		_G.REPorterFrameTab:Hide()
		_G.InterfaceOptionsFrame:SetFrameStrata("HIGH")
		_G.REPorterFrameExternal:SetFrameStrata("LOW")
	end
end
--
