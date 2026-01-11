local QUESTS = {}
local villainpos = {
	[1] = Vector(-818.118835, 573.782654, -12287.968750),
	[2] = Vector(702.737427, -708.223816, -12287.968750),
	[3] = Vector(686.544006, 670.515625, -12287.968750),
	[4] = Vector(-35.703747, -19.430010, -12287.968750),
	[5] = Vector(383.199829, -12.883080, -12287.968750),
	[6] = Vector(383.199829, -12.883080, -12287.968750),
	[7] = Vector(383.199829, -12.883080, -12287.968750), -- натсроить позишн
}
local villagespos = {
	[1] = Vector(-818.118835, 573.782654, -12287.968750),
	[2] = Vector(702.737427, -708.223816, -12287.968750),
	[3] = Vector(686.544006, 670.515625, -12287.968750), -- настроить позишн
}
QUESTS.QuestName = "Защитник"
QUESTS.main = true
QUESTS.navigate = false
QUESTS.description = 'Группа бандитов поймала жеских челов. Спаси их'
QUESTS.Complete = 0
QUESTS.Amount = 0
QUESTS.mobClass = "drg_roach_geim_eremite_gloves"
QUESTS.difficulty = 3

function QUESTS:OnProgress( ply, mob )
	local isent = isentity(mob)
	print('test')
	if isent then
		print('test1')
	    if mob:GetClass() == self.mobClass then
			print('test2')
	        self.Amount = math.Clamp(self.Amount + 1, 0, self.Complete)
			self.tasks[1].amount = tostring(self.Amount)
	    end
	else
		self.tasks[2].amount = tostring(math.Clamp(tonumber(self.tasks[2].amount) + 1, 0, 3))
		ents.GetByIndex(mob):Remove()
	end

	if self.Amount >= self.Complete and tonumber(self.tasks[2].amount) >= tonumber(self.tasks[2].need) then
		ply:CompleteQuest( self )
	end

	refresh_clientquests(ply)
end

function QUESTS:GetDesc(data)
	return "Высвободить заложников"
end

function QUESTS:GetName()
	return "Защитник"
end

function QUESTS:GetID()
    return "defendnpc"
end

function QUESTS:GetBaseValue(ply)
    local rand = math.random(3, 7)
	self.Complete = rand
	self.questname = "Защитник"
	self.location = "(IN DEV)"
	self.tasks = {[1] = {name = "Отбить жителей у бандитов", amount = "0", need = rand}, [2] = {name = "Поговорить и помочь жителям", amount = "0", need = 3}}
end

function QUESTS:OnAccepted(ply, data)
	print("Start OnAccepted")
	--[[
	print(self.Complete)
    for i = 1, self.Complete do
		local ent = ents.Create(self.mobClass)
		ent:SetPos( villainpos[i] )
		ent:Spawn()
	end
	print("End for i = 1, self.Complete")
	for i = 1, #villagespos do
		local ent = ents.Create("npc_quest")
		ent.Model = "models/cloudteam/fantasy/custom/people_male.mdl"
		ent.Dialogue = "Защита"
		ent.WaitPly = ply:SteamID()
		ent.Table = ent:EntIndex()
		ent.Sequence = "c_crouchwalkidle_spade"
		ent.NameNPC = "Напуганный житель"
		ent:SetPos( villagespos[i] )
		ent:Spawn()
	end
	print("End for i = 1, #villagespos do")]]
end

return QUESTS
