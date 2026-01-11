-- incredible-gmod.ru

ENT.Base = "base_entity"
ENT.AutomaticFrameAdvance = true

ENT.NetID = ENT.Folder

ENT.Spawnable 	= false -- its base :v
ENT.AdminOnly 	= false

ENT.Author       = "DEMIT"
ENT.Contact      = ""

function ENT:SetAutomaticFrameAdvance(bool)
	self.AutomaticFrameAdvance = bool
end
