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

local function ShouldDrawShield()
    if not isBlocking then return false end
    if blockMaxDurability <= 0 then return false end
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return false end
    return true
end

hook.Add("PostDrawTranslucentRenderables", "fighting.Block.WorldIcon", function(depth, skybox)
    if skybox then return end
    if not ShouldDrawShield() then return end

    local ply = LocalPlayer()
    local staminaPercent = math.Clamp(blockDurability / blockMaxDurability, 0, 1)
    if staminaPercent <= 0 then return end

    local pos = ply:GetPos() + Vector(0, 0, 72)

    local ang = EyeAngles()
    ang:RotateAroundAxis(ang:Right(), 90)
    ang:RotateAroundAxis(ang:Up(), -90)

    local scaleMul = 0.6 + 0.4 * staminaPercent
    local baseSize = 24
    local iconSize = baseSize * scaleMul

    cam.Start3D2D(pos, ang, 0.08)
        local x = -iconSize * 0.5
        local y = -iconSize * 0.5

        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(shieldEmpty)
        surface.DrawTexturedRect(x, y, iconSize, iconSize)

        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(shieldFull)

        local vStart = 1 - staminaPercent
        local drawY = y + (iconSize * vStart)
        local drawH = iconSize * staminaPercent

        surface.DrawTexturedRectUV(x, drawY, iconSize, drawH, 0, vStart, 1, 1)
    cam.End3D2D()
end)
