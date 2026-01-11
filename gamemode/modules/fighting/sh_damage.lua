fighting = fighting or {}

local DAMAGE = {}

DAMAGE.Types = {
	PHYSICAL = 1,
	MAGICAL  = 2,
	PURE     = 3,
	DEBUFF   = 4,
}

-- Нормализация резиста: rawResist (в %) -> 0..maxCap
local function normalizeResist(raw, cap)
	raw = raw or 0
	cap = cap or 0.8 -- по умолчанию максимум 80%

	local frac = raw / 100
	if frac < 0 then frac = 0 end
	if frac > cap then frac = cap end

	return frac
end

-- Получение статов и резистов с fallback-ами
local function getStat(ent, name, default)
	default = default or 0
	if not IsValid(ent) or not ent.GetAttribute then return default end
	return ent:GetAttribute(name) or default
end

local function getResist(ent, name, default)
	default = default or 0
	if not IsValid(ent) or not ent.GetResist then
		-- Если у тебя другая система, можно повесить на NWInt или Attributes
		if ent.GetAttribute then
			return ent:GetAttribute(name) or default
		end
		return default
	end
	return ent:GetResist(name) or default
end

--[[
	context = {
		powerMul     = 1.0,   -- общий множитель силы умения
		crit         = false, -- был ли крит
		critMul      = 1.5,   -- множитель крита
		element      = "fire"/"ice"/... (для будущих стих.
		ignoreArmor  = false, -- игнор физ.защиты
		ignoreMR     = false, -- игнор маг.защиты
		ignoreResist = false, -- игнор резистов эффектов
		debuffID     = "poison"/"bleed"/... -- для DEBUFF
	}
]]
function DAMAGE:Calculate(dmgType, attacker, target, baseDamage, context)
	context = context or {}
	baseDamage = baseDamage or 0

	if not IsValid(target) then return 0 end

	local finalDamage = baseDamage
	local powerMul    = context.powerMul or 1

	if dmgType == self.Types.PHYSICAL then
		-- Физ.урон: скейл от силы/оружия vs физ.деф
		local atk  = getStat(attacker, "strength", 10)
		local def  = getStat(target,   "phys_def", 10)
		local flat = getStat(attacker, "phys_flat", 0) -- плоский бонус урона

		local raw = baseDamage + atk * 2 + flat

		if not context.ignoreArmor then
			-- формула снижения: чем выше def, тем сильнее отдача, но без жестких ступеней
			local red = def / (def + 100) -- 0..~1
			-- сверху добиваем общим физ.резистом (из экипа/баффов)
			local physResist = getResist(target, "phys_resist", 0) -- в процентах
			local physFrac   = normalizeResist(physResist, 0.7)    -- максимум 70%

			local totalRed = 1 - (1 - red) * (1 - physFrac)
			raw = raw * (1 - totalRed)
		end

		finalDamage = raw

	elseif dmgType == self.Types.MAGICAL then
		-- Маг.урон: интеллект vs маг.деф
		local matk = getStat(attacker, "intelligence", 10)
		local mdef = getStat(target,   "mag_def", 10)
		local flat = getStat(attacker, "magic_flat", 0)

		local raw = baseDamage + matk * 2.5 + flat

		if not context.ignoreMR then
			local red = mdef / (mdef + 100)
			local magResist = getResist(target, "magic_resist", 0)
			local magFrac   = normalizeResist(magResist, 0.7)

			local totalRed = 1 - (1 - red) * (1 - magFrac)
			raw = raw * (1 - totalRed)
		end

		finalDamage = raw

	elseif dmgType == self.Types.PURE then
		-- Чистый урон: только множители, без защит/резистов
		finalDamage = baseDamage

	elseif dmgType == self.Types.DEBUFF then
		-- Дебафф-урон: фиксированный тик, но режется резистом к эффекту
		local raw = baseDamage

		if not context.ignoreResist then
			local debuffID = context.debuffID or "generic"
			-- резист к эффектам можно хранить по ключу "resist_poison" / "resist_bleed" и т.п.
			local key = "resist_" .. debuffID
			local effResist = getResist(target, key, 0)
			local effFrac   = normalizeResist(effResist, 0.9) -- до 90% снижения тиков

			raw = raw * (1 - effFrac)
		end

		finalDamage = raw
	end

	-- Общий множитель силы умения
	finalDamage = finalDamage * powerMul

	-- Критический удар (для физ/маг, если надо)
	if (dmgType == self.Types.PHYSICAL or dmgType == self.Types.MAGICAL) and context.crit then
		local critMul = context.critMul or 1.5
		finalDamage = finalDamage * critMul
	end

	-- Минимальный дамаг чтобы не было нулевых ударов
	if finalDamage < 1 then
		finalDamage = 1
	end

	return math.Round(finalDamage)
end

-- Нанесение урона
function DAMAGE:Apply(attacker, target, dmgType, baseDamage, position, context)
	if not IsValid(target) then return 0 end
	if not IsValid(attacker) then attacker = target end

	context = context or {}

	local damage = self:Calculate(dmgType, attacker, target, baseDamage, context)
	if damage <= 0 then return 0 end

	local d = DamageInfo()

	d:SetDamage(damage)
	d:SetAttacker(attacker)
	d:SetInflictor(attacker.GetActiveWeapon and attacker:GetActiveWeapon() or attacker)
	d:SetDamagePosition(position or (target:GetPos() + Vector(0, 0, 50)))
	d:SetDamageCustom(dmgType)

	-- Маппим типы под Source для визуальных эффектов/поведения
	if dmgType == self.Types.PHYSICAL then
		d:SetDamageType(DMG_SLASH)
	elseif dmgType == self.Types.MAGICAL then
		d:SetDamageType(DMG_ENERGYBEAM)
	elseif dmgType == self.Types.PURE then
		d:SetDamageType(DMG_DIRECT)
	elseif dmgType == self.Types.DEBUFF then
		d:SetDamageType(DMG_POISON)
	end

	target:TakeDamageInfo(d)

	if SERVER and netstream then
		netstream.Start(nil, "fighting.ShowDamage", {
			attacker = attacker,
			target   = target,
			damage   = damage,
			type     = dmgType,
			pos      = target:GetPos() + Vector(0, 0, 50),
			crit     = context.crit or false
		})
	end

	return damage
end

-- Удобные шорткаты, чтобы в коде смотреться приятно
function DAMAGE:Phys(attacker, target, base, pos, ctx)
	return self:Apply(attacker, target, self.Types.PHYSICAL, base, pos, ctx)
end

function DAMAGE:Magic(attacker, target, base, pos, ctx)
	return self:Apply(attacker, target, self.Types.MAGICAL, base, pos, ctx)
end

function DAMAGE:Pure(attacker, target, base, pos, ctx)
	return self:Apply(attacker, target, self.Types.PURE, base, pos, ctx)
end

function DAMAGE:Debuff(attacker, target, base, pos, ctx)
	return self:Apply(attacker, target, self.Types.DEBUFF, base, pos, ctx)
end

fighting.Damage = DAMAGE

return DAMAGE
