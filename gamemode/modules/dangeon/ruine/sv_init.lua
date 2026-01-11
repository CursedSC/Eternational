RuinDungeon = RuinDungeon or {}

RuinDungeon.Config = { 
    Doors = { 
        Entrance = "*150",
        Inner = "*151",
        Boss = "*155" 
    },
    
    EntryZone = {
        Min = Vector("-10333.899414063", "-8508.2255859375", "-954.31567382813"),
        Max = Vector("-9232.2353515625", "-7286.712890625", "-282.54217529297")
    },
    
    NPCSpawns = {
        {pos = Vector("-10004.311523438", "-5833.6171875", "-765.07159423828"), npc = "drg_roach_geim_eremite1", lvl = {10, 15}, respawn = 600},
        {pos = Vector("-9392.1181640625", "-5516.9633789063", "-807.21826171875"), npc = "drg_roach_geim_eremite1", lvl = {10, 15}, respawn = 600},
        {pos = Vector("-9461.6533203125", "-4891.353515625", "-878.48278808594"), npc = "drg_roach_geim_eremite3", lvl = {10, 15}, respawn = 600},
        {pos = Vector("-10065.974609375", "-4684.2607421875", "-918.49682617188"), npc = "drg_roach_geim_eremite3", lvl = {10, 15}, respawn = 600},
        {pos = Vector("-9459.3017578125", "-4091.6948242188", "-996.82629394531"), npc = "drg_roach_geim_eremite1", lvl = {10, 15}, respawn = 600},
        {pos = Vector("-9789.123046875", "-6073.275390625", "-781.33697509766"), npc = "drg_roach_geim_eremite1", lvl = {10, 15}, respawn = 600},
    },
    
    EliteNPC = {
        class = "drg_roach_geim_eremite_katar",
        pos = Vector("-9766.51953125", "-6825.5903320313", "-603.96875"),
        drops = {
            {item = "temple_dangeon_ruin", chance = 30}
        }
    },
    
    SpawnPositions = {
        Entry = {
            Vector("-9778.642578", "-7344.787598", "-531.330444"),
            Vector("-9654.680664", "-7340.794922", "-531.330444"),
            Vector("-9903.300781", "-7348.801758", "-531.330444"),
            Vector("-9977.986328", "-7351.206055", "-531.330444"),
            Vector("-9581.318359", "-7355.200195", "-526.837769"),
        },
        Boss = {
            Vector("-6262.702148", "-12743.459961", "-441.369720"),
            Vector("-6263.623535", "-12864.703125", "-441.369720"),
            Vector("-6174.273926", "-12970.238281", "-439.873932"),
            Vector("-6017.103027", "-12698.085938", "-440.434052"),
            Vector("-6088.577148", "-13185.470703", "-448.167053"),
        }
    },
    
    GuardianNPCs = {
        {class = "drg_roach_geim_darkwraith_banner", pos = Vector("-9604.680664", "-7784.048828", "-533.654663")},
        {class = "drg_roach_geim_darkwraith_lance", pos = Vector("-9905.875000", "-7828.224609", "-533.843872")}
    },
    
    Boss = { 
        class = "drg_roach_geim_aherald2",
        pos = Vector("-5872.734375", "-12880.741211", "-449.116974")
    },
    
    StartWaitTime = 30
}

RuinDungeon.State = RuinDungeon.State or {
    IsActive = false,
    IsWaiting = false,
    Squad = nil,
    ActiveNPCs = {},
    GuardianNPCs = {},
    Boss = nil,
    EliteNPC = nil
}

function RuinDungeon:SpawnNPC(spawnData, index)
    if self.State.ActiveNPCs["npc"..index] and IsValid(self.State.ActiveNPCs["npc"..index]) then
        self.State.ActiveNPCs["npc"..index]:Remove()
    end
    if IsValid(self.State.EliteNPC) then 
        for i=2,3 do 
            ParticleEffect("gael_dirt_land", self.State.EliteNPC:GetAttachment(i).Pos, Angle(0,0,0), self.State.EliteNPC)
        end
        timer.Simple(0.1, function()
            self.State.EliteNPC:Remove()
        end)    
    end

    local npc = ents.Create(spawnData.npc)
    if !npc or !IsValid(npc) then return end
    
    npc:SetPos(spawnData.pos)
    npc:Spawn()
    
    local lvl = math.random(spawnData.lvl[1], spawnData.lvl[2])
    npc.SpawnPosition = spawnData.pos
    npc.NextCheck = 0
    applyLevel(npc, lvl) 
    npc.RuindDangeon = true
    npc.InReturn = false
    npc.CustomDrop = {
        {item = "fragmet_story", chance = 30}, 
    }   
 
    self.State.ActiveNPCs["npc"..index] = npc
    
    timer.Create("RuinDungeonRespawn"..index, spawnData.respawn, 0, function()
        if IsValid(self.State.ActiveNPCs["npc"..index]) then return end
        
        local newNpc = self:SpawnNPC(spawnData, index)
        self.State.ActiveNPCs["npc"..index] = newNpc
    end)
    
    return npc  
end

function RuinDungeon:SpawnEliteNPC()
    local elite = ents.Create(self.Config.EliteNPC.class)
    elite:SetPos(self.Config.EliteNPC.pos)
    elite:Spawn()
    elite.CustomDrop = self.Config.EliteNPC.drops
    
    for i=2,3 do 
        ParticleEffect("gael_dirt_land", elite:GetAttachment(i).Pos, Angle(0,0,0), elite)
    end
    
    self.State.EliteNPC = elite
    return elite
end

function RuinDungeon:Reset()
    self.State.IsActive = false
    self.State.IsWaiting = false
    
    if IsValid(self.State.Boss) then self.State.Boss:Remove() end
    
    for _, npc in pairs(self.State.GuardianNPCs) do
        if IsValid(npc) then npc:Remove() end
    end
    self.State.GuardianNPCs = {}
    
    if IsValid(self.State.Squad) then
        for _, ply in pairs(self.State.Squad:GetMembers()) do
            if IsValid(ply) then
                ply:SetNWBool("InDangeon", false)
            end
        end
    end
    
    for index, spawnData in pairs(self.Config.NPCSpawns) do
        if IsValid(self.State.ActiveNPCs["npc"..index]) then
            self.State.ActiveNPCs["npc"..index]:Remove()
        end
        
        local npc = self:SpawnNPC(spawnData, index)
        self.State.ActiveNPCs["npc"..index] = npc
    end
    
    print("Ruin dungeon has been reset")
end

function RuinDungeon:IsPlayerInZone(ply)
    if !IsValid(ply) or !ply:IsPlayer() or !ply:Alive() then return false end
    
    local pos = ply:GetPos()
    local min = self.Config.EntryZone.Min
    local max = self.Config.EntryZone.Max
    
    if pos.x >= min.x and pos.x <= max.x and
       pos.y >= min.y and pos.y <= max.y and
       pos.z >= min.z and pos.z <= max.z then
        return true
    end
    
    return false
end

function RuinDungeon:StartWaitingPeriod()
    self.State.IsWaiting = true
    
    timer.Create("RuinDungeonStartWait", self.Config.StartWaitTime, 1, function()
        self.State.IsWaiting = false
        self.State.IsActive = true
        
        if IsValid(self.State.Squad) then
            for _, ply in pairs(self.State.Squad:GetMembers()) do
                if IsValid(ply) then
                    ply:Freeze(false)
                    ply:SetNWBool("InDangeon", true)
                end
            end
        end
    end)
end

function RuinDungeon:SpawnBoss()
    local boss = ents.Create(self.Config.Boss.class)
    boss:SetPos(self.Config.Boss.pos)
    boss:Spawn()
    
    self.State.Boss = boss
    return boss
end

function RuinDungeon:SpawnGuardians()
    self.State.GuardianNPCs = {}
    
    for i, guardianData in ipairs(self.Config.GuardianNPCs) do
        local guardian = ents.Create(guardianData.class)
        guardian:SetPos(guardianData.pos)
        guardian:Spawn()
        
        self.State.GuardianNPCs[i] = guardian
    end
end

function RuinDungeon:CheckAllNPCsDefeated()
    local totalNPCs = #self.Config.NPCSpawns
    local defeatedCount = 0
    
    for index, _ in pairs(self.Config.NPCSpawns) do
        local npc = self.State.ActiveNPCs["npc"..index]
        
        if !IsValid(npc) or npc:Health() <= 0 then
            defeatedCount = defeatedCount + 1
        end
    end
    
    return defeatedCount == totalNPCs
end

function RuinDungeon:SetupHooks()
    hook.Add("PlayerDeath", "RuinDungeon_PlayerDeath", function(victim, inflictor, attacker)
        if not self.State.IsActive or not victim:GetNWBool("InDangeon") then return end
        if not IsValid(self.State.Squad) then return end
        
        local allDead = true
        for _, ply in pairs(self.State.Squad:GetMembers()) do
            if IsValid(ply) and ply:Alive() and ply:GetNWBool("InDangeon") then
                allDead = false
                break
            end
        end
        
        if allDead then
            for _, ply in pairs(self.State.Squad:GetMembers()) do
                if IsValid(ply) then
                    ply:ChatPrint("All party members have died. The dungeon will reset.")
                end
            end
            timer.Simple(5, function() 
                self:Reset() 
            end)
        end
    end)

    hook.Add("OnNPCKilled", "RuinDungeon_NPCKilled", function(npc, attacker, inflictor)
        if !npc.RuindDangeon then return end
        
        if self:CheckAllNPCsDefeated() then
            self:SpawnEliteNPC()
        end
    end)

    hook.Add("PlayerUse", "RuinDungeon_PlayerUse", function(ply, ent)
        if self.State.IsActive then 
            if ent:GetModel() == self.Config.Doors.Boss then 
                local squadMembers = self.State.Squad:GetMembers()
                for k, v in pairs(squadMembers) do
                    if k <= #self.Config.SpawnPositions.Boss then
                        v:SetPos(self.Config.SpawnPositions.Boss[k])
                    end
                end

                self:SpawnBoss()
                return false
            end
            
            if ent:GetModel() == self.Config.Doors.Inner then
                if IsValid(self.State.GuardianNPCs[1]) and self.State.GuardianNPCs[1]:Health() > 0 then 
                    return false
                end
                if IsValid(self.State.GuardianNPCs[2]) and self.State.GuardianNPCs[2]:Health() > 0 then 
                    return false
                end
            end
            return
        end 

        if ent:GetModel() == self.Config.Doors.Entrance then
            local squad = ply:GetSquad()
            if !squad then return end 
            
            if !ply:IsSquadLeader() then return end
            
            if !ply.inventory:hasItems("dangeon_ruin") then return end
            
            self.State.Squad = squad
            ply.inventory:removeItemsBySource("dangeon_ruin", 1)

            local squadMembers = squad:GetMembers()
            for k, v in pairs(squadMembers) do
                if k <= #self.Config.SpawnPositions.Entry then
                    v:SetPos(self.Config.SpawnPositions.Entry[k])
                end
            end

            self:SpawnGuardians()
            
            self.State.IsActive = true
            return false
        end
    end)
end

function RuinDungeon:Initialize()
    for index, spawnData in pairs(self.Config.NPCSpawns) do
        local npc = self:SpawnNPC(spawnData, index)
        self.State.ActiveNPCs["npc"..index] = npc
    end
    
    self:SetupHooks()
    
end

RuinDungeon:Initialize()