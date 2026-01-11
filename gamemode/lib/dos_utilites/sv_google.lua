local api_key = "AIzaSyBsZ1_9A0U-zU7B-P2swBRm9Lfqk6wQJB0"
if 1 then return end

ENEMY_GOOGLE = {}

local function parseEnemy(npc, info)
	if not ENEMY_GOOGLE[npc] then ENEMY_GOOGLE[npc] = {} end

	ENEMY_GOOGLE[npc][tonumber(info[3])] = {
		name = info[1],
		health = tonumber(info[5]),
		damage = tonumber(info[6]),
		armor = tonumber(info[7]),
		xp = tonumber(info[8]),
	}
	--print("Зарегестрирован:", info[1], "уровень", info[3])
end

local function SpawnNPCAtPlayerPosition(ply, cmd, args)
	if not ply:IsSuperAdmin() then return end
    local pos = ply:GetPos()
    local ang = ply:EyeAngles()
    local npc = args[1]
    local lvl = tonumber(args[2])
    local info = ENEMY_GOOGLE[npc][lvl]
    local npc = ents.Create(npc)
    PrintTable(info)
    npc:SetPos(pos + Vector(0,0,10))
    npc.StartHealth = info.health
    npc.DamageFantasy = info.damage
    npc:Spawn()
    npc:SetNWInt("LVL", lvl)
    npc:SetNWInt("armor", info.armor)
    npc:SetNWInt("maxarmor", info.armor)
    npc:SetNWString("Name", info.name)
end
concommand.Add("spawn_npctest", SpawnNPCAtPlayerPosition)


hook.Add( "EntityTakeDamage", "fnt/npcs/dmg", function( target, dmginfo )
	local attacker = dmginfo:GetAttacker()
	local npc = attacker:GetClass()
	if not ENEMY_GOOGLE[npc] then return end 
	local lvl = attacker:GetNWInt("LVL")
	local npc_info = ENEMY_GOOGLE[npc][lvl]
	dmginfo:SetDamage(attacker.DamageFantasy)
end )


function ParseTableFor(npc, dip)
http.Fetch( "https://sheets.googleapis.com/v4/spreadsheets/1jiwfuxHhKc7eEVj4Kr1xkrLj6EWzrqfaxsM21LSuMUA/values/'Лист1'!"..dip.."?key=".. api_key,
	
	-- onSuccess function
	function( body, length, headers, code )
		local result = util.JSONToTable(body)
		local values = result.values 
		for k, i in pairs(values) do 
			if i[1] then parseEnemy(npc, i) end
		end
	end,

	-- onFailure function
	function( message )
		-- We failed. =(
		print( message )
	end,

	-- header example
	{ 
		["accept-encoding"] = "gzip, deflate",
		["accept-language"] = "fr" 
	}
)
end

ParseTableFor("npc_vj_dm_goblin", "A5:H104")
ParseTableFor("npc_vj_dm_ghoul", "I5:P104")
ParseTableFor("npc_vj_dm_paokai", "Q5:X104")
ParseTableFor("npc_vj_dm_villager_undead", "A106:H205")
ParseTableFor("npc_vj_dm_necroguard", "I106:P205")
ParseTableFor("npc_vj_dm_undead", "Q106:X205")
ParseTableFor("npc_vj_dm_necroguard_arrow", "I207:P306")
ParseTableFor("npc_vj_dm_deathknight", "Q207:X306")
ParseTableFor("npc_vj_dm_orc", "A308:H407")
ParseTableFor("npc_vj_dm_orc_arrow", "I308:P407")	
ParseTableFor("npc_vj_dm_orc_chief", "Q308:X407")	
ParseTableFor("npc_vj_dm_necromancer", "A409:H508")	



local spawntables = {
	-- Замок 
	{npc = "npc_vj_dm_necroguard", lvls = {min = 5, max = 10}, pos = Vector(-6912.619629, -13395.131836, -684.129944)},
	{npc = "npc_vj_dm_necroguard", lvls = {min = 5, max = 10}, pos = Vector(-6906.724609, -13665.174805, -685.600342)},
	{npc = "npc_vj_dm_necroguard", lvls = {min = 5, max = 10}, pos = Vector(-7635.017090, -13530.654297, -656.030212)},
	{npc = "npc_vj_dm_necroguard", lvls = {min = 5, max = 10}, pos = Vector(-7672.428223, -13620.416016, -656.857544)},
	{npc = "npc_vj_dm_necroguard", lvls = {min = 5, max = 10}, pos = Vector(-7611.350586, -13710.309570, -654.54412)},
	{npc = "npc_vj_dm_necroguard", lvls = {min = 5, max = 10}, pos = Vector(-7588.202148, -13828.867188, -644.510559)},
	{npc = "npc_vj_dm_necroguard", lvls = {min = 5, max = 10}, pos = Vector(-8115.853516, -13474.554688, -660.277405)},
	{npc = "npc_vj_dm_necroguard", lvls = {min = 5, max = 10}, pos = Vector(-8065.765625, -13663.943359, -667.097717)},
	{npc = "npc_vj_dm_necroguard", lvls = {min = 5, max = 10}, pos = Vector(-8055.724121, -13551.518555, -465.174164)},
	{npc = "npc_vj_dm_necroguard", lvls = {min = 5, max = 10}, pos = Vector(-7926.373047, -13464.908203, -465.174164)},
	{npc = "npc_vj_dm_necroguard", lvls = {min = 5, max = 10}, pos = Vector(-8423.711914, -13676.670898, -466.983643)},
	{npc = "npc_vj_dm_necroguard_arrow", lvls = {min = 5, max = 10}, pos = Vector(-7765.034668, -13683.871094, -281.82260)},

	{npc = "npc_vj_dm_necroguard", lvls = {min = 5, max = 10}, pos = Vector(-8099.393555, -13604.565430, -247.774429)},
	{npc = "npc_vj_dm_necroguard", lvls = {min = 5, max = 10}, pos = Vector(-7997.203125, -13578.181641, -256.318817)},

	{npc = "npc_vj_dm_necroguard_arrow", lvls = {min = 5, max = 10}, pos = Vector(-8684.778320, -13758.595703, -247.000626)},
	{npc = "npc_vj_dm_necroguard_arrow", lvls = {min = 5, max = 10}, pos = Vector(-8472.254883, -13773.000977, -261.230988)},
	{npc = "npc_vj_dm_necroguard_arrow", lvls = {min = 5, max = 10}, pos = Vector(-8351.519531, -13124.471680, -259.555847)},

	{npc = "npc_vj_dm_necroguard", lvls = {min = 5, max = 10}, pos = Vector(-8400.867188, -13047.460938, -386.377319)},

	{npc = "npc_vj_dm_necroguard_arrow", lvls = {min = 5, max = 10}, pos = Vector(-7457.586914, -12879.211914, -389.300201)},
	{npc = "npc_vj_dm_necroguard_arrow", lvls = {min = 5, max = 10}, pos = Vector(-7325.863281, -12931.938477, -396.822449)},
	{npc = "npc_vj_dm_necroguard_arrow", lvls = {min = 5, max = 10}, pos = Vector(-6648.768066, -12726.895508, -73.674011)},


	{npc = "npc_vj_dm_deathknight", lvls = {min = 20, max = 20}, pos = Vector(-7919.203125, -11412.777344, 4380), hp = 1, name = "Лорд Мондраг"},

	{npc = "npc_vj_dm_necroguard", lvls = {min = 15, max = 15}, pos = Vector(-8137.447266, -11382.210938, 4380)},
	{npc = "npc_vj_dm_necroguard", lvls = {min = 15, max = 15}, pos = Vector(-7816.966797, -11438.743164, 4380)},

}
t_spawntables = t_spawntables or {}


function CheckSpawnNPC()
	for k, i in pairs(spawntables) do 
		if t_spawntables[k] and IsValid(t_spawntables[k]) then continue end
		local lvl = math.random(i.lvls.min, i.lvls.max)
		local info = ENEMY_GOOGLE[i.npc][lvl]
	    local npc = ents.Create(i.npc)
	    npc:SetPos(i.pos + Vector(0,0,10))
	    npc.StartHealth = i.hp or info.health
	    npc.DamageFantasy = info.damage
	    npc:Spawn()
	    npc:SetNWInt("LVL", lvl)
	    npc:SetNWInt("armor", info.armor)
	    npc:SetNWInt("maxarmor", info.armor)
	    npc:SetNWString("Name", i.name or info.name)
	    t_spawntables[k] = npc
	end 
end

