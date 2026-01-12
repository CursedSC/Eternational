SWEP.Base = "sword_base"

if (SERVER) then
    AddCSLuaFile()
end

if (CLIENT) then
    SWEP.PrintName = "Меч"
end

SWEP.Category = "Оружие"
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/cloudteam/fantasy/weapons/sword16.mdl" -- models/cloudteam/fantasy/weapons/sword.mdl
SWEP.HoldType = "d_sword"
SWEP.Type = "sword"
SWEP.Spawnable = true

SWEP.Damage = 10 -- Базовый урон меча
SWEP.MainAtt = "strength"

-- Настройки хитбокса (сфера)
SWEP.HitRadius     = 75
SWEP.HitZOffset    = 50
SWEP.HitMaxTargets = 2

local baseAttackFunc = function(self, player)
    timer.Simple(0.3, function()
        if not IsValid(self) or not IsValid(player) then return end

        player:LagCompensation(true)
        self:DoDamage()
        player:LagCompensation(false)

        if player:OnGround() then
            player.InAction = false
        end
    end)
end

SWEP.AttackList = {
    [1] = { seq = "b_right_t2",   cd = 0.7, Attack = baseAttackFunc },
    [2] = { seq = "b_left_t2",    cd = 0.7, Attack = baseAttackFunc },
    [3] = { seq = "arc_atksword2", cd = 0.9, Attack = baseAttackFunc },
}

function SWEP:PrimaryAttack()
    if not self:CanAttack() then return end
    if self.cd and self.cd >= CurTime() then return end

    local player = self.Owner
    local attackData = self.AttackList[self.AttackId]
    self.cd = CurTime() + attackData.cd

    if SERVER then 
        netstream.Start(nil, "fantasy/play/anim", player, attackData.seq, 0, true)
        player:EmitSound("sword/sword_wooh.wav", 100)
        attackData.Attack(self, player)
    end

    self.AttackId = self.AttackId + 1
    if self.AttackId > #self.AttackList then self.AttackId = 1 end
end

function SWEP:DoDamage()
    -- Сфера перед игроком (чуть смещена вперед для удобства)
    local origin = self.Owner:GetPos() + Vector(0,0,self.HitZOffset) + self.Owner:GetForward() * 45
    
    local hits = fighting.Hitbox:Sphere(origin, {
        radius   = self.HitRadius,
        attacker = self.Owner,
        throughWalls = false
    })

    local targetsHit = 0
    for i = 1, #hits do
        if targetsHit >= self.HitMaxTargets then break end

        local target = hits[i].entity
        if IsValid(target) and target ~= self.Owner then
            doAttackDamage(self.Owner, target, self, self.Damage)
            targetsHit = targetsHit + 1
        end
    end
end

hook.Add("StartCommand", "StartCommandExample", function(ply, cmd)
    if ply.InAction then
        --cmd:ClearMovement()
    end
end)
