HORDE = {}
indicators = {}
HORDE.DMG_PURE = 0

HORDE.DMG_PHYSICAL = 1
HORDE.DMG_BALLISTIC = 2
HORDE.DMG_BLUNT = 3
HORDE.DMG_SLASH = 4

HORDE.DMG_FIRE = 5
HORDE.DMG_COLD = 6
HORDE.DMG_LIGHTNING = 7
HORDE.DMG_POISON = 8
HORDE.DMG_BLAST = 9
HORDE.DMG_BLOOD = 10

HORDE.DMG_TYPE_STRING = {
    [HORDE.DMG_PHYSICAL] = "Other Physical",
    [HORDE.DMG_BALLISTIC] =  "Ballistic",
    [HORDE.DMG_BLUNT] =  "Blunt",
    [HORDE.DMG_SLASH] =  "Slashing",
    [HORDE.DMG_FIRE] = "Fire",
    [HORDE.DMG_COLD] = "Cold",
    [HORDE.DMG_LIGHTNING] = "Lightning",
    [HORDE.DMG_POISON] = "Poison",
    [HORDE.DMG_BLAST] = "Blast",
    [HORDE.DMG_PURE] = "Pure",
}

HORDE.DMG_TYPE_ICON = {
    [HORDE.DMG_PHYSICAL] = "materials/damagetype/physical.png",
    [HORDE.DMG_SLASH] =  "materials/damagetype/slash.png",
    [HORDE.DMG_BLUNT] =  "materials/damagetype/blunt.png",
    [HORDE.DMG_BALLISTIC] =  "materials/damagetype/ballistic.png",
    [HORDE.DMG_FIRE] = "materials/damagetype/fire.png",
    [HORDE.DMG_COLD] = "materials/damagetype/cold.png",
    [HORDE.DMG_LIGHTNING] = "materials/damagetype/lightning.png",
    [HORDE.DMG_POISON] = "materials/damagetype/poison.png",
    [HORDE.DMG_BLAST] = "materials/damagetype/blast.png",
    [HORDE.DMG_PURE] = "materials/damagetype/physical.png",
    [HORDE.DMG_BLOOD] = "materials/damagetype/physical.png",
}

HORDE.DMG_COLOR = {
    [HORDE.DMG_PHYSICAL] = Color(255, 255, 255),
    [HORDE.DMG_SLASH] =  Color(255, 255, 255),
    [HORDE.DMG_BLUNT] =  Color(255, 255, 255),
    [HORDE.DMG_BALLISTIC] =  Color(255, 255, 255),
    [HORDE.DMG_FIRE] = Color(255,51,51),
    [HORDE.DMG_COLD] = Color(0,191,255),
    [HORDE.DMG_LIGHTNING] = Color(255,215,0),
    [HORDE.DMG_POISON] = Color(255, 0, 255),
    [HORDE.DMG_BLAST] = Color(255,140,0),
    [HORDE.DMG_PURE] = Color(255,255,255),
    [HORDE.DMG_BLOOD] = Color(255,0,0),
}

function HORDE:IsBloodDamage(dmginfo)
    return dmginfo:GetDamageType() == DMG_BLOOD
end

function HORDE:IsBallisticDamage(dmginfo)
    return dmginfo:IsDamageType(DMG_BULLET) or dmginfo:IsDamageType(DMG_SNIPER) or dmginfo:IsDamageType(DMG_BUCKSHOT)
end

function HORDE:IsBluntDamage(dmginfo)
    return dmginfo:IsDamageType(DMG_CLUB)
end

function HORDE:IsSlashDamage(dmginfo)
    return dmginfo:IsDamageType(DMG_SLASH)
end

function HORDE:IsMeleeDamage(dmginfo)
    return dmginfo:IsDamageType(DMG_SLASH) or dmginfo:IsDamageType(DMG_CLUB)
end

function HORDE:IsPhysicalDamage(dmginfo)
    return HORDE:IsBallisticDamage(dmginfo) or HORDE:IsBluntDamage(dmginfo) or HORDE:IsSlashDamage(dmginfo) or dmginfo:IsDamageType(DMG_GENERIC) or dmginfo:IsDamageType(DMG_CRUSH) or dmginfo:IsDamageType(DMG_SONIC)
end

function HORDE:IsFireDamage(dmginfo)
    return dmginfo:IsDamageType(DMG_BURN) or dmginfo:IsDamageType(DMG_SLOWBURN) or dmginfo:IsDamageType(DMG_PLASMA)
end

function HORDE:IsColdDamage(dmginfo)
    return dmginfo:IsDamageType(DMG_REMOVENORAGDOLL)
end

function HORDE:IsLightningDamage(dmginfo)
    return dmginfo:IsDamageType(DMG_SHOCK) or dmginfo:IsDamageType(DMG_ENERGYBEAM)
end

function HORDE:IsPoisonDamage(dmginfo)
    return dmginfo:IsDamageType(DMG_NERVEGAS) or dmginfo:IsDamageType(DMG_ACID) or dmginfo:IsDamageType(DMG_POISON) or dmginfo:IsDamageType(DMG_PARALYZE)
end

function HORDE:IsBlastDamage(dmginfo)
    return dmginfo:IsDamageType(DMG_BLAST) or dmginfo:IsDamageType(DMG_MISSILEDEFENSE)
end

function HORDE:GetDamageType(dmginfo)
    if HORDE:IsPhysicalDamage(dmginfo) then
        if HORDE:IsBloodDamage(dmginfo) then return HORDE.DMG_BLOOD end
        if HORDE:IsBallisticDamage(dmginfo) then return HORDE.DMG_BALLISTIC end
        if HORDE:IsSlashDamage(dmginfo) then return HORDE.DMG_SLASH end
        if HORDE:IsBluntDamage(dmginfo) then return HORDE.DMG_BLUNT end
        return HORDE.DMG_PHYSICAL
    else
        if HORDE:IsFireDamage(dmginfo) then return HORDE.DMG_FIRE end
        if HORDE:IsColdDamage(dmginfo) then return HORDE.DMG_COLD end
        if HORDE:IsLightningDamage(dmginfo) then return HORDE.DMG_LIGHTNING end
        if HORDE:IsPoisonDamage(dmginfo) then return HORDE.DMG_POISON end
        if HORDE:IsBlastDamage(dmginfo) then return HORDE.DMG_BLAST end
        return HORDE.DMG_PURE
    end
end
 
local function spawnIndicator(type, text, col, icon, pos, vel, ttl)
    local ind = {}
    ind.text = text
    ind.type = type
    ind.pos  = Vector(pos.x, pos.y, pos.z)
    ind.vel  = Vector(vel.x, vel.y, vel.z)
    ind.col  = Color(col.r, col.g, col.b)
    ind.ttl       = ttl
    ind.life      = ttl
    ind.icon   = icon
    ind.spawntime = CurTime()
    table.insert(indicators, ind)
end

netstream.Hook("fnt/player/blocked", function(pos)
	spawnIndicator(0, "Заблокировано!", Color(255,255,255), nil, pos + Vector(0,0,30), VectorRand(), 1)
end)

netstream.Hook("fnt/player/custom", function(pos, text, color)
	spawnIndicator(0, text, color, nil, pos + Vector(0,0,30), VectorRand(), 1)
end)

netstream.Hook("fnt/player/notblocked", function(pos)
	spawnIndicator(0, "Слабость", Color(255,200,200), nil, pos + Vector(0,0,30), VectorRand(), 0.75)
end)
-- Called when an indicator should be created for this player.
netstream.Hook("Horde_HitnumbersSpawn", function(dmg, dmgtype, pos, dmg_c)
    if dmg < 1 then
        dmg = math.Round(dmg, 3)
    else
        dmg = math.floor(dmg)
    end

    local ttl      = 0.75
    local dmginfo = DamageInfo()
    dmginfo:SetDamageType(dmgtype)
    local horde_type = HORDE:GetDamageType(dmginfo)
    col = HORDE.DMG_COLOR[horde_type]
    if dmg_c == 5 then col = Color(0,255,0) end
    local icon = Material(HORDE.DMG_TYPE_ICON[horde_type], "mips smooth")
    spawnIndicator(0, tostring(dmg), col, icon, pos, VectorRand(), ttl)
end)

net.Receive("Horde_HitnumbersDebuffSpawn", function()
    if not GetConVar("horde_display_damage"):GetBool() then return end

    -- Get damage type and amount.
    local debuff = net.ReadUInt(32)
    local pos   = net.ReadVector()
    local col = HORDE.STATUS_COLOR[debuff] or color_white
    local icon = Material(HORDE.Status_Icon[debuff], "mips smooth")
    local ttl      = 1.5

    spawnIndicator(1, HORDE.Status_String[debuff], col, icon, pos, VectorRand(), ttl)
end)

hook.Add("HUDPaint", "Horde_DrawIndicators2D", function()
    if #indicators == 0 then return end
    local ind
    for i=1, #indicators do
        ind = indicators[i]
        cam.Start3D()
        local spos = ind.pos:ToScreen()
        local x = spos.x
        local y = spos.y
        cam.End3D()

        cam.Start2D()
        if ind.type == 0 then
            surface.SetFont("DermaLarge")
            local width = surface.GetTextSize(ind.text)
            surface.SetTextColor(0, 0, 0, 255 * ind.life)
            surface.SetTextPos(x - (width / 2), y)
            surface.DrawText(ind.text)

            surface.SetFont("DermaLarge")

            surface.SetTextColor(ind.col.r, ind.col.g, ind.col.b, (ind.life / ind.ttl * 255))
            surface.SetTextPos(x - (width / 2), y)
            surface.DrawText(ind.text)
--[[
            surface.SetMaterial(ind.icon)
            surface.SetDrawColor(ind.col.r, ind.col.g, ind.col.b, (ind.life / ind.ttl * 255))
            surface.DrawTexturedRect(x - (width / 2) + surface.GetTextSize(ind.text) + 5, y + ScreenScale(1), ScreenScale(6), ScreenScale(6))]]
        else
            surface.SetFont("DermaLarge")
            local width = surface.GetTextSize(ind.text)
            surface.SetTextColor(0, 0, 0, 255 * ind.life)
            surface.SetTextPos(x - (width / 2), y)
            surface.DrawText(ind.text)

            surface.SetFont("DermaLarge")

            surface.SetTextColor(ind.col.r, ind.col.g, ind.col.b, (ind.life / ind.ttl * 255))
            surface.SetTextPos(x - (width / 2), y)
            surface.DrawText(ind.text)
--[[
            surface.SetMaterial(ind.icon)
            surface.SetDrawColor(ind.col.r, ind.col.g, ind.col.b, (ind.life / ind.ttl * 255))
            surface.DrawTexturedRect(x - (width / 2) + surface.GetTextSize(ind.text) + 7, y + ScreenScale(1), ScreenScale(8), ScreenScale(8))]]
        end

        cam.End2D()
    end

    for i=1, #indicators do
        ind       = indicators[i]
        ind.life  = ind.life - RealFrameTime()
    --  ind.vel.z = math.Min(ind.vel.z - 0.05, 2)
        --ind.vel.z = ind.vel.z - gravity
        ind.pos   = ind.pos + Vector(0, 0, RealFrameTime() * 32)
        ind.pos   = ind.pos + (ind.vel * RealFrameTime() * 16)
    end

    -- Check for and remove expired hit texts.
    local i = 1
    while i <= #indicators do
        if indicators[i].life < 0 then
            table.remove(indicators, i)
        else
            i = i + 1
        end
    end
end)