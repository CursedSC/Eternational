if pcall(require, "chttp") and CHTTP ~= nil then
    HTTP = CHTTP
else
    return MsgC(Color(255, 0, 0), "Discord Chat Relay ERROR!", Color(255, 255, 255), "Please install https://github.com/timschumi/gmod-chttp!")
end

--[[
embeds = {
    [1] = {
        title = title,
        color = 16750899,
        description = text,
        timestamp = "",
        fields = {},
        thumbnail = {},
        author = {
            name = "",
            icon_url = "", 
        },
    }
}]]

logger = {}

local function getFullDataString(ply)
    if !IsValid(ply) then return "Unknown" end
    if !ply:IsPlayer() then return ply.PrintName end
    return ply:GetName().." | "..ply:SteamID().."/"..ply:SteamID64().." | "..ply:Nick()
end


logger.ChatLog = function(ply, text, act)
    local act = act or "Сообщение"
    local table_s = {
        content = "###  "..act.."\n**["..getFullDataString(ply).."]**\n`"..text.."`",
        username = "Логирование",
    }
    
    HTTP({
        method = "post",
        type = "application/json; charset=utf-8",
        headers = {
            ["User-Agent"] = "Discord Chat Relay",
        },
        url = "https://discord.com/api/webhooks/1337874756086665279/fRTK95kJf0SSiQqRNzbTkdeJWn4rqXFgjQjBoIiv8injq56oXK2qmc_DDQEXKJQnOsMx",
        body = util.TableToJSON(table_s),
        failed = function(error)
            MsgC(Color(255, 0, 0), "Discord API HTTP Error:", Color(255, 255, 255), error, "\n")
        end,
        success = function(code, response)
            if code ~= 204 then
                MsgC(Color(255, 0, 0), "Discord API HTTP Error:", Color(255, 255, 255), code, response, "\n")
            end
        end
    })
end

logger.ItemLog = function(ply, item, count) 
    local act = act or "Сообщение"
    local table_s = {
        content = "### Получил предмет\n**["..getFullDataString(ply).."]**\n> "..item.." x"..count,
        username = "Логирование",
    }
    HTTP({
        method = "post",
        type = "application/json; charset=utf-8",
        headers = {
            ["User-Agent"] = "Discord Chat Relay",
        },
        url = "https://discord.com/api/webhooks/1337882626203062384/7bpzmdgXonWRrwBAG4MhPC_46d8l3LyFrAeJi9xc5AwAcGaUpxHVSdyo2PWjjFtnYXsr",
        body = util.TableToJSON(table_s),
        failed = function(error)
            MsgC(Color(255, 0, 0), "Discord API HTTP Error:", Color(255, 255, 255), error, "\n")
        end,
        success = function(code, response)
            if code ~= 204 then
                MsgC(Color(255, 0, 0), "Discord API HTTP Error:", Color(255, 255, 255), code, response, "\n")
            end
        end
    })
end

logger.DamageLog = function(ply1, ply2, dmg)

    local table_s = {
        content = "**["..getFullDataString(ply1).."]** нанес урон по **["..getFullDataString(ply2).."]** в размере `"..dmg.."`",
        username = "Логирование",
    }
    
    HTTP({
        method = "post",
        type = "application/json; charset=utf-8",
        headers = {
            ["User-Agent"] = "Discord Chat Relay",
        },
        url = "https://discord.com/api/webhooks/1339209998466813963/lSRld7AP27jMRI8EjiL2k1Oj0iU2gBXyiga4eWaRiF24zQ-oP-aBbU3yIgU-y2ms3PId",
        body = util.TableToJSON(table_s),
        failed = function(error)
            MsgC(Color(255, 0, 0), "Discord API HTTP Error:", Color(255, 255, 255), error, "\n")
        end,
        success = function(code, response)
            if code ~= 204 then
                MsgC(Color(255, 0, 0), "Discord API HTTP Error:", Color(255, 255, 255), code, response, "\n")
            end
        end
    })
end



hook.Add("EntityTakeDamage", "logger.EntityTakeDamage", function(ent, dmginfo)
    if ent:IsPlayer() then
        local attacker = dmginfo:GetAttacker()
        if attacker:IsPlayer() then
            logger.DamageLog(attacker, ent, dmginfo:GetDamage())
        end
    end
end)