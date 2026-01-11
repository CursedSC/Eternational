AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
  	self:SetModel(self.Model)
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)

	self:RunAnimation(self.Sequence)
	self.anim = self.Sequence

	self:SetNWString("Name", "Владимир")
	self:SetNWString("Job", "Скупщик")
end

function ENT:Use(ply)
	--if self.WaitPly != ply:SteamID() and self.WaitPly != '' then return end
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
	local dialogue = "npc_getitem"
	for k, v in pairs(ply.Quests["Side"]) do
		if v.name == "Добыть и передать скупщику" then
			dialogue = "npc_waitgetitem"
			break
		end
		if v.name == "Проверить заданые координаты" and v.tasks[1].iscompleted then
			dialogue = "npc_waitpoints"
			break
		end
		if v.codename == "hunt" and v.tasks[1].iscompleted then
			dialogue = "npc_waithunt"
			break
		end
	end

	netstream.Start(ply, "dialoguesystem/npcstart", nil, dialogue, nil, self)
end

function ENT:Think()
    --if self.WaitPly == '' then self:Remove() end
end
