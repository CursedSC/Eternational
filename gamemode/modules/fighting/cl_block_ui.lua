local shieldFull = Material("materials/fantasy/hud/shield_full.png", "noclamp smooth")
local shieldEmpty = Material("materials/fantasy/hud/shield_empty.png", "noclamp smooth")

hook.Add("PostPlayerDraw", "fighting.Block.HUD", function(ply)
    if not IsValid(ply) or not ply:Alive() then return end
    if ply == LocalPlayer() and GetViewEntity() == LocalPlayer() and not (LocalPlayer():ShouldDrawLocalPlayer()) then return end
    
    local isBlocking = ply:GetNW2Bool("IsBlocking", false)
    if not isBlocking then return end
    
    local durability = ply:GetNW2Int("BlockDurability", 100)
    local maxDurability = 100 -- Константа из sv_block.lua
    local percent = math.Clamp(durability / maxDurability, 0, 1)
    
    local attach = ply:GetAttachment(ply:LookupAttachment("eyes"))
    local pos = attach and attach.Pos or (ply:GetPos() + Vector(0,0,70))
    pos = pos + Vector(0, 0, 10) -- Над головой
    
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)
    
    cam.Start3D2D(pos, Angle(0, ang.y, 90), 0.1)
        surface.SetDrawColor(255, 255, 255, 255)
        
        -- Рисуем пустой щит (фон)
        surface.SetMaterial(shieldEmpty)
        surface.DrawTexturedRect(-32, -64, 64, 64)
        
        -- Рисуем полный щит с crop'ом по высоте (прочность)
        -- Используем ScissorRect или маску высоты текстуры
        -- Простой вариант: рисуем часть текстуры
        
        local h = 64 * percent
        local yOffset = 64 - h
        
        -- Отрезаем нижнюю часть (или верхнюю, смотря как хотим "наполнять")
        -- Обычно прочность тратится сверху или снизу? Сделаем "тающий" щит
        -- render.SetScissorRect - сложнее в 3D2D. 
        -- Проще нарисовать поверх полный щит с текстурными координатами
        
        surface.SetMaterial(shieldFull)
        -- DrawTexturedRectUV( x, y, w, h, startU, startV, endU, endV )
        -- Рисуем только нижнюю часть высотой h
        surface.DrawTexturedRectUV(-32, -64 + yOffset, 64, h, 0, 1-percent, 1, 1)
        
    cam.End3D2D()
end)
