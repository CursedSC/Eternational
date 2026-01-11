SWEP.Base = "sword_base"

if (SERVER) then
    AddCSLuaFile()
end 

SWEP.PrintName = "Фалиант"
SWEP.Spawnable = true
SWEP.Category = "Оружие"
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/prop/catalyst/genshin_impact_catalyst_apprentice.mdl"
SWEP.Damage = 5
SWEP.Type = "catalisator"
SWEP.SphereSize = 60
SWEP.HoldType = "idle"
SWEP.CanBlock = false
function SWEP:DrawWorldModel()
    if CLIENT and IsValid(self.ClientModel) then
        local ply = self:GetOwner()
        if IsValid(ply) then
            local boneIndex = ply:LookupBone("ValveBiped.Bip01_Spine")
            if boneIndex then
                local bonePos, boneAng = ply:GetBonePosition(boneIndex)
                local offset = Vector(10, -15, -30) -- Adjust the offset as needed
                local targetPos = bonePos + boneAng:Forward() * offset.x + boneAng:Right() * offset.y + boneAng:Up() * offset.z

                local currentPos = self.ClientModel:GetPos()
                local lerpPos = LerpVector(FrameTime() * 5, currentPos, targetPos) -- Adjust the smoothing factor as needed
				boneAng = boneAng + Angle(25, 130, -90) -- Adjust the angle as needed
                self.ClientModel:SetPos(lerpPos)
                self.ClientModel:SetAngles(boneAng)
                self.ClientModel:DrawModel()
            end
        else
            self.ClientModel:SetPos(self:GetPos())
            self.ClientModel:SetAngles(self:GetAngles())
            self.ClientModel:DrawModel()
        end
    else
        self:DrawModel()
    end
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    if CLIENT then
        self.ClientModel = ClientsideModel(self.WorldModel)
        self.ClientModel:SetNoDraw(true)
    end
end

function SWEP:OnRemove()
    if CLIENT and IsValid(self.ClientModel) then
        self.ClientModel:Remove()
    end
end
