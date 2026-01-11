--[[
    Player MetaTable Extensions for Character Data Management

    This module extends the Player MetaTable to manage character data in the Fantasy gamemode.

    Functions:
        Player:SyncData()
            Synchronizes the player's character data with the client.

        Player:InitializeCharacter()
            Initializes the player's character data with default values.

        Player:GetCharacterData(key, d)
            Retrieves a specific piece of character data.
            @param key - The key of the character data to retrieve.
            @param d - The default value to return if the key does not exist.

        Player:SetCharacterData(key, value)
            Sets a specific piece of character data and synchronizes it with the client.
            @param key - The key of the character data to set.
            @param value - The value to set for the specified key.

        Player:GetName(bKnow)
            Retrieves the player's name, with an option to check if the name is known.
            @param bKnow - Boolean indicating if the name is known.

        Player:SetName(value)
            Sets the player's name.
            @param value - The name to set.

        Player:GetGender()
            Retrieves the player's gender.

        Player:GetAttributes()
            Retrieves the player's attributes.

        Player:GetAttribute(attribute)
            Retrieves a specific attribute value, including any buffs.
            @param attribute - The attribute to retrieve.

        Player:SetAttribute(attribute, value)
            Sets a specific attribute value.
            @param attribute - The attribute to set.
            @param value - The value to set for the specified attribute.

        Player:AddKnowSkill(id)
            Adds a known skill to the player's character data.
            @param id - The ID of the skill to add.

        Player:GetKnowSkills()
            Retrieves all known skills of the player.

        Player:GetKnowSkill(skill)
            Checks if a specific skill is known by the player.
            @param skill - The skill to check.

        Player:SetKnowSkills(skill, value)
            Sets a specific known skill value.
            @param skill - The skill to set.
            @param value - The value to set for the specified skill.

        Player:GetAttributesSkills()
            Retrieves the player's attribute skills.

        Player:SetAttributesSkills(skills)
            Sets the player's attribute skills.
            @param skills - The skills to set.

        Player:GetRace()
            Retrieves the player's race.

        Player:SetRace(newRace)
            Sets the player's race.
            @param newRace - The race to set.

        Player:GetLvl()
            Retrieves the player's level.

        Player:SetLvl(newLvl)
            Sets the player's level.
            @param newLvl - The level to set.

        Player:getClass()
            Retrieves the player's class.

        Player:GetExperience()
            Retrieves the player's experience points.

        Player:GetMaxExperience()
            Calculates and retrieves the maximum experience points needed for the next level.

        Player:GetSkillPoints()
            Retrieves the player's skill points.

        Player:AddSkillPoints(value)
            Adds skill points to the player's character data.
            @param value - The number of skill points to add.

        Player:Acquaintance(player)
            Checks if the player is acquainted with another player.
            @param player - The player to check acquaintance with.

        Player:GetPersonalStorage()
            Retrieves the player's personal storage inventory.
]]
local Player = FindMetaTable("Player")

function Player:SyncData()
    netstream.Start(self, "fantasy/character/init", self.characterData)
end

function Player:InitializeCharacter()
    self.characterData = {
        name = "Unknown",
        gender = "Мужчина",
        level = 1,
        experience = 0,
        skillPoint = 0,
        race = RACE_HUMAN,
        knowSkills = {},
		knowRecipes = {},
        attributesSkills = {},
        attributes = {
            strength = 5,
            agility = 5,
            intelligence = 5,
            vitality = 5,
            luck = 5
        },
    }
end

function Player:GetDescription()
    return self.characterData.description or ""
end

function Player:SetDescription(value)
    self.characterData.description = value
end

-- Getter and Setter for characterData
function Player:GetCharacterData(key, d)
    return self.characterData[key] or d
end

function Player:SetCharacterData(key, value)
    self.characterData[key] = value
    self:SyncData()
end

function Player:GetName(bKnow)
    if bKnow then return self:GetNWString("RPName") end
    if CLIENT then
        local Gues = LocalPlayer():Acquaintance(self) or (LocalPlayer() == self)
        local nonName = (self:GetGender() == "Мужчина") and "Незнакомец" or "Незнакомка"

        return Gues and self:GetNWString("RPName") or nonName
    end

    return self:GetNWString("RPName")
end

function Player:SetName(value)
    self.characterData.name = value
end

function Player:GetGender()
    if CLIENT then
        return self:GetNWString("Gender", "Мужской")
    end
    return self.characterData.gender
end

function Player:GetAttributes()
    return self.characterData.attributes
end
-- Getter and Setter for attributes
function Player:GetAttribute(attribute)
    if !self.characterData then return 0 end
    if !self.characterData.attributes then return 0 end
    local playerbuff = self:GetArmorStat(attribute)
    local standart = self.characterData.attributes[attribute] or 1
    return standart + playerbuff
end

function Player:SetAttribute(attribute, value)
    self.characterData.attributes[attribute] = value
end

function Player:AddKnowSkill(id)
    self.characterData.knowSkills[id] = true
end

-- Getter and Setter for knowSkills
function Player:GetKnowSkills()
    return self.characterData.knowSkills
end

function Player:GetKnowSkill(skill)
    return self.characterData.knowSkills[skill] or false
end

function Player:SetKnowSkills(skill, value)
    self.characterData.knowSkills[skill] = value
end

-- Getter and Setter for attributesSkills
function Player:GetAttributesSkills()
    return self.characterData.attributesSkills
end

function Player:SetAttributesSkills(skills)
    self.characterData.attributesSkills = skills
    self:SyncData()
end
function Player:GetAttributesSkillsPoints()
    return self.characterData.attributesSkillsPoints or 0
end

function Player:SetAttributesSkillsPoints(skills)
    self.characterData.attributesSkillsPoints = skills
    self:SyncData()
end

function Player:GetRace()
    return self.characterData.race
end

function Player:SetRace(newRace)
    self.characterData.race = newRace
end

function Player:GetLvl()
    return self.characterData.level
end

function Player:SetLvl(newLvl)
    self.characterData.level = newLvl
end

function Player:getClass()
    return self.characterData.class or 0
end

function Player:GetExperience()
    return self.characterData.experience
end

function Player:GetMaxExperience()
    local currentLvl = self.characterData.level
    local needToLvlUp = 500 * currentLvl

    return needToLvlUp
end

function Player:GetLevel()
    return self.characterData.level
end

function Player:GetSkillPoints()
    return self.characterData.skillPoint
end

function Player:AddSkillPoints(value)
    self.characterData.skillPoint = self.characterData.skillPoint + value
end

function Player:Acquaintance(player)
    local st = player:SteamID()
    local acquaintance = self:GetCharacterData("acquaintance", {})
    return acquaintance[st]
end

function Player:GetPersonalStorage()
    local storage = self.characterData.personalStorage or Inventory:new(nil, 15)
    self.characterData.personalStorage = storage
    print(storage)
    return storage
end

function Player:AddMoney(amount)
    local current = self:GetCharacterData("money") or 0
    self:SetCharacterData("money", current + amount)
end

function Player:TakeMoney(amount)
    local current = self:GetCharacterData("money") or 0
    self:SetCharacterData("money", math.max(0, current - amount))
end

function Player:AddKnowRecipe(recipe)
	local recipes = table.Copy(self:GetCharacterData("knowRecipes", {}))
	if not table.HasValue(recipes, recipe) then
		recipes[#recipes + 1] = recipe
	end

	self:SetCharacterData("knowRecipes", recipes)
end

function Player:RemoveKnowRecipe(recipe)
	local recipes = table.Copy(self:GetCharacterData("knowRecipes", {}))
	local toremove = nil
	for k, v in pairs(recipes) do
		if v == recipe then
			recipes[k] = nil
		end
	end

	self:SetCharacterData("knowRecipes", recipes)
end

function Player:GetWeight()
    return 20
end

if SERVER then concommand.Add("kkk", function(ply)
    ply:AddMoney(1000)
end) end
