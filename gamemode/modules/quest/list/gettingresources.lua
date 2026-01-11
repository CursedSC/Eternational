local QUESTS = {}
QUESTS.Amount = 0
QUESTS.Complete = 0
QUESTS.QuestName = "Поиск ресурсов"
QUESTS.main = false
QUESTS.navigate = false
QUESTS.resource = "???"
QUESTS.canpicked = true
QUESTS.positions = {}
QUESTS.description = 'Найти и собрать помеченые ресурсы.'
QUESTS.difficulty = 2
QUESTS.resource = "???"

local tblitems = {
	[1] = "wood",
	[2] = "stone",
}

function QUESTS:OnProgress( ply, ent )
	local inv = ply.inventory
	local count = 0
	for k, v in pairs(inv["items"]) do
		if v.itemSource == self.resource then
			count = count + 1
		end
		if count == self.Complete then break end
	end
	if inv:getItemByItemSource(self.resource) and count == self.Complete then
		ply:CompleteQuest(self)
		count = 0
		for k, v in pairs(inv["items"]) do
			if v.itemSource == self.resource then
				v = nil
				count = count + 1
			end
			if count == self.Complete then break end
		end
	end

	ent:Remove()

	saveInventory(ply)
	refresh_clientquests(ply)
end

function QUESTS:GetDesc()
    return "Найти и собрать: ".. self.resource
end

function QUESTS:GetName()
	return "Поиск ресурсов"
end

function QUESTS:GetBaseValue()
	self.Complete = math.random(1, 4)
	local rand = table.Random(tblitems)
	self.resource = rand
	self.questname = 'Поиск ресурсов'
	self.location = "Разные точки"
	self.tasks = {[1] = {name = "Собрать нужные ресурсы", amount = "0", need = tostring(self.Complete)}}
end

function QUESTS:GetID()
    return "gettingresources"
end

function QUESTS:OnAccepted(ply, data)

end

return QUESTS
