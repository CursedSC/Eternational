local HITBOX = {}
fighting = fighting or {}

HITBOX.Types = {
	CONE        = 1, -- Конус для ближнего боя
	SPHERE      = 2, -- Сфера для медленных магических атак
	TORUS       = 3, -- Кольцо вокруг игрока
	CAPSULE     = 4, -- Линейный/лучевой хитбокс
}

-- Вспомогательный фильтр целей
local function IsValidTarget(ent)
	if not IsValid(ent) then return false end
	if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then return true end
	return false
end

-- Общая функция построения ответа
local function AddHit(tableOut, ent, origin)
	local pos = ent:LocalToWorld(ent:OBBCenter())
	table.insert(tableOut, {
		entity   = ent,
		position = pos,
		distance = origin:Distance(pos),
	})
end

--[[
	КОНУСНЫЙ ХИТБОКС
	Особенности:
	- учитывает угол обзора
	- поддерживает минимальную дистанцию ("мёртвая зона" у лица)
	- bias к центру экрана: цели по центру конуса приоритетнее
]]
function HITBOX:Cone(ply, data)
	-- data: {
	-- 	range      = 120,
	-- 	angle      = 90,
	-- 	minRange   = 10,
	-- 	zOffset    = 50,
	-- 	ignore     = { ent1, ent2 },
	-- }
	if not IsValid(ply) then return {} end

	data = data or {}
	local range    = data.range or 120
	local angle    = data.angle or 90
	local minRange = data.minRange or 0
	local zOffset  = data.zOffset or 50

	local origin  = ply:GetPos() + Vector(0, 0, zOffset)
	local forward = ply:GetForward()
	local entities = ents.FindInSphere(origin, range)
	local result   = {}

	local ignore = {}
	if istable(data.ignore) then
		for _, ent in ipairs(data.ignore) do
			ignore[ent] = true
		end
	end

	local angleCos = math.cos(math.rad(angle * 0.5))

	for _, ent in ipairs(entities) do
		if ent == ply or ignore[ent] or not IsValidTarget(ent) then continue end

		local targetPos = ent:LocalToWorld(ent:OBBCenter())
		local dir  = (targetPos - origin)
		local dist = dir:Length()
		if dist < minRange then continue end

		dir:Normalize()
		local dot = forward:Dot(dir)
		if dot < angleCos then continue end

		-- Чуть-чуть aim assist: проигнорировать мелкие неровности карты
		local tr = util.TraceLine({
			start  = origin,
			endpos = targetPos,
			filter = ply,
			mask   = MASK_SHOT
		})

		if tr.Hit and tr.Entity ~= ent then continue end

		local centerBias = (dot - angleCos) / (1 - angleCos) -- 0..1
		AddHit(result, ent, origin)
		result[#result].score = centerBias * 0.6 + (1 - dist / range) * 0.4
	end

	table.SortByMember(result, "score", true)
	return result
end

--[[
	СФЕРИЧЕСКИЙ ХИТБОКС
	Используется для взрывов, медленных снарядов и областных заклинаний.
]]
function HITBOX:Sphere(origin, data)
	-- data: {
	-- 	radius  = 100,
	-- 	ignore  = { ent1, ent2 },
	-- 	throughWalls = false,
	-- }
	data = data or {}
	local radius = data.radius or 100
	local entities = ents.FindInSphere(origin, radius)
	local result = {}

	local ignore = {}
	if istable(data.ignore) then
		for _, ent in ipairs(data.ignore) do
			ignore[ent] = true
		end
	end

	for _, ent in ipairs(entities) do
		if ignore[ent] or not IsValidTarget(ent) then continue end

		local pos = ent:LocalToWorld(ent:OBBCenter())
		if not data.throughWalls then
			local tr = util.TraceLine({
				start  = origin,
				endpos = pos,
				filter = data.ignore,
				mask   = MASK_SHOT
			})
			if tr.Hit and tr.Entity ~= ent then continue end
		end

		AddHit(result, ent, origin)
	end

	table.SortByMember(result, "distance", true)
	return result
end

--[[
	ТОРОИДАЛЬНЫЙ ХИТБОКС (RING / ДОНАТ)
	- внутренняя область безопасна
	- внешнее кольцо наносит урон
]]
function HITBOX:Torus(ply, data)
	-- data: {
	-- 	innerRadius = 50,
	-- 	outerRadius = 200,
	-- 	zOffset     = 0,
	-- }
	if not IsValid(ply) then return {} end
	data = data or {}

	local inner = data.innerRadius or 50
	local outer = data.outerRadius or 200
	local z     = data.zOffset or 0

	local origin   = ply:GetPos() + Vector(0, 0, z)
	local entities = ents.FindInSphere(origin, outer)
	local result   = {}

	for _, ent in ipairs(entities) do
		if ent == ply or not IsValidTarget(ent) then continue end

		local pos = ent:LocalToWorld(ent:OBBCenter())
		local dist = origin:Distance(pos)
		if dist < inner or dist > outer then continue end

		AddHit(result, ent, origin)
		result[#result].ringFactor = (dist - inner) / (outer - inner) -- 0..1
	end

	table.SortByMember(result, "ringFactor", true)
	return result
end

--[[
	КАПСУЛЬНЫЙ ХИТБОКС (луч / slash по траектории)
	Используется для очень точных ударов и лучевых заклинаний.
]]
function HITBOX:Capsule(startPos, endPos, radius, filter)
	filter = filter or {}
	local result = {}

	local mins = Vector(-radius, -radius, -radius)
	local maxs = Vector(radius,  radius,  radius)

	local tr = util.TraceHull({
		start  = startPos,
		endpos = endPos,
		mins   = mins,
		maxs   = maxs,
		filter = filter,
		mask   = MASK_SHOT
	})

	if tr.Hit and IsValidTarget(tr.Entity) then
		AddHit(result, tr.Entity, startPos)
		result[1].hitPos = tr.HitPos
	end

	return result
end

-- Утилита: поиск лучшей цели в конусе (для автолока по ближайшей цели)
function HITBOX:GetBestInCone(ply, data)
	local list = self:Cone(ply, data)
	return list[1] -- либо nil
end

fighting.Hitbox = HITBOX
