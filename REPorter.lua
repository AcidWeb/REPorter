REPorterNamespace = {["AceTimer"] = {}};
local RE = REPorterNamespace;
local RES = REPorterSettings;
LibStub("AceTimer-3.0"):Embed(RE.AceTimer);

RE.POIIconSize = 30;
RE.POINumber = 25;
RE.MapUpdateRate = 0.05;
RE.BGVehicles = {};
RE.POINodes = {};
RE.PlayersTip = {};
RE.BGOverlayNum = 0;

RE.DefaultTimer = 60;
RE.DoIEvenCareAboutNodes = false;
RE.DoIEvenCareAboutPoints = false;
RE.DoIEvenCareAboutGates = false;
RE.PlayedFromStart = true;
RE.IoCAllianceGateName = "";
RE.IoCHordeGateName = "";
RE.IoCGateEstimator = {};
RE.IoCGateEstimatorText = "";
RE.SMEstimatorText = "";
RE.SMEstimatorReport = "";
RE.IsWinning = "";
RE.GateSyncRequested = false;

RE.BlipOffsetT = 0.5;
RE.BlinkPOIMin = 0.3;
RE.BlinkPOIMax = 0.6;
RE.BlinkPOI = 0.3;
RE.BlinkPOIUp = true;

RE.CurrentMap = "";
RE.ClickedPOI = "";

RE.FoundNewVersion = false;
RE.AddonVersionCheck = 90;
RE.Debug = 1;

RE.BlipCoords = {
	["WARRIOR"] = { 0, 0.125, 0, 0.25 },
	["PALADIN"] = { 0.125, 0.25, 0, 0.25 },
	["HUNTER"] = { 0.25, 0.375, 0, 0.25 },
	["ROGUE"] = { 0.375, 0.5, 0, 0.25 },
	["PRIEST"] = { 0.5, 0.625, 0, 0.25 },
	["DEATHKNIGHT"] = { 0.625, 0.75, 0, 0.25 },
	["SHAMAN"] = { 0.75, 0.875, 0, 0.25 },
	["MAGE"] = { 0.875, 1, 0, 0.25 },
	["WARLOCK"] = { 0, 0.125, 0.25, 0.5 },
	["DRUID"] = { 0.25, 0.375, 0.25, 0.5 },
	["MONK"] = { 0.125, 0.25, 0.25, 0.5 },
	["DEMONHUNTER"]	= { 0.375, 0.5, 0.25, 0.5 }
}
RE.ClassColors = {
	["HUNTER"] = "AAD372",
	["WARLOCK"] = "9482C9",
	["PRIEST"] = "FFFFFF",
	["PALADIN"] = "F48CBA",
	["MAGE"] = "68CCEF",
	["ROGUE"] = "FFF468",
	["DRUID"] = "FF7C0A",
	["SHAMAN"] = "0070DD",
	["WARRIOR"] = "C69B6D",
	["DEATHKNIGHT"] = "C41E3A",
	["MONK"] = "00FF96",
	["DEMONHUNTER"] = "A330C9"
};
RE.MapSettings = {
	["ArathiBasin"] = {["HE"] = 340, ["WI"] = 340, ["HO"] = 210, ["VE"] = 50, ["pointsToWin"] = 1500, ["WorldStateNum"] = 2, ["StartTimer"] = 120},
	["WarsongGulch"] = {["HE"] = 460, ["WI"] = 275, ["HO"] = 270, ["VE"] = 40, ["StartTimer"] = 120},
	["AlteracValley"] = {["HE"] = 460, ["WI"] = 200, ["HO"] = 270, ["VE"] = 35, ["StartTimer"] = 120},
	["NetherstormArena"] = {["HE"] = 340, ["WI"] = 200, ["HO"] = 275, ["VE"] = 90, ["pointsToWin"] = 1500, ["WorldStateNum"] = 3, ["StartTimer"] = 120},
	["StrandoftheAncients"] = {["HE"] = 410, ["WI"] = 275, ["HO"] = 240, ["VE"] = 100, ["StartTimer"] = 120},
	["IsleofConquest"] = {["HE"] = 370, ["WI"] = 325, ["HO"] = 230, ["VE"] = 85, ["StartTimer"] = 120},
	["GilneasBattleground2"] = {["HE"] = 360, ["WI"] = 325, ["HO"] = 230, ["VE"] = 90, ["pointsToWin"] = 1500, ["WorldStateNum"] = 2, ["StartTimer"] = 120},
	["TwinPeaks"] = {["HE"] = 435, ["WI"] = 250, ["HO"] = 280, ["VE"] = 40, ["StartTimer"] = 120},
	["TempleofKotmogu"] = {["HE"] = 250, ["WI"] = 400, ["HO"] = 185, ["VE"] = 155, ["pointsToWin"] = 1500, ["WorldStateNum"] = 2, ["StartTimer"] = 120},
	["STVDiamondMineBG"] = {["HE"] = 325, ["WI"] = 435, ["HO"] = 175, ["VE"] = 95, ["pointsToWin"] = 1500, ["WorldStateNum"] = 2, ["StartTimer"] = 120},
	["GoldRush"] = {["HE"] = 410, ["WI"] = 510, ["HO"] = 155, ["VE"] = 50, ["pointsToWin"] = 1500, ["WorldStateNum"] = 2, ["StartTimer"] = 120}
};
RE.EstimatorSettings = {
	["ArathiBasin"] = { [0] = 0, [1] = 0.8333, [2] = 1.1111, [3] = 1.6667, [4] = 3.3333, [5] = 30},
	["NetherstormArena"] = { [0] = 0, [1] = 0.5, [2] = 1, [3] = 2.5, [4] = 5},
	["GilneasBattleground2"] = { [0] = 0, [1] = 1.1111, [2] = 3.3333, [3] = 30},
	["GoldRush"] = { [0] = 0, [1] = 1.6, [2] = 3.2, [3] = 6.4},
	["TempleofKotmogu"] = {["CenterP"] = 1, ["InnerP"] = 0.8, ["OuterP"] = 0.6},
	["STVDiamondMineBG"] = 150
}
RE.POIDropDown = {
	{ text = "Incoming", hasArrow = true, notCheckable = true,
	menuList = {
		{ text = "1", notCheckable = true, minWidth = 15, func = function() REPorter_SmallButton(1, true); CloseDropDownMenus() end },
		{ text = "2", notCheckable = true, minWidth = 15, func = function() REPorter_SmallButton(2, true); CloseDropDownMenus() end },
		{ text = "3", notCheckable = true, minWidth = 15, func = function() REPorter_SmallButton(3, true); CloseDropDownMenus() end },
		{ text = "4", notCheckable = true, minWidth = 15, func = function() REPorter_SmallButton(4, true); CloseDropDownMenus() end },
		{ text = "5", notCheckable = true, minWidth = 15, func = function() REPorter_SmallButton(5, true); CloseDropDownMenus() end },
		{ text = "5+", notCheckable = true, minWidth = 15, func = function() REPorter_SmallButton(6, true); CloseDropDownMenus() end }
	} },
	{ text = "Help", notCheckable = true, func = function() REPorter_BigButton(true, true) end },
	{ text = "Clear", notCheckable = true, func = function() REPorter_BigButton(false, true) end },
	{ text = "", notCheckable = true, disabled = true },
	{ text = "Attack", notCheckable = true, func = function() REPorter_ReportDropDownClick("Attack") end },
	{ text = "Guard", notCheckable = true, func = function() REPorter_ReportDropDownClick("Guard") end },
	{ text = "Heavily defended", notCheckable = true, func = function() REPorter_ReportDropDownClick("Heavily defended") end },
	{ text = "Losing", notCheckable = true, func = function() REPorter_ReportDropDownClick("Losing") end },
	{ text = "", notCheckable = true, disabled = true },
	{ text = "Report status", notCheckable = true, func = function() REPorter_ReportDropDownClick("") end }
};
RE.DefaultConfig = {
	barHandle = 1,
	firstTime = true,
	locked = false,
	nameAdvert = false,
	opacity = 0.75,
	scale = 1
};
RE.ReportBarAnchor = {
	[1] = {"BOTTOMLEFT", "BOTTOMRIGHT"},
	[2] = {"LEFT", "RIGHT"},
	[3] = {"TOPLEFT", "TOPRIGHT"},
	[4] = {"BOTTOMRIGHT", "BOTTOMLEFT"},
	[5] = {"RIGHT", "LEFT"},
	[6] = {"TOPRIGHT", "TOPLEFT"}
};
RE.AceConfig = {
  type = "group",
  args = {
		locked = {
			name = "Lock map",
			desc = "When checked map is locked in place.",
			type = "toggle",
			width = "full",
			order = 1,
			set = function(_, val) RES.locked = val end,
			get = function(_) return RES.locked end
		},
    nameAdvert = {
      name = "Add \"[REPorter]\" to end of each report",
			desc = "When checked shameless ad is added to each battleground report.",
      type = "toggle",
			width = "full",
			order = 2,
      set = function(_, val) RES.nameAdvert = val; REPorter_UpdateConfig() end,
      get = function(_) return RES.nameAdvert end
    },
		barHandle = {
			name = "Report bar location",
			desc = "Anchor point of bar with quick report buttons.",
			type = "select",
			width = "double",
			order = 3,
			values = {
				[1] = "Bottom left",
				[2] = "Left",
				[3] = "Top left",
				[4] = "Bottom right",
				[5] = "Right",
				[6] = "Top right"
			},
			set = function(_, val) RES.barHandle = val; REPorter_UpdateConfig() end,
			get = function(_) return RES.barHandle end
		},
		scale = {
			name = "Map scale",
			desc = "This option control map size.",
			type = "range",
			width = "double",
			min = 0.5,
			max = 1.5,
			step = 0.05,
			set = function(_, val) RES.scale = val; REPorter_UpdateConfig() end,
			get = function(_) return RES.scale end
		},
		opacity = {
			name = "Map alpha",
			desc = "This option control map transparency.",
			type = "range",
			width = "double",
			isPercent = true,
			min = 0.1,
			max = 1,
			step = 0.01,
			set = function(_, val) RES.opacity = val; REPorter_UpdateConfig() end,
			get = function(_) return RES.opacity end
		},
		help = {
			name = "Map position is saved separately for each battleground.",
			type = "description",
			fontSize = "medium",
			order = 0
		}
  }
};

-- *** Auxiliary functions
function REPorter_BlinkPOI()
	if RE.BlinkPOI + 0.03 <= RE.BlinkPOIMax and RE.BlinkPOIUp then
		RE.BlinkPOI = RE.BlinkPOI + 0.03;
	else
		if RE.BlinkPOIUp then
			RE.BlinkPOIUp = false;
			RE.BlinkPOI = RE.BlinkPOI - 0.03;
		elseif RE.BlinkPOI - 0.03 <= RE.BlinkPOIMin then
			RE.BlinkPOIUp = true;
			RE.BlinkPOI = RE.BlinkPOI - 0.03;
		else
			RE.BlinkPOI = RE.BlinkPOI - 0.03;
		end
	end
end

function REPorter_ShortTime(TimeRaw)
	local TimeSec = math.floor(TimeRaw % 60);
	local TimeMin = math.floor(TimeRaw / 60);
	if TimeSec < 10 then
		TimeSec = "0" .. TimeSec;
	end
	return TimeMin .. ":" .. TimeSec;
end

function REPorter_Round(num, idp)
	local mult = 10^(idp or 0);
	return math.floor(num * mult + 0.5) / mult;
end

function REPorter_GetRealCoords(rawX, rawY)
	local realX, realY = 0, 0;
	-- X -17
	-- Y -78
	realX = rawX * 783;
	realY = -rawY * 522;
	return realX, realY;
end

function REPorter_PointDistance(x1, y1, x2, y2)
	local dx, dy, distance = 0, 0, 0;
	dx = x2 - x1;
	dy = y2 - y1;
	return math.sqrt(math.pow(dx, 2) + math.pow(dy, 2));
end

function REPorter_TableCount(Table)
	local RENum = 0;
	local RETable = {};
	for k,v in pairs(Table) do
		RENum = RENum + 1;
		table.insert(RETable, k);
	end
	return RENum, RETable;
end

function REPorter_ClearTextures()
	RE.AceTimer:CancelTimer(RE.EstimatorTimer);
	REPorterPlayer:Hide();
	for i=1, MAX_RAID_MEMBERS do
		local partyMemberFrame = _G["REPorterRaid"..(i)];
		partyMemberFrame:Hide();
	end
	for i=1, RE.POINumber do
		_G["REPorterPOI"..i]:Hide();
		_G["REPorterPOI"..i.."WarZone"]:Hide();
		_G["REPorterPOI"..i.."Timer"]:Hide();
		local tableCount, tableInternal = REPorter_TableCount(RE.POINodes);
		for i=1, tableCount do
			RE.AceTimer:CancelTimer(RE.POINodes[tableInternal[i]]["timer"]);
		end
	end
	for i=1, NUM_WORLDMAP_FLAGS do
		local flagFrameName = "REPorterFlag"..i;
		local flagFrame = _G[flagFrameName];
		flagFrame:Hide();
	end
	if RE.numVehicles then
		for i=1, RE.numVehicles do
			RE.BGVehicles[i]:Hide();
		end
	end
	local numDetailTiles = GetNumberOfDetailTiles();
	for i=1, numDetailTiles do
		_G["REPorter"..i]:SetTexture(nil);
	end
	for i=1, RE.BGOverlayNum do
		_G["REPorterMapOverlay"..i]:SetTexture(nil);
	end
	RE.POINodes = {};
end

function REPorter_CreatePOI(index)
	local frameMain = CreateFrame("Frame", "REPorterPOI"..index, REPorter);
	frameMain:SetWidth(RE.POIIconSize);
	frameMain:SetHeight(RE.POIIconSize);
	frameMain:SetScript("OnEnter", REPorterUnit_OnEnterPOI);
	frameMain:SetScript("OnLeave", REPorter_HideTooltip);
	frameMain:SetScript("OnMouseDown", REPorter_OnClickPOI);
	local texture = frameMain:CreateTexture(frameMain:GetName().."Texture", "BORDER");
	texture:SetPoint("CENTER", frameMain, "CENTER");
	texture:SetWidth(RE.POIIconSize - 13);
	texture:SetHeight(RE.POIIconSize - 13);
	texture:SetTexture("Interface\\Minimap\\POIIcons");
	local texture = frameMain:CreateTexture(frameMain:GetName().."TextureBG", "BACKGROUND");
	texture:SetPoint("TOPLEFT", frameMain, "TOPLEFT");
	texture:SetPoint("BOTTOMLEFT", frameMain, "BOTTOMLEFT");
	texture:SetWidth(RE.POIIconSize);
	texture:SetTexture(0,0,0,0.3, "BACKGROUND");
	local texture = frameMain:CreateTexture(frameMain:GetName().."TextureBGofBG", "BACKGROUND");
	texture:SetPoint("TOPRIGHT", frameMain, "TOPRIGHT");
	texture:SetPoint("BOTTOMRIGHT", frameMain, "BOTTOMRIGHT");
	texture:SetWidth(RE.POIIconSize);
	texture:SetTexture(0,0,0,0.3, "BACKGROUND");
	texture:Hide();
	local texture = frameMain:CreateTexture(frameMain:GetName().."TextureBGTop1", "BORDER");
	texture:SetPoint("TOPLEFT", frameMain, "TOPLEFT");
	texture:SetWidth(RE.POIIconSize);
	texture:SetHeight(3);
	texture:SetTexture(0,1,0,1, "BORDER");
	local texture = frameMain:CreateTexture(frameMain:GetName().."TextureBGTop2", "BORDER");
	texture:SetPoint("BOTTOMLEFT", frameMain, "BOTTOMLEFT");
	texture:SetWidth(RE.POIIconSize);
	texture:SetHeight(3);
	texture:SetTexture(0,1,0,1, "BORDER");
	local frame = CreateFrame("Frame", "REPorterPOI"..index.."WarZone", REPorter);
	frame:SetWidth(64);
	frame:SetHeight(64);
	local texture = frame:CreateTexture(frame:GetName().."Texture", "BACKGROUND");
	texture:SetAllPoints(frame);
	texture:SetTexture("Interface\\Addons\\REPorter\\Textures\\REPorterWarZone");
	frame:Hide();
	local frame = CreateFrame("Frame", "REPorterPOI"..index.."Timer", REPorterTimerOverlay, "REPorterPOITimerTemplate");
	frame:SetPoint("CENTER", frameMain, "CENTER");
end

function REPorter_UpdateIoCEstimator()
	if RE.IoCGateEstimator[FACTION_HORDE] < RE.IoCGateEstimator[FACTION_ALLIANCE] then
		RE.IoCGateEstimatorText = "|cFF00A9FF"..REPorter_Round((RE.IoCGateEstimator[FACTION_HORDE]/600000)*100, 0).."%|r";
	elseif RE.IoCGateEstimator[FACTION_HORDE] > RE.IoCGateEstimator[FACTION_ALLIANCE] then
		RE.IoCGateEstimatorText = "|cFFFF141D"..REPorter_Round((RE.IoCGateEstimator[FACTION_ALLIANCE]/600000)*100, 0).."%|r";
	else
		RE.IoCGateEstimatorText = "";
	end
end

function REPorter_HideTooltip()
	GameTooltip:Hide();
end

function REPorter_SOTAStartCheck()
	local startCheck = {GetMapLandmarkInfo(7)};
	local sideCheck = {GetMapLandmarkInfo(10)};
	return (startCheck[3] == 46 or startCheck[3] == 48), sideCheck[3] == 102;
end

function REPorter_EstimatorFill(AllianceTimeToWin, HordeTimeToWin, RefreshTimer)
	local RefreshTimer = RefreshTimer or 5;
	local TimeLeft = RE.AceTimer:TimeLeft(RE.EstimatorTimer);
	if AllianceTimeToWin > 1 and HordeTimeToWin > 1 then
		if AllianceTimeToWin < HordeTimeToWin then
			if RE.IsWinning ~= FACTION_ALLIANCE or (TimeLeft - AllianceTimeToWin > RefreshTimer) or (TimeLeft - AllianceTimeToWin < -RefreshTimer) then
				RE.AceTimer:CancelTimer(RE.EstimatorTimer);
				RE.IsWinning = FACTION_ALLIANCE;
				RE.EstimatorTimer = RE.AceTimer:ScheduleTimer("Null", REPorter_Round(AllianceTimeToWin, 0));
			end
		elseif AllianceTimeToWin > HordeTimeToWin then
			if RE.IsWinning ~= FACTION_HORDE or (TimeLeft - HordeTimeToWin > RefreshTimer) or (TimeLeft - HordeTimeToWin < -RefreshTimer) then
				RE.AceTimer:CancelTimer(RE.EstimatorTimer);
				RE.IsWinning = FACTION_HORDE;
				RE.EstimatorTimer = RE.AceTimer:ScheduleTimer("Null", REPorter_Round(HordeTimeToWin, 0));
			end
		else
			RE.IsWinning = "";
		end
	elseif AlliancePointNum == RE.MapSettings[RE.CurrentMap]["pointsToWin"] or HordePointNum == RE.MapSettings[RE.CurrentMap]["pointsToWin"] then
		RE.AceTimer:CancelTimer(RE.EstimatorTimer);
		RE.IsWinning = "";
	end
end

function REPorter_GetNearestPOI()
	local playerX, playerY = GetPlayerMapPosition("player");
	local node = "";
	if playerX ~= 0 and playerY ~= 0 then
	    playerX, playerY = REPorter_GetRealCoords(playerX, playerY);
	    for i=1, GetNumMapLandmarks() do
	        local name, _, _, x, y, _, showInBattleMap = GetMapLandmarkInfo(i);
	        if name and showInBattleMap then
	            x, y = REPorter_GetRealCoords(x, y);
	            if REPorter_PointDistance(playerX, playerY, x, y) < 50 then
					node = name;
	                break;
	            end
			end
	    end
	end
	return node;
end

function RE.AceTimer.Null()
	-- And Now His Watch is Ended
end

function RE.AceTimer.JoinCheck()
	local BGTime = GetBattlefieldInstanceRunTime()/1000;
	if RE.Debug > 0 then
		print("\124cFF74D06C[REPorter]\124r Join check - "..BGTime);
	end
	if BGTime > RE.MapSettings[RE.CurrentMap]["StartTimer"] then
		RE.PlayedFromStart = false;
		if RE.CurrentMap == "StrandoftheAncients" or RE.CurrentMap == "IsleofConquest" then
			RE.GateSyncRequested = true;
			SendAddonMessage("REPorter", "GateSyncRequest;", "INSTANCE_CHAT");
		end
	end
end

function RE.AceTimer.TabHider()
	REPorterTab:SetAlpha(0.20);
end
--

-- *** Event functions
function REPorter_OnLoad(self)
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("CHAT_MSG_ADDON");
	self:RegisterEvent("MODIFIER_STATE_CHANGED");
	RE.updateTimer = 0;
end

function REPorter_OnShow(self)
	SetMapToCurrentZone();
	REPorterExternal:SetScrollChild(REPorter);
	if RES.firstTime then
		RES.firstTime = nil;
		REPorterTutorial:Show();
	end
	REPorterTab:SetAlpha(0.25);
end

function REPorter_OnHide(self)
	REPorterExternal:SetScript("OnUpdate", nil);
	RE.CurrentMap = "";
	RE.DoIEvenCareAboutNodes = false;
	RE.DoIEvenCareAboutPoints = false;
	RE.DoIEvenCareAboutGates = false;
	REPorterExternal:UnregisterEvent("UPDATE_WORLD_STATES");
	REPorterExternal:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	REPorterExternal:UnregisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL");
	RE.IsWinning = "";
	REPorter_ClearTextures();
	CloseDropDownMenus();
	REPorterEstimator_Text:SetText("");
end

function REPorter_OnEnter(self)
	RE.AceTimer:CancelTimer(RE.TabHiderTimer);
	REPorterTab:SetAlpha(RES.opacity);
end

function REPorter_OnLeave(self)
	RE.AceTimer:CancelTimer(RE.TabHiderTimer);
	RE.TabHiderTimer = RE.AceTimer:ScheduleTimer("TabHider", 1.5);
end

function REPorter_OnEvent(self, event, ...)
	if event == "ADDON_LOADED" and ... == "REPorter" then
		if not REPorterSettings then
			REPorterSettings = RE.DefaultConfig;
		end
		RES = REPorterSettings;
		LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("REPorter", RE.AceConfig);
		LibStub("AceConfigDialog-3.0"):AddToBlizOptions("REPorter", "REPorter");
		REPorter_UpdateConfig();
		RegisterAddonMessagePrefix("REPorter");
		BINDING_HEADER_REPORTERB = "REPorter";
		BINDING_NAME_REPORTERINC1 = "Incoming 1";
		BINDING_NAME_REPORTERINC2 = "Incoming 2";
		BINDING_NAME_REPORTERINC3 = "Incoming 3";
		BINDING_NAME_REPORTERINC4 = "Incoming 4";
		BINDING_NAME_REPORTERINC5 = "Incoming 5";
		BINDING_NAME_REPORTERINC6 = "Incoming 5+";
		BINDING_NAME_REPORTERHELP = "Help";
		BINDING_NAME_REPORTERCLEAR = "Clear";
    for i=1, RE.POINumber do
        REPorter_CreatePOI(i);
    end
	elseif event == "CHAT_MSG_ADDON" and ... == "REPorter" then
		local _, REMessage, _, RESender = ...;
		if RE.Debug > 0 then
			print("\124cFF74D06C[REPorter]\124r "..RESender.." - "..REMessage);
		end
		local REMessageEx = {strsplit(";", REMessage)};
		if REMessageEx[1] == "Version" then
			if not RE.FoundNewVersion and tonumber(REMessageEx[2]) > RE.AddonVersionCheck then
				print("\124cFF74D06C[REPorter]\124r New version released!");
				RE.FoundNewVersion = true;
			end
		elseif REMessageEx[1] == "GateSyncRequest" and RE.PlayedFromStart then
			local message = "GateSync;";
			local tableCount, tableInternal = REPorter_TableCount(RE.POINodes);
			for i=1, tableCount do
				if RE.POINodes[tableInternal[i]]["health"] then
					message = message..RE.POINodes[tableInternal[i]]["id"]..";"..RE.POINodes[tableInternal[i]]["health"]..";";
				end
			end
			SendAddonMessage("REPorter", message, "INSTANCE_CHAT");
		elseif RE.GateSyncRequested and REMessageEx[1] == "GateSync" then
			RE.GateSyncRequested = false;
			local tableCount, tableInternal = REPorter_TableCount(RE.POINodes);
			for i=1, tableCount do
				for k=2, #REMessageEx do
					if REMessageEx[k] == RE.POINodes[tableInternal[i]]["id"] then
						RE.POINodes[tableInternal[i]]["health"] = REMessageEx[k+1];
					end
				end
			end
		end
	elseif event == "UPDATE_WORLD_STATES" and RE.MapSettings[RE.CurrentMap] then
		if RE.CurrentMap == "TempleofKotmogu" then
			local AlliancePointsNeeded, AlliancePointsPerSec, AllianceTimeToWin, HordePointsNeeded, HordePointsPerSec, HordeTimeToWin = nil, 0, 0, nil, 0, 0;
			local _, _, _, text = GetWorldStateUIInfo(RE.MapSettings["TempleofKotmogu"]["WorldStateNum"]);
			if text ~= nil then
				local Message = {strsplit("/", text)};
				if Message[1] then
					Message = {strsplit(" ", Message[1])};
					AlliancePointsNeeded = RE.MapSettings["TempleofKotmogu"]["pointsToWin"] - tonumber(Message[3]);
				end
			end
			local _, _, _, text = GetWorldStateUIInfo(RE.MapSettings["TempleofKotmogu"]["WorldStateNum"]+1);
			if text ~= nil then
				local Message = {strsplit("/", text)};
				if Message[1] then
					Message = {strsplit(" ", Message[1])};
					HordePointsNeeded = RE.MapSettings["TempleofKotmogu"]["pointsToWin"] - tonumber(Message[3]);
				end
			end
			if AlliancePointsNeeded and HordePointsNeeded then
				local numFlags = GetNumBattlefieldFlagPositions();
				for i=1, NUM_WORLDMAP_FLAGS do
					if i <= numFlags then
						local flagX, flagY, flagToken = GetBattlefieldFlagPosition(i);
						if flagX > 0 and flagY > 0 then
							flagX, flagY = REPorter_GetRealCoords(flagX, flagY);
							if flagToken == "AllianceFlag" then
								if flagX < 420 and flagX > 350 and flagY < -255 and flagY > -305 then
									AlliancePointsPerSec = AlliancePointsPerSec + RE.EstimatorSettings["TempleofKotmogu"]["CenterP"];
								elseif flagX < 470 and flagX > 300 and flagY < -210 and flagY > -350 then
									AlliancePointsPerSec = AlliancePointsPerSec + RE.EstimatorSettings["TempleofKotmogu"]["InnerP"];
								else
									AlliancePointsPerSec = AlliancePointsPerSec + RE.EstimatorSettings["TempleofKotmogu"]["OuterP"];
								end
							else
								if flagX < 420 and flagX > 350 and flagY < -255 and flagY > -305 then
									HordePointsPerSec = HordePointsPerSec + RE.EstimatorSettings["TempleofKotmogu"]["CenterP"];
								elseif flagX < 470 and flagX > 300 and flagY < -210 and flagY > -350 then
									HordePointsPerSec = HordePointsPerSec + RE.EstimatorSettings["TempleofKotmogu"]["InnerP"];
								else
									HordePointsPerSec = HordePointsPerSec + RE.EstimatorSettings["TempleofKotmogu"]["OuterP"];
								end
							end
						end
					end
				end
				if AlliancePointsPerSec > 0 then
					AllianceTimeToWin = AlliancePointsNeeded / AlliancePointsPerSec;
				else
					AllianceTimeToWin = 10000;
				end
				if HordePointsPerSec > 0 then
					HordeTimeToWin = HordePointsNeeded / HordePointsPerSec;
				else
					HordeTimeToWin = 10000;
				end
				REPorter_EstimatorFill(AllianceTimeToWin, HordeTimeToWin, 2);
			end
		elseif RE.CurrentMap == "STVDiamondMineBG" then
			local AlliancePointsNeeded, AllianceCartsNeeded, HordePointsNeeded, HordeCartsNeeded = nil, 15, nil, 15;
			local _, _, _, text = GetWorldStateUIInfo(RE.MapSettings["STVDiamondMineBG"]["WorldStateNum"]);
			if text ~= nil then
				local Message = {strsplit("/", text)};
				if Message[1] then
					Message = {strsplit(" ", Message[1])};
					AlliancePointsNeeded = RE.MapSettings["STVDiamondMineBG"]["pointsToWin"] - tonumber(Message[2]);
				end
			end
			local _, _, _, text = GetWorldStateUIInfo(RE.MapSettings["STVDiamondMineBG"]["WorldStateNum"]+1);
			if text ~= nil then
				local Message = {strsplit("/", text)};
				if Message[1] then
					Message = {strsplit(" ", Message[1])};
					HordePointsNeeded = RE.MapSettings["STVDiamondMineBG"]["pointsToWin"] - tonumber(Message[2]);
				end
			end
			if AlliancePointsNeeded and HordePointsNeeded then
				AllianceCartsNeeded = REPorter_Round(AlliancePointsNeeded / RE.EstimatorSettings["STVDiamondMineBG"], 1);
				HordeCartsNeeded = REPorter_Round(HordePointsNeeded / RE.EstimatorSettings["STVDiamondMineBG"], 1);
				if AllianceCartsNeeded > HordeCartsNeeded then
					RE.SMEstimatorText = "|cFFFF141D"..HordeCartsNeeded.."\ncarts|r";
					RE.SMEstimatorReport = FACTION_HORDE.." victory: "..HordeCartsNeeded.." carts";
				elseif AllianceCartsNeeded < HordeCartsNeeded then
					RE.SMEstimatorText = "|cFF00A9FF"..AllianceCartsNeeded.."\ncarts|r";
					RE.SMEstimatorReport = FACTION_ALLIANCE.." victory: "..AllianceCartsNeeded.." carts";
				else
					RE.SMEstimatorText = "";
					RE.SMEstimatorReport = "";
				end
			end
		else
			local AllianceBaseNum, AlliancePointNum, HordeBaseNum, HordePointNum, AllianceTimeToWin, HordeTimeToWin = 0, nil, 0, nil, 0, 0;
			local _, _, _, text = GetWorldStateUIInfo(RE.MapSettings[RE.CurrentMap]["WorldStateNum"]);
			if text ~= nil then
				local Mes1 = {strsplit("/", text)};
				if Mes1[2] then
					local Mes2 = {strsplit(":", Mes1[1])};
					local Mes3 = {strsplit(" ", Mes2[2])};
					AllianceBaseNum = tonumber(Mes3[2]);
					AlliancePointNum = tonumber(Mes2[3]);
				end
			end
			_, _, _, text = GetWorldStateUIInfo(RE.MapSettings[RE.CurrentMap]["WorldStateNum"]+1);
			if text ~= nil then
				local Mes1 = {strsplit("/", text)};
				if Mes1[2] then
					Mes2 = {strsplit(":", Mes1[1])};
					Mes3 = {strsplit(" ", Mes2[2])};
					HordeBaseNum = tonumber(Mes3[2]);
					HordePointNum = tonumber(Mes2[3]);
				end
			end
			if AlliancePointNum and HordePointNum and AllianceBaseNum and HordeBaseNum then
				if RE.EstimatorSettings[RE.CurrentMap][AllianceBaseNum] == 0 then
					AllianceTimeToWin = 10000;
				else
					AllianceTimeToWin = (RE.MapSettings[RE.CurrentMap]["pointsToWin"] - AlliancePointNum) / RE.EstimatorSettings[RE.CurrentMap][AllianceBaseNum];
				end
				if RE.EstimatorSettings[RE.CurrentMap][HordeBaseNum] == 0 then
					HordeTimeToWin = 10000;
				else
					HordeTimeToWin = (RE.MapSettings[RE.CurrentMap]["pointsToWin"] - HordePointNum) / RE.EstimatorSettings[RE.CurrentMap][HordeBaseNum];
				end
				REPorter_EstimatorFill(AllianceTimeToWin, HordeTimeToWin)
			end
		end
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and select(2, ...) == "SPELL_BUILDING_DAMAGE" then
		local guid, gateName, _, _, _, _, _, damage = select(8, ...);
		if RE.CurrentMap ~= "IsleofConquest" then
			RE.POINodes[gateName]["health"] = RE.POINodes[gateName]["health"] - damage;
		else
			local gateID = {strsplit("-", guid)};
			if gateID[6] == "195496" then -- Horde East
				RE.POINodes[RE.IoCHordeGateName.." - East"]["health"] = RE.POINodes[RE.IoCHordeGateName.." - East"]["health"] - damage;
				if RE.POINodes[RE.IoCHordeGateName.." - East"]["health"] < RE.IoCGateEstimator[FACTION_HORDE] then
					RE.IoCGateEstimator[FACTION_HORDE] = RE.POINodes[RE.IoCHordeGateName.." - East"]["health"];
				end
			elseif gateID[6] == "195494" then -- Horde Central
				RE.POINodes[RE.IoCHordeGateName.." - Front"]["health"] = RE.POINodes[RE.IoCHordeGateName.." - Front"]["health"] - damage;
				if RE.POINodes[RE.IoCHordeGateName.." - Front"]["health"] < RE.IoCGateEstimator[FACTION_HORDE] then
					RE.IoCGateEstimator[FACTION_HORDE] = RE.POINodes[RE.IoCHordeGateName.." - Front"]["health"];
				end
			elseif gateID[6] == "195495" then -- Horde West
				RE.POINodes[RE.IoCHordeGateName.." - West"]["health"] = RE.POINodes[RE.IoCHordeGateName.." - West"]["health"] - damage;
				if RE.POINodes[RE.IoCHordeGateName.." - West"]["health"] < RE.IoCGateEstimator[FACTION_HORDE] then
					RE.IoCGateEstimator[FACTION_HORDE] = RE.POINodes[RE.IoCHordeGateName.." - West"]["health"];
				end
			elseif gateID[6] == "195698" then -- Alliance East
				RE.POINodes[RE.IoCAllianceGateName.." - East"]["health"] = RE.POINodes[RE.IoCAllianceGateName.." - East"]["health"] - damage;
				if RE.POINodes[RE.IoCAllianceGateName.." - East"]["health"] < RE.IoCGateEstimator[FACTION_ALLIANCE] then
					RE.IoCGateEstimator[FACTION_ALLIANCE] = RE.POINodes[RE.IoCAllianceGateName.." - East"]["health"];
				end
			elseif gateID[6] == "195700" then -- Alliance Center
				RE.POINodes[RE.IoCAllianceGateName.." - Front"]["health"] = RE.POINodes[RE.IoCAllianceGateName.." - Front"]["health"] - damage;
				if RE.POINodes[RE.IoCAllianceGateName.." - Front"]["health"] < RE.IoCGateEstimator[FACTION_ALLIANCE] then
					RE.IoCGateEstimator[FACTION_ALLIANCE] = RE.POINodes[RE.IoCAllianceGateName.." - Front"]["health"];
				end
			elseif gateID[6] == "195699" then -- Alliance West
				RE.POINodes[RE.IoCAllianceGateName.." - West"]["health"] = RE.POINodes[RE.IoCAllianceGateName.." - West"]["health"] - damage;
				if RE.POINodes[RE.IoCAllianceGateName.." - West"]["health"] < RE.IoCGateEstimator[FACTION_ALLIANCE] then
					RE.IoCGateEstimator[FACTION_ALLIANCE] = RE.POINodes[RE.IoCAllianceGateName.." - West"]["health"];
				end
			elseif RE.Debug > 0 then
				print("\124cFF74D06C[REPorter]\124r Unknown gate - "..gateID);
			end
			REPorter_UpdateIoCEstimator();
		end
	elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
		local _, instanceType = IsInInstance();
		REPorterExternal:Hide();
		if instanceType == "pvp" then
			REPorterExternal:Show();
			RE.PlayedFromStart = true;
			RE.GateSyncRequested = false;
			if RE.Debug > 0 then
				print("\124cFF74D06C[REPorter]\124r Pre-create");
			end
			REPorter_Create(false);
			SendAddonMessage("REPorter", "Version;"..RE.AddonVersionCheck, "INSTANCE_CHAT");
			if IsInGuild() then
				SendAddonMessage("REPorter", "Version;"..RE.AddonVersionCheck, "GUILD");
			end
		end
	elseif event == "MODIFIER_STATE_CHANGED" and REPorterExternal:IsShown() then
		if IsShiftKeyDown() and IsAltKeyDown() then
			REPorterExternalOverlay:Hide();
			REPorterTimerOverlay:Show();
			REPorterTimerOverlay:SetFrameStrata("DIALOG");
		else
			REPorterExternalOverlay:Show();
			REPorterTimerOverlay:Hide();
			REPorterTimerOverlay:SetFrameStrata("MEDIUM");
		end
	elseif event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" then
		-- SotA hack
		REPorter_Create(true);
	end
end

function REPorter_OnUpdate(self, elapsed)
	if RE.updateTimer < 0 then
		REPorter_BlinkPOI();
		local subZoneName = GetSubZoneText();
		if (subZoneName and subZoneName ~= "" and RE.CurrentMap ~= "GoldRush") or (RE.CurrentMap == "GoldRush" and REPorter_GetNearestPOI() ~= "") then
			for _, i in pairs({"SB1", "SB2", "SB3", "SB4", "SB5", "SB6", "BB1", "BB2"}) do
				_G["REPorterTab_"..i]:Enable();
			end
		else
			for _, i in pairs({"SB1", "SB2", "SB3", "SB4", "SB5", "SB6", "BB1", "BB2"}) do
				_G["REPorterTab_"..i]:Disable();
			end
		end

		local numFlags = GetNumBattlefieldFlagPositions();
		for i=1, NUM_WORLDMAP_FLAGS do
			local flagFrameName = "REPorterFlag"..i;
			local flagFrame = _G[flagFrameName];
			if i <= numFlags then
				local flagX, flagY, flagToken = GetBattlefieldFlagPosition(i);
				local flagTexture = _G[flagFrameName.."Texture"];
				if flagX == 0 and flagY == 0 then
					flagFrame:Hide();
				else
					flagX, flagY = REPorter_GetRealCoords(flagX, flagY);
					flagFrame:SetPoint("CENTER", "REPorterOverlay", "TOPLEFT", flagX, flagY);
					local flagTexture = _G[flagFrameName.."Texture"];
					flagTexture:SetTexture("Interface\\WorldStateFrame\\"..flagToken);
					flagFrame:EnableMouse(false);
					flagFrame:Show();
				end
			else
				flagFrame:Hide();
			end
		end

		RE.numVehicles = GetNumBattlefieldVehicles();
		local totalVehicles = #RE.BGVehicles;
		local index = 0;
		for i=1, RE.numVehicles do
			if i > totalVehicles then
				local vehicleName = "REPorter"..i;
				RE.BGVehicles[i] = CreateFrame("FRAME", vehicleName, REPorterOverlay, "REPorterVehicleTemplate");
				RE.BGVehicles[i].texture = _G[vehicleName.."Texture"];
			end
			if RE.CurrentMap == "IsleofConquest" then
				RE.BGVehicles[i]:EnableMouse(true);
				RE.BGVehicles[i]:SetScript("OnEnter", REPorterUnit_OnEnterVehicle);
				RE.BGVehicles[i]:SetScript("OnLeave", REPorter_HideTooltip);
			else
				RE.BGVehicles[i]:EnableMouse(false);
				RE.BGVehicles[i]:SetScript("OnEnter", nil);
				RE.BGVehicles[i]:SetScript("OnLeave", nil);
			end
			local vehicleX, vehicleY, unitName, isPossessed, vehicleType, orientation, isPlayer = GetBattlefieldVehicleInfo(i);
			if vehicleX and not isPlayer and vehicleType ~= "Idle" then
				vehicleX, vehicleY = REPorter_GetRealCoords(vehicleX, vehicleY);
				RE.BGVehicles[i].texture:SetTexture(WorldMap_GetVehicleTexture(vehicleType, isPossessed));
				RE.BGVehicles[i].texture:SetRotation(orientation);
				RE.BGVehicles[i].name = unitName;
				RE.BGVehicles[i]:SetPoint("CENTER", "REPorterOverlay", "TOPLEFT", vehicleX, vehicleY);
				RE.BGVehicles[i]:Show();
				index = i;
			else
				RE.BGVehicles[i]:Hide();
			end
		end
		if index < totalVehicles then
			for i=index+1, totalVehicles do
				RE.BGVehicles[i]:Hide();
			end
		end

		for i=1, RE.POINumber do
			_G["REPorterPOI"..i]:Hide();
			_G["REPorterPOI"..i.."WarZone"]:Hide();
			_G["REPorterPOI"..i.."Timer"]:Hide();
		end
		for i=1, GetNumMapLandmarks() do
			local battlefieldPOIName = "REPorterPOI"..i;
			local battlefieldPOI = _G[battlefieldPOIName];
			local battlefieldPOIWarZone = _G[battlefieldPOIName.."WarZone"];
			local name, description, textureIndex, x, y, _, showInBattleMap = GetMapLandmarkInfo(i);
			if name and showInBattleMap and textureIndex ~= 0 then
				x, y = REPorter_GetRealCoords(x, y);
				local x1, x2, y1, y2 = GetPOITextureCoords(textureIndex);
				if RE.CurrentMap == "IsleofConquest" then
					if i == 9 then
						RE.IoCAllianceGateName = name;
						name = name.." - East";
						x = x + 10;
					elseif i == 10 then
						name = name.." - West";
						x = x - 10;
					elseif i == 11 then
						name = name.." - Front";
						y = y + 15;
					elseif i == 6 then
						RE.IoCHordeGateName = name;
						name = name.." - Front";
						y = y - 15;
					elseif i == 7 then
						name = name.." - East";
						x = x + 10;
					elseif i == 8 then
						name = name.." - West";
						x = x - 10;
					end
				elseif RE.CurrentMap == "AlteracValley" then
					if x > 343 and x < 346 then
						x = 350;
						y = -108;
					elseif x > 330 and x < 343 then
						x = 318;
					elseif x > 402 and x < 405 then
						x = 412;
					elseif x > 383 and x < 387 and y > -80 then
						x = 388;
						y = -85;
					elseif y < -186 and y > -189 then
						y = -192;
					elseif y < -398 and y > -402 then
						x = 398;
					elseif y < -439 and y > -442 and x > 383 and x < 386 then
						x = 410;
						y = -440;
					elseif y < -460 then
						y = -472;
					end
				end
				if RE.POINodes[name] == nil then
					RE.POINodes[name] = {["id"] = i, ["name"] = name, ["status"] = description, ["x"] = x, ["y"] = y, ["texture"] = textureIndex};
					if RE.CurrentMap == "IsleofConquest" then
	          if i == 6 or i == 7 or i == 8 or i == 9 or i == 10 or i == 11 then
	              RE.POINodes[name]["health"] = 600000;
	              RE.POINodes[name]["maxHealth"] = 600000;
	          end
					elseif RE.CurrentMap == "StrandoftheAncients" then
						local isStarted, isAlliance = REPorter_SOTAStartCheck();
						if isStarted then
							if isAlliance then
								if i == 3 or i == 4 then
									RE.POINodes[name]["health"] = 11000;
									RE.POINodes[name]["maxHealth"] = 11000;
								elseif i == 1 or i == 2 then
									RE.POINodes[name]["health"] = 13000;
									RE.POINodes[name]["maxHealth"] = 13000;
								elseif i == 10 then
									RE.POINodes[name]["health"] = 14000;
									RE.POINodes[name]["maxHealth"] = 14000;
								elseif i == 11 then
									RE.POINodes[name]["health"] = 10000;
									RE.POINodes[name]["maxHealth"] = 10000;
								end
							else
								if i == 3 or i == 4 then
									RE.POINodes[name]["health"] = 11000;
									RE.POINodes[name]["maxHealth"] = 11000;
								elseif i == 1 or i == 2 then
									RE.POINodes[name]["health"] = 13000;
									RE.POINodes[name]["maxHealth"] = 13000;
								elseif i == 11 then
									RE.POINodes[name]["health"] = 14000;
									RE.POINodes[name]["maxHealth"] = 14000;
								elseif i == 12 then
									RE.POINodes[name]["health"] = 10000;
									RE.POINodes[name]["maxHealth"] = 10000;
								end
							end
						end
					end
				else
					RE.POINodes[name]["id"] = i;
					RE.POINodes[name]["name"] = name;
					RE.POINodes[name]["status"] = description;
					RE.POINodes[name]["x"] = x;
					RE.POINodes[name]["y"] = y;
					if RE.DoIEvenCareAboutNodes and RE.POINodes[name]["texture"] and RE.POINodes[name]["texture"] ~= textureIndex then
						REPorter_NodeChange(textureIndex, name);
					end
					RE.POINodes[name]["texture"] = textureIndex;
				end
				battlefieldPOI.name = name;
				battlefieldPOI:SetPoint("CENTER", "REPorter", "TOPLEFT", x, y);
				battlefieldPOI:SetWidth(RE.POIIconSize);
				battlefieldPOI:SetHeight(RE.POIIconSize);
				_G[battlefieldPOIName.."Texture"]:SetTexCoord(x1, x2, y1, y2);
				_G[battlefieldPOIName.."WarZone"]:SetPoint("CENTER", "REPorter", "TOPLEFT", x, y);
				if RE.AceTimer:TimeLeft(RE.POINodes[name]["timer"]) == 0 then
					if strfind(description, FACTION_HORDE) then
						_G[battlefieldPOIName.."TextureBG"]:SetTexture(1,0,0,0.3);
					elseif strfind(description, FACTION_ALLIANCE) then
						_G[battlefieldPOIName.."TextureBG"]:SetTexture(0,0,1,0.3);
					else
						_G[battlefieldPOIName.."TextureBG"]:SetTexture(0,0,0,0.3);
					end
					_G[battlefieldPOIName.."TextureBG"]:SetWidth(RE.POIIconSize);
					_G[battlefieldPOIName.."TextureBGofBG"]:Hide();
					if RE.DoIEvenCareAboutGates and RE.POINodes[name]["health"] and RE.POINodes[name]["health"] ~= 0 and textureIndex ~= 76 and textureIndex ~= 79 and textureIndex ~= 82 and textureIndex ~= 104 and textureIndex ~= 107 and textureIndex ~= 110 then
						_G[battlefieldPOIName.."TextureBGTop1"]:Hide();
						_G[battlefieldPOIName.."TextureBGTop2"]:Show();
						_G[battlefieldPOIName.."TextureBGTop2"]:SetWidth((RE.POINodes[name]["health"]/RE.POINodes[name]["maxHealth"]) * RE.POIIconSize);
						if RE.GateSyncRequested then
							_G[battlefieldPOIName.."Timer_Caption"]:SetText("|cFFFF141D"..REPorter_Round((RE.POINodes[name]["health"]/RE.POINodes[name]["maxHealth"])*100, 0).."%|r");
						else
							_G[battlefieldPOIName.."Timer_Caption"]:SetText(REPorter_Round((RE.POINodes[name]["health"]/RE.POINodes[name]["maxHealth"])*100, 0).."%");
						end
						_G[battlefieldPOIName.."Timer"]:Show();
					else
						_G[battlefieldPOIName.."TextureBGTop1"]:Hide();
						_G[battlefieldPOIName.."TextureBGTop2"]:Hide();
						_G[battlefieldPOIName.."Timer"]:Hide();
					end
				else
					local timeLeft = RE.AceTimer:TimeLeft(RE.POINodes[name]["timer"]);
					_G[battlefieldPOIName.."TextureBG"]:SetWidth(RE.POIIconSize - ((timeLeft / RE.DefaultTimer) * RE.POIIconSize));
					_G[battlefieldPOIName.."TextureBGofBG"]:Show();
					_G[battlefieldPOIName.."TextureBGofBG"]:SetWidth((timeLeft / RE.DefaultTimer) * RE.POIIconSize);
					if RE.POINodes[name]["isCapturing"] == FACTION_HORDE then
						_G[battlefieldPOIName.."TextureBG"]:SetTexture(1,0,0,RE.BlinkPOI);
					elseif RE.POINodes[name]["isCapturing"] == FACTION_ALLIANCE then
						_G[battlefieldPOIName.."TextureBG"]:SetTexture(0,0,1,RE.BlinkPOI);
					end
					if timeLeft <= 10 then
						_G[battlefieldPOIName.."TextureBGTop1"]:Show();
						_G[battlefieldPOIName.."TextureBGTop2"]:Show();
						_G[battlefieldPOIName.."TextureBGTop1"]:SetWidth((timeLeft / 10) * RE.POIIconSize);
						_G[battlefieldPOIName.."TextureBGTop2"]:SetWidth((timeLeft / 10) * RE.POIIconSize);
					else
						_G[battlefieldPOIName.."TextureBGTop1"]:Hide();
						_G[battlefieldPOIName.."TextureBGTop2"]:Hide();
					end
					_G[battlefieldPOIName.."Timer"]:Show();
					_G[battlefieldPOIName.."Timer_Caption"]:SetText(REPorter_ShortTime(REPorter_Round(RE.AceTimer:TimeLeft(RE.POINodes[name]["timer"]), 0)));
				end
				if RE.CurrentMap == "AlteracValley" or (RE.CurrentMap == "IsleofConquest" and RE.POINodes[name]["texture"] >= 77 and RE.POINodes[name]["texture"] <= 82) then
					_G[battlefieldPOIName.."WarZone"]:Hide();
				else
					if GetNumGroupMembers() > 0 then
						for i=1, MAX_RAID_MEMBERS do
							local unit = "raid"..i;
							local partyX, partyY = GetPlayerMapPosition(unit);
							partyX, partyY = REPorter_GetRealCoords(partyX, partyY);
							if (partyX ~= 0 and partyY ~= 0) and (UnitAffectingCombat(unit)) then
								if REPorter_PointDistance(x, y, partyX, partyY) < 33 then
									_G[battlefieldPOIName.."WarZone"]:Show();
									break;
								end
							end
							_G[battlefieldPOIName.."WarZone"]:Hide();
						end
					end
				end
				battlefieldPOI:Show();
			end
		end

		if RE.CurrentMap == "STVDiamondMineBG" then
			local textureCount = 0;
			local scale = 0.78;
			for i=1, GetNumMapOverlays() do
				local textureName, textureWidth, textureHeight, offsetX, offsetY = GetMapOverlayInfo(i);
				if textureName ~= "" or textureWidth == 0 or textureHeight == 0 then
					local numTexturesWide = ceil(textureWidth / 256);
					local numTexturesTall = ceil(textureHeight / 256);
					local neededTextures = textureCount + (numTexturesWide * numTexturesTall);
					if neededTextures > RE.BGOverlayNum then
						for j=RE.BGOverlayNum + 1, neededTextures do
							REPorter:CreateTexture("REPorterMapOverlay"..j, "ARTWORK");
						end
						RE.BGOverlayNum = neededTextures;
					end
					local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight;
					for j=1, numTexturesTall do
						if ( j < numTexturesTall ) then
							texturePixelHeight = 256;
							textureFileHeight = 256;
						else
							texturePixelHeight = mod(textureHeight, 256);
							if ( texturePixelHeight == 0 ) then
								texturePixelHeight = 256;
							end
							textureFileHeight = 16;
							while(textureFileHeight < texturePixelHeight) do
								textureFileHeight = textureFileHeight * 2;
							end
						end
						for k=1, numTexturesWide do
							textureCount = textureCount + 1;
							local texture = _G["REPorterMapOverlay"..textureCount];
							if ( k < numTexturesWide ) then
								texturePixelWidth = 256;
								textureFileWidth = 256;
							else
								texturePixelWidth = mod(textureWidth, 256);
								if ( texturePixelWidth == 0 ) then
									texturePixelWidth = 256;
								end
								textureFileWidth = 16;
								while(textureFileWidth < texturePixelWidth) do
									textureFileWidth = textureFileWidth * 2;
								end
							end
							texture:SetWidth(texturePixelWidth * scale);
							texture:SetHeight(texturePixelHeight * scale);
							texture:SetTexCoord(0, texturePixelWidth / textureFileWidth, 0, texturePixelHeight / textureFileHeight);
							texture:SetPoint("TOPLEFT", "REPorter", "TOPLEFT", (offsetX + (256 * (k - 1))) * scale, -((offsetY + (256 * (j - 1))) * scale));
							texture:SetTexture(textureName..(((j - 1) * numTexturesWide) + k));
							texture:SetAlpha(RES.opacity);
							texture:Show();
						end
					end
				end
			end
			for i=textureCount + 1, RE.BGOverlayNum do
				_G["REPorterMapOverlay"..i]:Hide();
			end
		end

		local playerCount = 0;
		if GetNumGroupMembers() > 0 then
			for i=1, MAX_RAID_MEMBERS do
				local unit = "raid"..i;
				local partyX, partyY = GetPlayerMapPosition(unit);
				local partyMemberFrame = _G["REPorterRaid"..(playerCount + 1)];
				local _, partyMemberClass = UnitClass(unit);
				if (partyX ~= 0 and partyY ~= 0) and not UnitIsUnit("raid"..i, "player") and partyMemberClass ~= nil then
					partyX, partyY = REPorter_GetRealCoords(partyX, partyY);
					partyMemberFrame:SetPoint("CENTER", "REPorterOverlay", "TOPLEFT", partyX, partyY);
					partyMemberFrame.unit = unit;
					partyMemberFrame.health = (UnitHealth(unit) / UnitHealthMax(unit) * 100);
					if UnitAffectingCombat(unit) then
						if partyMemberFrame.health < 26 then
							partyMemberFrame.icon:SetTexture("Interface\\Addons\\REPorter\\Textures\\REPorterBlipDyingAndDead");
							partyMemberFrame.icon:SetTexCoord(
							RE.BlipCoords[partyMemberClass][1],
							RE.BlipCoords[partyMemberClass][2],
							RE.BlipCoords[partyMemberClass][3] + RE.BlipOffsetT,
							RE.BlipCoords[partyMemberClass][4] + RE.BlipOffsetT
							);
						else
							partyMemberFrame.icon:SetTexture("Interface\\Addons\\REPorter\\Textures\\REPorterBlipNormalAndCombat");
							partyMemberFrame.icon:SetTexCoord(
							RE.BlipCoords[partyMemberClass][1],
							RE.BlipCoords[partyMemberClass][2],
							RE.BlipCoords[partyMemberClass][3] + RE.BlipOffsetT,
							RE.BlipCoords[partyMemberClass][4] + RE.BlipOffsetT
							);
						end
					elseif UnitIsDeadOrGhost(unit) then
						partyMemberFrame.icon:SetTexture("Interface\\Addons\\REPorter\\Textures\\REPorterBlipDyingAndDead");
						partyMemberFrame.icon:SetTexCoord(
						RE.BlipCoords[partyMemberClass][1],
						RE.BlipCoords[partyMemberClass][2],
						RE.BlipCoords[partyMemberClass][3],
						RE.BlipCoords[partyMemberClass][4]
						);
					else
						partyMemberFrame.icon:SetTexture("Interface\\Addons\\REPorter\\Textures\\REPorterBlipNormalAndCombat");
						partyMemberFrame.icon:SetTexCoord(
						RE.BlipCoords[partyMemberClass][1],
						RE.BlipCoords[partyMemberClass][2],
						RE.BlipCoords[partyMemberClass][3],
						RE.BlipCoords[partyMemberClass][4]
						);
					end
					partyMemberFrame:Show();
					playerCount = playerCount + 1;
				else
					partyMemberFrame:Hide();
				end
			end
		end

		local playerX, playerY = GetPlayerMapPosition("player");
		local partyMemberFrame = _G["REPorterPlayer"];
		if playerX ~= 0 and playerY ~= 0 then
			playerX, playerY = REPorter_GetRealCoords(playerX, playerY);
			partyMemberFrame:SetPoint("CENTER", "REPorterPlayerArrow", "TOPLEFT", playerX, playerY);
			partyMemberFrame.icon:SetTexture("Interface\\MINIMAP\\MinimapArrow");
			partyMemberFrame.icon:SetRotation(GetPlayerFacing());
			partyMemberFrame:Show();
		else
			partyMemberFrame:Hide();
		end

		if RE.AceTimer:TimeLeft(RE.EstimatorTimer) > 0 then
			if RE.IsWinning == FACTION_ALLIANCE then
				REPorterEstimator_Text:SetText("|cFF00A9FF"..REPorter_ShortTime(REPorter_Round(RE.AceTimer:TimeLeft(RE.EstimatorTimer), 0)).."|r");
			elseif RE.IsWinning == FACTION_HORDE then
				REPorterEstimator_Text:SetText("|cFFFF141D"..REPorter_ShortTime(REPorter_Round(RE.AceTimer:TimeLeft(RE.EstimatorTimer), 0)).."|r");
			else
				REPorterEstimator_Text:SetText("");
			end
		elseif RE.CurrentMap == "STVDiamondMineBG" then
			REPorterEstimator_Text:SetText(RE.SMEstimatorText);
		elseif RE.CurrentMap == "IsleofConquest" and not RE.GateSyncRequested then
			REPorterEstimator_Text:SetText(RE.IoCGateEstimatorText);
		else
			REPorterEstimator_Text:SetText("");
		end

		RE.updateTimer = RE.MapUpdateRate;
	else
		RE.updateTimer = RE.updateTimer - elapsed;
	end
end

function REPorterUnit_OnEnterPlayer(self)
	local x, y = self:GetCenter();
	local parentX, parentY = self:GetParent():GetCenter();
	if ( x > parentX ) then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end

	local unitButton;
	local tooltipText = "";
	local newLineString = "";

	for i=1, MAX_RAID_MEMBERS do
		unitButton = _G["REPorterRaid"..i];
		if RE.PlayersTip[i] == nil then
			RE.PlayersTip[i] = {};
		end
		RE.PlayersTip[i][1] = false;
		if unitButton:IsVisible() and unitButton:IsMouseOver() then
			local _, class = UnitClass(unitButton.unit);
			if class then
				RE.PlayersTip[i][1] = true;
				RE.PlayersTip[i][2] = "|cFF"..RE.ClassColors[class]..UnitName(unitButton.unit).."|r |cFFFFFFFF["..REPorter_Round(unitButton.health, 0).."%]|r";
			end
		end
	end
	for i=1, MAX_RAID_MEMBERS do
		if i == 1 then
			if RE.PlayersTip[i][1] and RE.PlayersTip[i][2] ~= nil then
					tooltipText = tooltipText..newLineString..RE.PlayersTip[i][2];
					newLineString = "\n";
			end
		else
			if RE.PlayersTip[i-1][2] ~= nil then
				if RE.PlayersTip[i][1] and RE.PlayersTip[i-1][2] ~= RE.PlayersTip[i][2] and RE.PlayersTip[i][2] ~= nil then
					tooltipText = tooltipText..newLineString..RE.PlayersTip[i][2];
					newLineString = "\n";
				end
			else
				if RE.PlayersTip[i][1] and RE.PlayersTip[i][2] ~= nil then
					tooltipText = tooltipText..newLineString..RE.PlayersTip[i][2];
					newLineString = "\n";
				end
			end
		end
	end

	GameTooltip:SetText(tooltipText);
	GameTooltip:Show();
end

function REPorterUnit_OnEnterVehicle(self)
	local x, y = self:GetCenter();
	local parentX, parentY = self:GetParent():GetCenter();
	if ( x > parentX ) then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end

	local unitButton;
	local newLineString = "";
	local tooltipText = "";
	local vehicleGroup = {};

	for i=1, #RE.BGVehicles do
		unitButton = RE.BGVehicles[i];
		if unitButton:IsVisible() and unitButton:IsMouseOver() then
			if RE.BGVehicles[i].name and RE.BGVehicles[i].name ~= "" then
				if vehicleGroup[RE.BGVehicles[i].name] then
					vehicleGroup[RE.BGVehicles[i].name] = vehicleGroup[RE.BGVehicles[i].name] + 1;
				else
					vehicleGroup[RE.BGVehicles[i].name] = 1;
				end
			end
		end
	end
	local tableNum, tableInternal = REPorter_TableCount(vehicleGroup);
	for i=1, tableNum do
		if vehicleGroup[tableInternal[i]] == 1 then
			tooltipText = tooltipText..newLineString..tableInternal[i];
		else
			tooltipText = tooltipText..newLineString.."|cFFFFFFFF"..vehicleGroup[tableInternal[i]].."x|r "..tableInternal[i];
		end
		newLineString = "\n";
	end
	GameTooltip:SetText(tooltipText);
	GameTooltip:Show();
end

function REPorterUnit_OnEnterPOI(self)
	local x, y = self:GetCenter();
	local parentX, parentY = self:GetParent():GetCenter();
	if ( x > parentX ) then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end

	local newLineString = "";
	local tooltipText = "";
	local battlefieldPOIName = self:GetName();
	local battlefieldPOI = _G[battlefieldPOIName];
	if battlefieldPOI:IsMouseOver() and battlefieldPOI.name ~= "" then
		local status = "";
		if RE.POINodes[battlefieldPOI.name]["status"] and RE.POINodes[battlefieldPOI.name]["status"] ~= "" then
			status = "\n"..RE.POINodes[battlefieldPOI.name]["status"];
		end
		if RE.POINodes[battlefieldPOI.name]["health"] then
			if RE.GateSyncRequested then
				status = "\n[|r|cFFFF141D"..REPorter_Round((RE.POINodes[battlefieldPOI.name]["health"]/RE.POINodes[battlefieldPOI.name]["maxHealth"])*100, 0).."%|r|cFFFFFFFF]";
			else
				status = "\n["..REPorter_Round((RE.POINodes[battlefieldPOI.name]["health"]/RE.POINodes[battlefieldPOI.name]["maxHealth"])*100, 0).."%]";
			end
		end
		if RE.AceTimer:TimeLeft(RE.POINodes[battlefieldPOI.name]["timer"]) == 0 then
			tooltipText = tooltipText..newLineString..battlefieldPOI.name.."|cFFFFFFFF"..status.."|r";
		else
			tooltipText = tooltipText..newLineString..battlefieldPOI.name.."|cFFFFFFFF ["..REPorter_ShortTime(REPorter_Round(RE.AceTimer:TimeLeft(RE.POINodes[battlefieldPOI.name]["timer"]), 0)).."]"..status.."|r";
		end
		newLineString = "\n";
	end
	GameTooltip:SetText(tooltipText);
	GameTooltip:Show();
end

function REPorter_OnClickPOI(self)
	CloseDropDownMenus();
	RE.ClickedPOI = RE.POINodes[self.name]["name"];
	EasyMenu(RE.POIDropDown, REPorter_ReportDropDown, self, 0 , 0, "MENU");
end
---

function REPorter_Create(isSecond)
	REPorterExternal:SetScript("OnUpdate", nil);
	local mapFileName = GetMapInfo();
	if mapFileName and RE.MapSettings[mapFileName] then
		if RE.Debug > 0 then
			print("\124cFF74D06C[REPorter]\124r Create!");
		end
		RE.CurrentMap = mapFileName;
		RE.POINodes = {};
		if RES[mapFileName] then
			REPorterExternal:ClearAllPoints();
			REPorterExternal:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", RES[mapFileName].x, RES[mapFileName].y);
		else
			REPorterExternal:ClearAllPoints();
			REPorterExternal:SetPoint("CENTER", "UIParent", "CENTER", 0, 0);
		end
		REPorterTimerOverlay:Hide();
		REPorterExternal:SetHeight(RE.MapSettings[mapFileName]["HE"]);
		REPorterExternalOverlay:SetHeight(RE.MapSettings[mapFileName]["HE"]);
		REPorterExternalPlayerArrow:SetHeight(RE.MapSettings[mapFileName]["HE"]);
		REPorterBorder:SetHeight(RE.MapSettings[mapFileName]["HE"] + 5);
		REPorterExternal:SetWidth(RE.MapSettings[mapFileName]["WI"]);
		REPorterExternalOverlay:SetWidth(RE.MapSettings[mapFileName]["WI"]);
		REPorterExternalPlayerArrow:SetWidth(RE.MapSettings[mapFileName]["WI"]);
		REPorterBorder:SetWidth(RE.MapSettings[mapFileName]["WI"] + 5);
		REPorterExternal:SetHorizontalScroll(RE.MapSettings[mapFileName]["HO"]);
		REPorterExternal:SetVerticalScroll(RE.MapSettings[mapFileName]["VE"]);
		REPorterExternalOverlay:SetHorizontalScroll(RE.MapSettings[mapFileName]["HO"]);
		REPorterExternalOverlay:SetVerticalScroll(RE.MapSettings[mapFileName]["VE"]);
		REPorterExternalOverlay:SetPoint("TOPLEFT", REPorterExternal, "TOPLEFT");
		REPorterExternalPlayerArrow:SetHorizontalScroll(RE.MapSettings[mapFileName]["HO"]);
		REPorterExternalPlayerArrow:SetVerticalScroll(RE.MapSettings[mapFileName]["VE"]);
		REPorterExternalPlayerArrow:SetPoint("TOPLEFT", REPorterExternal, "TOPLEFT");
		REPorterTab:Show();
		local texName;
		local numDetailTiles = GetNumberOfDetailTiles();
		for i=1, numDetailTiles do
			if mapFileName == "STVDiamondMineBG" then
				texName = "Interface\\WorldMap\\"..mapFileName.."\\"..mapFileName.."1_"..i;
			else
				texName = "Interface\\WorldMap\\"..mapFileName.."\\"..mapFileName..i;
			end
			_G["REPorter"..i]:SetTexture(texName);
		end
		if mapFileName == "AlteracValley" or mapFileName == "GilneasBattleground2" or mapFileName == "IsleofConquest" or mapFileName == "ArathiBasin" or mapFileName == "GoldRush" or (IsRatedBattleground() and mapFileName == "NetherstormArena") then
			RE.DoIEvenCareAboutNodes = true;
		else
			RE.DoIEvenCareAboutNodes = false;
		end
		if mapFileName == "GilneasBattleground2" or mapFileName == "NetherstormArena" or mapFileName == "ArathiBasin" or mapFileName == "GoldRush" or mapFileName == "STVDiamondMineBG" or mapFileName == "TempleofKotmogu" then
			RE.DoIEvenCareAboutPoints = true;
			REPorterExternal:RegisterEvent("UPDATE_WORLD_STATES");
		else
			RE.DoIEvenCareAboutPoints = false;
		end
		if mapFileName == "IsleofConquest" then
			RE.IoCGateEstimator = {};
			RE.IoCGateEstimator[FACTION_ALLIANCE] = 600000;
			RE.IoCGateEstimator[FACTION_HORDE] = 600000;
			RE.IoCGateEstimatorText = "";
		end
		if mapFileName == "StrandoftheAncients" or mapFileName == "IsleofConquest" then
			RE.DoIEvenCareAboutGates = true;
			REPorterExternal:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
		else
			RE.DoIEvenCareAboutGates = false;
		end
		if mapFileName == "AlteracValley" then
			RE.DefaultTimer = 240;
		else
			RE.DefaultTimer = 60;
		end
		if mapFileName == "StrandoftheAncients" then
			REPorterExternal:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL");
		end
		if mapFileName == "STVDiamondMineBG" then
			RE.SMEstimatorText = "";
			RE.SMEstimatorReport = "";
		end
		if not isSecond then
			RE.AceTimer:ScheduleTimer("JoinCheck", 5);
		end
		REPorterExternal:SetScript("OnUpdate", REPorter_OnUpdate);
	end
end

function REPorter_NodeChange(newTexture, nodeName)
	RE.AceTimer:CancelTimer(RE.POINodes[nodeName]["timer"]);
	if RE.CurrentMap == "AlteracValley" then
		if newTexture == 9 then -- Tower Ally
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE;
		elseif newTexture == 12 then -- Tower Horde
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE;
		elseif newTexture == 4 then -- GY Ally
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE;
		elseif newTexture == 14 then -- GY Horde
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE;
		end
	elseif RE.CurrentMap == "NetherstormArena" then
		if newTexture == 9 then -- Tower Ally
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE;
		elseif newTexture == 12 then -- Tower Horde
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE;
		end
	elseif RE.CurrentMap == "GilneasBattleground2" then
		if newTexture == 9 then -- Lighthouse Ally
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE;
		elseif newTexture == 12 then -- Lighthouse Horde
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE;
		elseif newTexture == 27 then -- Waterworks Ally
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE;
		elseif newTexture == 29 then -- Waterworks Horde
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE;
		elseif newTexture == 17 then -- Mine Ally
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE;
		elseif newTexture == 19 then -- Mine Horde
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE;
		end
	elseif RE.CurrentMap == "IsleofConquest" then
		if newTexture == 9 then -- Keep Ally
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE;
		elseif newTexture == 12 then -- Keep Horde
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE;
		elseif newTexture == 152 then -- Oil Ally
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE;
		elseif newTexture == 154 then -- Oil Horde
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE;
		elseif newTexture == 147 then -- Dock Ally
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE;
		elseif newTexture == 149 then -- Dock Horde
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE;
		elseif newTexture == 137 then -- Workshop Ally
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE;
		elseif newTexture == 139 then -- Workshop Horde
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE;
		elseif newTexture == 142 then -- Air Ally
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE;
		elseif newTexture == 144 then -- Air Horde
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE;
		elseif newTexture == 17 then -- Quary Ally
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE;
		elseif newTexture == 19 then -- Quary Horde
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE;
		end
	elseif RE.CurrentMap == "ArathiBasin" then
		if newTexture == 32 then -- Farm Ally
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE;
		elseif newTexture == 34 then -- Farm Horde
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE;
		elseif newTexture == 17 then -- Mine Ally
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE;
		elseif newTexture == 19 then -- Mine Horde
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE;
		elseif newTexture == 37 then -- Stables Ally
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE;
		elseif newTexture == 39 then -- Stables Horde
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE;
		elseif newTexture == 27 then -- Blacksmith Ally
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE;
		elseif newTexture == 29 then -- Blacksmith Horde
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE;
		elseif newTexture == 22 then -- Lumbermill Ally
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE;
		elseif newTexture == 24 then -- Lumbermill Horde
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE;
		end
	elseif RE.CurrentMap == "GoldRush" then
		if newTexture == 17 then -- Mine Ally
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_ALLIANCE;
		elseif newTexture == 19 then -- Mine Horde
			RE.POINodes[nodeName]["timer"] = RE.AceTimer:ScheduleTimer("Null", RE.DefaultTimer);
			RE.POINodes[nodeName]["isCapturing"] = FACTION_HORDE;
		end
	end
end

function REPorter_POIPlayers(POIName)
	local playerNumber = 0;
	if RE.POINodes[POIName] then
		if GetNumGroupMembers() > 0 then
			for i=1, MAX_RAID_MEMBERS do
				local unit = "raid"..i;
				local partyX, partyY = GetPlayerMapPosition(unit);
				partyX, partyY = REPorter_GetRealCoords(partyX, partyY);
				if (partyX ~= 0 or partyY ~= 0) and UnitIsDeadOrGhost(unit) ~= 1 then
					if REPorter_PointDistance(RE.POINodes[POIName]["x"], RE.POINodes[POIName]["y"], partyX, partyY) < 33 then
						playerNumber = playerNumber + 1;
					end
				end
			end
			if playerNumber ~= 0 then
				return " - "..UnitFactionGroup("player").." players in area: "..playerNumber;
			else
				return "";
			end
		end
	end
	return "";
end

function REPorter_POIStatus(POIName)
	if RE.POINodes[POIName]then
		if RE.AceTimer:TimeLeft(RE.POINodes[POIName]["timer"]) == 0 then
			if RE.POINodes[POIName]["health"] and not RE.GateSyncRequested then
				local gateHealth = REPorter_Round((RE.POINodes[POIName]["health"]/RE.POINodes[POIName]["maxHealth"])*100, 0);
				return " - "..HEALTH..": "..gateHealth.."%";
			end
			return "";
		else
			local timeLeft = REPorter_ShortTime(REPorter_Round(RE.AceTimer:TimeLeft(RE.POINodes[POIName]["timer"]), 0));
			return " - To cap: "..timeLeft;
		end
	end
	return "";
end

function REPorter_POIOwner(POIName, isReport)
	local prefix = " - ";
	if isReport then
		prefix = "";
	end
	if RE.POINodes[POIName] then
		if strfind(RE.POINodes[POIName]["status"], FACTION_HORDE) then
			return prefix..POIName.." ("..FACTION_HORDE..")";
		elseif strfind(RE.POINodes[POIName]["status"], FACTION_ALLIANCE) then
			return prefix..POIName.." ("..FACTION_ALLIANCE..")";
		else
			if RE.POINodes[POIName]["isCapturing"] == FACTION_HORDE then
				return prefix..POIName.." ("..FACTION_HORDE..")";
			elseif RE.POINodes[POIName]["isCapturing"] == FACTION_ALLIANCE then
				return prefix..POIName.." ("..FACTION_ALLIANCE..")";
			else
				return prefix..POIName;
			end
		end
	end
	return prefix..POIName;
end

function REPorter_SmallButton(number, otherNode)
	local _, instanceType = IsInInstance();
	if instanceType == "pvp" then
		local name = "";
		if otherNode then
			name = RE.ClickedPOI;
		elseif RE.CurrentMap == "GoldRush" then
			name = REPorter_GetNearestPOI();
		else
			name = GetSubZoneText();
		end
		local message = "";
		if name and name ~= "" then
			if number < 6 then
				message = "INCOMING "..number;
			else
				message = "INCOMING 5+";
			end
			SendChatMessage(message..REPorter_POIOwner(name)..REPorter_POIStatus(name)..REPorter_POIPlayers(name)..RE.ReportPrefix, "INSTANCE_CHAT");
		else
			print("\124cFF74D06C[REPorter]\124r This location don't have name. Action canceled.");
		end
	else
		print("\124cFF74D06C[REPorter]\124r This addon work only on battlegrounds.");
	end
end

function REPorter_BigButton(isHelp, otherNode)
	local _, instanceType = IsInInstance();
	if instanceType == "pvp" then
		local name = "";
		if otherNode then
			name = RE.ClickedPOI;
		elseif RE.CurrentMap == "GoldRush" then
			name = REPorter_GetNearestPOI();
		else
			name = GetSubZoneText();
		end
		if name and name ~= "" then
			if isHelp then
				SendChatMessage("HELP"..REPorter_POIOwner(name)..REPorter_POIStatus(name)..REPorter_POIPlayers(name)..RE.ReportPrefix, "INSTANCE_CHAT");
			else
				SendChatMessage("CLEAR"..REPorter_POIOwner(name)..REPorter_POIStatus(name)..REPorter_POIPlayers(name)..RE.ReportPrefix, "INSTANCE_CHAT");
			end
		else
			print("\124cFF74D06C[REPorter]\124r This location don't have name. Action canceled.");
		end
	else
		print("\124cFF74D06C[REPorter]\124r This addon work only on battlegrounds.");
	end
end

function REPorter_ReportEstimator()
	if RE.AceTimer:TimeLeft(RE.EstimatorTimer) > 0 then
		SendChatMessage(RE.IsWinning.." victory: "..REPorter_ShortTime(REPorter_Round(RE.AceTimer:TimeLeft(RE.EstimatorTimer), 0))..RE.ReportPrefix, "INSTANCE_CHAT");
	elseif RE.CurrentMap == "STVDiamondMineBG" and RE.SMEstimatorReport ~= "" then
		SendChatMessage(RE.SMEstimatorReport, "INSTANCE_CHAT");
	elseif RE.CurrentMap == "IsleofConquest" and not RE.GateSyncRequested then
		SendChatMessage(FACTION_ALLIANCE..": "..REPorter_Round((RE.IoCGateEstimator[FACTION_ALLIANCE]/600000)*100, 0).."% - "..FACTION_HORDE..": "..REPorter_Round((RE.IoCGateEstimator[FACTION_HORDE]/600000)*100, 0).."%"..RE.ReportPrefix, "INSTANCE_CHAT");
	end
end

function REPorter_ReportDropDownClick(reportType)
	if reportType ~= "" then
		SendChatMessage(strupper(reportType)..REPorter_POIOwner(RE.ClickedPOI)..REPorter_POIStatus(RE.ClickedPOI)..REPorter_POIPlayers(RE.ClickedPOI)..RE.ReportPrefix, "INSTANCE_CHAT");
	else
		SendChatMessage(REPorter_POIOwner(RE.ClickedPOI, true)..REPorter_POIStatus(RE.ClickedPOI)..REPorter_POIPlayers(RE.ClickedPOI)..RE.ReportPrefix, "INSTANCE_CHAT");
	end
end

function REPorter_UpdateConfig()
	local x, y = 0, 0;
	REPorterExternal:SetAlpha(RES["opacity"]);
	REPorterExternal:SetScale(RES["scale"]);
	if RES.nameAdvert then
		RE.ReportPrefix = " - [REPorter]";
	else
		RE.ReportPrefix = "";
	end
	REPorterTab:ClearAllPoints();
	if IsAddOnLoaded("ElvUI") and IsAddOnLoaded("AddOnSkins") then
		if RES.barHandle > 3 then
			x, y = -2, 0;
		else
			x, y = 2, 0;
		end
	else
		if RES.barHandle > 3 then
			x, y = 2, 0;
		else
			x, y = -2, 0;
		end
	end
	REPorterTab:SetPoint(RE.ReportBarAnchor[RES.barHandle][1], REPorterBorder, RE.ReportBarAnchor[RES.barHandle][2], x, y);
end
