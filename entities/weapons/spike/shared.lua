SWEP.Base = "sword_base"

if (SERVER) then
	AddCSLuaFile()
end 
 
if (CLIENT) then
	SWEP.PrintName = "Копье"
end
SWEP.Spawnable = true
SWEP.Category = "Оружие"
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/cloudteam/fantasy/weapons/spear21.mdl" -- models/cloudteam/fantasy/weapons/sword.mdl
SWEP.Damage = 5
SWEP.HoldType = "d_knife"
SWEP.Type = "knife"
SWEP.SphereSize = 100
SWEP.AttackList = {
	[1] = {
		seq = "b_c3_t2",
		cd = 0.8,
		Attack = function(self, player)
			timer.Simple(0.1, function()
				local damagePos = self.Owner:GetPos() + Vector(0,0,50)
				local damagePos2 = self.Owner:GetPos() + Vector(0,0,50) + ( self:GetAttackAngle():Forward() * self.SphereSize)
				self:DoDamage(damagePos, damagePos2)
				if player:OnGround() then  
					--player:SetVelocity(player:GetForward() * 400)
					player.InAction = false 
				end
			end)
		end,
	}
}

function SWEP:PrimaryAttack(ignore)
	if !self:CanAttack() then return end
	if self.cd and self.cd >= CurTime() then return end
	local player = self.Owner 
	local attackData = self.AttackList[self.AttackId]
	self.cd = CurTime() + attackData.cd
	if SERVER then netstream.Start(nil, "fantasy/play/anim", player, attackData.seq,  0, true) end

	
	if SERVER then 
		player:EmitSound("sword/sword_wooh.wav", 100)
		attackData.Attack(self, player)
	end
	self.AttackId = self.AttackId + 1 
	if self.AttackId > #self.AttackList then self.AttackId = 1 end
end

function ents.FindInCapsule(startPos, endPos, radius)
    local foundEntities = {}
    
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) then
            local entPos = ent:GetPos()

            local toStart = entPos - startPos
            local toEnd = entPos - endPos
            local capsuleDir = (endPos - startPos):GetNormalized()
            local projectedLength = math.Clamp(toStart:Dot(capsuleDir), 0, startPos:Distance(endPos))
            local closestPoint = startPos + capsuleDir * projectedLength

            if entPos:DistToSqr(closestPoint) <= radius * radius then
                table.insert(foundEntities, ent)
            end
        end
    end

    return foundEntities
end


function SWEP:DoDamage(damagePos, damagePos2)
	local entityAttacked = ents.FindInCapsule(damagePos, damagePos2, 30) //ents.FindInSphere(pos, self.SphereSize)
	for k, i in pairs(entityAttacked) do 
		if !i:IsNPC() and !i:IsPlayer() and !i:IsNextBot() then continue end 
		if i == self.Owner then continue end  
		doAttackDamage(self.Owner, i, self, self.Damage)
	end
end