if (SERVER) then
	AddCSLuaFile()
end

if (CLIENT) then
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.PrintName = "База"
	SWEP.DrawCrosshair = true
end

SWEP.UseHands = false
SWEP.Category = "Оружие"
SWEP.Author = "Demit"
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/cloudteam/fantasy/weapons/sword16.mdl" -- models/cloudteam/fantasy/weapons/sword.mdl
SWEP.AdminSpawnable = false
SWEP.Spawnable = true
SWEP.Primary.NeverRaised = true
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 90
SWEP.Primary.Delay = 3
SWEP.Primary.Ammo = ""
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Delay = 0
SWEP.Secondary.Ammo = ""
SWEP.SphereSize = 60
SWEP.CanBlock = true
SWEP.SphereSize = 60
SWEP.HoldType = "d_sword"
SWEP.HoldTypeBlock = "d_sword_block"
SWEP.BlockAnim = "wos_aoc_sword_block"
SWEP.cd = 0

function SWEP:Deploy()
    self.IsBlock = false
    self.AttackId = 1
    self.LastBlock = self.LastBlock or 0
    self:SetHoldType(self.HoldType)

    return true
end

function SWEP:Initialize()
	self.OnBlock = false
    self.AttackId = 1
    self.LastBlock = self.LastBlock or 0
    self:SetHoldType(self.HoldType)

end

function SWEP:Holster( wep )
	self.OnBlock = false
	self.AttackId = 1
    self.LastBlock = self.LastBlock or 0
	return true
end 
 
function SWEP:CanBlocking()
	return self.CanBlock and (self.LastBlock < CurTime()) and (!self.Owner.InSkill) and (!self.Owner.InPari) and (!self.Owner.InSkill) and (self.cd < CurTime())
end 

function SWEP:IsBlocking()
	return self.CanBlock and (self.LastBlock > CurTime())
end 


function SWEP:GetAttackAngle()
	local angle = self.Owner:GetAngles()
	local angle = Angle(0, angle.y, 0)
	return angle
end 

function SWEP:GetDistanseAttack()
    local base = self.SphereSize
    local playerInventory = self.Owner.inventory
    local hasWeapon = playerInventory:GetEquippedItem("weapon")

    if hasWeapon then 
        local bonus = hasWeapon:getMeta("sharpBonus") or nil
        if bonus and bonus["distantion"] then 
            base = base + sharpBonus["distantion"]
        end 
    end

    return base
end

function SWEP:DoAnimation( anim )
	self:SetHoldType(anim)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:CanAttack( anim )
    return (self.cd < CurTime()) and (!self.Owner.InSkill) and (!self.Owner.InPari)
end

function SWEP:SecondaryAttack()	
    if self.Owner:HasCooldown(SKILL_BLOCK) then return end
    if !self:CanBlocking() then return end

    -- Реализация блока под варик поситива
    --[[
    if CLIENT then return end	
    local ply = self.Owner
    Fight.Skills.Block(ply)
    if ply.IsBlock then self:SetHoldType(self.HoldTypeBlock) else self:SetHoldType(self.HoldType) end]]

    -- Реализация блока под мой варик
    local ply = self.Owner
    local isMove = ply:GetVelocity():Length2D() > 0
    self.LastBlock = CurTime() + 0.5
    if SERVER then netstream.Start(nil, "fantasy/play/anim", ply, self.BlockAnim,  0, true) end
    self.cd = CurTime() + 0.8
    ply:AddCooldown(SKILL_BLOCK, 1)
end
 
netstream.Hook("fantasy/play/anim", function(target, anim, a, b)
    target:AddVCDSequenceToGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD, target:LookupSequence(anim), a, b)
end)