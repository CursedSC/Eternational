/*hook.Add("OnNPCKilled", "QuestsOnNPCKilled", function(npc, attacker, inflictor)
    if not attacker:IsPlayer() then return end
    local haveKillMobs, listQuests1 = attacker:QuestsHave("killmobs")
	local haveKillVillains, listQuests2 = attacker:QuestsHave("defendnpc")
    if !haveKillMobs and !haveKillVillains and !haveGetItem then return end

    if haveKillMobs then
		for k, v in pairs(listQuests1) do
	        v:OnProgress(attacker, npc)
	    end
	end

	if haveKillVillains then
		for k, v in pairs(listQuests2) do
	        v:OnProgress(attacker, npc)
	    end
	end
end)

hook.Add("PlayerSpawn", "PlayerSetDailyQuests", function( ply )
	loadQuests(ply)
	ply.Quests["CanPick"] = ply.Quests["CanPick"] or {}
	ply.Quests["Current"] = ply.Quests["Current"] or {}
	ply.Quests["Completed"] = ply.Quests["Completed"] or {}
	for i = 1, 3 do
		local tbl1 = table.Random(questsList)
		while not tbl1.canpicked do
			tbl1 = table.Random(questsList)
		end
		local tbl = table.Copy(tbl1)
		tbl:GetBaseValue(ply)
		tbl.QuestDesc = tbl:GetDesc(tbl)
		tbl.QuestName = tbl:GetName()
		tbl = questData(tbl)
		table.insert(ply.Quests["CanPick"], tbl)
	end
	savedataquests(ply)
end)

hook.Add("Think", "PlayerCheckPositionsOnQuest",function ()
	for k, v in pairs(player.GetAll()) do
		local havequest, listquests = v:QuestsHave("points")
		if havequest then
			for i, p in pairs(v.Quests) do
				if p.points then
					for a, b in pairs(p.points) do
						if table.HasValue(ents.FindInSphere(b, 200), v) then
							p:OnProgress(v, a)
						end
					end
				end
			end
		else
			continue
		end
	end
end)

function addQuestToPlayer(player, questid, data)
    player:AddQuest(questid, data)
end

function refresh_clientquests(ply)
	local tbltosend = {}
	for k, v in pairs(ply.Quests) do
		if k != "CanPick" then
			for a, b in pairs(v) do
				tbltosend[#tbltosend + 1] = questData(b)
				tbltosend[#tbltosend].iscompleted = k == "Completed" and true or false
			end
		end
	end
	netstream.Start(ply, "questsystem/returnfromserver", tbltosend)
end

netstream.Hook("questboard_pickdaily", function(ply, data)
	print("Picking daily quest")
	addQuestToPlayer(ply, data.id, data)
	refresh_clientquests(ply)
end)

netstream.Hook("questsystem/getquestsfromserver", function(ply)
	refresh_clientquests(ply)
end)

netstream.Hook("dialoguesystem/setquest", function(ply, iscompletequest, quest, tble)
	if iscompletequest then
	    for k, v in pairs(ply.Quests["Current"]) do
	       if v.id == quest then
			   v:OnProgress(ply, tble)
		   end
	    end
	else
		local tbl = table.Copy(questsList[quest])
		tbl:GetBaseValue(ply)
		tbl.QuestDesc = tbl:GetDesc(tbl)
		tbl.QuestName = tbl:GetName()
		addQuestToPlayer(ply, quest, tbl)
	end
end)

file.CreateDir("fantasy/quests")
function savedataquests(ply)
	if not ply.Quests then return end

	local data = util.TableToJSON(ply.Quests, true)
    file.Write("fantasy/quests/" .. ply:SteamID64() .. ".txt", data)
	refresh_clientquests(ply)
end

function loadQuests(ply)
	if file.Exists("fantasy/quests/" .. ply:SteamID64() .. ".txt", "DATA") then
		local data = file.Read("fantasy/quests/" .. ply:SteamID64() .. ".txt", "DATA")
		ply.Quests = util.JSONToTable(data)
	else
		ply.Quests = {
			["Current"] = {},
			["CanPick"] = {},
			["Completed"] = {},
		}
	end
	refresh_clientquests(ply)
end


concommand.Add("rerollQuests", function(ply)
	if not ply:IsSuperAdmin() then return end
	ply.Quests["CanPick"] = {}
	for i = 1, 3 do
		local tbl1 = table.Random(questsList)
		local tbl = table.Copy(tbl1)
		tbl:GetBaseValue(ply)
		tbl.QuestDesc = tbl:GetDesc(tbl)
		tbl = questData(tbl)
		table.insert(ply.Quests["CanPick"], tbl)
	end
	PrintTable(ply.Quests["CanPick"])
	savedataquests(ply)
end)*/
