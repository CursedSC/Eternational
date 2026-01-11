local quest = table.Copy(basequest)
local variations = {
	[1] = {class = "drg_roach_geim_hilichurl", mob = "Аборигенов", moneyformob = 20, min = 10, max = 15},
	[2] = {class = {"drg_roach_geim_th1", "drg_roach_geim_th2", "drg_roach_geim_th3"}, mob = "Разбойников", moneyformob = 50, min = 3, max = 6},
}
quest.title = "Охота"
quest.type = "Side"
quest.secondtype = "killnpc"
quest.name = ""
quest.codename = "hunt"
quest.tasks = {}
quest.Owner = "SteamID64"

quest.difficulty = 3
quest.description = "В окрестностях расплодились опасные твари – нападают на путников и пугают местных. Власти платят за их устранение. Никаких сложностей – просто работа для крепких рук и острого меча. После завершения работы - доложить скупщику."
quest.location = "Окрестности Баскервиля"
quest.navigate = false
quest.removeafterleave = false

function quest:SetBaseValues(ply, variation)
	local randtable = variation and variations[variation] or table.Random(variations)
	local randommobvalue = randtable.mob
	local randommobkey = randtable.class

	self.name = "Охота на " .. randommobvalue
	self.tasks = {
		[1] = {text = 'Убить ' .. randommobvalue, current = 0, need = math.random(randtable.min, randtable.max), itemid = randommobkey, taskname = "kill", iscompleted = false},
		[2] = {text = 'Доложить скупщику', current = 0, need = 1, taskname = "talktonpc", iscompleted = false},
	}
	self.rewards = {[1] = {dataid = "money", amount = randtable.moneyformob * self.tasks[1].need}}
	self.Owner = ply:SteamID64()
end

return quest
