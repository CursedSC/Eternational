local shieldFull = Material("vgui/shield_full.png", "smooth")
local shieldEmpty = Material("vgui/shield_empty.png", "smooth")

local blockDurability = 0
local blockMaxDurability = 1
local isBlocking = false

net.Receive("fighting.Block.Update", function()
    blockDurability = net.ReadFloat()
    blockMaxDurability = net.ReadFloat()
end)

net.Receive("fighting.Block.Start", function()
    isBlocking = true
end)

net.Receive("fighting.Block.Stop", function()
    isBlocking = false
end)

hook.Add("HUDPaint", "fighting.Block.HUD", function()
    if not isBlocking then return end
    if blockMaxDurability <= 0 then return end
    
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    local sw, sh = ScrW(), ScrH()
    local iconSize = 64
    
    -- Центр экрана (чуть ниже прицела, чтобы не перекрывать обзор)
    local x = sw * 0.5 - iconSize * 0.5
    local y = sh * 0.5 + 30 
    
    local durabilityPercent = math.Clamp(blockDurability / blockMaxDurability, 0, 1)
    
    -- 1. Рисуем "пустой" щит (фон)
    surface.SetDrawColor(255, 255, 255, 200)
    surface.SetMaterial(shieldEmpty)
    surface.DrawTexturedRect(x, y, iconSize, iconSize)
    
    -- 2. Рисуем "полный" щит с обрезкой по высоте (эффект убывания вниз)
    -- Используем ScissorRect для обрезки части текстуры
    local clipHeight = iconSize * durabilityPercent
    local clipY = y + (iconSize - clipHeight)
    
    render.SetScissorRect(x, clipY, x + iconSize, y + iconSize, true)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(shieldFull)
        surface.DrawTexturedRect(x, y, iconSize, iconSize)
    render.SetScissorRect(0, 0, 0, 0, false)
    
    -- Текст прочности
    draw.SimpleText(
        math.floor(blockDurability),
        "DermaDefault",
        sw * 0.5,
        y + iconSize + 2,
        Color(255, 255, 255, 200),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_TOP
    )
end)
