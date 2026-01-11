AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel( "models/props_c17/gravestone_cross001a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self.add = 10
	self.OpenCD = CurTime()
end

--
function ENT:Use(activator)
	if self.OpenCD > CurTime() then return end
	self.OpenCD = CurTime() + 1  
	local cmd = activator.data
	activator:ConCommand("+duck")
	activator:Freeze(true)
	timer.Simple(5, function() activator:ConCommand("-duck") activator:Freeze(false) activator:ChatPrint("Ваши мольбы не были услышаны богами.") RP.chat.commands["/do"].server(activator, "/do Вокруг монумента нависла нериятная аура.") end)
end


