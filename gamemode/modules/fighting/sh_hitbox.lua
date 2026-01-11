fighting = fighting or {}

local HITBOX = {}

HITBOX.Types = {
	CONE      = 1, -- конус перед игроком (melee)
	SPHERE    = 2, -- сфера (магия, взрывы)
	TORUS     = 3, -- кольцо вокруг (аое, но не под ногами)
	COLUMN    = 4, -- вертикальная колонна (столбы, лучи сверху)
	CYLINDER  = 5, -- цилиндр (радиус + высота)
}

--============================--
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ    --
--============================--

local function isValidTarget(ent, attacker, filter)
	if not IsValid(ent) then return false end
	if ent == attacker then return false end
	if not (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) then return false end
	if filter and filter(ent) == false then return false end
	return true
end

local function getCenter(ent)
	if not IsValid(ent) then return nil end
	return ent:LocalToWorld(ent:OBBCenter())
end

local function addHit(out, ent, origin)
	local pos = getCenter(ent)
	if not pos then return end

	out[#out + 1] = {
		entity   = ent,
		pos      = pos,
		distance = origin:Distance(pos)
	}
end

local function collectFromSphere(origin, radius, attacker, filter)
	local entities = ents.FindInSphere(origin, radius)
	local result   = {}

	for _, ent in ipairs(entities) do
		if isValidTarget(ent, attacker, filter) then
			addHit(result, ent, origin)
		end
	end

	table.SortByMember(result, "distance", true)
	return result
end

--============================--
-- БАЗОВЫЕ ФОРМЫ ХИТБОКСОВ    --
--============================--

--[[
	КОНУСНЫЙ ХИТБОКС (MELEE)
	data = {
		range    = 120,
		angle    = 90,   -- полный угол
		minRange = 0,    -- мёртвая зона
		zOffset  = 50,
		minZ     = -40,
		maxZ     = 80,
		filter   = function(ent) end
	}
]]
function HITBOX:Cone(ply, data)
	if not IsValid(ply) then return {} end

	data = data or {}

	local range    = data.range or 120
	local angleDeg = data.angle or 90
	local minRange = data.minRange or 0
	local zOffset  = data.zOffset or 50
	local minZ     = data.minZ or -40
	local maxZ     = data.maxZ or 80
	local filter   = data.filter

	local origin  = (data.origin or ply:GetPos()) + Vector(0, 0, zOffset)
	local forward = (data.forward or ply:GetForward()):GetNormalized()

	local angleRad = math.rad(angleDeg * 0.5)
	local cosHalf  = math.cos(angleRad)

	local baseList = collectFromSphere(origin, range, ply, filter)
	local result   = {}

	for _, hit in ipairs(baseList) do
		local pos = hit.pos
		local toTarget = pos - origin
		local vertical = toTarget.z

		if vertical < minZ or vertical > maxZ then continue end

		local dist2D = Vector(toTarget.x, toTarget.y, 0):Length()
		if dist2D < minRange or dist2D > range then continue end

		toTarget.z = 0
		if toTarget:LengthSqr() <= 0 then continue end

		local dir = toTarget:GetNormalized()
		local dot = forward:Dot(dir)
		if dot < cosHalf then continue end

		-- приоритет центр/близость
		local centerBias = (dot - cosHalf) / (1 - cosHalf)
		local distBias   = 1 - (dist2D / range)

		local entry = {
			entity   = hit.entity,
			pos      = pos,
			distance = dist2D,
			score    = centerBias * 0.6 + distBias * 0.4
		}

		result[#result + 1] = entry
	end

	table.SortByMember(result, "score", true)
	return result
end

--[[
	СФЕРА (MAGIC / AOE)
	data = {
		radius       = 100,
		attacker     = ply,
		filter       = function(ent) end,
		throughWalls = false
	}
]]
function HITBOX:Sphere(origin, data)
	data = data or {}

	local radius   = data.radius or 100
	local attacker = data.attacker
	local filter   = data.filter

	local baseList = collectFromSphere(origin, radius, attacker, filter)
	local result   = {}

	for _, hit in ipairs(baseList) do
		local pos = hit.pos

		if not data.throughWalls then
			local tr = util.TraceLine({
				start  = origin,
				endpos = pos,
				filter = attacker,
				mask   = MASK_SHOT
			})

			if tr.Hit and tr.Entity ~= hit.entity then
				continue
			end
		end

		result[#result + 1] = hit
	end

	table.SortByMember(result, "distance", true)
	return result
end

--[[
	ТОРУС (RING)
	data = {
		innerRadius = 50,
		outerRadius = 200,
		zOffset     = 0,
		minZ        = -40,
		maxZ        = 80,
		attacker    = ply,
		filter      = function(ent) end
	}
]]
function HITBOX:Torus(data)
	data = data or {}

	local attacker = data.attacker
	local origin   = (data.origin or (IsValid(attacker) and attacker:GetPos()) or vector_origin) + Vector(0, 0, data.zOffset or 0)
	local inner    = data.innerRadius or 50
	local outer    = data.outerRadius or 200
	local minZ     = data.minZ or -40
	local maxZ     = data.maxZ or 80
	local filter   = data.filter

	local baseList = collectFromSphere(origin, outer, attacker, filter)
	local result   = {}

	for _, hit in ipairs(baseList) do
		local pos = hit.pos
		local toTarget = pos - origin
		local vertical = toTarget.z

		if vertical < minZ or vertical > maxZ then continue end

		local dist2D = Vector(toTarget.x, toTarget.y, 0):Length()
		if dist2D < inner or dist2D > outer then continue end

		local factor = (dist2D - inner) / (outer - inner)

		result[#result + 1] = {
			entity   = hit.entity,
			pos      = pos,
			distance = dist2D,
			ring    = factor
		}
	end

	table.SortByMember(result, "ring", true)
	return result
end

--[[
	КОЛОННА (СТОЛБ / ЛУЧ СВЕРХУ)
	data = {
		radius   = 80,
		height   = 200,
		attacker = ply,
		filter   = function(ent) end
	}
]]
function HITBOX:Column(basePos, data)
	data = data or {}

	local attacker = data.attacker
	local radius   = data.radius or 80
	local height   = data.height or 200
	local filter   = data.filter

	local topZ = basePos.z + height
	local baseList = collectFromSphere(basePos, math.max(radius, height), attacker, filter)
	local result   = {}

	for _, hit in ipairs(baseList) do
		local pos = hit.pos

		if pos.z < basePos.z or pos.z > topZ then continue end

		local dist2D = Vector(pos.x - basePos.x, pos.y - basePos.y, 0):Length()
		if dist2D > radius then continue end

		result[#result + 1] = {
			entity   = hit.entity,
			pos      = pos,
			distance = dist2D
		}
	end

	table.SortByMember(result, "distance", true)
	return result
end

--[[
	ЦИЛИНДР (РАДИУС + ВЫСОТА)
	data = {
		radius   = 100,
		height   = 160,
		attacker = ply,
		filter   = function(ent) end
	}
]]
function HITBOX:Cylinder(centerPos, data)
	data = data or {}

	local attacker = data.attacker
	local radius   = data.radius or 100
	local height   = data.height or 160
	local filter   = data.filter

	local halfH = height * 0.5
	local minZ  = centerPos.z - halfH
	local maxZ  = centerPos.z + halfH

	local baseList = collectFromSphere(centerPos, math.max(radius, height), attacker, filter)
	local result   = {}

	for _, hit in ipairs(baseList) do
		local pos = hit.pos

		if pos.z < minZ or pos.z > maxZ then continue end

		local dist2D = Vector(pos.x - centerPos.x, pos.y - centerPos.y, 0):Length()
		if dist2D > radius then continue end

		result[#result + 1] = {
			entity   = hit.entity,
			pos      = pos,
			distance = dist2D
		}
	end

	table.SortByMember(result, "distance", true)
	return result
end

--============================--
-- ВРАППЕРЫ ПОД ОРУЖИЕ/СКИЛЛЫ --
--============================--

-- Универсальный враппер под конфиг
-- cfg = {
-- 	type   = HITBOX.Types.CONE / ...,
-- 	data  = {...},
-- }
function HITBOX:FromConfig(ply, cfg)
	if not cfg or not cfg.type then return {} end

	local t = cfg.type

	if t == HITBOX.Types.CONE then
		return self:Cone(ply, cfg.data)
	elseif t == HITBOX.Types.SPHERE then
		return self:Sphere(cfg.data.origin, cfg.data)
	elseif t == HITBOX.Types.TORUS then
		return self:Torus(cfg.data)
	elseif t == HITBOX.Types.COLUMN then
		return self:Column(cfg.data.basePos, cfg.data)
	elseif t == HITBOX.Types.CYLINDER then
		return self:Cylinder(cfg.data.centerPos, cfg.data)
	end

	return {}
end

-- Враппер под melee-оружие (мечи/топоры и т.п.)
-- weapon ожидется со свойствами:
-- 	weapon.HitRange
-- 	weapon.HitAngle
-- 	weapon.HitZOffset
function HITBOX:MeleeHit( ply, weapon, extra )
	if not IsValid(ply) or not IsValid(weapon) then return {} end

	extra = extra or {}

	local data = {
		range    = extra.range    or weapon.HitRange or 110,
		angle    = extra.angle    or weapon.HitAngle or 90,
		minRange = extra.minRange or 0,
		zOffset  = extra.zOffset  or weapon.HitZOffset or 50,
		minZ     = extra.minZ     or -40,
		maxZ     = extra.maxZ     or 80,
		filter   = extra.filter
	}

	return self:Cone(ply, data)
end

-- Враппер под магические шары (fireball и т.п.)
-- origin можно брать как позицию снаряда или точку перед игроком
function HITBOX:MagicSphere( origin, radius, extra )
	extra = extra or {}

	local data = {
		radius       = radius,
		attacker     = extra.attacker,
		filter       = extra.filter,
		throughWalls = extra.throughWalls or false
	}

	return self:Sphere(origin, data)
end

-- Враппер под аое вокруг кастера (торус)
function HITBOX:MagicRing( ply, inner, outer, extra )
	if not IsValid(ply) then return {} end

	extra = extra or {}

	local data = {
		attacker    = ply,
		origin      = extra.origin or ply:GetPos(),
		innerRadius = inner,
		outerRadius = outer,
		zOffset     = extra.zOffset or 0,
		minZ        = extra.minZ or -40,
		maxZ        = extra.maxZ or 80,
		filter      = extra.filter
	}

	return self:Torus(data)
end

-- Враппер под столбовые заклинания
function HITBOX:Pillar( basePos, radius, height, extra )
	extra = extra or {}

	local data = {
		radius   = radius,
		height   = height,
		attacker = extra.attacker,
		filter   = extra.filter
	}

	return self:Column(basePos, data)
end

-- Враппер под цилиндрические зоны (ауры, домажные круги)
function HITBOX:Aura( centerPos, radius, height, extra )
	extra = extra or {}

	local data = {
		radius   = radius,
		height   = height,
		attacker = extra.attacker,
		filter   = extra.filter
	}

	return self:Cylinder(centerPos, data)
end

-- Быстрый выбор лучшей цели в конусе (для автолока)
function HITBOX:GetBestMeleeTarget( ply, weapon, extra )
	local list = self:MeleeHit(ply, weapon, extra)
	return list[1]
end

--============================--
-- DEBUG-ВИЗУАЛИЗАЦИЯ         --
--============================--

local function debugSphere(pos, radius, time, color)
	if not debugoverlay then return end
	color = color or Color(0, 150, 255, 100)
	debugoverlay.Sphere(pos, radius, time or 0.1, color, true)
end

local function debugColumn(basePos, radius, height, time, color)
	if not debugoverlay then return end
	color = color or Color(0, 255, 0, 100)
	debugoverlay.Cylinder(basePos, Vector(0, 0, height), radius, time or 0.1, color)
end

HITBOX.Debug = {
	Sphere = debugSphere,
	Column = debugColumn,
}

fighting.Hitbox = HITBOX

return HITBOX
