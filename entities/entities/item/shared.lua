ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Item"
ENT.Spawnable = false
ENT.Catagory = "Dev"

local table_sword = {
	[55] = true,
	[57] = true,
	[59] = true,
	[80] = true,
	[51] = true,
}

local table_ale = {
	[58] = true,
}

local table_bow = {
	[61] = true,
	[82] = true,
}


function ENT:Draw(f)
	self:DrawModel(f)
	if not items.it[self:GetNWInt("id_")] then return end

	local angle = EyeAngles()


	angle = Angle( 0, angle.y, 0 )


	angle.y = angle.y + math.sin( CurTime() ) * 10


	angle:RotateAroundAxis( angle:Up(), -90 )
	angle:RotateAroundAxis( angle:Forward(), 90 )


	local pos =self:GetPos() + Vector(0, 0, 1)


	pos = pos + Vector( 0, 0, math.cos( CurTime() / 2 ) + 20 )


	cam.Start3D2D( pos, angle, 0.01 )
	
		ITEMS_TEX.items[items.it[self:GetNWInt("id_")].icon]( 512 / 2 * -1, 0, 512, 512 ) 
		
	cam.End3D2D()
end