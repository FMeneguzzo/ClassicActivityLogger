ClassicActivityLogger = {} -- Initial value, will be overridden on variables load if not nil

local name = UnitName("player")
local class = UnitClass("player")
local realm = GetRealmName()
local money = GetMoney()

-- Fire every minute as safety net (eg: power outage)
local function heartbeat()
	local level = UnitLevel("player")
	-- heartbeat will track player money over time, while money event will track real time gold flux
	tinsert(ClassicActivityLogger,format("%s,%s,%s,%s,%s,%s,%s",date(),name,class,realm,level,"HEARTBEAT",money))
	C_Timer.After(60, heartbeat)
end

local frame = CreateFrame("Frame")

frame:Hide()
frame:SetScript("OnEvent", function (self, event, ...)
	local level = UnitLevel("player")

	-- Not all events have an associated value
	local mainValue = select(1, ...)
	if mainValue == nil then
		mainValue = ""
	end

	if event == "PLAYER_LEVEL_UP" then
		level = mainValue
		RequestTimePlayed()
	end

	-- Money difference must be calculated
	if event == "PLAYER_MONEY" then
		oldMoney = money
		money = GetMoney()
		mainValue = money - oldMoney
	end

	-- Save money also on logout
	if event == "PLAYER_LOGOUT" then
		mainValue = money
	end

	tinsert(ClassicActivityLogger,format("%s,%s,%s,%s,%s,%s,%s",date(),name,class,realm,level,event,mainValue))
end
)

frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("PLAYER_MONEY")
frame:RegisterEvent("TIME_PLAYED_MSG")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("PLAYER_LEAVING_WORLD")

-- Start heartbeat on variables load, first might be lost as variables will load after then
heartbeat()
