local meta = FindMetaTable('Player')
local cooldown = {}
 
function meta:AddCooldown(name, duration)
	print(name)
	cooldown[self] = cooldown[self] or {}
	cooldown[self][name] = CurTime() + duration
	if SERVER then 
		netstream.Start(self, "fantasy/fight/cooldown", self, name, duration)
	end	
end

function meta:HasCooldown(name)
	cooldown[self] = cooldown[self] or {}
	return cooldown[self][name] and cooldown[self][name] > CurTime() or false
end

function meta:GetCooldowns()
	cooldown[self] = cooldown[self] or {}
	return cooldown[self]
end

function meta:GetCooldown(name)
	cooldown[self] = cooldown[self] or {}
	return self:HasCooldown(name) and (cooldown[self][name] - CurTime()) or 0
end

function meta:RemoveCooldown(name)
	cooldown[self] = cooldown[self] or {}
	cooldown[self][name] = nil
end

netstream.Hook("fantasy/fight/cooldown", function(ply, name, duration)
	local ply = ply or Localplayer()	
	ply:AddCooldown(name, duration)
end)

if CLIENT then 
	local function DrawCooldowns()
		local ply = LocalPlayer()
		local cd = ply:GetCooldowns()
		
		local x, y = 20, 150
		for name, endTime in pairs(cd) do
			local timeLeft = endTime - CurTime()
			if timeLeft > 0 then
				draw.SimpleText(name .. ": " .. string.format("%.1f", timeLeft) .. "s", "TL X28", x, y, Color(136, 62, 62), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				y = y + 40
			end
		end
	end
	
	hook.Add("HUDPaint", "DrawCooldowns", DrawCooldowns)
end

