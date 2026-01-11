include("sv_loader.lua")
questsystem = {}
file.CreateDir("fantasy/quests")
local questpick = {
	[1] = {questname = "hunt", variations = {1, 2}},
	[2] = {questname = "getitem", variations = {4, 5}},
	[3] = {questname = "checkpoints"},
}

function questsystem.loadData(ply)
	if file.Exists("fantasy/quests/" .. ply:SteamID64() .. ".txt", "DATA") then
		local data = file.Read("fantasy/quests/" .. ply:SteamID64() .. ".txt", "DATA")
		ply.Quests = util.JSONToTable(data)

		for keyquesttype, questtype in pairs(ply.Quests) do
			for _, quest in pairs(questtype) do
				for key, questlist in pairs(questslist) do
					if key == quest.codename then
						for namefunc, func in pairs(questlist) do
							if keyquesttype == "Pick" then
								if isfunction(func) and namefunc == "SetBaseValues" then
									local variation = quest.variation or nil
									quest[namefunc] = func
									quest:SetBaseValues(ply, variation)
								end
							end
							if isfunction(func) and namefunc == "OnAccepted" then
								quest[namefunc] = func
								quest:OnAccepted(quest.argstable)
							end
							if isfunction(func) and namefunc != "SetBaseValues" then
								quest[namefunc] = func
							end
						end
					end
				end
			end
		end
	else
		questsystem.resetData(ply)
	end

	questsystem.saveData(ply)
end

local function updatedataquest_forclient(data)
	local datatoreturn = table.Copy(data)
	for k, v in pairs(datatoreturn) do
		for a, b in pairs(v) do
			for c, d in pairs(b) do
				if isfunction(d) then
					b[c] = nil
				end
			end
		end
	end

	return datatoreturn
end

function questsystem.saveData(ply, navigatetype, navigatekey)
	local data = util.TableToJSON(ply.Quests)
	navigatetype = navigatetype or nil
	navigatekey = navigatekey or nil
	file.Write("fantasy/quests/" .. ply:SteamID64() .. ".txt", data)

	netstream.Start(ply, "quests/clientdataupdate", updatedataquest_forclient(ply.Quests), navigatetype, navigatekey)
end

function questsystem.resetData(ply)
	ply.Quests = {
		["Main"] = {},
		["Side"] = {},
		["Pick"] = {},
		["Complete"] = {},
	}

	questsystem.saveData(ply)
	questsystem.setDailyQuests(ply)
end

function questsystem.addQuest(ply, questdata, variation, typeset)
	if not ply.Quests then questsystem.resetData(ply) end
	local data = table.Copy(questdata)
	if variation then data:SetBaseValues(ply, variation) else data:SetBaseValues(ply) end
	data.SetBaseValues = nil
	table.insert(typeset and ply.Quests[typeset] or ply.Quests[data.type], data)

	if typeset != "Pick" then
		for _, typequest in pairs(ply.Quests) do
			for _, quests in pairs(typequest) do
				quests.navigate = false
			end
		end
		data.navigate = typeset == "Pick" and false or true
	end

	questsystem.saveData(ply, data.type, table.KeyFromValue(typeset and ply.Quests[typeset] or ply.Quests[data.type], data))
end

function questsystem.hasQuestType(ply, questtype)
	if not ply.Quests then questsystem.resetData(ply) return false end

	for _, quest in pairs(ply.Quests["Main"]) do
		if quest.secondtype == questtype then
			return true
		else
			continue
		end
	end

	for _, quest in pairs(ply.Quests["Side"]) do
		if quest.secondtype == questtype then
			return true
		else
			continue
		end
	end

	return false
end

function questsystem.hasQuestTitle(ply, questtitle)
	if not ply.Quests then questsystem.resetData(ply) return false end

	for _, quest in pairs(ply.Quests["Main"]) do
		if quest.title == questtitle then
			return true
		else
			continue
		end
	end

	for _, quest in pairs(ply.Quests["Side"]) do
		if quest.title == questtitle then
			return true
		else
			continue
		end
	end

	return false
end

function questsystem.getQuestsType(ply, questtype)
	if not ply.Quests then questsystem.resetData(ply) return false end
	local result = {}

	for _, quest in pairs(ply.Quests["Main"]) do
		if quest.secondtype == questtype then
			result[#result + 1] = quest
		else
			continue
		end
	end

	for _, quest in pairs(ply.Quests["Side"]) do
		if quest.secondtype == questtype then
			result[#result + 1] = quest
		else
			continue
		end
	end

	return result
end

function questsystem.getQuestsTitle(ply, questtitle)
	if not ply.Quests then questsystem.resetData(ply) return false end
	local result = {}

	for _, quest in pairs(ply.Quests["Main"]) do
		if quest.title == questtitle then
			result[#result + 1] = quest
		else
			continue
		end
	end

	for _, quest in pairs(ply.Quests["Side"]) do
		if quest.title == questtitle then
			result[#result + 1] = quest
		else
			continue
		end
	end

	return result
end

function questsystem.removeQuest(ply, questdata)
	if not ply.Quests then questsystem.resetData(ply) return end

	for k, v in pairs(ply.Quests[questdata.type]) do
		if v == questdata then
			ply.Quests[questdata.type][k] = nil
		end
	end

	questsystem.saveData(ply)
end

function questsystem.completeQuest(ply, questdata)
	if not ply.Quests then questsystem.resetData(ply) return end

	ply.Quests["Complete"][#ply.Quests["Complete"] + 1] = questdata.type != "Side" and table.Copy(questdata) or nil
	questsystem.removeQuest(ply, questdata)

	questsystem.saveData(ply)
end

function questsystem.refreshDailyQuests()
	for k, v in pairs(file.Find("fantasy/quests/*", "DATA")) do
		local data = util.JSONToTable(file.Read("fantasy/quests/"..v, "DATA")) or {["Main"] = {}, ["Side"] = {}, ["Pick"] = {}, ["Complete"] = {},}

		for k, v in pairs(data["Side"]) do
			if v.isdaily then
				data["Side"][k] = nil
			end
		end

		for i = 1, 9 do
			local rand = math.random(1, #questpick)
			local variation = questpick[rand].variations and questpick[rand].variations[math.random(1, #questpick[rand].variations)] or nil
			local dataquest = table.Copy(questslist[questpick[rand].questname])

			dataquest.variation = variation
			dataquest.isdaily = true
			data["Pick"][i] = dataquest
		end

		file.Write("fantasy/quests/"..v, util.TableToJSON(data))
	end

	for k, v in pairs(player.GetAll()) do
		questsystem.loadData(v)
	end
end

function questsystem.setDailyQuests(ply)
	local data = util.JSONToTable(file.Read("fantasy/quests/"..ply:SteamID64()..".txt", "DATA")) or {["Main"] = {}, ["Side"] = {}, ["Pick"] = {}, ["Complete"] = {},}

	for k, v in pairs(data["Side"]) do
		if v.isdaily then
			data["Side"][k] = nil
		end
	end

	for i = 1, 9 do
		local rand = math.random(1, #questpick)
		local variation = questpick[rand].variations and questpick[rand].variations[math.random(1, #questpick[rand].variations)] or nil
		local dataquest = table.Copy(questslist[questpick[rand].questname])

		dataquest.variation = variation
		dataquest.isdaily = true
		data["Pick"][i] = dataquest
	end

	file.Write("fantasy/quests/"..ply:SteamID64()..".txt", util.TableToJSON(data))
	questsystem.loadData(ply)
end

hook.Add("PlayerSpawn", "LoadQuestData", function (ply)
	questsystem.loadData(ply)
end)

hook.Add("OnNPCKilled", "QuestProgress_killtype", function (npc, attacker, inflictor)
	if IsValid(attacker) and attacker:IsPlayer() then
		local quests = questsystem.getQuestsType(attacker, "killnpc")
		if quests then
			for _, quest in pairs(quests) do
				if istable(quest.tasks[1].itemid) then
					quest.tasks[1].current = math.Clamp(quest.tasks[1].current + 1, quest.tasks[1].current, quest.tasks[1].need)
					if quest.tasks[1].current == quest.tasks[1].need then
						quest:OnComplete()
					end
					questsystem.saveData(attacker)
				else
					quest:OnProgress("kill", npc:GetClass(), 1, true, nil)
				end
			end
		end
	end
end)

hook.Add("InventoryChangeItem", "QuestProgress_itemgettype", function (owner, itemid, quantity)
	if IsValid(owner) then
		local quests = questsystem.getQuestsType(owner, "getitem")
		local bool, amount = owner.inventory:hasItems(itemid, 0)
		if quests then
			for _, quest in pairs(quests) do
				quest:OnProgress("getitem", itemid, quantity, true, nil)
			end
		end
	end
end)

hook.Add("Think", "QuestProgress_checkpointstype",function ()
	for k, v in pairs(player.GetAll()) do
		for _, quest in pairs(v.Quests["Main"]) do
			if quest.points then
				for key, point in pairs(quest.points) do
					if table.HasValue(ents.FindInSphere(point, 200), v) then
						quest.points[key] = nil
						quest:OnProgress("checkpoints", nil, 1, true, nil)
					end
				end
			end
		end
		for _, quest in pairs(v.Quests["Side"]) do
			if quest.points then
				for key, point in pairs(quest.points) do
					if table.HasValue(ents.FindInSphere(point, 200), v) then
						quest.points[key] = nil
						quest:OnProgress("checkpoints", nil, 1, true, nil)
					end
				end
			end
		end
	end
end)

netstream.Hook("dialoguesystem/setquest", function(ply, questid, variation)
	variation = variation or 0
	questsystem.addQuest(ply, questslist[questid], variation)
end)

netstream.Hook("questsystem/pickdaily", function(ply, questdata, questnum)
	for _, typequest in pairs(ply.Quests) do
		for _, quests in pairs(typequest) do
			quests.navigate = false
		end
	end
	questdata.navigate = true

	ply.Quests["Pick"][questnum] = nil
	ply.Quests["Side"][#ply.Quests["Side"] + 1] = questdata

	for _, questtype in pairs(ply.Quests) do
		for _, quest in pairs(questtype) do
			for key, questlist in pairs(questslist) do
				if key == questdata.codename then
					for namefunc, func in pairs(questlist) do
						if isfunction(func) and namefunc != "SetBaseValues" then
							quest[namefunc] = func
						end
					end
				end
			end
		end
	end

	questsystem.saveData(ply, "Side", table.KeyFromValue(ply.Quests["Side"], questdata))
end)

netstream.Hook("questsystem/setnavigate", function(ply, questtype, questnum)
	local queststonavigate = ply.Quests[questtype][questnum]

	for _, typequest in pairs(ply.Quests) do
		for _, quests in pairs(typequest) do
			if quests == queststonavigate then
				quests.navigate = not quests.navigate
			else
				quests.navigate = false
			end
		end
	end

	questsystem.saveData(ply)
end)

netstream.Hook("dialoguesystem/progressquest", function(ply, questtype, questnum, taskid, itemid, removeitem)
	if IsValid(ply) then
		local questtoprogress = ply.Quests[questtype][questnum]
		local needforprogress = 0
		local bool, amount = ply.inventory:hasItems(itemid, 0)
		if questtoprogress then
			for k, v in pairs(questtoprogress.tasks) do
				if taskid == "talktonpc" then
					if v.taskname == taskid then
						questtoprogress:OnProgress(taskid, itemid, 1, true, removeitem)
						break
					end
				else
					if v.taskname == taskid and v.itemid == itemid then
						needforprogress = v.need - v.current
					end
				end
			end

			if itemid == nil and taskid != "talktonpc" then
				for k, v in pairs(questtoprogress.tasks) do
					if v.taskname == taskid then
						bool, amount = ply.inventory:hasItems(v.itemid, 0)
						needforprogress = v.need - v.current

						questtoprogress:OnProgress(taskid, v.itemid, math.Clamp(amount, 0, needforprogress), true, removeitem)
						ply.inventory:removeItemsBySource(v.itemid, math.Clamp(amount, 0, needforprogress))
					end
				end
			elseif taskid != "talktonpc" then
				questtoprogress:OnProgress(taskid, itemid, math.Clamp(amount, 0, needforprogress), true, removeitem)
				ply.inventory:removeItemsBySource(itemid, math.Clamp(amount, 0, needforprogress))
			end
		end
	end
end)
