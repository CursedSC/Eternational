/*local meta = FindMetaTable('Player')
meta.Quests = meta.Quests or {}

function meta:AddQuest( id, data )
    self.Quests = self.Quests or {}
	self.Quests["Current"] = self.Quests["Current"] or {}

    local quest = table.Copy(questsList[id])
    for k, i in pairs(data) do
        quest[k] = i
    end
    table.insert(self.Quests["Current"], quest)
	if quest.OnAccepted then
		quest:OnAccepted(self, data)
	end

	savedataquests(self)
end

function meta:CompleteQuest( id )
	local idfordata = questData(id)
    self.Quests = self.Quests or {}
	self.Quests["Completed"] = self.Quests["Completed"] or {}
	for k, v in pairs(self.Quests["Current"]) do
        if v == id then
            table.remove(self.Quests["Current"], k)
        end
    end

	if idfordata.main then
		table.insert(self.Quests["Completed"], idfordata)
	end
	savedataquests(self)
end

function meta:QuestsHave(id)
    local isHave = false
    local tableQuests = {}
	self.Quests["Current"] = self.Quests["Current"] or {}
    for k, v in pairs(self.Quests["Current"]) do
        if v.id == id then
            isHave = true
            tableQuests[k] = v
        end
    end

    return isHave, tableQuests
end*/
