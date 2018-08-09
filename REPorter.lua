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

--GLOBALS: FACTION_ALLIANCE, FACTION_HORDE, HELP_LABEL, ATTACK, HEALTH, BLUE_GEM, RED_GEM, OPTIONS, MAX_RAID_MEMBERS, UIDROPDOWNMENU_VALUE_PATCH_VERSION, UIDROPDOWNMENU_MAXLEVELS, UIDROPDOWNMENU_MAXBUTTONS, UIDROPDOWNMENU_OPEN_PATCH_VERSION, UIDROPDOWNMENU_OPEN_MENU, issecurevariable
local select, pairs, strsplit, tonumber, strfind, print, strupper, next, strmatch, wipe, floor = _G.select, _G.pairs, _G.strsplit, _G.tonumber, _G.strfind, _G.print, _G.strupper, _G.next, _G.strmatch, _G.wipe, _G.floor
local CreateFrame = _G.CreateFrame
local CreateFramePool = _G.CreateFramePool
local IsInInstance = _G.IsInInstance
local IsInGuild = _G.IsInGuild
local IsShiftKeyDown = _G.IsShiftKeyDown
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local IsInBrawl = _G.C_PvP.IsInBrawl
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
RE.POINumber = 20
RE.MapUpdateRate = 0.05
RE.LastMap = 0
RE.CurrentMap = -1
RE.NeedRefresh = false
RE.UpdateInProgress = false
RE.BGVehicles = {}
RE.POINodes = {}
RE.POIInfo = {}
RE.POIList = {}
RE.VignetteInfo = {}
RE.VignettePosition = {}
RE.PinTextures = {}
RE.ClickedPOI = ""

RE.DefaultTimer = 60
RE.CareAboutNodes = false
RE.CareAboutPoints = false
RE.CareAboutGates = false
RE.CareAboutFlags = false
RE.CareAboutVehicles = false
RE.PlayedFromStart = true
RE.IoCAllianceGateName = ""
RE.IoCHordeGateName = ""
RE.IoCGateHealth = 1497600
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
RE.AddonVersionCheck = 216
RE.ScreenHeight, RE.ScreenWidth = _G.UIParent:GetCenter()

RE.MapSettings = {
	[AB] = {["PointsToWin"] = 1500, ["StartTimer"] = 120, ["PlayerNumber"] = 15},
	[WG] = {["StartTimer"] = 120, ["PlayerNumber"] = 10},
	[AV] = {["StartTimer"] = 120, ["PlayerNumber"] = 40},
	[EOTS] = {["PointsToWin"] = 1500, ["StartTimer"] = 120, ["PlayerNumber"] = 15},
	[IOC] = {["StartTimer"] = 120, ["PlayerNumber"] = 40},
	[BFG] = {["PointsToWin"] = 1500, ["StartTimer"] = 120, ["PlayerNumber"] = 10},
	[TP] = {["StartTimer"] = 120, ["PlayerNumber"] = 10},
	[TOK] = {["PointsToWin"] = 1500, ["StartTimer"] = 120, ["PlayerNumber"] = 10},
	[SM] = {["PointsToWin"] = 1500, ["StartTimer"] = 120, ["PlayerNumber"] = 10},
	[DG] = {["PointsToWin"] = 1500, ["StartTimer"] = 120, ["PlayerNumber"] = 15},
	[TMVS] = {["StartTimer"] = 120, ["PlayerNumber"] = 40},
	[SS] = {["StartTimer"] = 120, ["PlayerNumber"] = 10}
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
	profile = {
		BarHandle = 11,
		BarX = RE.ScreenHeight,
		BarY = RE.ScreenWidth,
		Locked = false,
		Opacity = 0.75,
		HideMinimap = false,
		DisplayMarks = false,
		DisplayHealers = false,
		Map = {
			[AB] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 325, ["wh"] = 325, ["mx"] = 16, ["my"] = -77, ["ms"] = 1},
			[WG] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 280, ["wh"] = 460, ["mx"] = -5, ["my"] = -38, ["ms"] = 1},
			[AV] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 185, ["wh"] = 450, ["mx"] = 32, ["my"] = -36, ["ms"] = 1},
			[EOTS] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 220, ["wh"] = 360, ["mx"] = 23, ["my"] = -41, ["ms"] = 1},
			[IOC] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 290, ["wh"] = 375, ["mx"] = 13, ["my"] = -23, ["ms"] = 1},
			[BFG] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 340, ["wh"] = 370, ["mx"] = 6, ["my"] = -28, ["ms"] = 1},
			[TP] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 245, ["wh"] = 460, ["mx"] = 1, ["my"] = -33, ["ms"] = 1},
			[TOK] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 390, ["wh"] = 250, ["mx"] = 19, ["my"] = -21, ["ms"] = 1},
			[SM] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 460, ["wh"] = 350, ["mx"] = 7, ["my"] = -43, ["ms"] = 1},
			[DG] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 520, ["wh"] = 385, ["mx"] = -10, ["my"] = -45, ["ms"] = 1},
			[TMVS] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 220, ["wh"] = 370, ["mx"] = -2, ["my"] = -22, ["ms"] = 1},
			[SS] = {["wx"] = RE.ScreenHeight, ["wy"] = RE.ScreenWidth, ["ww"] = 360, ["wh"] = 385, ["mx"] = 66, ["my"] = -63, ["ms"] = 1}
		}
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
		Options = {
			type = "group",
			name = OPTIONS,
			args = {
				Locked = {
					name = L["Lock map"],
					desc = L["When checked map and report bar is locked in place."],
					type = "toggle",
					width = "full",
					order = 1,
					set = function(_, val) RE.Settings.profile.Locked = val; RE:UpdateConfig() end,
					get = function(_) return RE.Settings.profile.Locked end
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
					set = function(_, val) RE.Settings.profile.HideMinimap = val; RE:UpdateConfig() end,
					get = function(_) return RE.Settings.profile.HideMinimap end
				},
				DisplayMarks = {
					name = L["Always display raid markers"],
					desc = L["When checked player pins will be always replaced with raid markers."],
					type = "toggle",
					width = "full",
					order = 4,
					set = function(_, val) RE.Settings.profile.DisplayMarks = val; RE:UpdateConfig() end,
					get = function(_) return RE.Settings.profile.DisplayMarks end
				},
				DisplayHealers = {
					name = L["Always highlight the healers"],
					desc = L["When checked healers will always be highlighted."],
					type = "toggle",
					width = "full",
					order = 5,
					set = function(_, val) RE.Settings.profile.DisplayHealers = val; RE:UpdateConfig() end,
					get = function(_) return RE.Settings.profile.DisplayHealers end
				},
				BarHandle = {
					name = L["Report bar location"],
					desc = L["Anchor point of a bar with quick report buttons."],
					type = "select",
					width = "double",
					order = 6,
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
					set = function(_, val) RE.Settings.profile.BarHandle = val; RE.Settings.profile.BarX, RE.Settings.profile.BarY = _G.REPorterBar:GetCenter(); RE:UpdateConfig() end,
					get = function(_) return RE.Settings.profile.BarHandle end
				},
				MapSettings = {
					name = BATTLEGROUND,
					desc = L["Map position is saved separately for each battleground."],
					type = "select",
					width = "double",
					order = 7,
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
					order = 8,
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
					order = 9,
					isPercent = true,
					min = 0.1,
					max = 1,
					step = 0.01,
					set = function(_, val) RE.Settings.profile.Opacity = val; RE:UpdateConfig() end,
					get = function(_) return RE.Settings.profile.Opacity end
				},
			}
		}
	}
}

local function ElvUISwag(sender)
  if sender == "Livarax-BurningLegion" then
    return [[|TInterface\PvPRankBadges\PvPRank09:0|t ]]
  end
  return nil
end

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
	local TimeSec = floor(TimeRaw % 60)
	local TimeMin = floor(TimeRaw / 60)
	if TimeSec < 10 then
		TimeSec = "0" .. TimeSec
	end
	return TimeMin .. ":" .. TimeSec
end

function RE:Round(num, idp)
	local mult = 10^(idp or 0)
	return floor(num * mult + 0.5) / mult
end

function RE:GetRealCoords(rawX, rawY)
	-- X -17 Y -78
	return rawX * 783, -rawY * 522
end

function RE:CheckCoordinates(x1, y1, x2, y2)
	x1 = floor(x1)
	y1 = floor(y1)
	return (x1 == x2 or x1 == x2 + 1 or x1 == x2 - 1) and (y1 == y2 or y1 == y2 + 1 or y1 == y2 - 1)
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
		RE.IoCGateEstimatorText = "|cFF00A9FF"..RE:Round((RE.IoCGateEstimator[FACTION_HORDE] / RE.IoCGateHealth) * 100, 0).."%|r"
	elseif RE.IoCGateEstimator[FACTION_HORDE] > RE.IoCGateEstimator[FACTION_ALLIANCE] then
		RE.IoCGateEstimatorText = "|cFFFF141D"..RE:Round((RE.IoCGateEstimator[FACTION_ALLIANCE] / RE.IoCGateHealth) * 100, 0).."%|r"
	else
		RE.IoCGateEstimatorText = ""
	end
end

function RE:PointParse(custom, id)
	local PointsNeeded, BaseNum = 0, 0
	if custom then
		local text = GetIconAndTextWidgetVisualizationInfo(GetAllWidgetsBySetID(GetTopCenterWidgetSetID())[id].widgetID).text
		if text ~= nil then
			PointsNeeded = RE.MapSettings[RE.CurrentMap].PointsToWin - tonumber(strmatch(text, "(%d+)/%d+"))
		end
	else
		local text = GetIconAndTextWidgetVisualizationInfo(GetAllWidgetsBySetID(GetTopCenterWidgetSetID())[id].widgetID).text
		if text ~= nil then
			BaseNum = tonumber(strmatch(text, "(%d+)"))
			PointsNeeded = RE.MapSettings[RE.CurrentMap].PointsToWin - tonumber(strmatch(text, "(%d+)/%d+"))
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

function RE:TimerNull()
	-- And Now His Watch is Ended
end

function RE:TimerJoinCheck()
	if RE.CurrentMap ~= -1 and GetBattlefieldInstanceRunTime()/1000 > RE.MapSettings[RE.CurrentMap].StartTimer then
		RE.PlayedFromStart = false
		RE:OnPOIUpdate()
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
	_G.REPorterBar:SetAlpha(RE.Settings.profile.Opacity)
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
		RE.ConfigFrame.obj.children[1].children[1].children[8]:SetValue(newscale)
	end
end

function RE:OnEvent(self, event, ...)
	if event == "ADDON_LOADED" and ... == "REPorter" then
		RE.UpdateTimer = 0
		RE.Settings = _G.LibStub("AceDB-3.0"):New("REPorterSettings", RE.DefaultConfig, true)
		RE.Settings.RegisterCallback(self, "OnProfileShutdown", function() RE:HideDummyMap(true) end)
		RE.Settings.RegisterCallback(self, "OnProfileReset", function() RE:HideDummyMap(false) end)
		RE.Settings.RegisterCallback(self, "OnProfileCopied", function() RE:HideDummyMap(false) end)
		RE.AceConfig.args.Profiles = _G.LibStub("AceDBOptions-3.0"):GetOptionsTable(RE.Settings)

		_G.LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("REPorter", RE.AceConfig)
		RE.ConfigFrame = _G.LibStub("AceConfigDialog-3.0"):AddToBlizOptions("REPorter", "REPorter")
		_G.InterfaceOptionsFrame:HookScript("OnHide", function() RE:HideDummyMap(true) end)
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

		RE.IsSkinned = _G.AddOnSkins and _G.AddOnSkins[1]:CheckOption("REPorter") or false
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
		end
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and next(RE.POINodes) ~= nil then
		local _, event, _, _, _, _, _, guid, _, _, _, _, _, _, damage = CombatLogGetCurrentEventInfo()
		if event ~= "SPELL_BUILDING_DAMAGE" then return end

		local gateID = {strsplit("-", guid)}
		if gateID[6] == "195496" then -- Horde East
			RE.POINodes[RE.IoCHordeGateName.." - "..L["East"]].health = RE.POINodes[RE.IoCHordeGateName.." - "..L["East"]].health - damage
			if RE.POINodes[RE.IoCHordeGateName.." - "..L["East"]].health < RE.IoCGateEstimator[FACTION_HORDE] then
				RE.IoCGateEstimator[FACTION_HORDE] = RE.POINodes[RE.IoCHordeGateName.." - "..L["East"]].health
			end
		elseif gateID[6] == "195494" then -- Horde Central
			RE.POINodes[RE.IoCHordeGateName.." - "..L["Front"]].health = RE.POINodes[RE.IoCHordeGateName.." - "..L["Front"]].health - damage
			if RE.POINodes[RE.IoCHordeGateName.." - "..L["Front"]].health < RE.IoCGateEstimator[FACTION_HORDE] then
				RE.IoCGateEstimator[FACTION_HORDE] = RE.POINodes[RE.IoCHordeGateName.." - "..L["Front"]].health
			end
		elseif gateID[6] == "195495" then -- Horde West
			RE.POINodes[RE.IoCHordeGateName.." - "..L["West"]].health = RE.POINodes[RE.IoCHordeGateName.." - "..L["West"]].health - damage
			if RE.POINodes[RE.IoCHordeGateName.." - "..L["West"]].health < RE.IoCGateEstimator[FACTION_HORDE] then
				RE.IoCGateEstimator[FACTION_HORDE] = RE.POINodes[RE.IoCHordeGateName.." - "..L["West"]].health
			end
		elseif gateID[6] == "195700" then -- Alliance East
			RE.POINodes[RE.IoCAllianceGateName.." - "..L["East"]].health = RE.POINodes[RE.IoCAllianceGateName.." - "..L["East"]].health - damage
			if RE.POINodes[RE.IoCAllianceGateName.." - "..L["East"]].health < RE.IoCGateEstimator[FACTION_ALLIANCE] then
				RE.IoCGateEstimator[FACTION_ALLIANCE] = RE.POINodes[RE.IoCAllianceGateName.." - "..L["East"]].health
			end
		elseif gateID[6] == "195698" then -- Alliance Center
			RE.POINodes[RE.IoCAllianceGateName.." - "..L["Front"]].health = RE.POINodes[RE.IoCAllianceGateName.." - "..L["Front"]].health - damage
			if RE.POINodes[RE.IoCAllianceGateName.." - "..L["Front"]].health < RE.IoCGateEstimator[FACTION_ALLIANCE] then
				RE.IoCGateEstimator[FACTION_ALLIANCE] = RE.POINodes[RE.IoCAllianceGateName.." - "..L["Front"]].health
			end
		elseif gateID[6] == "195699" then -- Alliance West
			RE.POINodes[RE.IoCAllianceGateName.." - "..L["West"]].health = RE.POINodes[RE.IoCAllianceGateName.." - "..L["West"]].health - damage
			if RE.POINodes[RE.IoCAllianceGateName.." - "..L["West"]].health < RE.IoCGateEstimator[FACTION_ALLIANCE] then
				RE.IoCGateEstimator[FACTION_ALLIANCE] = RE.POINodes[RE.IoCAllianceGateName.." - "..L["West"]].health
			end
		end
		RE:UpdateIoCEstimator()
	elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
		local instance = select(2, IsInInstance())
		if RE.CurrentMap ~= -1 then
			RE:SaveMapSettings()
		end
		if instance ~= "pvp" then
			_G.REPorterFrame:Hide()
			_G.REPorterBar:Hide()
			_G.REPorterFrameEstimator:Hide()
		end
		if instance == "pvp" and RE.CurrentMap == -1 then
			local mapID = GetBestMapForUnit("player")
			if mapID == ABW then mapID = AB end
			if mapID and RE.MapSettings[mapID] then
				RE.CurrentMap = mapID
				RE:Startup()
			end
		elseif instance ~= "pvp" and RE.CurrentMap ~= -1 then
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
	elseif event == "AREA_POIS_UPDATED" or event == "VIGNETTES_UPDATED" then
		RE:OnPOIUpdate()
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

function RE:OnPOIUpdate()
	RE.UpdateInProgress = true
	wipe(RE.POIList)
	wipe(RE.POIInfo)
	for _, v in pairs(RE.POINodes) do
		v.active = false
	end
	if RE.CurrentMap ~= SS then
		RE.POIList = GetAreaPOIForMap(RE.CurrentMap)
	else
		RE.POIList = GetVignettes()
	end
	for i=1, #RE.POIList do
		local battlefieldPOIName = "REPorterFrameCorePOI"..i
		local battlefieldPOI = _G[battlefieldPOIName]
		local colorOverride = false
		if RE.CurrentMap == SS then
			wipe(RE.VignetteInfo)
			wipe(RE.VignettePosition)
			RE.VignetteInfo = GetVignetteInfo(RE.POIList[i])
			RE.VignettePosition = GetVignettePosition(RE.POIList[i], RE.CurrentMap)
			local xZ, yZ = RE:Round(RE.VignettePosition.x, 3), RE:Round(RE.VignettePosition.y, 3)
			RE.POIInfo = {["areaPoiID"] = RE.VignetteInfo.vignetteID, ["name"] = RE.VignetteInfo.name, ["description"] = "", ["position"] = {["x"] = RE.VignettePosition.x, ["y"] = RE.VignettePosition.y}, ["textureIndex"] = 0, ["atlasID"] = RE.VignetteInfo.atlasName}
			if RE.AzeriteNodes[xZ] and RE.AzeriteNodes[xZ][yZ] then
				RE.POIInfo.name = RE.AzeriteNodes[xZ][yZ]
			end
			if RE.VignetteInfo.atlasName == "AzeriteReady" then
				RE.POIInfo.textureIndex = 1002
			elseif RE.VignetteInfo.atlasName == "AzeriteSpawning" then
				RE.POIInfo.textureIndex = 1001
			end
		else
			RE.POIInfo = GetAreaPOIInfo(RE.CurrentMap, RE.POIList[i])
		end
		if RE.POIInfo.name and RE.POIInfo.textureIndex ~= nil and RE.POIInfo.textureIndex ~= 0 then
			local x, y = RE:GetRealCoords(RE.POIInfo.position.x, RE.POIInfo.position.y)
			local x1, x2, y1, y2 = GetPOITextureCoords(RE.POIInfo.textureIndex)
			if RE.CurrentMap == IOC then
				RE.POIInfo.gate = false
				if RE:CheckCoordinates(x, y, 421, -401) then
					RE.IoCAllianceGateName = RE.POIInfo.name
					RE.POIInfo.name = RE.POIInfo.name.." - "..L["East"]
					RE.POIInfo.gate = true
					x = x + 15
				elseif RE:CheckCoordinates(x, y, 381, -401) then
					RE.POIInfo.name = RE.POIInfo.name.." - "..L["West"]
					RE.POIInfo.gate = true
					x = x - 13
				elseif RE:CheckCoordinates(x, y, 401, -384) then
					RE.POIInfo.name = RE.POIInfo.name.." - "..L["Front"]
					RE.POIInfo.gate = true
					y = y + 15
				elseif RE:CheckCoordinates(x, y, 380, -165) then
					RE.IoCHordeGateName = RE.POIInfo.name
					RE.POIInfo.name = RE.POIInfo.name.." - "..L["Front"]
					RE.POIInfo.gate = true
					y = y - 15
				elseif RE:CheckCoordinates(x, y, 406, -145) then
					RE.POIInfo.name = RE.POIInfo.name.." - "..L["East"]
					RE.POIInfo.gate = true
					x = x + 10
				elseif RE:CheckCoordinates(x, y, 355, -145) then
					RE.POIInfo.name = RE.POIInfo.name.." - "..L["West"]
					RE.POIInfo.gate = true
					x = x - 10
					y = y - 1
				end
			elseif RE.CurrentMap == AV then
				if RE:CheckCoordinates(x, y, 385, -78) then
					y = y - 15
				elseif RE:CheckCoordinates(x, y, 405, -189) then
					y = y - 10
				elseif RE:CheckCoordinates(x, y, 404, -299) then
					x = x + 10
				elseif RE:CheckCoordinates(x, y, 385, -401) then
					x = x + 10
				elseif RE:CheckCoordinates(x, y, 332, -83) then
					x = x - 20
				elseif RE:CheckCoordinates(x, y, 334, -95) then
					y = y - 20
				elseif RE:CheckCoordinates(x, y, 354, -76) then
					y = y + 10
				elseif RE:CheckCoordinates(x, y, 352, -78) then
					y = y + 15
				elseif RE:CheckCoordinates(x, y, 390, -53) then
					y = y - 5
				elseif RE:CheckCoordinates(x, y, 387, -444) then
					x = x + 25
					y = y + 5
				elseif RE:CheckCoordinates(x, y, 385, -463) then
					y = y - 10
				end
			elseif RE.CurrentMap == TOK then
				if RE.POIInfo.areaPoiID == 2774 then
					RE.POIInfo.name = RE.POIInfo.name.." - "..BLUE_GEM
					colorOverride = {0, 0, 1}
				elseif RE.POIInfo.areaPoiID == 2775 then
					RE.POIInfo.name = RE.POIInfo.name.." - "..L["Purple"]
					colorOverride = {0.5, 0, 0.5}
				elseif RE.POIInfo.areaPoiID == 2776 then
					RE.POIInfo.name = RE.POIInfo.name.." - "..RED_GEM
					colorOverride = {1, 0, 0}
				elseif RE.POIInfo.areaPoiID == 2777 then
					RE.POIInfo.name = RE.POIInfo.name.." - "..L["Green"]
					colorOverride = {0, 1, 0}
				end
			end
			if RE.POINodes[RE.POIInfo.name] == nil then
				RE.POINodes[RE.POIInfo.name] = {["id"] = i, ["poiID"] = RE.POIInfo.areaPoiID, ["name"] = RE.POIInfo.name, ["status"] = RE.POIInfo.description, ["x"] = x, ["y"] = y, ["texture"] = RE.POIInfo.textureIndex, ["active"] = true}
				if RE.CurrentMap == IOC and RE.POIInfo.gate then
					RE.POINodes[RE.POIInfo.name].health = RE.IoCGateHealth
					RE.POINodes[RE.POIInfo.name].maxHealth = RE.IoCGateHealth
				elseif RE.CurrentMap == SS and RE.PlayedFromStart then
					RE:NodeChange(RE.POIInfo.textureIndex, RE.POIInfo.name)
				end
			else
				RE.POINodes[RE.POIInfo.name].id = i
				RE.POINodes[RE.POIInfo.name].poiID = RE.POIInfo.areaPoiID
				RE.POINodes[RE.POIInfo.name].name = RE.POIInfo.name
				RE.POINodes[RE.POIInfo.name].status = RE.POIInfo.description
				RE.POINodes[RE.POIInfo.name].x = x
				RE.POINodes[RE.POIInfo.name].y = y
				RE.POINodes[RE.POIInfo.name].active = true
				if RE.CareAboutNodes and RE.POINodes[RE.POIInfo.name].texture and RE.POINodes[RE.POIInfo.name].texture ~= RE.POIInfo.textureIndex then
					RE:NodeChange(RE.POIInfo.textureIndex, RE.POIInfo.name)
				end
				RE.POINodes[RE.POIInfo.name].texture = RE.POIInfo.textureIndex
			end
			battlefieldPOI.name = RE.POIInfo.name
			battlefieldPOI:SetPoint("CENTER", "REPorterFrameCorePOI", "TOPLEFT", x, y)
			battlefieldPOI:SetWidth(RE.POIIconSize)
			battlefieldPOI:SetHeight(RE.POIIconSize)
			if RE.POIInfo.textureIndex > 1000 then
				_G[battlefieldPOIName.."Texture"]:SetAtlas(RE.POIInfo.atlasID)
			else
				_G[battlefieldPOIName.."Texture"]:SetTexCoord(x1, x2, y1, y2)
			end
			if colorOverride then
				_G[battlefieldPOIName.."Texture"]:SetVertexColor(colorOverride[1], colorOverride[2], colorOverride[3], 1)
			else
				_G[battlefieldPOIName.."Texture"]:SetVertexColor(1, 1, 1, 1)
			end
		end
	end
	RE.UpdateInProgress = false
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
			for i = 1, RE.MapSettings[RE.CurrentMap].PlayerNumber do
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
							_G.REPorterFrameCoreUP:AddUnit(unit, texture.."Healer", 30, 30, r, g, b, 1, 0, false)
						end
					else
						RE.IsOverlay = false
						if RE.Settings.profile.DisplayMarks and raidMarker ~= nil then
							texture = "Interface\\Addons\\REPorter\\Textures\\RaidMarker"..raidMarker
							_G.REPorterFrameCoreUP:AddUnit(unit, texture, 25, 25, 1, 1, 1, 1, 0, false)
						elseif RE.Settings.profile.DisplayHealers and UnitGroupRolesAssigned(unit) == "HEALER" then
							_G.REPorterFrameCoreUP:AddUnit(unit, texture.."Healer", 30, 30, r, g, b, 1, 0, false)
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

		if RE.CareAboutFlags then
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
		end

		if RE.CareAboutVehicles then
			RE.NumVehicles = GetNumBattlefieldVehicles()
			local totalVehicles = #RE.BGVehicles
			local index = 0
			for i=1, RE.NumVehicles do
				if i > totalVehicles then
					local vehicleName = "REPorterFrameCorePOIVehicle"..i
					RE.BGVehicles[i] = CreateFrame("FRAME", vehicleName, _G.REPorterFrameCorePOI, "REPorterVehicleTemplate")
					RE.BGVehicles[i].texture = _G[vehicleName.."Texture"]
				end
				local vehicleX, vehicleY, unitName, isPossessed, vehicleType, orientation, isPlayer, isAlive = GetBattlefieldVehicleInfo(i, RE.CurrentMap)
				if vehicleX and isAlive and not isPlayer and vehicleType ~= "Idle" then
					vehicleX, vehicleY = RE:GetRealCoords(vehicleX, vehicleY)
					RE.BGVehicles[i].texture:SetTexture(GetVehicleTexture(vehicleType, isPossessed))
					RE.BGVehicles[i].texture:SetRotation(orientation)
					RE.BGVehicles[i].name = unitName
					RE.BGVehicles[i]:SetPoint("CENTER", "REPorterFrameCorePOI", "TOPLEFT", vehicleX, vehicleY)
					if IsShiftKeyDown() and IsAltKeyDown() then
						RE.BGVehicles[i]:SetFrameLevel(9)
					else
						RE.BGVehicles[i]:SetFrameLevel(playerBlipFrameLevel - 1)
					end
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
		end

		if not RE.UpdateInProgress then
			for i=1, RE.POINumber do
				_G["REPorterFrameCorePOI"..i]:Hide()
				_G["REPorterFrameCorePOI"..i.."Timer"]:Hide()
			end
			for _, v in pairs(RE.POINodes) do
				if v.active then
				  local battlefieldPOIName = "REPorterFrameCorePOI"..v.id
					local battlefieldPOI = _G[battlefieldPOIName]
				  if TIMER:TimeLeft(v.timer) == 0 then
				    if strfind(v.status, FACTION_HORDE) then
				      _G[battlefieldPOIName.."TextureBG"]:SetColorTexture(1,0,0,0.3)
				    elseif strfind(v.status, FACTION_ALLIANCE) then
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
				    if RE.CareAboutGates and v.health and v.health > 0 then
				      _G[battlefieldPOIName.."TextureBGTop1"]:Hide()
				      _G[battlefieldPOIName.."TextureBGTop2"]:Show()
				      _G[battlefieldPOIName.."TextureBGTop2"]:SetWidth((v.health/v.maxHealth) * RE.POIIconSize)
				      if RE.PlayedFromStart then
								_G[battlefieldPOIName.."TimerCaption"]:SetText(RE:Round((v.health/v.maxHealth)*100, 0).."%")
				      else
				        _G[battlefieldPOIName.."TimerCaption"]:SetText("|cFFFF141D"..RE:Round((v.health/v.maxHealth)*100, 0).."%|r")
				      end
				      _G[battlefieldPOIName.."Timer"]:Show()
				    else
				      _G[battlefieldPOIName.."TextureBGTop1"]:Hide()
				      _G[battlefieldPOIName.."TextureBGTop2"]:Hide()
				      _G[battlefieldPOIName.."Timer"]:Hide()
				    end
				  else
				    local timeLeft = TIMER:TimeLeft(v.timer)
				    _G[battlefieldPOIName.."TextureBG"]:SetWidth(RE.POIIconSize - ((timeLeft / RE.DefaultTimer) * RE.POIIconSize))
				    _G[battlefieldPOIName.."TextureBGofBG"]:Show()
				    _G[battlefieldPOIName.."TextureBGofBG"]:SetWidth((timeLeft / RE.DefaultTimer) * RE.POIIconSize)
				    if v.isCapturing == FACTION_HORDE or RE.CurrentMap == SS then
				      _G[battlefieldPOIName.."TextureBG"]:SetColorTexture(1,0,0,RE.BlinkPOIValue)
				    elseif v.isCapturing == FACTION_ALLIANCE then
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
				    _G[battlefieldPOIName.."TimerCaption"]:SetText(RE:ShortTime(RE:Round(TIMER:TimeLeft(v.timer), 0)))
				  end
					battlefieldPOI:Show()
				end
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
		elseif RE.CurrentMap == IOC and RE.PlayedFromStart then
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

function RE:UnitOnEnterPOI(self)
	local tooltipText = ""
	local prefix = ""
	local battlefieldPOI = _G[self:GetName()]

	if battlefieldPOI:IsMouseOver() and battlefieldPOI.name ~= "" then
		local status = ""
		if RE.POINodes[battlefieldPOI.name].status and RE.POINodes[battlefieldPOI.name].status ~= "" then
			status = "\n"..RE.POINodes[battlefieldPOI.name].status
		end
		if RE.POINodes[battlefieldPOI.name].health then
			if RE.PlayedFromStart then
				status = "\n["..RE:Round((RE.POINodes[battlefieldPOI.name].health/RE.POINodes[battlefieldPOI.name].maxHealth)*100, 0).."%]"
			else
				status = "\n[|r|cFFFF141D"..RE:Round((RE.POINodes[battlefieldPOI.name].health/RE.POINodes[battlefieldPOI.name].maxHealth)*100, 0).."%|r|cFFFFFFFF]"
			end
		end
		if TIMER:TimeLeft(RE.POINodes[battlefieldPOI.name].timer) == 0 then
			tooltipText = tooltipText..prefix..battlefieldPOI.name.."|cFFFFFFFF"..status.."|r"
		else
			tooltipText = tooltipText..prefix..battlefieldPOI.name.."|cFFFFFFFF ["..RE:ShortTime(RE:Round(TIMER:TimeLeft(RE.POINodes[battlefieldPOI.name].timer), 0)).."]"..status.."|r"
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
	RE.ClickedPOI = RE.POINodes[self.name].name
	_G.EasyMenu(RE.POIDropDown, _G.REPorterReportDropDown, self, 0 , 0, "MENU")
end
---

-- *** Core functions
function RE:Startup()
	RE.PlayedFromStart = true
	RE:Create()
	_G.REPorterFrameCoreUP:ResetCurrentMouseOverUnits()
	_G.REPorterFrame:Show()
	_G.REPorterFrameEstimator:Show()
	if RE.Settings.profile.HideMinimap then
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
	RE.CareAboutVehicles = false
	_G.REPorterFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	_G.REPorterFrame:UnregisterEvent("VIGNETTES_UPDATED")
	_G.REPorterFrame:UnregisterEvent("AREA_POIS_UPDATED")
	_G.REPorterFrameEstimatorText:SetText("")
	_G.REPorterFrameCoreUP:ResetCurrentMouseOverUnits()
	_G.CloseDropDownMenus()
	BUCKET:UnregisterBucket(RE.EventBucket)
	if not _G.MinimapCluster:IsShown() and RE.Settings.profile.HideMinimap then
		_G.MinimapCluster:Show()
	end
	for i=1, RE.POINumber do
		_G["REPorterFrameCorePOI"..i]:Hide()
		_G["REPorterFrameCorePOI"..i.."Timer"]:Hide()
		_G["REPorterFrameCorePOI"..i.."Texture"]:SetTexture("Interface\\Minimap\\POIIcons")
		_G["REPorterFrameCorePOI"..i.."Texture"]:SetTexCoord(0, 1, 0, 1)
		for _, v in pairs(RE.POINodes) do
			TIMER:CancelTimer(v.timer)
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
	_G.REPorterFrameEstimator:ClearAllPoints()
	RE.IsBrawl = IsInBrawl()
	RE.POINodes = {}

	if RE.CurrentMap == TOK or RE.CurrentMap == DG then
		_G.REPorterFrameEstimator:SetPoint("RIGHT", _G.UIWidgetTopCenterContainerFrame, "LEFT", -50, 0)
	elseif RE.CurrentMap == SM or RE.CurrentMap == IOC then
		_G.REPorterFrameEstimator:SetPoint("RIGHT", _G.UIWidgetTopCenterContainerFrame, "LEFT", -35, 0)
	else
		_G.REPorterFrameEstimator:SetPoint("RIGHT", _G.UIWidgetTopCenterContainerFrame, "LEFT", -60, 0)
	end

	if RE.CurrentMap == IOC then
		RE.IoCGateEstimator = {}
		RE.IoCGateEstimator[FACTION_ALLIANCE] = RE.IoCGateHealth
		RE.IoCGateEstimator[FACTION_HORDE] = RE.IoCGateHealth
		RE.IoCGateEstimatorText = ""
	elseif RE.CurrentMap == SM then
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

	if RE.CurrentMap == AV or RE.CurrentMap == BFG or RE.CurrentMap == IOC or RE.CurrentMap == AB or RE.CurrentMap == DG or RE.CurrentMap == SS or RE.CurrentMap == EOTS or RE.CurrentMap == TOK then
		RE.CareAboutNodes = true
		if RE.CurrentMap == SS then
			_G.REPorterFrame:RegisterEvent("VIGNETTES_UPDATED")
		else
			_G.REPorterFrame:RegisterEvent("AREA_POIS_UPDATED")
		end
	else
		RE.CareAboutNodes = false
	end
	if RE.CurrentMap == BFG or RE.CurrentMap == EOTS or RE.CurrentMap == AB or RE.CurrentMap == DG or RE.CurrentMap == SM or RE.CurrentMap == TOK then
		RE.CareAboutPoints = true
		RE.EventBucket = BUCKET:RegisterBucketEvent({"BATTLEGROUND_POINTS_UPDATE", "UPDATE_UI_WIDGET"}, 2, RE.OnPointsUpdate)
	else
		RE.CareAboutPoints = false
	end
	if RE.CurrentMap == IOC then
		RE.CareAboutGates = true
		_G.REPorterFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	else
		RE.CareAboutGates = false
	end
	if RE.CurrentMap == WG or RE.CurrentMap == TP or RE.CurrentMap == EOTS or RE.CurrentMap == TOK or (RE.CurrentMap == DG and RE.IsBrawl) then
		RE.CareAboutFlags = true
	else
		RE.CareAboutFlags = false
	end
	if RE.CurrentMap == IOC or RE.CurrentMap == SM or RE.CurrentMap == DG then
		RE.CareAboutVehicles = true
	else
		RE.CareAboutVehicles = false
	end

	RE:LoadMapSettings()
	RE:SetupReportBar()
	TIMER:ScheduleTimer(RE.TimerJoinCheck, 5)
	_G.REPorterFrameCore:SetScript("OnUpdate", RE.OnUpdate)
end

function RE:NodeChange(newTexture, nodeName)
	TIMER:CancelTimer(RE.POINodes[nodeName].timer)
	if RE.CurrentMap == AV then
		if newTexture == 9 then -- Tower Ally
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_ALLIANCE
		elseif newTexture == 12 then -- Tower Horde
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_HORDE
		elseif newTexture == 4 then -- GY Ally
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_ALLIANCE
		elseif newTexture == 14 then -- GY Horde
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_HORDE
		end
	elseif RE.CurrentMap == EOTS then
		if newTexture == 9 then -- Tower Ally
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_ALLIANCE
		elseif newTexture == 12 then -- Tower Horde
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_HORDE
		end
	elseif RE.CurrentMap == BFG then
		if newTexture == 9 then -- Lighthouse Ally
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_ALLIANCE
		elseif newTexture == 12 then -- Lighthouse Horde
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_HORDE
		elseif newTexture == 27 then -- Waterworks Ally
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_ALLIANCE
		elseif newTexture == 29 then -- Waterworks Horde
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_HORDE
		elseif newTexture == 17 then -- Mine Ally
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_ALLIANCE
		elseif newTexture == 19 then -- Mine Horde
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_HORDE
		end
	elseif RE.CurrentMap == IOC then
		if newTexture == 9 then -- Keep Ally
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_ALLIANCE
		elseif newTexture == 12 then -- Keep Horde
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_HORDE
		elseif newTexture == 152 then -- Oil Ally
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_ALLIANCE
		elseif newTexture == 154 then -- Oil Horde
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_HORDE
		elseif newTexture == 147 then -- Dock Ally
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_ALLIANCE
		elseif newTexture == 149 then -- Dock Horde
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_HORDE
		elseif newTexture == 137 then -- Workshop Ally
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_ALLIANCE
		elseif newTexture == 139 then -- Workshop Horde
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_HORDE
		elseif newTexture == 142 then -- Air Ally
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_ALLIANCE
		elseif newTexture == 144 then -- Air Horde
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_HORDE
		elseif newTexture == 17 then -- Quary Ally
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_ALLIANCE
		elseif newTexture == 19 then -- Quary Horde
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_HORDE
		end
	elseif RE.CurrentMap == AB then
		if newTexture == 32 then -- Farm Ally
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_ALLIANCE
		elseif newTexture == 34 then -- Farm Horde
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_HORDE
		elseif newTexture == 17 then -- Mine Ally
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_ALLIANCE
		elseif newTexture == 19 then -- Mine Horde
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_HORDE
		elseif newTexture == 37 then -- Stables Ally
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_ALLIANCE
		elseif newTexture == 39 then -- Stables Horde
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_HORDE
		elseif newTexture == 27 then -- Blacksmith Ally
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_ALLIANCE
		elseif newTexture == 29 then -- Blacksmith Horde
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_HORDE
		elseif newTexture == 22 then -- Lumbermill Ally
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_ALLIANCE
		elseif newTexture == 24 then -- Lumbermill Horde
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_HORDE
		end
	elseif RE.CurrentMap == DG then
		if newTexture == 17 then -- Mine Ally
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_ALLIANCE
		elseif newTexture == 19 then -- Mine Horde
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = FACTION_HORDE
		end
	elseif RE.CurrentMap == SS then
		if newTexture == 1001 then
			RE.POINodes[nodeName].timer = TIMER:ScheduleTimer(RE.TimerNull, RE.DefaultTimer)
			RE.POINodes[nodeName].isCapturing = ""
		end
	end
end

function RE:POIStatus(POIName)
	if RE.POINodes[POIName]then
		if TIMER:TimeLeft(RE.POINodes[POIName].timer) == 0 then
			if RE.POINodes[POIName].health and RE.PlayedFromStart then
				local gateHealth = RE:Round((RE.POINodes[POIName].health / RE.POINodes[POIName].maxHealth) * 100, 0)
				return " - "..HEALTH..": "..gateHealth.."%"
			end
			return ""
		else
			local timeLeft = RE:ShortTime(RE:Round(TIMER:TimeLeft(RE.POINodes[POIName].timer), 0))
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
		if strfind(RE.POINodes[POIName].status, FACTION_HORDE) then
			return prefix..POIName.." ("..FACTION_HORDE..")"
		elseif strfind(RE.POINodes[POIName].status, FACTION_ALLIANCE) then
			return prefix..POIName.." ("..FACTION_ALLIANCE..")"
		else
			if RE.POINodes[POIName].isCapturing == FACTION_HORDE and TIMER:TimeLeft(RE.POINodes[POIName].timer) ~= 0 then
				return prefix..POIName.." ("..FACTION_HORDE..")"
			elseif RE.POINodes[POIName].isCapturing == FACTION_ALLIANCE and TIMER:TimeLeft(RE.POINodes[POIName].timer) ~= 0 then
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
	elseif RE.CurrentMap == IOC and RE.PlayedFromStart then
		SendChatMessage(FACTION_ALLIANCE.." "..L["gate"]..": "..RE:Round((RE.IoCGateEstimator[FACTION_ALLIANCE] / RE.IoCGateHealth) * 100, 0).."% - "..FACTION_HORDE.." "..L["gate"]..": "..RE:Round((RE.IoCGateEstimator[FACTION_HORDE] / RE.IoCGateHealth) * 100, 0).."%", "INSTANCE_CHAT")
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
	_G.REPorterFrame:SetAlpha(RE.Settings.profile.Opacity)
	_G.REPorterBar:SetAlpha(0.25)
	_G.REPorterFrameBorderResize:SetShown(not RE.Settings.profile.Locked)
	RE:SetupReportBar()
	if select(2, IsInInstance()) == "pvp" then
		_G.MinimapCluster:SetShown(not RE.Settings.profile.HideMinimap)
	end
end

function RE:UpdateScaleConfig(_, val)
	if RE.Settings.profile.Map[RE.CurrentMap] then
		if val then
			local scale = RE:Round(val, 2)
			_G.REPorterFrameCore:SetScale(scale)
			RE.Settings.profile.Map[RE.CurrentMap].ms = scale
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
	local handle = RE.Settings.profile.BarHandle
	local offset = 0

	if RE.IsSkinned then
		if handle == 3 or handle == 6 or handle == 9 or handle == 12 then
			offset = -2
		elseif handle == 1 or handle == 4 or handle == 7 or handle == 10 then
			offset = 2
		end
	end

	_G.REPorterBar:ClearAllPoints()
	if handle < 15 and not RE.ZonesWithoutSubZones[RE.CurrentMap] then
		_G.REPorterBar:SetAlpha(0.25)
		if RE.IsSkinned then
			_G.REPorterBarB1:SetPoint("TOPLEFT", "REPorterBar", "TOPLEFT", 5, -5)
		else
			_G.REPorterBarB1:SetPoint("TOPLEFT", "REPorterBar", "TOPLEFT", 10, -10)
		end
		if handle < 7 or handle == 13 then
			if handle == 13 then
				_G.REPorterBar:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", RE.Settings.profile.BarX, RE.Settings.profile.BarY)
			elseif handle > 3 then
				_G.REPorterBar:SetPoint(RE.ReportBarAnchor[handle][1], _G.REPorterFrameBorder, RE.ReportBarAnchor[handle][2], 1, offset)
			else
				_G.REPorterBar:SetPoint(RE.ReportBarAnchor[handle][1], _G.REPorterFrameBorder, RE.ReportBarAnchor[handle][2], -1, offset)
			end
			if RE.IsSkinned then
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
				_G.REPorterBar:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", RE.Settings.profile.BarX, RE.Settings.profile.BarY)
			elseif handle > 9 then
				_G.REPorterBar:SetPoint(RE.ReportBarAnchor[handle][1], _G.REPorterFrameBorder, RE.ReportBarAnchor[handle][2], offset, -1)
			else
				_G.REPorterBar:SetPoint(RE.ReportBarAnchor[handle][1], _G.REPorterFrameBorder, RE.ReportBarAnchor[handle][2], offset, 1)
			end
			if RE.IsSkinned then
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
		local wx, wy = RE.Settings.profile.Map[RE.CurrentMap].wx, RE.Settings.profile.Map[RE.CurrentMap].wy
		local ww = RE.Settings.profile.Map[RE.CurrentMap].ww
		local wh = RE.Settings.profile.Map[RE.CurrentMap].wh
		local mx, my = RE.Settings.profile.Map[RE.CurrentMap].mx, RE.Settings.profile.Map[RE.CurrentMap].my
		local ms = RE.Settings.profile.Map[RE.CurrentMap].ms

		_G.REPorterFrame:ClearAllPoints()
		_G.REPorterFrameCore:ClearAllPoints()
		_G.REPorterFrameCoreAnchor:ClearAllPoints()
		_G.REPorterFrame:SetWidth(ww)
		_G.REPorterFrame:SetHeight(wh)
		_G.REPorterFrame:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", wx, wy)
		_G.REPorterFrameCore:SetScale(ms)
		_G.REPorterFrameCore:SetPoint("CENTER", _G.REPorterFrameCoreAnchor, "CENTER")
		_G.REPorterFrameCoreAnchor:SetPoint("CENTER", _G.REPorterFrameClip, "CENTER", mx, my)
		_G.REPorterFrame:SetAlpha(RE.Settings.profile.Opacity)

		local textures
		if RE.CurrentMap == AB and RE.IsBrawl then
			textures = GetMapArtLayerTextures(ABW, 1)
			RE.ZonesWithoutSubZones[AB] = true
		else
			textures = GetMapArtLayerTextures(RE.CurrentMap, 1)
			RE.ZonesWithoutSubZones[AB] = nil
		end
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

		RE.Settings.profile.Map[RE.CurrentMap] = {["wx"] = RE:Round(wx, 0), ["wy"] = RE:Round(wy, 0), ["ww"] = RE:Round(ww, 0), ["wh"] = RE:Round(wh, 0), ["mx"] = RE:Round(mx, 0), ["my"] = RE:Round(my, 0), ["ms"] = RE:Round(ms, 2)}
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

function RE:HideDummyMap(save)
	if _G.REPorterFrame:IsShown() and select(2, IsInInstance()) ~= "pvp" then
		if save then RE:SaveMapSettings() end
		RE.CurrentMap = -1
		RE.LastMap = 0
		_G.REPorterFrame:Hide()
		_G.REPorterBar:Hide()
		_G.InterfaceOptionsFrame:SetFrameStrata("HIGH")
	end
end
--
