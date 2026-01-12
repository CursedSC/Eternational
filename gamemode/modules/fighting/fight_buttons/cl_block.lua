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

-- Убираем HUDPaint, используем PostPlayerDraw для отрисовки на модели
hook.Add("PostPlayerDraw", "fighting.Block.3DIcon", function(ply)
    if not IsValid(ply) or not ply:Alive() then return end
    if ply ~= LocalPlayer() and not (ply.IsBlocking_CL) then return end -- Пока только для локального игрока или если синхронизировано
    
    -- Для локального игрока используем локальные переменные
    -- Для других игроков нужно будет синхронизировать состояние (пока оставим для LocalPlayer для теста или добавим NWBool)
    if ply == LocalPlayer() and not isBlocking then return end
    
    -- Получаем позицию центра тела (примерно Spine или Chest)
    local boneId = ply:LookupBone("ValveBiped.Bip01_Spine2")
    local pos, ang
    
    if boneId then
        pos, ang = ply:GetBonePosition(boneId)
    else
        pos = ply:GetPos() + Vector(0,0,40)
        ang = Angle(0,0,0)
    end
    
    -- Настраиваем угол, чтобы иконка смотрела на камеру или была фиксирована относительно игрока
    -- Вариант 1: Смотрит всегда на камеру (billboard)
    local eyePos = EyePos()
    local lookAng = (eyePos - pos):Angle()
    lookAng:RotateAroundAxis(lookAng:Right(), 90)
    lookAng:RotateAroundAxis(lookAng:Up(), -90)
    
    -- Смещаем немного вперед/вверх
    pos = pos + Vector(0,0,5)

    local iconSize = 20 -- Размер в мире
    local durabilityPercent = math.Clamp(blockDurability / blockMaxDurability, 0, 1)
    
    cam.Start3D2D(pos, lookAng, 0.5)
        -- Центрируем отрисовку
        local x = -iconSize / 2
        local y = -iconSize / 2
        
        -- Фон (пустой щит)
        surface.SetDrawColor(255, 255, 255, 200)
        surface.SetMaterial(shieldEmpty)
        surface.DrawTexturedRect(x, y, iconSize, iconSize)
        
        -- Заполнение (полный щит) - используем scissoring для эффекта "опустошения" снизу вверх или просто альфу?
        -- Просьба была "кончалась", обычно это crop. Сделаем через Stencil или UV
        -- Простой способ: отрисовать часть текстуры через DrawTexturedRectUV, но проще всего менять высоту
        
        local currentHeight = iconSize * durabilityPercent
        local yOffset = iconSize - currentHeight
        
        -- Отрисовка полной части (обрезанной)
        -- Мы рисуем поверх пустой, обрезая снизу (или сверху, как "кончается")
        -- Пусть "тает" сверху вниз или снизу вверх? Обычно щит ломается - пусть прозрачнеет или уменьшается? 
        -- "иконка щита кончалась" - сделаем через 3D2D scissor (хотя в cam.Start3D2D scissor глючит).
        -- Лучше просто менять прозрачность или рисовать поверх с расчетом UV, но для простоты - 
        -- Рисуем полный щит с прозрачностью, зависящей от HP, или просто поверх
        
        -- Вариант с "заполнением" (вертикальный прогресс бар в форме щита)
        render.SetScissorRect( 0, 0, 0, 0, false ) -- сброс
        
        -- Рисуем полный щит поверх
        -- Чтобы сделать эффект "убывания", можно использовать Poly или просто менять цвет
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(shieldFull)
        
        -- Хитрость для 3D2D кропа:
        -- Проще всего нарисовать "полный" щит, но высотой меньше? Нет, исказится.
        -- Используем DrawTexturedRectUV
        
        -- u1, v1, u2, v2
        -- v идет от 0 (верх) до 1 (низ). 
        -- Если щит полный (100%), рисуем от 0 до 1.
        -- Если 50%, рисуем от 0.5 до 1 (нижняя половина) или от 0 до 0.5?
        -- Обычно "кончается" значит уровень падает. Значит рисуем нижнюю часть.
        
        -- vStart = 1 - durabilityPercent
        -- yStart = y + (iconSize * (1 - durabilityPercent))
        -- height = iconSize * durabilityPercent
        
        local vStart = 1 - durabilityPercent
        local drawY = y + (iconSize * vStart)
        local drawH = iconSize * durabilityPercent
        
        surface.DrawTexturedRectUV(x, drawY, iconSize, drawH, 0, vStart, 1, 1)
        
    cam.End3D2D()
end)

-- Хук для обновления состояния блокирования других игроков (если нужно)
net.Receive("fighting.Block.UpdateState", function()
    local ply = net.ReadEntity()
    local state = net.ReadBool()
    if IsValid(ply) then
        ply.IsBlocking_CL = state
    end
end)
