local quest = table.Copy(basequest)
quest.title = "Помощь старику"
quest.type = "Main"
quest.secondtype = "helpoldman"
quest.name = "Странные слухи"
quest.codename = "helpoldman"
quest.tasks = {}
quest.Owner = "SteamID64"
quest.rewards = {[1] = {dataid = "money", amount = 50}}

quest.difficulty = 1
quest.description = "Местные жители шепчутся о сумасшедшем старике, твердящим о древнем проклятии, из-за которого лесные духи стали агрессивными. Вы решили разузнать об этом и поговорили со стариком, который рассказал вам об зачарованном тотеме в Старом лесу. Тотем охраняется аборигенами - нужно разобраться с ними и разбить тотем."
quest.location = "Старый лес"
quest.navigate = false

function quest:SetBaseValues(ply)
	self.tasks = {
		[1] = {text = 'Отправиться в Старый лес', current = 0, need = 1, taskname = "checkpoints", iscompleted = false},
		[2] = {text = 'Найти зачарованный тотем и сломать его', current = 0, need = 1, itemid = "questitemuse", taskname = "talktonpc", iscompleted = false},
		[3] = {text = 'Вернуться к старику и принести ему остатки тотема', current = 0, need = 1, itemid = "endquest", taskname = "talktonpc", iscompleted = false},
	}
	self.points = {[1] = Vector(-6876.941406, 8621.463867, -42.751015)}
	self.argstable = {["Model"] = "models/nocturnal_basin.mdl", ["itemname"] = "Древний тотем", ["WaitPly"] = ply:SteamID(), ["Dialogue"] = "questitem_totem", ["position"] = Vector(-6688.758789, 8302.294922, 1.355957)}

	self.Owner = ply:SteamID64()
	self:OnAccepted(self.argstable)
end

function quest:OnAccepted(table)
	if self.tasks[2].iscompleted then return end

	for k, v in pairs(ents.GetAll()) do
		if v:GetClass() == "questitem" then
			if v.Dialogue == table["Dialogue"] then
				v.WaitPly[#v.WaitPly + 1] = table["WaitPly"]
				self.entities[#self.entities + 1] = ent
				return
			end
		end
	end

	local ent = ents.Create("questitem")
	ent.Model = table["Model"]
	ent.itemname = table["itemname"]
	ent.WaitPly = {[1] = table["WaitPly"]}
	ent.Dialogue = table["Dialogue"]
	ent:SetPos(table["position"])

	ent:Spawn()
	self.entities[#self.entities + 1] = ent
end

return quest
