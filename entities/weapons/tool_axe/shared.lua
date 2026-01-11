if (SERVER) then
    AddCSLuaFile()
end 
SWEP.DrawAmmo = false
SWEP.Primary.NeverRaised = true
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 90
SWEP.Primary.Delay = 3
SWEP.Primary.Ammo = ""
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Delay = 0
SWEP.Secondary.Ammo = ""

SWEP.PrintName = "Кирка"
SWEP.Spawnable = true
SWEP.Category = "Инструменты"
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_mgs_pickaxe.mdl"

function SWEP:SecondaryAttack()	
end

function SWEP:PrimaryAttack()
end
function SWEP:Initialize()

end
