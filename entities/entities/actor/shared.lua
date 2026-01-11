ENT.Type = "anim"
ENT.Base = "base_gmodentity"
--
ENT.PrintName = "Актер"
ENT.Spawnable = true
ENT.Category = "[Role Play]"
ENT.ActivePoint = Vector(0, 0, 0)
ENT.InMove = false
function ENT:Draw()
    self:DrawModel()
end

function ENT:MoveTo(vector, speed, callback)
    self.InMove = true;
    self.ActivePoint = vector;
    self.SpeedMove = speed or 1;
end

function ENT:Think()
    if self.InMove then 
        local current_pos = self:GetPos()
        self:SetPos(current_pos + Vector(self.SpeedMove,self.SpeedMove,self.SpeedMove))
        if current_pos == self.ActivePoint then self.InMove = false end
    end
end


concommand.Add("StartMove", function(ply)
    local tr = util.TraceLine( util.GetPlayerTrace( ply ) )
    if IsValid(tr.Entity) then tr.Entity:MoveTo(tr.Entity:GetPos() + Vector(0,10,0), 1, nil) end
end)