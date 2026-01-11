local QUESTS = {}
QUESTS.Amount = 0
QUESTS.Complete = 0
QUESTS.QuestName = "Знакомство с Алхимией"
QUESTS.main = true
QUESTS.navigate = false
QUESTS.resource = "???"
QUESTS.positions = {}
QUESTS.canpicked = false
QUESTS.description = 'Вы захотели опробовать себя в чем-то новом. Запах трав, зелья, теории, лекарства.. Для вас это очень увлекательно! Именно поэтому алхимия это то, что вам нужно. Удачи в изучении!'

function QUESTS:OnProgress( ply )
	local inv = ply.inventory
	local count = 0
	for k, v in pairs(inv["items"]) do
		if v.itemSource == "wood" then
			count = count + 1
		end
		if count == self.Complete then break end
	end
	if inv:getItemByItemSource("wood") and count == self.Complete then
		self:CompleteQuest(ply)
		count = 0
		for k, v in pairs(inv["items"]) do
			if v.itemSource == "wood" then
				v = nil
				count = count + 1
			end
			if count == self.Complete then break end
		end
	end

	saveInventory(ply)
	refresh_clientquests(ply)
end

function QUESTS:CompleteQuest(ply)
	local playerSkills = ply:GetAttributesSkills() or {}
	local tbl = ply:GetCharacterData("jobs", {})
	tbl[#tbl + 1] = "alchemy"
	ply:CompleteQuest(self)

	playerSkills["alchemy"] = playerSkills["alchemy"] or {}
    playerSkills["alchemy"]["alchemy"] = 1
	ply:SetAttributesSkills(playerSkills)

	ply:SetCharacterData("jobs", tbl)
	netstream.Start(ply, "fantasy/skill/update")
end

function QUESTS:GetDesc()
    return "Найти и собрать для изучения требуемые ресурсы"
end

function QUESTS:GetName()
	return "Получение специализации: Алхимик"
end

function QUESTS:GetBaseValue()
	for i = 1, self.Complete do
		local random = math.random(1, #rand.positions)
		while table.HasValue(self.positions, rand.positions[random]) do
			random = math.random(1, #rand.positions)
		end
		self.positions[#self.positions + 1] = rand.positions[random]
	end
	self.Complete = 5
	self.questname = "Получение специализации: Алхимик"
	self.location = "Разные точки"
	self.tasks = {}
	self.tasks[1] = {name = "Собрать и передать нужные ресурсы, поговорить о дальнейшем обучении", amount = "0", need = "1"}
end

function QUESTS:GetID()
    return "specialization_alchemist"
end

function QUESTS:OnAccepted(ply, data)

end

return QUESTS
