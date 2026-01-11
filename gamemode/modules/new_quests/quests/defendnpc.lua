local quest = {}
local mobs = {
	["npc_zombie"] = "Зомби",
}
quest.title = "Найти и спасти пропавших"
quest.type = "Side"
quest.secondtype = "killnpc"
quest.name = ""
quest.codename = "defendnpc"
quest.tasks = {}
quest.Owner = "SteamID64"

quest.difficulty = 3
quest.description = "IN DEV"
quest.location = "IN DEV"
quest.navigate = false
quest.removeafterleave = false

function quest:SetBaseValues(ply, variation)
	local randommobvalue = variation and mobs[variation] or table.Random(mobs)
	local randommobkey = table.KeyFromValue(mobs, randommobvalue)

	self.name = "Помочь попавшим в беду жителям"
	self.tasks = {
		[1] = {text = 'Убить ' .. randommobvalue, current = 0, need = math.random(5, 7), npc_class = randommobkey, taskname = "kill", iscompleted = false},
		[2] = {text = 'Поговорить и помочь выжившим жителям', current = 0, need = 4, npc_class = "npc_dialogue", taskname = "dialogue", iscompleted = false},
	}
	self.Owner = ply:SteamID64()
end

function quest:OnProgress(taskname, npcclass)
	local tasknum = false
	for k, v in pairs(self.tasks) do
		if v.taskname == taskname and v.npc_class == npcclass then
			tasknum = k
			break
		end
 	end
	if not tasknum then return end

	self.tasks[tasknum].current = math.Clamp(self.tasks[tasknum].current + 1, 0, self.tasks[tasknum].need)
	self.tasks[tasknum].iscompleted = self.tasks[tasknum].current == self.tasks[tasknum].need

	local completed = 0
	for k, v in pairs(self.tasks) do
		if v.iscompleted then completed = completed + 1 end
	end

	if completed == table.Count(self.tasks) then
		self:OnComplete()
	end

	questsystem.saveData(player.GetBySteamID64(self.Owner))
end

function quest:OnComplete()
	local ply = player.GetBySteamID64(self.Owner)
	if self.rewards then
		for k, v in pairs(self.rewards) do
			if v.dataid == "item" then
				local itemtoadd = Item:new(v.itemid)
				ply.inventory:addItem(itemtoadd, v.amount)
			elseif v.dataid == "specialization" then
				local jobs = table.Copy(ply:GetCharacterData("jobs", {}))
				jobs[v.specialization] = true

				ply:SetCharacterData("jobs", jobs)
			else
				ply:SetCharacterData(v.dataid, ply:GetCharacterData(v.dataid) + v.amount)
			end
		end
	end

	self.navigate = false
	questsystem.completeQuest(ply, self)
	if self.nextquest then questsystem.addQuest(ply, questslist[self.nextquest], self.variation and self.variation or nil) end
end

--return quest
