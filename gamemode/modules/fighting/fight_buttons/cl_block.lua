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

-- Иконка на теле локального игрока (проекция в экранные координаты)
hook.Add("HUDPaint", "fighting.Block.HUD.Local", function()
    if not isBlocking then return end

    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    if blockMaxDurability <= 0 then return end

    local worldPos = ply:GetPos() + Vector(0, 0, 60)
    local screenPos = worldPos:ToScreen()

    if not screenPos.visible then return end

    local iconSize = 64
    local x = screenPos.x - iconSize * 0.5
    local y = screenPos.y - iconSize * 0.5

    local durabilityPercent = math.Clamp(blockDurability / blockMaxDurability, 0, 1)

    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(shieldEmpty)
    surface.DrawTexturedRect(x, y, iconSize, iconSize)

    if durabilityPercent > 0 then
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(shieldFull)

        local vStart = 1 - durabilityPercent
        local drawY = y + (iconSize * vStart)
        local drawH = iconSize * durabilityPercent

        surface.DrawTexturedRectUV(x, drawY, iconSize, drawH, 0, vStart, 1, 1)
    end
end)
