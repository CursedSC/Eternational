local rootFolder = "fantasy/fractions"
standartRoles = {
    ["member"] = {
        name = "Житель",
        imune = 1,
        acces = {}
    },
    ["helper"] = {
        name = "Помощник",
        imune = 2,
        acces = {
            invite = true,
            storage = true,
            giveroles = true,
            kick = true
        }
    },
    ["leader"] = {
        name = "Лидер",
        imune = 999,
        acces = {
            invite = true,
            storage = true,
            editroles = true,
            kick = true,
            giveroles = true,
        }
    }
}

Fraction = {}
Fraction.__index = Fraction

function Fraction:new()
    local self = setmetatable({}, Fraction)
    self.id = "none"
    self.Leader = false
    self.storage = Inventory:new(nil, 25)
    self.Roles = standartRoles
    self.members = {}
    return self
end

function Fraction:__tostring() 
    local id = self.id 
	return "Фракция ["..id.."]"
end

function Fraction:Init(id, loadedJson)
   self.Leader = loadedJson.Leader or false 
   self.Roles = loadedJson.Roles or standartRoles
   self.id = id
   self.storage = Inventory:new(nil, 25)
   self.members = loadedJson.members or {}
   if loadedJson.storage then
        self.storage = Inventory:fromTable(loadedJson["storage"])
   end
   print(self.storage.id)
   self.storage.SyncCallBack = function()
        print("SyncCallBack")
        self:Save()
   end
   
end

function Fraction:Save()
    local saveJson = util.TableToJSON(self, true)
    local idSave = self.id 
    file.Write(rootFolder.."/"..idSave..".json", saveJson)
end

function Fraction:AddMember(player, role)
    if !player:IsPlayer() then return end
    local role = role or "member"

    player:SetNWString("fraction", self.id)
    player:SetNWString("fractionRole", role)

    player:SetCharacterData("fraction", self.id)
    player:SetCharacterData("fractionRole", role)

    player:SyncData()

    self.members = self.members or {}
    self.members[player:SteamID()] = role
    
    fractions.Save(self)
end

function Fraction:GetStorage()
    local storage = self.storage or Inventory:new(nil, 25)
    print("GetStorage")
    print(self.storage)
    return storage
end

function Fraction:GetLeader(leader)
    return self.Leader
end

function Fraction:SetLeader(newLeader)
    local leaderSteam = newLeader
    if newLeader:IsPlayer() then 
        leaderSteam = newLeader:SteamID()
    end
    self.Leader = leaderSteam
    if SERVER then fractions.Save(self) end
end

function Fraction:RoleCan(role, param)
    return self.Roles[role].acces[param]
end

local meta = FindMetaTable("Player")

function meta:IsLeader(fraction)
    local trueLeder = fraction:GetLeader()
    if !trueLeder then return false end
    local SteamID = self:SteamID()
    return (trueLeder == SteamID)
end

function meta:GetFraction()
    local fraction = self:GetNWString("fraction", false)
    return fraction
end

function meta:GetFractionRole()
    local fraction = self:GetFraction()
    if !fraction then return end 
    local fractionRole = self:GetNWString("fractionRole", "member")
    return fractionRole
end

function meta:FractionCan(param)
    local fraction = self:GetFraction()
    if !fraction then return end
    local fraction = fractions.List[fraction]
    if !fraction then return end
    local role = self:GetFractionRole()
    return fraction.Roles[role].acces[param]
end

function meta:CanAboveRole(role)
    local selfFraction = self:GetFraction()
    if !selfFraction then return end 
    local selfRole = self:GetFractionRole()
    local targetRole = role
    local fractionMeta = fractions.List[selfFraction]
    local selfImune = fractionMeta.Roles[selfRole].imune 
    local targetImune = fractionMeta.Roles[targetRole].imune 
    return selfImune > targetImune
end

function meta:CanAbovePlayer(target)
    local selfFraction = self:GetFraction()
    if !selfFraction then return end 
    local targetFraction = target:GetFraction()
    if !targetFraction then return end 
    if selfFraction != targetFraction then return end 
    local selfRole = self:GetFractionRole()
    local targetRole = target:GetFractionRole()
    local fractionMeta = fractions.List[selfFraction]
    local selfImune = fractionMeta.Roles[selfRole].imune 
    local targetImune = fractionMeta.Roles[targetRole].imune 
    return selfImune > targetImune
end

