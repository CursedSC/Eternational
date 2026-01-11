local quest = table.Copy(basequest)
local points = {
	["Лесорубка"] = Vector(-511.320374, 8015.899414, 63.783623),
	["ОзероУЛесорубки"] = Vector(-2431.175537, 9670.359375, -272.915649),
	["НачалоВодопада"] = Vector(836.439941, 4704.873047, 100.535767),
	["МостУВходаВГород"] = Vector(0.858198, 1152.250244, 3.031235),
	["ВходВПещеру"] = Vector(-6566.923340, 9091.713867, -89.858681),
	["Кладбище"] = Vector(-2062.300781, -2437.694092, -0.005096),
	["МостУЛесорубки"] = Vector(-1654.620972, 6282.590820, 40.606873),
	["МостУКаньона"] = Vector(-9677.259766, 2089.349609, -83.389091),
	["Развилка"] = Vector(-5316.220215, 7784.237793, -227.438629),
	["Развилка2"] = Vector(-6720.674316, 2956.964355, -153.924545),
}
quest.title = "Разведка"
quest.type = "Side"
quest.secondtype = "checkpoints"
quest.name = ""
quest.codename = "checkpoints"
quest.tasks = {}
quest.Owner = "SteamID64"
quest.points = {}

quest.difficulty = 1
quest.description = "Местные власти обеспокоены – в окрестностях стали замечать подозрительную активность. То ли бандиты, то ли твари из глухих лесов, а может, и вовсе что-то похуже. Твоя задача проста: проверить указанные точки на карте, осмотреться и доложить, всё ли в порядке. Никаких лишних рисков, никакой геройской ерунды – просто разведка и доклад. Но если вдруг что-то пойдёт не так… лучше быть готовым."
quest.location = "Окрестности Баскервиля"
quest.navigate = false
quest.removeafterleave = false

function quest:SetBaseValues(ply)
	local randompoints = {}
	local needpoints = math.random(3, 7)
	while table.Count(randompoints) != needpoints do
		local randvalue = table.Random(points)
		local randkey = table.KeyFromValue(points, randvalue)

		if not table.HasValue(randompoints, randvalue) then
			randompoints[randkey] = randvalue
		end
	end

	self.name = "Проверить заданые координаты"
	self.tasks = {
		[1] = {text = 'Проверить точки', current = 0, need = needpoints, taskname = "checkpoints", iscompleted = false},
		[2] = {text = 'Доложить о состоянии точек Скупщику', current = 0, need = 1, taskname = "talktonpc", iscompleted = false},
	}
	self.rewards = {[1] = {dataid = "money", amount = 10 * needpoints}}
	self.Owner = ply:SteamID64()
	self.points = randompoints
end

return quest
