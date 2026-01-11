-- cl_time.lua - Time-based hook library for client-side operations

TimeLib = TimeLib or {}
TimeLib.Hooks = {
    Minute = {},
    Hour = {},
    Day = {},
    Week = {},
    Month = {},
    Custom = {} -- For custom time intervals
}

local lastMinute = -1
local lastHour = -1
local lastDay = -1
local lastWeek = -1
local lastMonth = -1

-- Add a hook that runs every minute
function TimeLib:OnMinute(id, callback)
    self.Hooks.Minute[id] = callback
    return id
end

-- Add a hook that runs every hour
function TimeLib:OnHour(id, callback)
    self.Hooks.Hour[id] = callback
    return id
end

-- Add a hook that runs every day
function TimeLib:OnDay(id, callback)
    self.Hooks.Day[id] = callback
    return id
end

-- Add a hook that runs every week
function TimeLib:OnWeek(id, callback)
    self.Hooks.Week[id] = callback
    return id
end

-- Add a hook that runs every month
function TimeLib:OnMonth(id, callback)
    self.Hooks.Month[id] = callback
    return id
end

-- Add a hook that runs at custom intervals (seconds)
function TimeLib:OnCustomInterval(id, interval, callback)
    self.Hooks.Custom[id] = {
        interval = interval,
        callback = callback,
        lastRun = CurTime()
    }
    return id
end

-- Remove a hook by ID and type
function TimeLib:RemoveHook(type, id)
    if self.Hooks[type] then
        self.Hooks[type][id] = nil
        return true
    end
    return false
end

-- Main timer function that checks and calls hooks
local function CheckTime()
    local currentTime = os.time()
    local currentDate = os.date("*t", currentTime)
    
    -- Check minute hooks
    if currentDate.min ~= lastMinute then
        lastMinute = currentDate.min
        for id, callback in pairs(TimeLib.Hooks.Minute) do
            callback(currentDate)
        end
    end
    
    -- Check hour hooks
    if currentDate.hour ~= lastHour then
        lastHour = currentDate.hour
        for id, callback in pairs(TimeLib.Hooks.Hour) do
            callback(currentDate)
        end
    end
    
    -- Check day hooks
    if currentDate.day ~= lastDay then
        lastDay = currentDate.day
        for id, callback in pairs(TimeLib.Hooks.Day) do
            callback(currentDate)
        end
    end
    
    -- Check week hooks (when day of week is 1 - Sunday)
    if currentDate.wday == 1 and lastWeek ~= currentDate.day then
        lastWeek = currentDate.day
        for id, callback in pairs(TimeLib.Hooks.Week) do
            callback(currentDate)
        end
    end
    
    -- Check month hooks (when day is 1)
    if currentDate.day == 1 and lastMonth ~= currentDate.month then
        lastMonth = currentDate.month
        for id, callback in pairs(TimeLib.Hooks.Month) do
            callback(currentDate)
        end
    end
    
    -- Check custom interval hooks
    local curTime = CurTime()
    for id, data in pairs(TimeLib.Hooks.Custom) do
        if curTime - data.lastRun >= data.interval then
            data.lastRun = curTime
            data.callback(currentDate)
        end
    end
end

-- Utility functions
function TimeLib:GetCurrentTime()
    return os.date("%H:%M:%S")
end

function TimeLib:GetCurrentDate()
    return os.date("%Y-%m-%d")
end

function TimeLib:GetCurrentDateTime()
    return os.date("%Y-%m-%d %H:%M:%S")
end

-- Initialize the timer
hook.Add("Think", "TimeLib_CheckTime", CheckTime)
