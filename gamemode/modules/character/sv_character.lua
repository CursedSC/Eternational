local Player = FindMetaTable("Player")
function Player:AddExperience(xp)
    local currentXP = self.characterData.experience
    local currentLvl = self.characterData.level
    local xpLess = self:GetCharacterData("xpLess", 0)
    local needToLvlUp = 500 * currentLvl

    if xpLess > 0 then
        xpLess = xpLess - xp
        if xpLess < 0 then
            xp = math.abs(xpLess)
            xpLess = 0
        else
            xp = 0
        end
        self:SetCharacterData("xpLess", xpLess)
    end
    if xp <= 0 then
        self:SyncData()
        return
    end
    local newXP = currentXP + xp

    while (newXP >= needToLvlUp) do
        newXP = newXP - needToLvlUp
        self.characterData.level = self.characterData.level + 1
        self.characterData.skillPoint = self.characterData.skillPoint + 1
    end

    self.characterData.experience = newXP
    self:SyncData()
end

hook.Add("PlayerDeath", "xpLess", function(ply)
    local currentLvl = ply.characterData.level
    local needToLvlUp = 500 * currentLvl
    local xpLessNew = math.floor(needToLvlUp * 0.05)
    local xpLess = ply:GetCharacterData("xpLess", 0)
    ply:SetCharacterData("xpLess", xpLess + xpLessNew)
end)

local function saveCharacterData(ply)
    if not ply.characterData then return end

    local data = util.TableToJSON(ply.characterData, true)
    file.Write("fantasy/character/" .. ply:SteamID64() .. ".txt", data)
end

file.CreateDir("fantasy")
file.CreateDir("fantasy/character")

local function loadCharacterData(ply)
    print("Loading character data for " .. ply:Nick())
    local filePath = "fantasy/character/" .. ply:SteamID64() .. ".txt"
    if file.Exists(filePath, "DATA") then
        local data = file.Read(filePath, "DATA")
        print("data:")
        print(data)
        ply.characterData = util.JSONToTable(data)
        ply.characterData.personalStorage = ply.characterData.personalStorage and (Inventory:fromTable(ply.characterData.personalStorage)) or Inventory:new(nil, 15)
        ply:SetNWString("RPName", ply.characterData.name)
        if ply.characterData.name == "Unknown" then
            netstream.Start(ply, "openCharacterCreator")
        end
        hook.Run(
            "Fantasy.CharacterLoaded",
            ply
        )
    else
        print("No character data found for " .. ply:Nick())
        netstream.Start(ply, "openCharacterCreator")
        ply:InitializeCharacter()
    end
    hook.Run("Fantasy.CharacterLoaded", ply)
end

function loadCharacterSteamID(steamid64)
    local loadedData = file.Read("fantasy/character/" .. steamid64 .. ".txt", "DATA")
    if not loadedData then return end
    return util.JSONToTable(loadedData)
end

function saveCharacterSteamID(steamid64, data)
    file.Write("fantasy/character/" .. steamid64 .. ".txt", util.TableToJSON(data, true))
end

// Dev Удалить на открытии
concommand.Add("loadCharacterData", function(ply)
    loadCharacterData(ply)
end)

concommand.Add("InitializeCharacter", function(ply)
    ply:InitializeCharacter()
    hook.Run("Fantasy.CharacterLoaded", ply)
end)

hook.Add("PlayerInitialSpawn", "loadCharacterData", function(ply)
    loadCharacterData(ply)
end)

hook.Add("PlayerDisconnected", "saveCharacterData", function(ply)
    saveCharacterData(ply)
end)

timer.Create("SaveCharacterData", 60, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        saveCharacterData(ply)
    end
end)

local spawnPos = {
    Vector("2777.162354 -3486.790771 195.986786"),
    Vector("2715.736816 -3594.830078 196.133942"),
    Vector("2617.882080 -3753.678955 195.893692"),
    Vector("2532.270752 -3618.380127 195.745224"),
    Vector("2886.394043 -3261.549072 196.479141"),
    Vector("2716.788574 -3150.343262 196.444504"),
    Vector("2883.370361 -3631.116211 196.693573"),
}

local availableClasses = {
    {class = CLASS_MAGIC, chance = 0.05},
    {class = CLASS_WARRIOR, chance = 0.3},
    {class = CLASS_DEFENDER, chance = 0.3},
    {class = CLASS_NOMAD, chance = 0.2},
    {class = CLASS_PRIEST, chance = 0.15},
}

local function getRandomClass()
    local totalChance = 0
    for _, classData in ipairs(availableClasses) do
        totalChance = totalChance + classData.chance
    end

    local randomValue = math.Rand(0, totalChance)
    local cumulativeChance = 0

    for _, classData in ipairs(availableClasses) do
        cumulativeChance = cumulativeChance + classData.chance
        if randomValue <= cumulativeChance then
            return classData.class
        end
    end
end

local function randomizePlayerClass(ply)
    local randomClass = getRandomClass()
    ply.characterData.class = randomClass

    ply:SyncData()
    ply:SetNWString("Class", randomClass)
end

netstream.Hook("rerollClass", function(ply)
    local rerolPoints = ply.characterData.rerolPoints or 1
    //if rerolPoints <= 0 then
    //    return
    //end
    //rerolPoints = rerolPoints - 1
    ply:SetCharacterData("rerolPoints", rerolPoints)
    randomizePlayerClass(ply)
    netstream.Start(ply, "showClassReveal", ply.characterData.class)
end)

concommand.Add("rerollClass", function(ply)
    local rerolPoints = ply.characterData.rerolPoints
    randomizePlayerClass(ply)
    netstream.Start(ply, "showClassReveal", ply.characterData.class)
end)

netstream.Hook("saveCharacter", function(ply, data)
    ply.characterData = {
        name = data.name,
        gender = data.gender,
        level = 1,
        experience = 0,
        skillPoint = 0,
        race = data.race,
        knowSkills = {},
		knowRecipes = {},
        attributesSkills = {},
        money = 500,
        attributes = listRace[data.race].attributes,
        description = data.description,
        custom = {
            cloth = data.cloth,
            hair = data.hair,
            clothSkin = data.clothSkin,
            color = data.hairColor,
        }
    }
    randomizePlayerClass(ply)
    ply:SyncData()
    ply:SetNWString("RPName", ply.characterData.name)

    local inventory = Inventory:new(ply, 63)
    ply.inventory = inventory
    inventory:sync()

    ply:Spawn()

    netstream.Start(ply, "showClassReveal", ply.characterData.class)
end)

hook.Add("PlayerSpawn", "fantasy/init/character", function(ply)
    timer.Simple(0, function()
        ply:SetPos(spawnPos[math.random(1, #spawnPos)])
        local race = ply:GetRace()
        local tbl = listRace[race]
        local gender = ply:GetGender()
        ply:SetModel(tbl.models[gender])
        local customModel = ply:GetCharacterData("customModel")
        if customModel and customModel != "" then
            ply:SetModel(customModel)
        end

        if ply.characterData.custom then
            PrintTable(ply.characterData.custom)
            ply:SetSkin(ply.characterData.custom.clothSkin)
            ply:SetPlayerColor(Vector(ply.characterData.custom.color.r / 255, ply.characterData.custom.color.g / 255, ply.characterData.custom.color.b / 255))
            ply:SetBodygroup(3, ply.characterData.custom.hair - 1)
            ply:SetBodygroup(1, ply.characterData.custom.cloth)
        end
        ply:Give("hands")

        local str = ply:GetAttribute("vitality")
        ply:SetHealth(100 + str * 10)
        ply:SetMaxHealth(100 + str * 10)
    end)
end)

hook.Add("Fantasy.CharacterLoaded", "fantasy/init/race", function(ply)
    print("Initializing character for " .. ply:Nick())
    netstream.Start(ply, "fantasy/character/init", ply.characterData)
    local race = ply:GetRace()
    local raceTable = listRace[race]
    ply:SetModel(raceTable.models[ply:GetGender()])
    ply:SetNWString("Gender", ply:GetGender())
    ply:SetNWString("RPName", ply:GetName())
    timer.Simple(2, function()
        print("Sending character data to " .. ply:Nick())
        netstream.Start(ply, "fantasy/character/init", ply.characterData)
    end)
end)

util.AddNetworkString("AdminSaveCharacterData")

net.Receive("AdminSaveCharacterData", function(len, ply)
    if not ply:IsSuperAdmin() then return end

    local data = net.ReadTable()
    local target = data.player
    target:SetName(data.name)
    target:SetNWString("RPName", data.name)
    target:SetCharacterData("gender", data.gender)

    local tRace = 1
    for k, i in pairs(listRace) do
        if i.name == data.race then
            tRace = k
        end
    end

    target:SetRace(tRace)
    target:SetLvl(data.level)
    target:SetCharacterData("experience", data.experience)
    target:SetCharacterData("skillPoint", data.skillPoints)
    target:SetCharacterData("customModel", data.customModel)

    for attribute, value in pairs(data.attributes) do
        target:SetAttribute(attribute, value)
    end

    saveCharacterData(target)
    netstream.Start(ply, "fantasy/character/init", ply.characterData)
    target:Spawn()
end)

netstream.Hook("fantasy/player/getAll", function(ply)
    if not ply:IsSuperAdmin() then return end
    local tbl = {}
    for k, v in pairs(player.GetAll()) do
        if v.characterData then
            tbl[v] = v.characterData
        end
    end
    netstream.Start(ply, "fantasy/player/getAll", tbl)
end)

netstream.Hook("fantasy/inventory/upgrade", function(ply, id)
    local playerPoints = ply:GetSkillPoints()
    print(playerPoints)
    if playerPoints < 1 then return end
    local attribute = ply:GetAttribute(id)
    if attribute >= 50 then return end
    ply:SetAttribute(id, attribute + 1)
    ply:AddSkillPoints(-1)
    ply:SyncData()
end)

netstream.Hook("fantasy/skill/learn", function(ply, category, skillId)
    local skillData = listAttributeSkill[category] and listAttributeSkill[category][skillId]
    if not skillData then return end

    local playerSkills = ply:GetAttributesSkills() or {}

    if playerSkills[category] and playerSkills[category][skillId] then
        return
    end

    for reqCategory, reqSkillId in pairs(skillData.needSkills) do
        if not playerSkills[reqCategory] or not playerSkills[reqCategory][reqSkillId] then
            return
        end
    end

    for cat, skills in pairs(playerSkills) do
        for playerSkillId, _ in pairs(skills) do
            local blockingSkill = listAttributeSkill[cat] and listAttributeSkill[cat][playerSkillId]
            if blockingSkill and blockingSkill.blockedSkills and
               blockingSkill.blockedSkills[category] == skillId then
                return
            end
        end
    end

    if ply:GetAttributesSkillsPoints() <= 0 then
        return
    end

    playerSkills[category] = playerSkills[category] or {}
    playerSkills[category][skillId] = 1

    ply:SetAttributesSkillsPoints(ply:GetAttributesSkillsPoints() - 1)

    ply:SetAttributesSkills(playerSkills)

    netstream.Start(ply, "fantasy/skill/update")
end)


concommand.Add("typeofmesv", function(ply)
    print(ply)
    print(type(ply))
end)