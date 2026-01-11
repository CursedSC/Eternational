CONFIG = CONFIG or {}
RP = {}
RP.chat = {}
RP.chat.commands = {}

local COLOR_WHITE = Color(255, 255, 255)
local COLOR_GREEN = Color(89, 255, 6)
local COLOR_RED = Color(255, 0, 0)
local COLOR_PURPLE = Color(139, 12, 161)

if CLIENT then
    local ScreenWidth = ScreenWidth or ScrW()
    local ScreenHeight = ScreenHeight or ScrH()

    local function weight_source(x)
        return ScreenWidth / 1920 * x
    end

    local function hight_source(x)
        return ScreenHeight / 1080 * x
    end

    local function Alpha(pr)
        return (255 / 100) * pr
    end
end

function RP.chat.register(command, func, func_c)
    RP.chat.commands[command] = {
        server = func,
        client = func_c,
    }
end

local ENTITY = FindMetaTable("Entity")

function ENTITY:GetViewAngle(pos)
    local diff = pos - self:EyePos()
    diff:Normalize()
    return math.abs(math.deg(math.acos(self:EyeAngles():Forward():Dot(diff))))
end

function ENTITY:InFov(ent, fov)
    return self:GetViewAngle(ent:EyePos()) < (fov or 88)
end

function ENTITY:InTrace(ent)
    return util.TraceLine({
        start = ent:EyePos(),
        endpos = self:EyePos()
    }).Entity == self
end

local _maxDist = 512 ^ 2
function ENTITY:IsScreenVisible(ent, maxDist, fov)
    return self:EyePos():DistToSqr(ent:EyePos()) < (maxDist or _maxDist) and self:IsLineOfSightClear(ent:EyePos()) and self:InFov(ent, fov)
end

local function s_func(ply, text)
    local try = math.random(1, 2)
    local text = string.TrimLeft(text, "/try")

    local a = try == 1
    local text2 = a and "Удачно " .. text or "Неудачно " .. text
    logger.ChatLog(ply, text2, "Попытка")
    for k, v in ipairs(ents.FindInSphere(ply:GetPos(), 300)) do
        if v:IsPlayer() then
            net.Start("rp.Chat.Command")
            net.WriteString("/try")
            net.WriteString(text)
            net.WriteEntity(ply)
            net.WriteBool(a)
            net.Send(v)
        end
    end
end

local function c_func()
    local data = net.ReadString()
    local playerr = net.ReadEntity()
    local bool = net.ReadBool()

    if bool then
        dbt:AddPlayerSay(playerr, {COLOR_WHITE, data}, " УДАЧНО выполняет действие:", false, false)
    else
        dbt:AddPlayerSay(playerr, {COLOR_WHITE, data}, " НЕУДАЧНО выполняет действие:", false, false)
    end
end

RP.chat.register("/try", s_func, c_func)

local function s_func(ply, text)
    local text = string.TrimLeft(text, "/w")
    logger.ChatLog(ply, text, "Шепот")
    for k, v in ipairs(ents.FindInSphere(ply:GetPos(), 150)) do
        if v:IsPlayer() then
            net.Start("rp.Chat.Command")
            net.WriteString("/w")
            net.WriteString(text)
            net.WriteEntity(ply)
            net.Send(v)
        end
    end
end

local function c_func()
    local data = net.ReadString()
    local playerr = net.ReadEntity()
    dbt:AddPlayerSay(playerr, {COLOR_WHITE, data}, " говорит шепотом:")
end

RP.chat.register("/w", s_func, c_func)

local function s_func(ply, text)
    local text = string.TrimLeft(text, "/y")
    logger.ChatLog(ply, text, "Крик")
    for k, v in ipairs(ents.FindInSphere(ply:GetPos(), 600)) do
        if v:IsPlayer() then
            net.Start("rp.Chat.Command")
            net.WriteString("/y")
            net.WriteString(text)
            net.WriteEntity(ply)
            net.Send(v)
        end
    end
end

local function c_func()
    local data = net.ReadString()
    local playerr = net.ReadEntity()
    dbt:AddPlayerSay(playerr, {COLOR_WHITE, data}, " кричит:")
end

RP.chat.register("/y", s_func, c_func)

local function s_func(ply, text)
    local text = string.TrimLeft(text, "/me ")
    logger.ChatLog(ply, text, "Действие персонажа")
    for k, v in ipairs(ents.FindInSphere(ply:GetPos(), 300)) do
        if v:IsPlayer() then
            net.Start("rp.Chat.Command")
            net.WriteString("/me")
            net.WriteString(text)
            net.WriteEntity(ply)
            net.Send(v)
        end
    end
end

local function c_func()
    local data = net.ReadString()
    local playerr = net.ReadEntity()
    if LocalPlayer():InFov(playerr, 88) or playerr == LocalPlayer() then
        dbt:AddPlayerSay(playerr, {COLOR_WHITE, data}, " действует:")
    else
        dbt:AddPlayerSay(playerr, {COLOR_WHITE, data}, " действует:", true)
    end
end

RP.chat.register("/me", s_func, c_func)

local function s_func(ply, text)
    local text = string.TrimLeft(text, "//")
    logger.ChatLog(ply, text, "Локальный НРП чат")
    for k, v in ipairs(ents.FindInSphere(ply:GetPos(), 300)) do
        if v:IsPlayer() then
            net.Start("rp.Chat.Command")
            net.WriteString("//")
            net.WriteString(text)
            net.WriteEntity(ply)
            net.Send(v)
        end
    end
end

local function c_func()
    local data = net.ReadString()
    local playerr = net.ReadEntity()
    dbt:AddPlayerSay(playerr, {COLOR_WHITE, data}, " пишет:", false, true)
end

RP.chat.register("//", s_func, c_func)

local function s_func(ply, text)
    local text = string.TrimLeft(text, "/roll")
    local roll = math.random(1, 100)
    globalroll = roll
    logger.ChatLog(ply, "Выкинул число " .. roll, "Кубики")
    for k, v in ipairs(ents.FindInSphere(ply:GetPos(), 300)) do
        if v:IsPlayer() then
            net.Start("rp.Chat.Command")
            net.WriteString("/roll")
            net.WriteEntity(ply)
            net.WriteFloat(roll)
            net.Send(v)
        end
    end
end

local function c_func()
    local playerr = net.ReadEntity()
    local roll = net.ReadFloat()
    dbt:AddPlayerSay(playerr, {COLOR_WHITE, "Число на кубиках - ", COLOR_GREEN, tostring(roll)}, " кидает кубики:", false, false, function(self, w, h, i, alphapercent)
        if not self.RollNum then self.RollNum = 0 end
        self.RollNum = Lerp(FrameTime() * 10, self.RollNum, roll)
        local ww, hh = surface.GetTextSize(i.ply:GetName())
        draw.SimpleText(i.ply:GetName(), "TL X18", weight_source(5), 0, Color(COLOR_GREEN.r, COLOR_GREEN.g, COLOR_GREEN.b, COLOR_GREEN.a * alphapercent))
        draw.SimpleText(i.action, "TL X18", weight_source(5) + ww, 0, Color(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b, COLOR_WHITE.a * alphapercent))
        local x, y = surface.DrawMulticolorText(weight_source(5), weight_source(25), "TL X18", {COLOR_WHITE, "Число на кубиках - ", Color(COLOR_GREEN.r, COLOR_GREEN.g, COLOR_GREEN.b, COLOR_GREEN.a * alphapercent), tostring(math.Round(self.RollNum))}, 700)
    end)
end

RP.chat.register("/roll", s_func, c_func)

local function s_func(ply, text)
    local text = string.TrimLeft(text, "/do ")
    logger.ChatLog(ply, text, "Окружение")
    for k, v in ipairs(ents.FindInSphere(ply:GetPos(), 300)) do
        if v:IsPlayer() then
            net.Start("rp.Chat.Command")
            net.WriteString("/do")
            net.WriteString(text)
            net.WriteEntity(ply)
            net.Send(v)
        end
    end
end

local function c_func()
    local data = net.ReadString()
    local playerr = net.ReadEntity()
    chat.AddText(COLOR_PURPLE, "[ОКРУЖЕНИЕ] ", COLOR_WHITE, data)
end

netstream.Hook("dbt/sendgm/do", function(data, playerr)
    chat.AddTextClick(function()
        netstream.Start("telepormeto", playerr)
    end, COLOR_WHITE, "[" .. playerr:GetName() .. "]", COLOR_WHITE, "[Окружение]", COLOR_GREEN, data)
end)

if SERVER then
    netstream.Hook("telepormeto", function(player, target)
        local position = serverguard:playerSend(player, target, true)
        if position then
            player:SetPos(position)
            player:SetEyeAngles(Angle(target:EyeAngles().pitch, target:EyeAngles().yaw, 0))
            return true
        else
            if serverguard.player:HasPermission(player, "Noclip") then
                player:SetMoveType(MOVETYPE_NOCLIP)
                position = serverguard:playerSend(player, target, true)
                player:SetPos(position)
                player:SetEyeAngles(Angle(target:EyeAngles().pitch, target:EyeAngles().yaw, 0))
                return true
            end
        end
    end)
end

RP.chat.register("/do", s_func, c_func)

local function s_func(ply, text)
    local text = string.TrimLeft(text, "/gm")
    for k, v in ipairs(player.GetAll()) do
        if v:GetUserGroup() == "gm" then
            net.Start("rp.Chat.Command")
            net.WriteString("/gm")
            net.WriteString(text)
            net.WriteEntity(ply)
            net.Send(v)
        end
    end
end

local function c_func()
    local data = net.ReadString()
    local playerr = net.ReadEntity()
    chat.AddText(COLOR_RED, "[СООБЩЕНИЕ ОТ ИГРОКА " .. playerr:Nick() .. "]", COLOR_WHITE, data)
end

RP.chat.register("/gm", s_func, c_func)

local function s_func(ply, text)
    local text = string.TrimLeft(text, "!pm ")
    local args = util.ExplodeByTags(text, " ", "\"", "\"", true)
    local target = util.FindPlayer(args[1], ply)
    if not IsValid(target) then ply:ChatPrint("Игрок отсуствует!") return end
    local text = args[2]
    net.Start("rp.Chat.Command")
    net.WriteString("!pm")
    net.WriteString(text)
    net.WriteEntity(ply)
    net.WriteEntity(target)
    net.WriteBool(true)
    net.Send(target)
    net.Start("rp.Chat.Command")
    net.WriteString("!pm")
    net.WriteString(text)
    net.WriteEntity(ply)
    net.WriteEntity(target)
    net.WriteBool(false)
    net.Send(ply)
end

local function c_func()
    local data = net.ReadString()
    local playerr = net.ReadEntity()
    local player_target = net.ReadEntity()
    local b = net.ReadBool()
    if not b then
        dbt:AddPlayerSay(playerr, {COLOR_RED, data}, " пишет личное сообщение для " .. player_target:Nick() .. ":", false, false, false, true, true)
    else
        dbt:AddPlayerSay(playerr, {COLOR_RED, data}, " пишет вам личное сообщение:", false, false, false, true, true)
    end
end

RP.chat.register("!pm", s_func, c_func)