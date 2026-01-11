local QUESTS = {}
local itemsname = {
	[1] = 'wood',
	[2] = 'stone',
	[3] = 'armor',
}
local npcsname = {
	[1] = 'Владу',
	[2] = 'Вовчику',
	[3] = 'Демиту',
}
local npcspos = {
	[1] = Vector(-818.118835, 573.782654, -12287.968750),
	[2] = Vector(702.737427, -708.223816, -12287.968750),
	[3] = Vector(686.544006, 670.515625, -12287.968750),
	[4] = Vector(-35.703747, -19.430010, -12287.968750),
	[5] = Vector(383.199829, -12.883080, -12287.968750),
}
QUESTS.DeliverTo = {}
QUESTS.ItemName = "???"
QUESTS.QuestName = "Доставка"
QUESTS.main = true
QUESTS.navigate = false
QUESTS.canpicked = true
QUESTS.description = 'Вас пригласили в город, расположенный на перекрестке важных торговых путей. В этом шумном городке вас подозвал незнакомец и попросил принести новоиспеченный клинок своим клиентам. Вы конечно же согласились и отправились на эту столь трудную миссию! Удачи!'
QUESTS.difficulty = 1

function QUESTS:OnProgress( ply, tbl )
	local entity = ents.GetByIndex(tbl["ent"])
	entity.WaitPly = ''
	for k, v in pairs(self.DeliverTo) do
		if k == entity.NameNPC then
			local inv = ply.inventory
			for k, v in pairs(inv["items"]) do
				if v.itemSource == self.ItemName then
					v = nil
					self.DeliverTo[k] = true
					self.tasks[k].amount = "1"
					entity.WaitPly = nil
					break
				end
			end
		end
	end
	local isready = true
	for k, v in pairs(self.DeliverTo) do
		if v == false then
			isready = false
		end
	end
	local result = isready and ply:CompleteQuest( self ) or false

	saveInventory(ply)
	refresh_clientquests(ply)
end

function QUESTS:GetDesc(data)
	local name = "Доставить "..data.ItemName

    return name
end

function QUESTS:GetName()
	return "Доставка"
end

function QUESTS:GetID()
    return "delivery"
end

function QUESTS:GetBaseValue(ply)
    local rand = math.random(2, 5)
	for i = 1, rand do
		self.DeliverTo[table.Random(npcsname)] = false
	end
	self.ItemName = table.Random(itemsname)
	self.WaitPly = ply:SteamID()
	self.questname = 'Доставить '..self.ItemName
	self.location = "Местность у курьеров"
	self.tasks = {}
	for k, v in pairs(self.DeliverTo) do
		self.tasks[k] = {name = "Доставить "..self.ItemName.." "..k, amount = "0", need = "1"}
	end
end

function QUESTS:OnAccepted(ply, data)

end

return QUESTS
