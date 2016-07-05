REPorterNamespace = {["AceTimer"] = {}};
local RE = REPorterNamespace;
LibStub("AceTimer-3.0"):Embed(RE.AceTimer);

RE.POIIconSize = 30;
RE.MapUpdateRate = 0.05;
RE.BGVehicles = {};
RE.POINodes = {};
RE.PlayersTip = {};
RE.BGPOISNum = 0;

RE.DefaultTimer = 60;
RE.DoIEvenCareAboutNodes = false;
RE.DoIEvenCareAboutPoints = false;
RE.DoIEvenCareAboutGates = false;
RE.PlayedFromStart = true;
RE.PlayedFromStartOneTimeTrigger = true;
RE.IoCAllianceGateName = "";
RE.IoCHordeGateName = "";
RE.IoCGateEstimator = {};
RE.IoCGateEstimatorText = "";
RE.IsWinning = "";
RE.GateSyncRequested = false;

RE.BlipOffsetT = 0.5;
RE.BlinkPOIMin = 0.3;
RE.BlinkPOIMax = 0.6;
RE.BlinkPOI = 0.3;
RE.BlinkPOIUp = true;

RE.CurrentMap = "";
RE.ClickedPOI = "";
RE.ReportPrefix = "";

RE.FoundNewVersion = false;
RE.AddonVersionCheck = 90;
RE.Debug = 1;

RE.DefaultConfig = {
	firstTime = 1,
	opacity = 0.85,
	nameAdvert = 1,
	scale = 1,
	version = RE.AddonVersionCheck
};
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
	["STVDiamondMineBG"] = {1}
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
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
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
	dx = x2 - x1
	dy = y2 - y1
	return math.sqrt(math.pow(dx,2) + math.pow(dy,2));
end

function REPorter_TableCount(Table)
	local RENum = 0;
	local RETable = {};
	for k,v in pairs(Table) do
		RENum = RENum + 1;
		table.insert(RETable, k);
	end
	return RENum, RETable
end

function REPorter_ClearTextures()
	RE.AceTimer:CancelTimer(RE.EstimatorTimer);
	REPorterPlayer:Hide();
	for i=1, MAX_RAID_MEMBERS do
		local partyMemberFrame = _G["REPorterRaid"..(i)];
		partyMemberFrame:Hide();
	end
	for i=1, RE.BGPOISNum do
		local battlefieldPOIName = "REPorterPOI"..i;
		local battlefieldPOI = _G[battlefieldPOIName];
		battlefieldPOI:Hide();
		_G[battlefieldPOIName.."WarZone"]:Hide()
		_G[battlefieldPOIName.."Timer"]:Hide()
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
end

function REPorter_CreatePOI(index)
	local frameMain = CreateFrame("Frame", "REPorterPOI"..index, REPorter);
	frameMain:SetWidth(RE.POIIconSize);
	frameMain:SetHeight(RE.POIIconSize);
	frameMain:SetScript("OnEnter", REPorterUnit_OnEnterPOI);
	frameMain:SetScript("OnLeave", REPorter_HideTooltip);
	frameMain:SetScript("OnMouseUp", REPorter_OnClickPOI);
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

function REPorter_WMOnHideUpdate()
	local _, instanceType = IsInInstance();
	if instanceType == "pvp" and (REPorter_SOTAStartCheck() or RE.CurrentMap ~= "StrandoftheAncients") and RE.CurrentMap ~= "AlteracValley" then
		REPorter_Update(true);
	end
end

function REPorter_SOTAStartCheck()
	local startCheck = {GetMapLandmarkInfo(7)};
	local sideCheck = {GetMapLandmarkInfo(10)};
	return (startCheck[3] == 46 or startCheck[3] == 48), sideCheck[3] == 102
end

function REPorter_EstimatorFill(AllianceTimeToWin, HordeTimeToWin, RefreshTimer)
	local RefreshTimer = RefreshTimer or 10;
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
		print("\124cFF74D06C[REPorter]\124r TimerJoinCheck - "..BGTime);
	end
	if BGTime > RE.MapSettings[RE.CurrentMap]["StartTimer"] then
		RE.PlayedFromStart = false;
		if RE.CurrentMap == "StrandoftheAncients" or RE.CurrentMap == "IsleofConquest" then
			RE.GateSyncRequested = true;
			SendAddonMessage("REPorter", "GateSyncRequest;", "INSTANCE_CHAT");
		end
	end
	RE.SyncTimer = nil;
end

function RE.AceTimer.TabHider()
	REPorterTab:SetAlpha(0.25);
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
	REPorter_OptionsReload(true);
	if REPSettings["firstTime"] then
		REPSettings["firstTime"] = nil;
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
	REPorterExternal:UnregisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE");
	REPorterExternal:UnregisterEvent("CHAT_MSG_BG_SYSTEM_HORDE");
	REPorterExternal:UnregisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL");
	REPorterExternal:UnregisterEvent("CHAT_MSG_RAID_BOSS_EMOTE");
	RE.IsWinning = "";
	REPorter_ClearTextures();
	CloseDropDownMenus();
	REPorterEstimator_Text:SetText("");
end

function REPorter_OnEnter(self)
	RE.AceTimer:CancelTimer(RE.TabHiderTimer);
	REPorterTab:SetAlpha(REPSettings["opacity"]);
end

function REPorter_OnLeave(self)
	RE.AceTimer:CancelTimer(RE.TabHiderTimer);
	RE.TabHiderTimer = RE.AceTimer:ScheduleTimer("TabHider", 1.5);
end

function REPorter_OnEvent(self, event, ...)
	if event == "ADDON_LOADED" and ... == "REPorter" then
		if (not REPSettings) then
			REPSettings = RE.DefaultConfig;
		end
		if REPSettings[""] ~= nil then
			REPSettings[""] = nil;
		end
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
		WorldMapFrame:HookScript("OnHide", REPorter_WMOnHideUpdate);
		REPorter_OptionsReload(true);
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
					AllianceTimeToWin = AlliancePointsNeeded / AlliancePointsPerSec;
				else
					AllianceTimeToWin = 10000;
				end
				if HordePointsPerSec > 0 then
					HordeTimeToWin = HordePointsNeeded / HordePointsPerSec;
				else
					HordeTimeToWin = 10000;
				end
				REPorter_EstimatorFill(AllianceTimeToWin, HordeTimeToWin, 5)
			end
		elseif RE.CurrentMap == "STVDiamondMineBG" then
			local AlliancePointsNeeded, AlliancePointsPerSec, AllianceTimeToWin, HordePointsNeeded, HordePointsPerSec, HordeTimeToWin = nil, 0, 0, nil, 0, 0;
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
				for i=1, GetNumBattlefieldVehicles() do
					local vehicleX, vehicleY, _, isPossessed, vehicleType = GetBattlefieldVehicleInfo(i);
					if vehicleX and vehicleY then
						local vehicleName = WorldMap_GetVehicleTexture(vehicleType, isPossessed);
						if vehicleName == "Interface\\Minimap\\Vehicle-SilvershardMines-MineCartBlue" then
							AlliancePointsPerSec = AlliancePointsPerSec + 1
						elseif vehicleName == "Interface\\Minimap\\Vehicle-SilvershardMines-MineCartRed" then
							HordePointsPerSec = HordePointsPerSec + 1
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
				REPorter_EstimatorFill(AllianceTimeToWin, HordeTimeToWin)
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
		local guid,gateName,_,_,_,_,_,damage = select(8,...);
		if RE.CurrentMap ~= "IsleofConquest" then
			RE.POINodes[gateName]["health"] = RE.POINodes[gateName]["health"] - damage;
		else
			local gateID = {strsplit("-", guid)}
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
			RE.PlayedFromStartOneTimeTrigger = true;
			RE.GateSyncRequested = false;
			if RE.Debug > 0 then
				print("\124cFF74D06C[REPorter]\124r Preupdate - EVENT!");
			end
			REPorter_Update();
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
	elseif event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" or event == "CHAT_MSG_BG_SYSTEM_ALLIANCE" or event == "CHAT_MSG_BG_SYSTEM_HORDE" or event == "CHAT_MSG_RAID_BOSS_EMOTE" then
		REPorter_Update();
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

		for i=1, RE.BGPOISNum do
			local battlefieldPOIName = "REPorterPOI"..i;
			local battlefieldPOI = _G[battlefieldPOIName];
			if i <= RE.numPOIs then
				local name, description, textureIndex, x, y, _, showInBattleMap = GetMapLandmarkInfo(i);
				if RE.CurrentMap == "IsleofConquest" and name then
					if i == 9 then
						name = name.." - East";
					elseif i == 10 then
						name = name.." - West";
					elseif i == 11 then
						name = name.." - Front";
					elseif i == 6 then
						name = name.." - Front";
					elseif i == 7 then
						name = name.." - East";
					elseif i == 8 then
						name = name.." - West";
					end
				end
				if showInBattleMap and name and RE.POINodes[name] then
					local x1, x2, y1, y2 = GetPOITextureCoords(textureIndex);
					x, y = REPorter_GetRealCoords(x, y);
					if RE.CurrentMap == "IsleofConquest" then
						if i == 9 then
							x = x + 10;
						elseif i == 10 then
							x = x - 10;
						elseif i == 11 then
							y = y + 15;
						elseif i == 6 then
							y = y - 15;
						elseif i == 7 then
							x = x + 10;
						elseif i == 8 then
							x = x - 10;
						end
					end
					if RE.CurrentMap == "AlteracValley" then
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
					battlefieldPOI:SetPoint("CENTER", "REPorter", "TOPLEFT", x, y);
					battlefieldPOI.name = name;
					_G[battlefieldPOIName.."WarZone"]:SetPoint("CENTER", "REPorter", "TOPLEFT", x, y);
					if RE.POINodes[name]["texture"] then
						if RE.DoIEvenCareAboutNodes and RE.POINodes[name]["texture"] ~= textureIndex then
							REPorter_NodeChange(textureIndex, name);
							RE.POINodes[name]["texture"] = textureIndex;
						end
					end
					RE.POINodes[name]["status"] = description;
					_G[battlefieldPOIName.."Texture"]:SetTexCoord(x1, x2, y1, y2);
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
					if RE.CurrentMap == "AlteracValley" then
						battlefieldPOI:Show();
						_G[battlefieldPOIName.."WarZone"]:Hide();
					elseif RE.CurrentMap == "IsleofConquest" and RE.POINodes[name]["texture"] >= 77 and RE.POINodes[name]["texture"] <= 82 then
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
						battlefieldPOI:Show();
					end
				else
					battlefieldPOI:Hide();
					_G[battlefieldPOIName.."WarZone"]:Hide();
				end
			else
				battlefieldPOI:Hide();
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
	if battlefieldPOI:IsVisible() and battlefieldPOI:IsMouseOver() and battlefieldPOI.name ~= "" then
		local status = ""
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

function REPorter_Update(NotResetHealth)
	REPorterExternal:SetScript("OnUpdate", nil);
	local mapFileName = GetMapInfo();
	if mapFileName and RE.MapSettings[mapFileName] then
		if RE.Debug > 0 then
			print("\124cFF74D06C[REPorter]\124r Update!");
		end
		RE.CurrentMap = mapFileName;
		if REPSettings[mapFileName] then
			REPorterExternal:ClearAllPoints();
			REPorterExternal:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", REPSettings[mapFileName].x, REPSettings[mapFileName].y);
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
		if not NotResetHealth then
			RE.POINodes = {};
		end
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
		RE.numPOIs = GetNumMapLandmarks();
		if RE.BGPOISNum < RE.numPOIs then
			for i=RE.BGPOISNum+1, RE.numPOIs do
				REPorter_CreatePOI(i);
			end
			RE.BGPOISNum = RE.numPOIs;
		end
		for i=1, RE.BGPOISNum do
			local battlefieldPOIName = "REPorterPOI"..i;
			local battlefieldPOI = _G[battlefieldPOIName];
			local battlefieldPOIWarZone = _G[battlefieldPOIName.."WarZone"];
			if i <= RE.numPOIs then
				local name, description, textureIndex, x, y, _, showInBattleMap = GetMapLandmarkInfo(i);
				if showInBattleMap and textureIndex ~= 0 then
					local x1, x2, y1, y2 = GetPOITextureCoords(textureIndex);
					_G[battlefieldPOIName.."Texture"]:SetTexCoord(x1, x2, y1, y2);
					x, y = REPorter_GetRealCoords(x, y);
					if mapFileName == "IsleofConquest" then
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
					end

					battlefieldPOI:SetPoint("CENTER", "REPorter", "TOPLEFT", x, y);
					battlefieldPOIWarZone:SetPoint("CENTER", "REPorter", "TOPLEFT", x, y);
					battlefieldPOI:SetWidth(RE.POIIconSize);
					battlefieldPOI:SetHeight(RE.POIIconSize);
					battlefieldPOI.name = name;
					battlefieldPOI:Show();

					if not NotResetHealth then
						RE.POINodes[name] = {["id"] = i, ["name"] = name, ["status"] = description, ["x"] = x, ["y"] = y, ["texture"] = textureIndex};
					else
						if RE.CurrentMap == "AlteracValley" and RE.POINodes[name] == nil then
							if RE.Debug > 0 then
								print("\124cFF74D06C[REPorter]\124r Dropped node - "..name);
							end
						else
							RE.POINodes[name]["id"] = i;
							RE.POINodes[name]["name"] = name;
							RE.POINodes[name]["status"] = description;
							RE.POINodes[name]["x"] = x;
							RE.POINodes[name]["y"] = y;
							RE.POINodes[name]["texture"] = textureIndex;
						end
					end

					if mapFileName == "IsleofConquest" and not NotResetHealth then
						if i == 6 or i == 7 or i == 8 or i == 9 or i == 10 or i == 11 then
							RE.POINodes[name]["health"] = 600000;
							RE.POINodes[name]["maxHealth"] = 600000;
						end
					end
					if mapFileName == "StrandoftheAncients" and not NotResetHealth then
						local isStarted, isAlliance = REPorter_SOTAStartCheck()
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
					battlefieldPOI.name = "";
					battlefieldPOI:Hide();
					_G[battlefieldPOIName.."WarZone"]:Hide();
				end
			else
				battlefieldPOI:Hide();
				_G[battlefieldPOIName.."WarZone"]:Hide();
			end
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
		if mapFileName == "IsleofConquest" and not NotResetHealth then
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
		if mapFileName == "TempleofKotmogu" then
			REPorterExternal:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE");
			REPorterExternal:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE");
			REPorterExternal:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE");
		end
		if mapFileName == "StrandoftheAncients" then
			REPorterExternal:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL");
		end

		if RE.PlayedFromStartOneTimeTrigger then
			RE.PlayedFromStartOneTimeTrigger = false;
			if RE.SyncTimer == nil then
				RE.SyncTimer = RE.AceTimer:ScheduleTimer("JoinCheck", 5);
			end
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

function REPorter_OptionsOnLoad(REPanel)
	REPanel.name = "REPorter";
	REPanel.okay = REPorter_OptionsReload;
	InterfaceOptions_AddCategory(REPanel);

	REPorterOptions_lockedText:SetText("Lock map");
	REPorterOptions_reportBarAnchorText:SetText("Show report bar above map");
	REPorterOptions_nameAdvertText:SetText("Add \"[REPorter]\" to end of each report");
	REPorterOptions_opacityText:SetText("Map alpha");
	REPorterOptions_opacityLow:SetText("5%");
	REPorterOptions_opacityHigh:SetText("100%");
	REPorterOptions_opacity:SetValueStep(0.05);
	REPorterOptions_scaleText:SetText("Map scale");
	REPorterOptions_scaleLow:SetText("0.5");
	REPorterOptions_scaleHigh:SetText("1.5");
	REPorterOptions_scale:SetValueStep(0.1);
end

function REPorter_OptionsReload(dontSaveSettings)
	if dontSaveSettings ~= true then
		REPSettings["locked"] = REPorterOptions_locked:GetChecked();
		REPSettings["reportBarAnchor"] = REPorterOptions_reportBarAnchor:GetChecked();
		REPSettings["nameAdvert"] = REPorterOptions_nameAdvert:GetChecked();
		REPSettings["opacity"] = REPorter_Round(REPorterOptions_opacity:GetValue(), 2);
		REPSettings["scale"] = REPorter_Round(REPorterOptions_scale:GetValue(), 1);
	end

	REPorterOptions_locked:SetChecked(REPSettings["locked"]);
	REPorterOptions_reportBarAnchor:SetChecked(REPSettings["reportBarAnchor"]);
	REPorterOptions_nameAdvert:SetChecked(REPSettings["nameAdvert"]);
	REPorterOptions_opacity:SetValue(REPSettings["opacity"]);
	REPorterOptions_scale:SetValue(REPSettings["scale"]);

	if REPSettings.nameAdvert then
		RE.ReportPrefix = " - [REPorter]";
	else
		RE.ReportPrefix = "";
	end
	REPorterTab:ClearAllPoints();
	if REPSettings.reportBarAnchor then
		REPorterTab:SetPoint("BOTTOM", REPorterBorder, "TOP", 0, 0);
	else
		REPorterTab:SetPoint("TOP", REPorterBorder, "BOTTOM", 0, 0);
	end
	REPorterExternal:SetAlpha(REPSettings["opacity"]);
	REPorterExternal:SetScale(REPSettings["scale"]);
end

function REPorter_AlphaSlider()
	REPorterOptions_opacityValue:SetText(REPorter_Round(REPorterOptions_opacity:GetValue(), 2));
	REPorterExternal:SetAlpha(REPorterOptions_opacity:GetValue());
end

function REPorter_ScaleSlider()
	REPorterOptions_scaleValue:SetText(REPorter_Round(REPorterOptions_scale:GetValue(), 1));
	REPorterExternal:SetScale(REPorter_Round(REPorterOptions_scale:GetValue(), 1));
end
