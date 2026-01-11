local quest = table.Copy(basequest)
quest.title = "Обучение ремеслу"
quest.type = "Main"
quest.secondtype = "specialization_alchemist"
quest.name = ""
quest.codename = "specialization_alchemist_secondstage"
quest.tasks = {}
quest.Owner = "SteamID64"

quest.difficulty = 1
quest.description = "Собрав нужные материалы и передав их мастеру, вы снискали его уважение. В благодарность кузнец решил приоткрыть перед вами врата ремесла и вручил свиток с наставлениями — изучите его тщательно."
quest.location = "Зельеварня"
quest.navigate = false
quest.rewards = {[1] = {dataid = "item", amount = 1, itemid = "studentpotion"}}
quest.removeafterleave = false

function quest:SetBaseValues(ply, variation)
	self.name = "Тайны Зельевара #2"
	self.nextquest = "specialization_alchemist_thirdstage"
	self.tasks = {
		[1] = {text = 'Изучить записку алхимика и пройти его проверку', current = 0, need = 1, taskname = "talktonpc", itemid = "test", iscompleted = false},
		[2] = {text = 'Поговорить с алхимиком', current = 0, need = 1, taskname = "talktonpc", itemid = "nextquest", iscompleted = false},
	}
	self.Owner = ply:SteamID64()
end

return quest
