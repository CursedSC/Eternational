local QUESTS = {}
QUESTS.Amount = 0
QUESTS.Complete = 0
QUESTS.MobName = "???"
QUESTS.mobClass = "npc_zombie"
QUESTS.QuestName = "Охота"
QUESTS.main = false
QUESTS.navigate = false
QUESTS.canpicked = true
QUESTS.description = 'Какой - то раненный охотник на нежить предложил вам работку. За оказанную ему помощь в убийстве этих тварей вам полагается монетка.'
QUESTS.difficulty = 3

local variations = {
	["Аборигены"] = "drg_roach_geim_hilichurl",
	["Зомби"] = "npc_zombie",
}

function QUESTS:OnProgress( ply, mob )
    if mob:GetClass() == self.mobClass then
        self.Amount = self.Amount + 1
		self.tasks[1].amount = tostring(self.Amount)
        if self.Amount >= self.Complete then
            ply:CompleteQuest( self )
        end
    end

	refresh_clientquests(ply)
end

function QUESTS:GetDesc()
    return "Убить "..self.MobName
end

function QUESTS:GetName()
	return "Охота"
end

function QUESTS:GetBaseValue()
	local datarand = table.Random(variations)
    self.MobName = table.KeyFromValue(variations, datarand)
	self.mobClass = datarand
	self.Complete = math.random(3, 7)
	self.questname = 'Убить '..self.MobName
	self.location = "(IN DEV)"
	self.tasks = {[1] = {name = "Убить "..self.MobName, amount = "0", need = tostring(self.Complete)}}
end

function QUESTS:GetID()
    return "killmobs"
end

function QUESTS:OnAccepted(ply, data)

end

return QUESTS
