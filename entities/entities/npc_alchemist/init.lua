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

	self:SetNWString("Name", "Элрик")
	self:SetNWString("Job", "Алхимик")
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
	for k, v in pairs(ply.Quests["Complete"]) do
		if v.name == "Тайны Зельевара #3" or v.name == "Жаркое дело #1" then
			netstream.Start(ply, "dialoguesystem/npcstart", nil, "npc_blacksmith_withoutquest", nil, self)
			return
		end
	end
	for k, v in pairs(ply.Quests["Main"]) do
		if v.name == "Жаркое дело #1" then
			netstream.Start(ply, "dialoguesystem/npcstart", nil, "npc_blacksmith_withoutquest", nil, self)
			return
		end
	end
	local dialogue = "npc_alchemist_start"
	local allcomplete = true
	for k, v in pairs(ply.Quests["Main"]) do
		if v.name == "Тайны Зельевара #1" then
			for _, task in pairs(v.tasks) do
				if task.iscompleted == false and task.taskname != "talktonpc" then
					allcomplete = false
					break
				end
			end
			if allcomplete then
				dialogue = "npc_alchemist_secondstage"
			else
				dialogue = "npc_alchemist_wait"
			end
			break
		end
		if v.name == "Тайны Зельевара #2" then
			dialogue = v.tasks[1].iscompleted and "npc_alchemist_thirdstage" or "npc_alchemist_test"
		end
		if v.name == "Тайны Зельевара #3" then
			for _, task in pairs(v.tasks) do
				if task.iscompleted == false and task.taskname != "talktonpc" then
					allcomplete = false
					break
				end
			end
			if allcomplete then
				dialogue = "npc_alchemist_end"
			else
				dialogue = "npc_alchemist_waitpotion"
			end
			break
		end
	end

	netstream.Start(ply, "dialoguesystem/npcstart", nil, dialogue, nil, self)
end

function ENT:Think()
    --if self.WaitPly == '' then self:Remove() end
end
