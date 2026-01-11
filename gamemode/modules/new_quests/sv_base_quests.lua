basequest = {}
basequest.title = "" -- Вырисовка основы квеста - например "Добыча предмета"
basequest.type = "" -- Тип квеста (Main, Side, Complete, Pick)
basequest.secondtype = "" -- Второй тип для поиска функцией(questsystem.hasQuestType or questsystem.getQuestsType)
basequest.name = "" -- Вырисовка имени квеста - например "Помощь скупщику"
basequest.codename = "" -- Название квеста для использования в коде
basequest.tasks = {} -- Задания квеста, выставляющиеся в quest:SetBaseValues
basequest.Owner = "" -- Владелец квеста(SteamID64)
basequest.rewards = {} -- Награды квеста({[номернаграды] = {dataid = "типнаграды", amount = количество, itemid = "айдипредмета"}})
-- Существующие дата айди для наград: item(предмет); specialization(специализация); остальная dataid будет вставляться в SetCharacterData(например money)
basequest.entities = {} -- Энтити, использующиеся в квесте. Для удаления после выполнения квеста

basequest.difficulty = 1 -- Сложность квеста для отрисовки(от 1 до 3)
basequest.description = "" -- Описание квеста для отрисовки
basequest.location = "" -- Локация квеста для отрисовки
basequest.navigate = false -- Базовая настройка отслеживания, не изменять
basequest.removeafterleave = false -- Удалить ли квест при выходе с сервера

-- OnProgress(taskname - название задания в quest.tasks; id - проверка таска; amount - количество прогресса; isadd - добавить или выставить прогресс; removeitem - айди предмета для удаления;)
function basequest:OnProgress(taskname, id, amount, isadd, removeitem)
	local tasknum = false
	amount = amount or 1
	for k, v in pairs(self.tasks) do
		if v.taskname == taskname and v.itemid == id then
			tasknum = k
			break
		end
 	end
	if not tasknum then return end

	self.tasks[tasknum].current = math.Clamp(isadd and self.tasks[tasknum].current + amount or amount, self.tasks[tasknum].current, self.tasks[tasknum].need)
	self.tasks[tasknum].iscompleted = self.tasks[tasknum].current == self.tasks[tasknum].need

	local completed = 0
	for k, v in pairs(self.tasks) do
		if v.iscompleted then completed = completed + 1 end
	end

	if completed == table.Count(self.tasks) then
		self:OnComplete()
	end

	if removeitem then
		local ply = player.GetBySteamID64(self.Owner)
		ply.inventory:removeItemsBySource(removeitem)
	end

	questsystem.saveData(player.GetBySteamID64(self.Owner))
end

function basequest:OnComplete()
	local ply = player.GetBySteamID64(self.Owner)
	if self.rewards then
		for k, v in pairs(self.rewards) do
			if v.dataid == "item" then
				local itemtoadd = Item:new(v.itemid)
				ply.inventory:addItem(itemtoadd, v.amount)
			elseif v.dataid == "specialization" then
				local jobs = table.Copy(ply:GetCharacterData("jobs", {}))
				jobs[v.specialization] = true

				ply:SetCharacterData("jobs", jobs)
			else
				ply:SetCharacterData(v.dataid, ply:GetCharacterData(v.dataid) + v.amount)
			end
		end
	end

	if self.entities then
		for k, v in pairs(self.entities) do
			if IsValid(v) and IsEntity(v) then
				if v.WaitPly then
					table.RemoveByValue(v.WaitPly, player.GetBySteamID64(self.Owner):SteamID())
					if table.IsEmpty(v.WaitPly) then
						v:Remove()
					end
				else
					v:Remove()
				end
			end
		end
	end

	self.navigate = false
	questsystem.completeQuest(ply, self)
	if self.nextquest then questsystem.addQuest(ply, questslist[self.nextquest], self.variation and self.variation or nil) end
end

return basequest
