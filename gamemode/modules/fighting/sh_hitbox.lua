local HITBOX = {}
fighting = fighting or {}

HITBOX.Types = {
    CONE = 1,    -- Конусообразный хитбокс для ближнего боя
    SPHERE = 2,  -- Сферический для магии (медленные атаки)
    TORUS = 3,   -- Тороидальный для атак вокруг себя
    CAPSULE = 4  -- Линейный/Лучевой
}

-- Конусный хитбокс (Melee)
function HITBOX:Cone(ply, range, angle)
    local pos = ply:GetPos()
    local forward = ply:GetForward()
    local entities = ents.FindInSphere(pos, range)
    local hitEntities = {}
    
    local angleCos = math.cos(math.rad(angle / 2))

    for _, ent in ipairs(entities) do
        if ent ~= ply and (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) then
            local dir = (ent:GetPos() - pos):GetNormalized()
            local dot = forward:Dot(dir)
            
            if dot > angleCos then
                -- Дополнительная проверка на прямую видимость, если нужно
                local tr = util.TraceLine({
                    start = pos + Vector(0,0,50),
                    endpos = ent:GetPos() + Vector(0,0,50),
                    filter = ply
                })
                
                if not tr.HitWorld then
                    table.insert(hitEntities, {
                        entity = ent,
                        distance = pos:Distance(ent:GetPos()),
                        position = ent:GetPos() + Vector(0,0,50)
                    })
                end
            end
        end
    end
    
    table.sort(hitEntities, function(a, b) return a.distance < b.distance end)
    return hitEntities
end

-- Сферический хитбокс (Magic Ball)
function HITBOX:Sphere(pos, radius, ignoreEnt)
    local entities = ents.FindInSphere(pos, radius)
    local hitEntities = {}
    
    for _, ent in ipairs(entities) do
        if ent ~= ignoreEnt and (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) then
            table.insert(hitEntities, {
                entity = ent,
                distance = pos:Distance(ent:GetPos()),
                position = ent:GetPos() + Vector(0,0,50)
            })
        end
    end
    
    table.sort(hitEntities, function(a, b) return a.distance < b.distance end)
    return hitEntities
end

-- Тороидальный хитбокс (AoE вокруг, но не внутри)
function HITBOX:Torus(ply, innerRadius, outerRadius)
    local pos = ply:GetPos()
    local entities = ents.FindInSphere(pos, outerRadius)
    local hitEntities = {}
    
    for _, ent in ipairs(entities) do
        if ent ~= ply and (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) then
            local dist = pos:Distance(ent:GetPos())
            if dist >= innerRadius and dist <= outerRadius then
                table.insert(hitEntities, {
                    entity = ent,
                    distance = dist,
                    position = ent:GetPos() + Vector(0,0,50)
                })
            end
        end
    end
    
    return hitEntities
end

fighting.Hitbox = HITBOX