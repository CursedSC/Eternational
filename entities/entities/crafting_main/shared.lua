ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Верстак"
ENT.Spawnable = true
ENT.Category = "Fantasy - Создание"

function ENT:Draw(f)
	self:DrawModel()
end