npc_spawns = {}

npc_spawns[1] = {
    {pos = Vector("-6585.437012 8388.705078 47.969193"), npc = "drg_roach_geim_hilichurl", lvl = {1, 5}, respawn = 300},
    {pos = Vector("-7208.857422 8642.235352 7.606960"), npc = "drg_roach_geim_hilichurl", lvl = {1, 5}, respawn = 300},
    {pos = Vector("-7085.394043 9006.040039 -10.812805"), npc = "drg_roach_geim_hilichurl", lvl = {1, 5}, respawn = 300},
    {pos = Vector("-6813.417480 9270.939453 -76.895920"), npc = "drg_roach_geim_hilichurl", lvl = {1, 5}, respawn = 300},
}

npc_spawns[2] = {
    {pos = Vector("61.204475 15081.351562 -135.177597"), npc = "drg_roach_geim_hilichurl", lvl = {5, 15}, respawn = 300},
    {pos = Vector("285.703400 15648.918945 -122.967239"), npc = "drg_roach_geim_hilichurl", lvl = {5, 15}, respawn = 300},
    {pos = Vector("461.046173 15243.865234 -116.583664"), npc = "drg_roach_geim_hilichurl", lvl = {5, 15}, respawn = 300},
    {pos = Vector("762.403687 14965.211914 -112.356277"), npc = "drg_roach_geim_hilichurl", lvl = {5, 15}, respawn = 300},
}

npc_spawns[3] = {
    {pos = Vector("-6021.839844 10032.721680 1941.104248"), npc = "drg_roach_geim_eremite1", lvl = {5, 10}, respawn = 300},
    {pos = Vector("-5718.853516 10037.624023 1941.104370"), npc = "drg_roach_geim_eremite1", lvl = {5, 10}, respawn = 300},
}

npc_spawns[4] = {
    {pos = Vector("5038.869629 13857.684570 5.364868"), npc = "drg_roach_geim_th2", lvl = {5, 10}, respawn = 300},
    {pos = Vector("4995.104004 14070.511719 0.361320"), npc = "drg_roach_geim_th1", lvl = {5, 10}, respawn = 300},
	{pos = Vector("4823.648926 14012.911133 9.089245"), npc = "drg_roach_geim_th3", lvl = {5, 10}, respawn = 300},
}
spawnedNPCTable = spawnedNPCTable or {}

local spawnNPC = function(k, i, s, v)
    local npc = ents.Create(v.npc)
    if !IsValid(npc) then return  end
    npc:SetPos(v.pos)
    npc:Spawn()
    local lvl = math.random(v.lvl[1], v.lvl[2])
    npc.SpawnPosition = v.pos
    npc.NextCheck = 0
    applyLevel(npc, lvl)

    -- returnin to spawn
    local old_CustomThink = npc.CustomThink
    function npc:CustomThink()
        if CurTime() < self.NextCheck then return end
        self.NextCheck = CurTime() + 1 -- Проверяем каждую секунду

        local dist = self:GetPos():Distance(self.SpawnPosition)
        if dist > 500 then
            self:MoveTowards(self.SpawnPosition)
        end
    end

    return npc
end

for k, i in pairs(npc_spawns) do
    for s, v in pairs(i) do
        if IsValid(spawnedNPCTable[k..s]) then continue  end
        local npc = spawnNPC(k, i, s, v)
        spawnedNPCTable[k..s] = npc
        timer.Create("npcSpawn"..k..s, v.respawn, 0, function()
            if IsValid(spawnedNPCTable[k..s]) then return end
            local npc = spawnNPC(k, i, s, v)
            spawnedNPCTable[k..s] = npc
        end)
    end
end
