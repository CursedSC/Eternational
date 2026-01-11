local quest = table.Copy(basequest)
local variations = {
	[1] = {
		name = "Помощь лесорубу",
		text = "Местный лесоруб просит вас помочь ему в сборе древесины. Он говорит, что в лесу много деревьев, которые нужно срубить, и он не справляется один.",
		item = {[1] = "wood"},
		location = "Поляна возле лесорубки",
		need = {
			min = 5,
			max = 10
		},
		questtype = "Side",
		rewards = {[1] = {dataid = "money", amount = 100}},
	},
	[2] = {
		name = "Жаркое дело #1",
		text = "Вы попросили помощи с обучением у городского кузнеца. Он не против, но тебе нужно помочь ему с добычей ресурсов.",
		item = {[1] = "coal", [2] = "iron_ore"},
		location = "Шахты",
		need = {
			min = 5,
			max = 10
		},
		questtype = "Main",
		nextquest = "specialization_blacksmith_secondstage",
		rewards = {[1] = {dataid = "item", amount = 1, itemid = "blacksmith_note"}}
	},
	[3] = {
		name = "Тайны Зельевара #1",
		text = "Вы попросили помощи с обучением у местного алхимика. Он не против, но тебе нужно помочь ему с добычей ресурсов.",
		item = {[1] = "sarphan", [2] = "jeltic"},
		location = "Поляны возле лесорубки",
		need = {
			min = 5,
			max = 10
		},
		questtype = "Main",
		nextquest = "specialization_alchemist_secondstage",
		rewards = {[1] = {dataid = "item", amount = 1, itemid = "alchemist_note"}}
	},
	[4] = {
		name = "Добыть и передать скупщику",
		text = "Дневной квест - помоги скупщику собрать ресурсы и отнеси ему.",
		item = {[1] = "wood", [2] = "jeltic"},
		location = "Поляна возле лесорубки",
		need = {
			min = 10,
			max = 20
		},
		questtype = "Side",
		rewards = {[1] = {dataid = "money", amount = 100}},
	},
	[5] = {
		name = "Добыть и передать скупщику",
		text = "Дневной квест - помоги скупщику собрать ресурсы и отнеси ему.",
		item = {[1] = "coal", [2] = "iron_ore"},
		location = "Шахты",
		need = {
			min = 5,
			max = 8
		},
		questtype = "Side",
		rewards = {[1] = {dataid = "money", amount = 100}},
	},
}
quest.title = "Добыча предмета"
quest.type = "Side"
quest.secondtype = "getitem"
quest.name = ""
quest.codename = "getitem"
quest.tasks = {}
quest.Owner = "SteamID64"

quest.difficulty = 2
quest.description = "IN DEV"
quest.location = "IN DEV"
quest.navigate = false
quest.removeafterleave = false

function quest:SetBaseValues(ply, variation)
	local randomvariation = variation and variations[variation] or table.Random(variations)
	self.type = randomvariation.questtype
	self.name = randomvariation.name
	self.description = randomvariation.text
	self.location = randomvariation.location
	self.variation = randomvariation.variationnextquest or nil
	self.rewards = randomvariation.rewards or nil
	self.nextquest = randomvariation.nextquest or nil

	for k, v in pairs(randomvariation.item) do
		local bool, amount = player.GetBySteamID64(ply:SteamID64()).inventory:hasItems(v, 0)
		local needtoget = math.random(randomvariation.need.min, randomvariation.need.max)
		self.tasks[#self.tasks + 1] = {text = 'Добыть ' .. itemList[v].Name, current = math.Clamp(amount, 0, needtoget), need = needtoget, itemid = v, taskname = "getitem", iscompleted = false}
		self.tasks[#self.tasks + 1] = {text = 'Отдать ' .. itemList[v].Name, current = 0, need = needtoget, itemid = v, taskname = "deliveryitem", iscompleted = false}
	end
	if variation == 2 then
		self.tasks[#self.tasks + 1] = {text = 'Поговорить с кузнецом о дальнейшем обучении', current = 0, need = 1, taskname = "talktonpc", itemid = "nextquest", iscompleted = false}
	end
	if variation == 3 then
		self.tasks[#self.tasks + 1] = {text = 'Поговорить с алхимиком о дальнейшем обучении', current = 0, need = 1, taskname = "talktonpc", itemid = "nextquest", iscompleted = false}
	end
	self.Owner = ply:SteamID64()
end

return quest
