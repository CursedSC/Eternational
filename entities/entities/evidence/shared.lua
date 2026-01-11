ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Улика[NOT SPAWN]"
ENT.Spawnable = true
ENT.Category = "ToA - Entity"
ENT.diss = 0
ang_cicl = 0
function ENT:Draw()
	ang_cicl = 0.1 + ang_cicl
	if self.adverted then return end
	local tr_p = util.TraceLine( util.GetPlayerTrace( LocalPlayer() ) )
	local dist = LocalPlayer():GetPos():Distance(self:GetPos())


	if tr_p.Entity and tr_p.Entity == self and dist <= 255 and LocalPlayer():IsFinding()then 
		ang_cicl = 0.5 + ang_cicl
		self.diss = Lerp(FrameTime()  / 2, self.diss, 64)

	elseif self.diss >= 0 and LocalPlayer():IsFinding() then 
		self.diss = Lerp(FrameTime(), self.diss, 0)
	end

	if self.diss >= 45 and not self.adverted then 
		self.adverted = true
		chat.AddText(Color(51, 153, 255), "[Обноружение]", Color(255,255,255), " ".. self:GetNWString("text"))
	end

	if LocalPlayer():IsFinding() and dist <= 255 then
		cam.Start3D2D( self:GetPos(), LocalPlayer():GetAngles() - Angle(100, 0, 0), 0.1 )
				surface.SetDrawColor( 255, 255, 255, (255 - dist)) --  + 150 * math.cos(CurTime() * 2)
				surface.SetMaterial( Material("circle.png") )
				surface.DrawTexturedRectRotated(0,0,64 - self.diss,64 - self.diss,ang_cicl)

		cam.End3D2D()
	end
end