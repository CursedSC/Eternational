DEFINE_BASECLASS("weapon_base")

SWEP.PrintName = "Лук ополченца"
SWEP.Category = "Оружия Тир 1"
SWEP.Author = "CloudTeam"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""

SWEP.ViewModelFOV = 68
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/CloudTeam/Fantasy/Weapons/Bow/1/v_huntingbow.mdl")
SWEP.WorldModel = Model("models/cloudteam/fantasy/weapons/bow15.mdl")

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "huntingbow_arrows"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.UseHands = true

SWEP.m_WeaponDeploySpeed = 1

SWEP.STATE_NONE = 0
SWEP.STATE_NOCKED = 1
SWEP.STATE_PULLED = 2
SWEP.STATE_RELEASE = 3

SWEP.ActivitySound = {}
SWEP.ActivitySound[ACT_VM_PULLBACK] = "Weapon_HuntingBow.Pull"
SWEP.ActivitySound[ACT_VM_PRIMARYATTACK] = "Weapon_HuntingBow.Single"
SWEP.ActivitySound[ACT_VM_LOWERED_TO_IDLE] = "Weapon_HuntingBow.Nock"
SWEP.ActivitySound[ACT_VM_DRAW] = "Weapon_HuntingBow.Draw"
SWEP.ActivitySound[ACT_VM_RELEASE] = "Weapon_HuntingBow.Pull"

SWEP.ActivityLength = {}
SWEP.ActivityLength[ACT_VM_PULLBACK] = 0.2
SWEP.ActivityLength[ACT_VM_PRIMARYATTACK] = 0.25
SWEP.ActivityLength[ACT_VM_DRAW] = 0.8
SWEP.ActivityLength[ACT_VM_RELEASE] = 0.5
SWEP.ActivityLength[ACT_VM_LOWERED_TO_IDLE] = 1
SWEP.ActivityLength[ACT_VM_IDLE_TO_LOWERED] = 0.25

SWEP.HoldTypeTranslate = {}
SWEP.HoldTypeTranslate[SWEP.STATE_NONE] = "normal"
SWEP.HoldTypeTranslate[SWEP.STATE_NOCKED] = "pistol"
SWEP.HoldTypeTranslate[SWEP.STATE_PULLED] = "pistol"
SWEP.HoldTypeTranslate[SWEP.STATE_RELEASE] = "grenade"

SWEP.type = "bow"
SWEP.ConfigType = "bow"
game.AddAmmoType {
	name = "huntingbow_arrows",
	tracer = TRACER_NONE
}

if CLIENT then
	language.Add("huntingbow_arrows_ammo", "Arrows")
end

sound.Add {
	channel = CHAN_AUTO,
	volume = 0.2,
	level = 60,
	name = "Weapon_HuntingBow.Draw",
	sound = { "weapons/huntingbow/draw_1.wav", "weapons/huntingbow/draw_2.wav" }
}

sound.Add {
	channel = CHAN_AUTO,
	volume = 0.4,
	level = 60,
	name = "Weapon_HuntingBow.Nock",
	sound = { "weapons/huntingbow/nock_1.wav", "weapons/huntingbow/nock_2.wav", "weapons/huntingbow/nock_3.wav" }
}

sound.Add {
	channel = CHAN_AUTO,
	volume = 0.3,
	level = 60,
	name = "Weapon_HuntingBow.Pull",
	sound = { "weapons/huntingbow/pull_1.wav", "weapons/huntingbow/pull_2.wav", "weapons/huntingbow/pull_3.wav" }
}

sound.Add {
	channel = CHAN_AUTO,
	volume = 1,
	level = 60,
	name = "Weapon_HuntingBow.Single",
	sound = { "weapons/huntingbow/shoot_1.wav", "weapons/huntingbow/shoot_2.wav", "weapons/huntingbow/shoot_3.wav" }
}

sound.Add {
	channel = CHAN_AUTO,
	volume = 1,
	level = 60,
	name = "Weapon_HuntingBow.ZoomIn",
	sound = "weapons/huntingbow/zoomin.wav"
}

sound.Add {
	channel = CHAN_AUTO,
	volume = 1,
	level = 60,
	name = "Weapon_HuntingBow.ZoomOut",
	sound = "weapons/huntingbow/zoomout.wav"
}

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "WepState")
end

local trans = {
	[1] = "E",
	[2] = "R",
	[3] = "F",
	[4] = "Caps" 
}


function SWEP:PrimaryAttack()
	return
end

function SWEP:SecondaryAttack()
	return
end

function SWEP:Reload()
	return
end

function SWEP:EmitSoundX(...)
	if (game.SinglePlayer() and SERVER) or (CLIENT and IsFirstTimePredicted()) then
		return self:EmitSound(...)
	end
end

function SWEP:PlayActivity(act)
	self:SendWeaponAnim(act)

	local snd = self.ActivitySound[act]
	if snd then
		self:EmitSoundX(snd)
	end

	local t = self.ActivityLength[act]
	if t then
		self:SetNextPrimaryFire(CurTime() + t)
	end
end

function SWEP:Ammo1()
	return self.Owner:GetAmmoCount(self:GetPrimaryAmmoType())
end

SWEP.ShakeBeginTime = 4
SWEP.ShakeLength = 5

SWEP.ShakeX = 0
SWEP.ShakeY = 0

local sin, cos = math.sin, math.cos

function SWEP:Think()
	local ply = self.Owner
	local CT = CurTime()
	local nextFire = self:GetNextPrimaryFire()
	if not self.cooldown then self.cooldown = {} self.cd = 0 end
	if self.dt.WepState == self.STATE_PULLED then
		local stamina  = math.Clamp(CT - self:GetNextSecondaryFire() - self.ShakeBeginTime, 0, self.ShakeLength) / self.ShakeLength
		local stamina2 = 1 - stamina ^ 3

		self.ShakeX = sin(CT * 3)      * 0.6 * stamina + sin(CT * 64)      * 0.2 * stamina ^ 3
		self.ShakeY = cos(CT * 2 + 45) * 0.6 * stamina + sin(CT * 58 + 45) * 0.2 * stamina ^ 3
	else
		self.ShakeX = 0
		self.ShakeY = 0
	end


	if nextFire >= CT then
		return
	end

	local noClip = self.Owner:GetMoveType() == MOVETYPE_NOCLIP
	local onGround = self.Owner:IsOnGround()
	if self.Owner:KeyDown(IN_ATTACK2) then 
		cam_type = 1
	else
		cam_type = 0
	end
	
	if self.dt.WepState == self.STATE_PULLED then
		local inv = ply.inventory or playerInventory
		local hasItem, itemCount = inv:hasItems("stick")
		if self.Owner:KeyDown(IN_RELOAD) or self.Owner:KeyDown(IN_SPEED) or (not onGround and not noClip) or not hasItem then
			self.dt.WepState = self.STATE_NOCKED
			self:PlayActivity(ACT_VM_RELEASE)
		elseif not self.Owner:KeyDown(IN_ATTACK) then
			self.dt.WepState = self.STATE_RELEASE
			self:PlayActivity(ACT_VM_PRIMARYATTACK)
			self:SetHoldType("bow.Act.2")
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			if SERVER then
				local ang = self.Owner:GetAimVector():Angle()
				local pos = self.Owner:EyePos() + ang:Up() * -7 + ang:Forward() * -4

				if not self.Owner:KeyDown(IN_ATTACK2) then
					pos = pos + ang:Right() * 1.5
				end
				local charge = self:GetNextSecondaryFire()
				      charge = math.Clamp(CT - charge, 0, 1)

				local arrow = ents.Create("huntingbow_arrow")
				arrow:SetOwner(self.Owner)
				arrow:SetPos(pos)
				arrow:SetAngles(ang)
				arrow:Spawn()
				arrow:SetModel("models/cloudteam/fantasy/weapons/arrow10.mdl")
				arrow:Activate()
				arrow:SetDMG(30)
				arrow:SetMoveType(MOVETYPE_FLY)
				arrow:SetVelocity(ang:Forward() * 3000 * charge)
				arrow.Weapon = self
				inv:removeItemsBySource("stick")
				self.aim_arror  = false
			end
		end
	elseif self.dt.WepState == self.STATE_RELEASE then
		if self.Owner:KeyDown(IN_ATTACK) and hasItem then 
			self.dt.WepState = self.STATE_NOCKED
			self:PlayActivity(ACT_VM_LOWERED_TO_IDLE)
			self:SetHoldType("bow.Act.1")
		else
			self.dt.WepState = self.STATE_NONE
			self:PlayActivity(ACT_VM_IDLE_TO_LOWERED)	
		end
	elseif self.dt.WepState == self.STATE_NOCKED then
		local inv = ply.inventory or playerInventory
		if inv:hasItems("stick") and self.Owner:KeyDown(IN_ATTACK) and not (not onGround and not noClip) and not self.Owner:KeyDown(IN_RELOAD) and not self.Owner:KeyDown(IN_SPEED) then
			self.dt.WepState = self.STATE_PULLED
			self:SetHoldType("bow.Act.1")
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			self:PlayActivity(ACT_VM_PULLBACK)
			self:SetNextSecondaryFire(CT)
		end
	elseif self.dt.WepState == self.STATE_NONE then
		if (self.Owner:KeyDown(IN_RELOAD) or self.Owner:KeyPressed(IN_ATTACK)) then
			self.dt.WepState = self.STATE_NOCKED 
			self:PlayActivity(ACT_VM_LOWERED_TO_IDLE)
		end
	elseif self.dt.WepState == BOW_HOLSTER then
		if SERVER then
			if IsValid(self.nextWeapon) then
				self.Owner:SelectWeapon(self.nextWeapon:GetClass())
				self.nextWeapon = nil
			end
		end
	end
end

function SWEP:Holster(wep)
	return true
end
function SWEP:DoAnimation( anim )
	self:SetHoldType(anim)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end
function SWEP:Deploy()
	if CLIENT then
		self.AimMult = 0
		self.AimMult2 = 0
	end

	self.dt.WepState = self.STATE_NONE
	self.nextWeapon = nil

	self:PlayActivity(ACT_VM_DRAW)
	return true
end