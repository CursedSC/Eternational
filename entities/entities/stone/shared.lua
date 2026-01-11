ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Камень"
ENT.Spawnable = true
ENT.Category = "Fantasy - Ресурсы"

function ENT:Draw(f)
	if self:GetNWBool("CanUse") then self:DrawModel(f) end
end