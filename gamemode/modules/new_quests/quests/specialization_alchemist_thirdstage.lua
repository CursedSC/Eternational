local quest = table.Copy(basequest)
quest.title = "Обучение ремеслу"
quest.type = "Main"
quest.secondtype = "specialization_alchemist_thirdstage"
quest.name = ""
quest.codename = "specialization_alchemist_thirdstage"
quest.tasks = {}
quest.Owner = "SteamID64"

quest.difficulty = 1
quest.description = "Успешно пройдя проверку знаний, вы получили рецепт неизвестного вам зелья. Теперь ваша задача — вложить максимум усилий в его создание, чтобы достойно представить своё творение мастеру."
quest.location = "Зельеварня"
quest.navigate = false
quest.rewards = {[1] = {dataid = "specialization", specialization = "alchemist"}}
quest.removeafterleave = false

function quest:SetBaseValues(ply, variation)
	self.name = "Тайны Зельевара #3"
	self.Owner = ply:SteamID64()
	self.tasks = {
		[1] = {text = 'Изучить новый рецепт от алхимика в инвентаре', current = 0, need = 1, taskname = "userecipe", itemid = "studentpotion", iscompleted = false},
		[2] = {text = 'Сварить зелье по рецепту алхимика в верстаке и отдать алхимику', current = 0, need = 1, taskname = "deliveryitem", itemid = "student_potion", iscompleted = false},
		[3] = {text = 'Поговорить с алхимиком', current = 0, need = 1, taskname = "talktonpc", itemid = "endquest", iscompleted = false},
	}
end

return quest
