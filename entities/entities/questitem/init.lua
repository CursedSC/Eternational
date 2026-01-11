AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
  	self:SetModel(self.Model)
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)

	self:SetNWString("Name", self.itemname)
	self:SetNWString("Job", "Квестовый предмет")
end

function ENT:Use(ply)
	if not table.HasValue(self.WaitPly, ply:SteamID()) then return end
	self:GetDialogue(ply)
	local direction = (ply:GetPos() - self:GetPos()):GetNormal()
	local angles = direction:Angle()
	local newAngles = Angle(0, angles.y, 0)

	-- Поворот головы в сторону игрока
	local headBone = self:LookupBone("ValveBiped.Bip01_Head1")
	if headBone then
		local currentAngles = self:GetManipulateBoneAngles(headBone)
		local targetAngles = Angle(angles.p - self:GetAngles().p, 0, 0)
		targetAngles = Angle(math.Clamp(targetAngles.p, -30, 30), 0, 0)
		self:ManipulateBoneAngles(headBone, targetAngles)
	end
end

function ENT:GetDialogue(ply)
	netstream.Start(ply, "dialoguesystem/npcstart", nil, self.Dialogue, nil, self)
end

function ENT:Think()
	for k, v in pairs(self.WaitPly) do
		if not player.GetBySteamID(v) then
			self.WaitPly[k] = nil
		end
	end

	if table.IsEmpty(self.WaitPly) then
		self:Remove()
	end
end
