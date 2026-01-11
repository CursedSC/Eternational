AddCSLuaFile("shared.lua")

include("shared.lua")----

function ENT:Initialize()
	self:SetModel( "models/props_junk/cardboard_box004a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self.kkk = false
	self.add = 10

	timer.Simple(120, function()

		if IsValid(self) then 
			self:Remove()
		end

	end)
end

function ENT:SetInfo(id,num,meta)
	self.id = id
	self.num = num
	self.meta = meta
	self:SetNWInt("id_", id)
end

function ENT:Use(activator)
	if self.kkk then return end
	local in_v = ReadInventory(activator)

	local PLAYER_DATA = ReadData(activator)
	if #in_v >= 165 then return end

	self.kkk = true
	inv.AddItemCustom(self.id, self.num, self.meta, activator) 
	self:Remove()
end


