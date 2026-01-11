
settings = settings or {}
settings.hooks = settings.hooks or {}
local configPath = "fantasy/settings.json"

local function saveConfig(data)
    local jsonData = util.TableToJSON(data, true)
    file.Write(configPath, jsonData)
end
 

local function loadConfig()
    file.CreateDir("fantasy")
    if not file.Exists(configPath, "DATA") then
        return {}
    end 

    local jsonData = file.Read(configPath, "DATA")
    local data = util.JSONToTable(jsonData)
    return data or {} 
end

local config = loadConfig()

local function GetConfig()
    return config
end

settings.OnValueHook = function(name, settingsName, func)
    settings.hooks[settingsName] =  settings.hooks[settingsName] or {}
    settings.hooks[settingsName][name] =  settings.hooks[settingsName][name] or {}
    settings.hooks[settingsName][name] = func
end

settings.OnValueEdited = function(name, value)
    settings.hooks[name] = settings.hooks[name] or {}
    for k, i in pairs(settings.hooks[name]) do 
        i(value)
    end
end

settings.Set = function(key, value)
    config[key] = value
    settings.OnValueEdited(key, value)
    saveConfig(config)
end

settings.Get = function(key, defaultValue)
    return config[key] or defaultValue
end
