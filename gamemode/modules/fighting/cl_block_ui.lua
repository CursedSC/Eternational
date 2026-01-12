-- ПУТЬ К ФАЙЛАМ:
-- garrysmod/gamemodes/[твое_название]/content/materials/fantasy/hud/shield_full.png
-- garrysmod/gamemodes/[твое_название]/content/materials/fantasy/hud/shield_empty.png
-- Или в аддоне:
-- addons/[твой_аддон]/materials/fantasy/hud/shield_full.png

local shieldFull = Material("fantasy/hud/shield_full.png", "noclamp smooth")
local shieldEmpty = Material("fantasy/hud/shield_empty.png", "noclamp smooth")

hook.Add("PostPlayerDraw", "fighting.Block.HUD", function(ply)
    if not IsValid(ply) or not ply:Alive() then return end
    -- Не рисуем на себе в первом лице (если не включен вид от 3 лица)
    if ply == LocalPlayer() and GetViewEntity() == LocalPlayer() and not LocalPlayer():ShouldDrawLocalPlayer() then return end
    
    local isBlocking = ply:GetNW2Bool("IsBlocking", false)
    if not isBlocking then return end
    
    local durability = ply:GetNW2Int("BlockDurability", 100)
    local maxDurability = 100 
    local percent = math.Clamp(durability / maxDurability, 0, 1)
    
    -- Центр игрока (OBBCenter)
    local pos = ply:LocalToWorld(ply:OBBCenter())
    
    -- Сдвинем чуть вперед к камере, чтобы модель игрока не перекрывала щит
    local ang = LocalPlayer():EyeAngles()
    ang.p = 0
    ang.r = 0
    
    -- Поворачиваем щит лицом к зрителю
    local drawAng = Angle(0, ang.y - 90, 90)
    
    -- Небольшой сдвиг вперед по взгляду игрока, чтобы висел "перед" ним
    pos = pos + ply:GetForward() * 10
    
    cam.Start3D2D(pos, drawAng, 0.1)
        surface.SetDrawColor(255, 255, 255, 255)
        
        -- Центрируем отрисовку (-32, -32, т.к. размер 64x64)
        -- Рисуем пустой щит (фон)
        surface.SetMaterial(shieldEmpty)
        surface.DrawTexturedRect(-32, -32, 64, 64)
        
        -- Рисуем полный щит (прочность)
        -- Сделаем "тающий" эффект снизу вверх (или сверху вниз)
        -- Здесь: чем меньше percent, тем меньше высота текстуры
        
        local h = 64 * percent
        local yOffset = 64 - h
        
        surface.SetMaterial(shieldFull)
        -- Рисуем обрезанную часть. 
        -- Начинаем с Y = -32 + yOffset (сдвигаем вниз, если прочность падает)
        -- Высота h
        -- UV V start = 1 - percent (обрезаем сверху текстуры)
        surface.DrawTexturedRectUV(-32, -32 + yOffset, 64, h, 0, 1-percent, 1, 1)
        
    cam.End3D2D()
end)
