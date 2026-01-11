AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Dropped Item"
ENT.Author = "YourName"
ENT.Spawnable = false

function ENT:Initialize()
    self:SetModel("models/props_junk/cardboard_box004a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:SetItemData(item)
    self.ItemData = item
end

function ENT:Use(activator, caller)
    if IsValid(caller) and caller:IsPlayer() then
        caller.inventory:addItem(self.ItemData)
        self:Remove()
    end
end