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
    local x = sw * 0.5 - iconSize * 0.5
    local y = sh * 0.7
    
    local durabilityPercent = blockDurability / blockMaxDurability
    
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(shieldEmpty)
    surface.DrawTexturedRect(x, y, iconSize, iconSize)
    
    surface.SetDrawColor(255, 255, 255, 255 * durabilityPercent)
    surface.SetMaterial(shieldFull)
    surface.DrawTexturedRect(x, y, iconSize, iconSize)
    
    draw.SimpleText(
        math.floor(blockDurability),
        "DermaDefault",
        sw * 0.5,
        y + iconSize + 10,
        Color(255, 255, 255, 255),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_TOP
    )
end)
