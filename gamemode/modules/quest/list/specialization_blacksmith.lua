local QUESTS = {}
QUESTS.Amount = 0
QUESTS.Complete = 0
QUESTS.QuestName = "Знакомство с Кузнечным делом"
QUESTS.main = true
QUESTS.navigate = false
QUESTS.resource = "???"
QUESTS.positions = {}
QUESTS.canpicked = false
QUESTS.description = 'Жар кузни, чистая мужская работа в испечении новых клинков для храбрых воинов. Звучит прекрасно! Давай попробуем в этом разобраться.'

function QUESTS:OnProgress( ply )
	local inv = ply.inventory
	local count = 0
	for k, v in pairs(inv["items"]) do
		if v.itemSource == "stone" then
			count = count + 1
		end
		if count == self.Complete then break end
	end
	if inv:getItemByItemSource("stone") and count == self.Complete then
		self:CompleteQuest(ply)
		count = 0
		for k, v in pairs(inv["items"]) do
			if v.itemSource == "stone" then
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
	tbl[#tbl + 1] = "smithing"
	ply:CompleteQuest(self)

	playerSkills["smithing"] = playerSkills["smithing"] or {}
    playerSkills["smithing"]["smithing"] = 1
	ply:SetAttributesSkills(playerSkills)

	ply:SetCharacterData("jobs", tbl)
	netstream.Start(ply, "fantasy/skill/update")
end

function QUESTS:GetDesc()
    return "Найти и собрать для изучения требуемые ресурсы"
end

function QUESTS:GetName()
	return "Получение специализации: Кузнец"
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
	self.questname = "Получение специализации: Кузнец"
	self.location = "Разные точки"
	self.tasks = {}
	self.tasks[1] = {name = "Собрать и передать нужные ресурсы, поговорить о дальнейшем обучении", amount = "0", need = "1"}
end

function QUESTS:GetID()
    return "specialization_blacksmith"
end

function QUESTS:OnAccepted(ply, data)

end

return QUESTS
