local QUESTS = {}
QUESTS.Amount = 0
QUESTS.Complete = 0
QUESTS.ItemName = "???"
QUESTS.QuestName = "Добыча предмета"
QUESTS.main = false
QUESTS.navigate = false
QUESTS.description = 'Добыть нужный предмет. Ничего трудного, наверное'
QUESTS.canpicked = true
QUESTS.difficulty = 1

function QUESTS:OnProgress( ply )
    self.tasks[1].amount = self.tasks[1].amount + 1
	if self.tasks[1].amount >= self.Complete then
		ply:CompleteQuest(self)
		self.tasks[1].amount = 0
	end
	savedataquests(ply)
end

function QUESTS:GetDesc()
    return self.desc
end

function QUESTS:GetName()
	return "Добыча предмета"
end

local QuestVariations = {}
QuestVariations[1] = {
	name = "Помощь лесорубу",
	text = "Местный лесоруб просит вас помочь ему в сборе древесины. Он говорит, что в лесу много деревьев, которые нужно срубить, и он не справляется один.",
	item = "wood",
	location = "Территория возле города",
	need = {
		min = 5,
		max = 10
	}
}


function QUESTS:GetBaseValue()
	local randtable = table.Random(QuestVariations)
    self.ItemName = randtable.item
	self.Complete = math.random(randtable.need.min, randtable.need.max)
	self.QuestName = randtable.name
	self.location = randtable.location
	self.desc = randtable.text
	self.tasks = {
		{
			name = "Добыть "..itemList[self.ItemName].Name, 
			amount = 0, 
			need = self.Complete
		}
	}
end

function QUESTS:GetID()
    return "getitem"
end

function QUESTS:OnAccepted(ply, data)

end

return QUESTS
