include("shared.lua")
local meta = FindMetaTable("Player")

hook.Add("HUDShouldDraw","KDHideHUD",function( name )
	if name == "CHudHealth" or name == "CHudBattery" then
		return false
	end
	if name == "CHudAmmo" and not AmmoHUD then
		return false
	end
end)

hook.Add("PlayerStartVoice", "ImageOnVoice", function()
  return false
end)

hook.Add("PlayerEndVoice", "ImageOnVoice", function()
  return false
end)

local mat = Material("pp/texturize/plain.png")



local blurMat2, Dynamic2 = Material("pp/blurscreen"), 0

hook.Add( "PlayerBindPress", "PlayerBindPressExample", function( ply, bind, pressed )
  if string.StartWith(bind, "slot") then return true end
end )

function BlurScreen(Num)

    local layers, density, alpha = 1, .4, 55

    surface.SetDrawColor(255, 255, 255, alpha)

    surface.SetMaterial(blurMat2)

    local FrameRate, Num, Dark = 1 / FrameTime(), Num, 150



    for i = 1, Num do

        blurMat2:SetFloat("$blur", (i / layers) * density * Dynamic2)

        blurMat2:Recompute()

        render.UpdateScreenEffectTexture()

        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

    end



    Dynamic2 = math.Clamp(Dynamic2 + (1 / FrameRate) * 7, 0, 1)

end



local percent2 = 0
local curprogress = 0
hook.Add("HUDPaint", "hpShow", function()
    if HideUI then return  end
    if IsValid(TestModel) then return  end
    local ply = LocalPlayer()
    local hp = ply:Health()
    local hpMax = ply:GetMaxHealth()
    local percent = hp / hpMax
    percent2 = Lerp(FrameTime() * 7, percent2 , percent - 0.02)

	for _, questtype in pairs(meta.Quests) do
		for k, quest in pairs(questtype) do
			if quest.navigate then
				surface.SetFont("TLP X15")
				local x, y = surface.GetTextSize(quest.name)
				surface.DrawMulticolorText(ScrW() - x - paintLib.WidthSource(20), ScrH()*0.43, "TLP X15", {Color(57, 83, 164), quest.name})
				local posy = 0
				for i, p in pairs(quest.tasks) do
					surface.SetFont("TLP X10")
					local str = p.text .. ": " .. tostring(p.current) .. '/' .. tostring(p.need)
					local x, y2 = surface.GetTextSize(str)
					surface.DrawMulticolorText(ScrW() - x - paintLib.WidthSource(20), ScrH()*0.43 + y + paintLib.HightSource(15)*posy, "TLP X10", {color_white, str})
					posy = posy + 1
				end

				if quest.title == "Охота" then
					for _, npc in pairs(ents.GetAll()) do
						if istable(quest.tasks[1].itemid) then
							if table.HasValue(quest.tasks[1].itemid, npc:GetClass()) then
								local startpos = npc:GetPos()
								startpos.z = startpos.z + 100
								local pos = startpos:ToScreen()
								draw.SimpleText('v', "TLP X20", pos.x, pos.y, Color(255, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
							end
						elseif npc:GetClass() == quest.tasks[1].itemid then
							local startpos = npc:GetPos()
							startpos.z = startpos.z + 100
							local pos = startpos:ToScreen()
							draw.SimpleText('v', "TLP X20", pos.x, pos.y, Color(255, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
						end
					end
				end
			end
		end
	end

	for _, quest in pairs(meta.Quests["Side"]) do
		if quest.points then
			for i, p in pairs(quest.points) do
				local pos = p:ToScreen()
		        draw.SimpleText('v', quest.navigate and "TLP X20" or "TLP X20", pos.x, pos.y, quest.navigate and Color(255, 0, 0, 255) or Color(57, 83, 164, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			end
		end
	end

	for _, quest in pairs(meta.Quests["Main"]) do
		if quest.points then
			for i, p in pairs(quest.points) do
				local pos = p:ToScreen()
		        draw.SimpleText('v', quest.navigate and "TLP X20" or "TLP X20", pos.x, pos.y, quest.navigate and Color(255, 0, 0, 255) or Color(57, 83, 164, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			end
		end
	end

	if ply.IsProgress then
		surface.SetDrawColor(50, 50, 50, 100)
		surface.DrawRect(ScrW()*0.5 - paintLib.WidthSource(150), ScrH()*0.5 - paintLib.HightSource(25), paintLib.WidthSource(300), paintLib.HightSource(50))
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawRect(ScrW()*0.5 - paintLib.WidthSource(150), ScrH()*0.5 - paintLib.HightSource(25), paintLib.WidthSource(300)*curprogress, paintLib.HightSource(50))
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawOutlinedRect(ScrW()*0.5 - paintLib.WidthSource(150), ScrH()*0.5 - paintLib.HightSource(25), paintLib.WidthSource(300), paintLib.HightSource(50))
		curprogress = math.Clamp(curprogress + 0.0005, 0, 1)
		if curprogress == 1 then
			curprogress = 0
			ply.IsProgress = false
			netstream.Start("questsystem/progressend", ply:GetEyeTrace().Entity)
		end
		if not input.IsKeyDown(KEY_E) then
			curprogress = 0
			ply.IsProgress = false
		end
		if ply:GetEyeTrace().Entity:GetClass() != "questitem_use" or ply:GetEyeTrace().Entity:GetPos():Distance(ply:GetPos()) > 100 then
			curprogress = 0
			ply.IsProgress = false
		end
	else
		curprogress = 0
	end
end)

netstream.Hook("questsystem/startprogress", function(ply, ent)
	ply.IsProgress = true
end)

netstream.Hook("ssss", function(a, b)
  debugoverlay.Sphere(a, b)
end)
avalibleFPV = false
concommand.Add("avalibleFPV", function()
  avalibleFPV = !avalibleFPV
end)
function isFPVEnable()
  return avalibleFPV
end
hook.Add( "HUDDrawTargetID", "HidePlayerInfo", function()

	return false

end )
OldnearestEntity = nil
hook.Add("HUDPaint", "DrawRoundedBoxOnNearestEntityToCenter2", function()
    local ply = LocalPlayer()
    if IsValid(TestModel) then return  end
    if HideUI then return  end
    if not IsValid(ply) then return end

    local screenCenter = Vector(ScrW() / 2, ScrH() / 2)
    local nearestEntity
    local nearestDistance = math.huge
    local maxDistance = 300 

    for _, ent in ipairs(ents.GetAll()) do
        if not (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) or ent == ply then continue end
        local distance = ply:GetPos():DistToSqr(ent:GetPos())
        if distance > maxDistance * maxDistance then continue end
        local pos = ent:LocalToWorld(ent:OBBCenter()):ToScreen()
        local screenDistance = screenCenter:DistToSqr(Vector(pos.x, pos.y))
        if screenDistance < nearestDistance then
            nearestDistance = screenDistance
            nearestEntity = ent
        end
    end

    if IsValid(nearestEntity) then
        if OldnearestEntity != nearestEntity then
            netstream.Start("fantasy/player/target", nearestEntity)
            OldnearestEntity = nearestEntity
        end
        if !IsValid(OldnearestEntity) then OldnearestEntity = nearestEntity end
        local pos = nearestEntity:LocalToWorld(nearestEntity:OBBCenter()):ToScreen()
        local boxWidth, boxHeight = 25, 25 
        local boxColor = Color(0, 0, 0, 200) 

        draw.RoundedBox(8, pos.x - boxWidth / 2, pos.y - boxHeight / 2, boxWidth, boxHeight, boxColor)

        local boxWidth, boxHeight = 15, 15 
        local boxColor = Color(68, 17, 116, 200) 

        draw.RoundedBox(8, pos.x - boxWidth / 2, pos.y - boxHeight / 2, boxWidth, boxHeight, boxColor)
    end
end)


local healthBars = {}
if SERVER then return end

local healthBars = {}

hook.Add("PostDrawTranslucentRenderables", "DrawNPCHealthBars", function()
    for ent, data in pairs(healthBars) do
        if not IsValid(ent) or ent:Health() <= 0 then
            healthBars[ent] = nil
            continue
        end

        local pos = ent:GetPos() + Vector(0, 0, ent:OBBMaxs().z + 15)
        local ang = EyeAngles()
        ang:RotateAroundAxis(ang:Right(), 90)
        ang:RotateAroundAxis(ang:Up(), -90)

        local hp = ent:Health()
        local maxHp = ent:GetMaxHealth()
        local name = ent.PrintName or "Unknown"
        local level = ent:GetNWInt("NPCLevel", 1)

        data.smoothHealth = Lerp(0.1, data.smoothHealth, hp)
        data.pulse = data.pulse or 0
        data.pulse = (data.pulse + FrameTime() * 2) % 1

        local hpFrac = math.Clamp(data.smoothHealth / maxHp, 0, 1)
        local width, height = 150 * 3, 4 * 3

        cam.Start3D2D(pos, ang, 0.05)
            draw.SimpleText(name .. " Lvl." .. level, "TLP X32", 0, -30,
                Color(255, 255, 255, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            draw.RoundedBox(1, -width/2, 0, width, height, Color(0, 0, 0, 120))
            local barColor = Color(
                200 + 55 * (1 - hpFrac),
                150 + 55 * hpFrac,
                100 - 100 * hpFrac
            )
            draw.RoundedBox(1, -width/2, 0, width * hpFrac, height, barColor)

            if hpFrac < 0.5 then
                draw.SimpleText(ent:Health(), "TLP X32", 0, 10,
                    Color(255, 255, 255, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        cam.End3D2D()
    end
end)

hook.Add("OnEntityCreated", "SetupNPCHealthBar", function(ent)
    timer.Simple(0, function()
        if IsValid(ent) and (ent:IsNPC() or ent:IsNextBot()) then
            healthBars[ent] = { smoothHealth = ent:Health() }
        end
    end)
end)

local standart = Vector(2647.214355, -3544.834961, 175.120255)
local standartAng = Angle(10,-85,0)
hook.Add("CalcView", "FantasyView", function(ply, pos, angles, fov)
    if !IsValid(TestModel) then return  end
    local view = {}

    view.origin = standart
    view.angles = standartAng + Angle(math.sin(CurTime()) * 0.3, math.sin(CurTime()) * 0.3, 0)
    view.fov = fov
    return view
end)

hook.Add("HUDPaint", "DrawRoundedBoxOnNearestEntityToCenter", function()
    local ply = LocalPlayer()
    if !IsValid(TestModel) then return  end

    draw.SimpleText("Fantasy RP", "TLP X55", ScrW() * 0.3, ScrH() * 0.15, color_white, TEXT_ALIGN_CENTER)
    draw.SimpleText("Открытое Бета Тестирование", "TLP X15", ScrW() * 0.34, ScrH() * 0.23, color_white, TEXT_ALIGN_CENTER)

    draw.SimpleText("Нажмите ЛКМ чтобы начать играть", "TLP X15", ScrW() * 0.3, ScrH() * 0.5, Color(161,161,161), TEXT_ALIGN_CENTER)
end)


hook.Add("InitPostEntity", "MainMenu", function()
    local thirdperson = GetConVar("simple_thirdperson_enabled")
    thirdperson:SetInt(0)
    TestModel = ClientsideModel(LocalPlayer():GetModel() or "models/cloudteam/fantasy/custom/people_male.mdl")
    TestModel:SetPos(Vector(2636.508301, -3553.702637, 125.888123))
    TestModel:SetAngles(Angle(0, 90, 0))

    local sinc = TestModel:LookupSequence("d1_t01_trainride_sit_idle")
    if sinc == -1 then
        sinc = TestModel:LookupSequence("d1_t02_plaza_sit01_idle")
        TestModel:SetPos(Vector(2636.508301, -3580.702637, 132.888123))
    end
    TestModel:ResetSequence(
        sinc
    )
    ply = LocalPlayer()
    function TestModel:GetPlayerColor() return ply:GetPlayerColor() end
    for i = 0, #ply:GetBodyGroups() - 1 do
        local bodygroupValue = ply:GetBodygroup(i)
        TestModel:SetBodygroup(i, bodygroupValue)
    end

    startFrame = vgui.Create("DFrame")
    startFrame:SetSize(ScrW(), ScrH())
    startFrame:SetTitle("")
    startFrame:ShowCloseButton(false)
    startFrame:SetDraggable(false)
    startFrame:Center()
    startFrame:MakePopup()
    startFrame.Paint = function(self, w, h)
        local lmb = input.IsMouseDown(MOUSE_LEFT)
        if lmb then
            startFrame:Close()
            TestModel:Remove()
            refreshItemsQmenu()
            local thirdperson = GetConVar("simple_thirdperson_enabled")
            thirdperson:SetInt(1)
        end
    end
    if needOpenCreation then
        creation:Build()
    end
end)


concommand.Add("GetPosToClipBoard", function(ply)
    local pos = ply:GetPos()
    local str = "Vector(\"" .. pos.x .. " " .. pos.y .. " " .. pos.z .. "\")"
    SetClipboardText(str)
    ply:ChatPrint("Position copied to clipboard: " .. str)
end)

hook.Add("HUDShouldDraw", "HideKillFeed", function(name)
    if name == "CHudDeathNotice" then return false end
end)
