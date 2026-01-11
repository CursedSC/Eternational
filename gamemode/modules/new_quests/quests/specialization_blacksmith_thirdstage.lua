local quest = table.Copy(basequest)
quest.title = "Обучение ремеслу"
quest.type = "Main"
quest.secondtype = "specialization_blacksmith_thirdstage"
quest.name = ""
quest.codename = "specialization_blacksmith_thirdstage"
quest.tasks = {}
quest.Owner = "SteamID64"

quest.difficulty = 1
quest.description = "Успешно пройдя проверку знаний, вы получили рецепт меча новичка. Теперь ваша задача — вложить максимум усилий в его создание, чтобы достойно представить своё творение мастеру."
quest.location = "Кузница"
quest.navigate = false
quest.rewards = {[1] = {dataid = "specialization", specialization = "smithing"}}
quest.removeafterleave = false

function quest:SetBaseValues(ply, variation)
	self.name = "Жаркое дело #3"
	self.Owner = ply:SteamID64()
	self.tasks = {
		[1] = {text = 'Изучить новый рецепт от кузнеца в инвентаре', current = 0, need = 1, taskname = "userecipe", itemid = "studentsword", iscompleted = false},
		[2] = {text = 'Сделать новое снаряжение по рецепту кузнеца в верстаке и отдать кузнецу', current = 0, need = 1, taskname = "deliveryitem", itemid = "student_sword", iscompleted = false},
		[3] = {text = 'Поговорить с кузнецом', current = 0, need = 1, taskname = "talktonpc", itemid = "endquest", iscompleted = false},
	}
end

return quest
