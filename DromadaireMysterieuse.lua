local DM = select(2,...)
local AlertFrame = CreateFrame("Button", "CamelSpotterAlertFrame", UIParent)

DromadaireMysterieuseDB = DromadaireMysterieuseDB or {};
DromadaireMysterieuseDB.WMON = DromadaireMysterieuseDB.WMON or {};
DromadaireMysterieuseDB.WMOFF = DromadaireMysterieuseDB.WMOFF or {};
DM.Uldum = 249 --249
local C_Map, SetCVar, GetCVar = C_Map, SetCVar, GetCVar
local eventRegistered, recent, cacheShowFriends, cacheShowAll, cacheShowFriendlyNPCs, cacheMaxDistance  = false
local previousValue = C_PvP.IsWarModeDesired()
local recentlyDisplayed, recentlyDisplayedEntry, recentlyClicked, reset
local floor = math.floor
local time = time
local mod = mod
local format = string.format
local gsub = string.gsub
local hooksecurefunc = hooksecurefunc
local findAgainTime = 180 -- Seconds
local realFigurineID = "50409" -- 50409
local fakeFigurineID = "50410" -- 50410
local warmodeText

function DM:ResetCVars()
	SetCVar("nameplateShowFriends", cacheShowFriends)
	SetCVar("nameplateShowAll", cacheShowAll)
	SetCVar("nameplateShowFriendlyNPCs", cacheShowFriendlyNPCs)
	local name,value = 'nameplateMaxDistance',cacheMaxDistance
	if ElvUI then
		ElvUI[1].LockedCVars[name] = value
	end
	SetCVar(name, value)
end

function DM:SetCVars()
	if not recentlyDisplayedEntry then
		recentlyDisplayedEntry = true
		print("|cffEEE4AE|Hlr4Dedes|hDromadaire Mystérieuse:|h|r Les namesplates aliees ont ete actives.")
		if TomTom then
			print("|cffEEE4AEDromadaire Mystérieuse:|r |cff85DBF3|HlgDIWxxS|h[Cliquez ici]|h|r pour les points TomTom.")
		end
		C_Timer.After(60, function() recentlyDisplayedEntry = false end)
	end

	SetCVar("nameplateShowAll", 1)
	SetCVar("nameplateShowFriends", 1)
	SetCVar("nameplateShowFriendlyNPCs", 1)
	local name,value = 'nameplateMaxDistance',100
	if ElvUI then
		ElvUI[1].LockedCVars["nameplateMaxDistance"] = 100
	end
	SetCVar(name, value)
end

function DM:verifyZone()
	local uiMapID = C_Map.GetBestMapForUnit("player")
	if uiMapID == DM.Uldum then
		return true
	else
		return false
	end
end

function DM:FormatTime(t)
	t = tonumber(t)
	if not t or t == 0 then return end
	local currentTime = time()
	local days = floor((currentTime - t)/86400)
	local hours = floor(mod((currentTime - t), 86400)/3600)
	local minutes = floor(mod((currentTime - t),3600)/60)
	local seconds = floor(mod((currentTime - t),60))
	if days > 0 then
		return format("%dd %02dh %02dm %02ds",days,hours,minutes,seconds)
	elseif hours > 0 then
		return format("%02dh %02dm %02ds",hours,minutes,seconds)
	else
		return format("%02dm %02ds",minutes,seconds)
	end
end

function DM:ReportLastSeen()
	reset = true
	local WARMODE
	if recentlyDisplayed then return end
	C_Timer.After(30, function() recentlyDisplayed = false end)
	local realmName = gsub(GetRealmName(),'[%s%-]','')
	if C_PvP.IsWarModeDesired() then
		WARMODE = "WMON"
	else
		WARMODE = "WMOFF"
	end
	if DromadaireMysterieuseDB[WARMODE] ~= nil then
		if DromadaireMysterieuseDB[WARMODE][realmName] == nil then
			DromadaireMysterieuseDB[WARMODE][realmName] = DromadaireMysterieuseDB[WARMODE][realmName] or {};
		end
		for realm in next, DromadaireMysterieuseDB[WARMODE] do
			if realm == realmName then
				if DromadaireMysterieuseDB[WARMODE][realm].time then
					local t = DromadaireMysterieuseDB[WARMODE][realm].time
					print("|cffEEE4AEDromadaire Mystérieuse:|r La figurine du dromadaire mystérieuse a ete vu pour la derniere fois: |cff37DB33"..self:FormatTime(t).."|r")
					recentlyDisplayed = true
					break
				end
			end
		end
	end
end

function DM:RecordLastSeen()
	local realmName = gsub(GetRealmName(),'[%s%-]','')
	if C_PvP.IsWarModeDesired() then
		DromadaireMysterieuseDB.WMON[realmName].time = time()
	else
		DromadaireMysterieuseDB.WMOFF[realmName].time = time()
	end
end

function DM:setMarker(unit)
	if not GetRaidTargetIndex(unit) then
		SetRaidTarget(unit, "8")
	end
end

function DM:camelString(npcID, buttonText)
	if npcID == realFigurineID then
		if buttonText then
			return string.format("|cff3DD341%s|r |cffFFDD00%s", "Vrai figurine dromadaire mystérieuse", BetterDate(CHAT_TIMESTAMP_FORMAT or '%H:%M', time()))
		else
			return string.format("|cff3DD341%s|r |cffFFDD00vu a %s", "Vrai figurine dromadaire mystérieuse", BetterDate(CHAT_TIMESTAMP_FORMAT or '%H:%M', time()))
		end
	else
		if buttonText then
			return string.format("|cffF72D55%s|r |cffFFDD00%s", "Fausse figurine dromadaire mystérieuse", BetterDate(CHAT_TIMESTAMP_FORMAT or '%H:%M', time()))
		else
			return string.format("|cffF72D55%s|r |cffFFDD00vu a %s", "Fausse figurine dromadaire mystérieuse", BetterDate(CHAT_TIMESTAMP_FORMAT or '%H:%M', time()))
		end
	end
end

function DM:Announce(npcID, unit)
	if C_PvP.IsWarModeDesired() then
		warmodeText = " MG On"
	else
		warmodeText = " MG Off"
	end
	local realmName = GetRealmName()
	if npcID == realFigurineID then
		PlaySound(63971, "Master")
		PlaySound(11773, "Master")
		PlaySound(71678, "Master")
		RaidNotice_AddMessage( RaidBossEmoteFrame, self:camelString(npcID), ChatTypeInfo["RAID_BOSS_EMOTE"] );
		print("|cffEEE4AEDromadaire mystérieuse:|r "..self:camelString(npcID))
		self:setMarker(unit)
		if not DromadaireMysterieuseDB.AlertWindowDisabled then
			AlertFrame.Text:SetText(self:camelString(npcID, true).."\n\n|cffFFDD00"..realmName..warmodeText.."|r")
			local width = AlertFrame.Text:GetStringWidth() or 180
			PixelUtil.SetSize(AlertFrame, (width + 16), 62)
			AlertFrame.Text:SetTextColor(0, 200, 0, 1)
			AlertFrame.bg:SetColorTexture(0, 0.2, 0, 1)
			AlertFrame:SetBackdropBorderColor(0, 0.7, 0, 1)
			AlertFrame:Show()
		end
	elseif npcID == fakeFigurineID then
		PlaySound(3175, "Master")
		PlaySound(89712, "Master")
		RaidNotice_AddMessage( RaidBossEmoteFrame, self:camelString(npcID), ChatTypeInfo["RAID_BOSS_EMOTE"] );
		print("|cffEEE4AEDromadaire mystérieuse:|r "..self:camelString(npcID))
		self:setMarker(unit)
		if not DromadaireMysterieuseDB.AlertWindowDisabled then
			AlertFrame.Text:SetText(self:camelString(npcID, true).."\n\n|cffFFDD00"..realmName..warmodeText.."|r")
			local width = AlertFrame.Text:GetStringWidth() or 180
			PixelUtil.SetSize(AlertFrame, (width + 16), 62)
			AlertFrame.Text:SetTextColor(200, 0, 0, 1)
			AlertFrame.bg:SetColorTexture(0.2, 0, 0, 1)
			AlertFrame:SetBackdropBorderColor(0.7, 0, 0, 1)
			AlertFrame:Show()
		end
	end
end

function DM:OnEvent(event, ...)
	if event == "PLAYER_LOGIN" then
		cacheShowFriends = GetCVar("nameplateShowFriends")
		cacheShowAll = GetCVar("nameplateShowAll")
		cacheShowFriendlyNPCs = GetCVar("nameplateShowFriendlyNPCs")
		cacheMaxDistance = GetCVar("nameplateMaxDistance")
		if not eventRegistered and self:verifyZone() then
			self:SetCVars()
			self:ReportLastSeen()
			self.f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
			self.f:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
			eventRegistered = true
		end
	elseif event == "NAME_PLATE_UNIT_ADDED" then
		local unit = ...
		if unit == nil then return end
		local guid = UnitGUID(unit)
		local t,_,_,_,_,npcID=strsplit("-", guid)
		local now = GetTime()
		if npcID == realFigurineID then -- Real 50409
			self:RecordLastSeen()
			if not reset and (recent and now - recent < findAgainTime) then return end
			reset = false
			recent = now
			self:Announce(npcID, unit)
		elseif npcID == fakeFigurineID then -- Dust 50410
			self:RecordLastSeen()
			if not reset and (recent and now - recent < findAgainTime) then return end
			reset = false
			recent = now
			self:Announce(npcID, unit)
		end
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		local unit = ...
		if unit == nil then return end
		local guid = UnitGUID(unit)
		local t,_,_,_,_,npcID=strsplit("-", guid)
	elseif event == "ZONE_CHANGED_NEW_AREA" then
		if not eventRegistered and self:verifyZone() then
			self:SetCVars()
			self:ReportLastSeen()
			self.f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
			self.f:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
			eventRegistered = true
		elseif eventRegistered then
			self:ResetCVars()
			self.f:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
			self.f:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
			eventRegistered = false
		end
	elseif event == "PLAYER_FLAGS_CHANGED" then
		if (C_PvP.IsWarModeDesired() ~= previousValue) then
			previousValue = C_PvP.IsWarModeDesired()
			if not self:verifyZone() then return end
			self:ReportLastSeen()
		end
	elseif event == "PLAYER_LOGOUT" then
		self:ResetCVars()
	end
end

hooksecurefunc("SetCVar", function(cvar, value)
	if cvar == "nameplateShowFriends" then
		cacheShowFriends = value
	elseif cvar == "nameplateShowAll" then
		cacheShowAll = value
	elseif cvar == "nameplateShowFriendlyNPCs" then
		cacheShowFriendlyNPCs = value
	end
end)

do
	AlertFrame:RegisterForClicks("AnyUp")
	AlertFrame:SetFlattensRenderLayers(true)
	AlertFrame:SetPoint("CENTER", UIParent, "TOP", 0, -100)
	AlertFrame:SetMovable(true)
	AlertFrame:SetClampedToScreen(true)
	AlertFrame:RegisterForDrag("LeftButton")
	AlertFrame:SetScript("OnDragStart", function()
		AlertFrame:StartMoving()
	end)
	AlertFrame:SetScript("OnDragStop", AlertFrame.StopMovingOrSizing)
	AlertFrame:SetScript("OnClick", function(self, btn)
		if btn == "RightButton" then
			AlertFrame:Hide()
		end
	end)

	AlertFrame.tooltip = "|TInterface\\HELPFRAME\\NewPlayerExperienceParts:24:24:0:0:1024:512:981:1013:66:98|tClique gauche pour bouger.\n|TInterface\\HELPFRAME\\NewPlayerExperienceParts:24:24:0:0:1024:512:981:1013:132:164|tCliaque droit pour fermer."
	AlertFrame:SetScript("OnEnter", function(self)
		if self.tooltip then
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOM");
			GameTooltip:SetText(self.tooltip, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1, true);
			GameTooltip:Show();
		end
	end)
	AlertFrame:SetScript("OnLeave", GameTooltip_Hide)

	AlertFrame.bg = AlertFrame:CreateTexture(nil, "BACKGROUND")
	AlertFrame.bg:SetAllPoints(AlertFrame)
	AlertFrame.bg:SetTexture(0,0,0)
	AlertFrame.bg:SetColorTexture(0,0,0)
	AlertFrame.bg:SetAlpha(0.8)

	AlertFrame:SetBackdrop({
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
			edgeFile = "Interface\\Buttons\\WHITE8X8",
			tile = true,
			tileSize = 8,
			edgeSize = 1,
		})
	AlertFrame:SetBackdropColor(0, 0, 0, 0)
	AlertFrame.Text = AlertFrame:CreateFontString (nil,  "BACKGROUND", "GameFontHighlightLarge")
	AlertFrame.Text:SetPoint("CENTER", AlertFrame, "CENTER")
	AlertFrame:Hide()
end

function DM:SlashCommands(msg)
	local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
	if not cmd or cmd == "" or cmd == "help" then
		print("|cffEEE4AEDromadaire Mystérieuse: /dm /dromadairemysterieuse|r")
		print("   Ajoutez les points GPS - /dm gps")
		print("   Cacher la fenetre d'alerte - /dm alerte")
	elseif cmd:lower() == "gps" then
		self:Waypoints()
	elseif cmd:lower() == "alerte" then
		if not DromadaireMysterieuseDB.AlertWindowDisabled then
			DromadaireMysterieuseDB.AlertWindowDisabled = true
			print("|cffEEE4AEDromadaire Mystérieuse:|r |cffB6B6B6Fenetre d'alerte desactivee.")
		else
			DromadaireMysterieuseDB.AlertWindowDisabled = false
			print("|cffEEE4AEDromadaire mystérieuse:|r |cff37DB33Fenetre d'alerte activee.")
		end
	end
end

SLASH_DROMADAIREMYSTERIEUSE1, SLASH_DROMADAIREMYSTERIEUSE2 = '/dm', '/dromadairemysterieuse'
SlashCmdList["DROMADAIREMYSTERIEUSE"] = function(...)
    DM:SlashCommands(...)
end

local SetHyperlink = ItemRefTooltip.SetHyperlink
function ItemRefTooltip:SetHyperlink(data, ...)
	if (data):sub(1, 8) == "lgDIWxxS" then
		if not recentlyClicked then
			recentlyClicked = true
			C_Timer.After(5, function() recentlyClicked = false end)
			DM:Waypoints()
		end
	elseif (data):sub(1, 8) == "lr4Dedes" then
		DM:SlashCommands("aide")
	else
		SetHyperlink(self, data, ...)
	end
end

function DM:OnLoad()
	self.f = CreateFrame("Frame")
	self.f:SetScript("OnEvent", function(_, ...)
		self:OnEvent(...)
	end)

	for _,e in next, ({ "PLAYER_LOGIN",
						"PLAYER_LOGOUT",
						"ZONE_CHANGED_NEW_AREA",
						"PLAYER_FLAGS_CHANGED" }) do
		self.f:RegisterEvent(e)
	end
end
DM:OnLoad()