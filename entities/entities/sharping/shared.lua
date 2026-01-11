ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Заточка"
ENT.Spawnable = true
ENT.Category = "Fantasy - Станции"

function ENT:Draw(f)
	self:DrawModel()
end