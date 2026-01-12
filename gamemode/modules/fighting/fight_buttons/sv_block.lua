AddCSLuaFile()

util.AddNetworkString("fighting.Block.Update")
util.AddNetworkString("fighting.Block.Start")
util.AddNetworkString("fighting.Block.Stop")

local BLOCK_DURABILITY_PERCENT = 0.5
local BLOCK_SPEED_MULT = 0.75
local PARRY_WINDOW = 0.3
local PARRY_COOLDOWN = 5

local PMETA = FindMetaTable("Player")

function PMETA:InitBlockDurability()
    self.BlockDurability = math.floor(self:Health() * BLOCK_DURABILITY_PERCENT)
    self.BlockMaxDurability = self.BlockDurability
    self:SyncBlockDurability()
end

function PMETA:GetBlockDurability()
    return self.BlockDurability or 0
end

function PMETA:GetBlockMaxDurability()
    return self.BlockMaxDurability or 1
end

function PMETA:DamageBlockDurability(dmg)
    if not self.BlockDurability then return end
    self.BlockDurability = math.max(0, self.BlockDurability - dmg)
    self:SyncBlockDurability()
    
    if self.BlockDurability <= 0 then
        self:StopBlocking(true)
    end
end

function PMETA:SyncBlockDurability()
    net.Start("fighting.Block.Update")
    net.WriteFloat(self:GetBlockDurability())
    net.WriteFloat(self:GetBlockMaxDurability())
    net.Send(self)
end

function PMETA:StartBlocking()
    if self.IsBlocking then return end
    if not IsValid(self:GetActiveWeapon()) then return end
    
    local wep = self:GetActiveWeapon()
    if not wep.CanBlock then return end
    
    self:InitBlockDurability()
    
    self.IsBlocking = true
    self.BlockStartTime = CurTime()
    self.BaseSpeed = self:GetRunSpeed()
    
    self:SetRunSpeed(self.BaseSpeed * BLOCK_SPEED_MULT)
    self:SetWalkSpeed(self.BaseSpeed * BLOCK_SPEED_MULT * 0.5)
    
    if wep.HoldTypeBlock then
        wep:SetHoldType(wep.HoldTypeBlock)
    end
    
    net.Start("fighting.Block.Start")
    net.Send(self)
    
    self:EmitSound("weapons/ar2/ar2_reload_rotate.wav", 60, 120)
end

function PMETA:StopBlocking(broken)
    if not self.IsBlocking then return end
    
    self.IsBlocking = false
    self.BlockDurability = nil
    self.BlockMaxDurability = nil
    
    if self.BaseSpeed then
        self:SetRunSpeed(self.BaseSpeed)
        self:SetWalkSpeed(self.BaseSpeed * 0.5)
    end
    
    local wep = self:GetActiveWeapon()
    if IsValid(wep) and wep.HoldType then
        wep:SetHoldType(wep.HoldType)
    end
    
    net.Start("fighting.Block.Stop")
    net.Send(self)
    
    if broken then
        self:EmitSound("physics/metal/metal_box_break1.wav", 70, 90)
        self:AddCooldown(SKILL_BLOCK, 3)
    else
        self:EmitSound("weapons/ar2/ar2_reload_push.wav", 60, 100)
    end
end

function PMETA:IsInParryWindow()
    if not self.BlockStartTime then return false end
    return (CurTime() - self.BlockStartTime) <= PARRY_WINDOW
end

function PMETA:IsAttackInFront(attackerPos)
    local plyPos = self:GetPos()
    local plyForward = self:GetForward()
    local toAttacker = (attackerPos - plyPos):GetNormalized()
    toAttacker.z = 0
    plyForward.z = 0
    plyForward:Normalize()
    
    local dot = plyForward:Dot(toAttacker)
    return dot > 0.3
end

hook.Add("KeyPress", "fighting.Block.KeyPress", function(ply, key)
    if key == IN_ATTACK2 then
        ply:StartBlocking()
    end
end)

hook.Add("KeyRelease", "fighting.Block.KeyRelease", function(ply, key)
    if key == IN_ATTACK2 then
        ply:StopBlocking(false)
    end
end)

hook.Add("PlayerDeath", "fighting.Block.Death", function(ply)
    if ply.IsBlocking then
        ply:StopBlocking(false)
    end
end)

hook.Add("EntityTakeDamage", "fighting.Block.Damage", function(target, dmginfo)
    if not target:IsPlayer() then return end
    if not target.IsBlocking then return end
    
    local attacker = dmginfo:GetAttacker()
    if not IsValid(attacker) then return end
    
    local attackPos = attacker:GetPos()
    if not target:IsAttackInFront(attackPos) then return end
    
    local damage = dmginfo:GetDamage()
    
    if target:IsInParryWindow() and not target:HasCooldown(SKILL_PARRY) then
        dmginfo:SetDamage(0)
        target:AddCooldown(SKILL_PARRY, PARRY_COOLDOWN)
        
        target:EmitSound("weapons/physcannon/energy_sing_explosion2.wav", 75, 150)
        ParticleEffectAttach("[1]_bomb1_add_2", PATTACH_POINT_FOLLOW, target, 6)
        
        netstream.Start(nil, "fnt/player/blocked", target:GetPos() + Vector(0,0,50))
        
        if attacker:IsPlayer() and target:GetPos():Distance(attackPos) < 250 then
            local wep = attacker:GetActiveWeapon()
            if IsValid(wep) then
                wep:SetNextPrimaryFire(CurTime() + 1.2)
                wep:SetNextSecondaryFire(CurTime() + 1.2)
            end
        end
    else
        target:DamageBlockDurability(damage)
        dmginfo:SetDamage(0)
        
        target:EmitSound("physics/metal/metal_box_impact_hard" .. math.random(1,3) .. ".wav", 70, math.random(95, 105))
        
        local effectPos = target:GetPos() + Vector(0,0,50) + target:GetForward() * 20
        ParticleEffect("slashhit_helper_2", effectPos, Angle(0,0,0))
    end
end)

hook.Add("PlayerSpawn", "fighting.Block.Spawn", function(ply)
    timer.Simple(0.1, function()
        if IsValid(ply) then
            ply:SyncBlockDurability()
        end
    end)
end)
