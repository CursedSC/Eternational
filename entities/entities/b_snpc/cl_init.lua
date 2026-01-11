-- incredible-gmod.ru

include("shared.lua")
surface.CreateFont( "Job_Font", {
	font = "Arial", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 33 * 10,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )
surface.CreateFont( "Job_Font_Out", {
	font = "Arial", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 37 * 10,
	weight = 610,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "Name_Font", {
	font = "Arial", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 33 * 10,
	weight = 650,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )
surface.CreateFont( "Name_Font_Out", {
	font = "Arial", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 37 * 10,
	weight = 660,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

function ENT:Draw(f)
	self:DrawModel(f)

	local angle = EyeAngles()


	angle = Angle( 0, angle.y, 0 )


	angle.y = angle.y + math.sin( CurTime() ) * 10


	angle:RotateAroundAxis( angle:Up(), -90 )
	angle:RotateAroundAxis( angle:Forward(), 90 )


	local pos =self:GetPos() + Vector(0, 0, 58)


	pos = pos + Vector( 0, 0, math.cos( CurTime() / 2 ) + 20 )


	cam.Start3D2D( pos, angle, 0.01 )
		-- Get the size of the text we are about to draw
		local text = "Testing"
		surface.SetFont( "Default" )
		local tW, tH = surface.GetTextSize( "Testing" )

		-- This defines amount of padding for the box around the text
		local pad = 5

		-- Draw some text
		draw.SimpleText( "<"..self:GetNWString("Job")..">", "Job_Font_Out", -tW / 2 + 17, -1, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( "<"..self:GetNWString("Job")..">", "Job_Font", -tW / 2 + 20, 0, Color(0, 191, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		draw.SimpleText( self:GetNWString("Name"), "Name_Font_Out", -tW / 2 + 17, -401, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( self:GetNWString("Name"), "Name_Font", -tW / 2 + 20, -400, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	cam.End3D2D()

end

net.Receive(ENT.NetID, function()
	local ent = net.ReadEntity()

	if ent.OnUse then
		ent:OnUse()
	end
end)
