local QUESTS = {}
QUESTS.Amount = 0
QUESTS.Complete = 0
QUESTS.QuestName = "Разведка"
QUESTS.main = false
QUESTS.navigate = false
QUESTS.canpicked = true
QUESTS.description = 'Проверить точечки по заданию.'
QUESTS.points = {}
QUESTS.difficulty = 1

local positions = {
	[1] = Vector(-818.118835, 573.782654, -12287.968750),
	[2] = Vector(702.737427, -708.223816, -12287.968750),
	[3] = Vector(686.544006, 670.515625, -12287.968750),
	[4] = Vector(-35.703747, -19.430010, -12287.968750),
	[5] = Vector(383.199829, -12.883080, -12287.968750),
	[6] = Vector(393.199829, -12.883080, -12287.968750),
	[7] = Vector(453.199829, -12.883080, -12287.968750),
	[8] = Vector(393.199829, -52.883080, -12287.968750),
	[9] = Vector(413.199829, -52.883080, -12287.968750),
	[10] = Vector(603.199829, -12.883080, -12287.968750),
}

function QUESTS:OnProgress( ply, pointkey )
	self.Amount = self.Amount + 1
	self.tasks[1].amount = tostring(self.Amount)
	self.points[pointkey] = nil
	if self.Amount == self.Complete then
		ply:CompleteQuest( self )
	end

	refresh_clientquests(ply)
end

function QUESTS:GetDesc()
    return "Проверить разные точки"
end

function QUESTS:GetName()
	return "Разведка"
end

function QUESTS:GetBaseValue()
	self.Complete = math.random(3, 7)
	for i = 1, self.Complete do
		local rand = math.random(1, #positions)
		while table.HasValue(self.points, positions[rand]) do
			rand = math.random(1, #positions)
		end
		self.points[#self.points + 1] = positions[rand]
	end
	self.questname = 'Проверить заданые точки.'
	self.location = "Разные точки"
	self.tasks = {[1] = {name = "Посетить помеченые точки", amount = "0", need = tostring(self.Complete)}}
end

function QUESTS:GetID()
    return "points"
end

function QUESTS:OnAccepted(ply, data)

end

return QUESTS
