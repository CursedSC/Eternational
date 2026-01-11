ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Пещерная Трава"
ENT.Spawnable = true
ENT.Category = "Fantasy - Ресурсы"

function ENT:Draw(f)
	self:DrawModel()
	if not self:GetNWBool("CanUse") then return end

	local angle = EyeAngles()


	angle = Angle( 0, angle.y, 0 )


	angle.y = angle.y + math.sin( CurTime() ) * 10


	angle:RotateAroundAxis( angle:Up(), -90 )
	angle:RotateAroundAxis( angle:Forward(), 90 )


	local pos =self:GetPos() + Vector(0, 0, 28)


	pos = pos + Vector( 0, 0, math.cos( CurTime() / 2 ) + 20 )


	cam.Start3D2D( pos, angle, 0.01 )
		-- Get the size of the text we are about to draw
		local text = "Testing"
		surface.SetFont( "Default" )
		local tW, tH = surface.GetTextSize( "Testing" )


		local pad = 5

		draw.SimpleText( "Вырос!", "Name_Font_Out", -tW / 2 + 17, -401, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( "Вырос!", "Name_Font", -tW / 2 + 20, -400, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	cam.End3D2D()
end