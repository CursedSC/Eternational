local ply = LocalPlayer()
local model = ClientsideModel("models/player/kleiner.mdl")
model:SetNoDraw(true)
model:SetPos(Vector(0, 0, 0))
model:SetAngles(Angle(0, 0, 0))

local applyEmotin = function( ply, data )
	if ( not IsValid( ply ) ) or ( not data ) then return end
	for k, v in pairs (data.data) do
		ply:SetFlexWeight( k, v )
	end
end  

dbt_emote = dbt_emote or {}
hook.Add("CalcView", 'CalcView_Ragdollfirsteye',function (ply, pos, angles, fov)
	if ply:GetNWBool("ragdolled", false) then
		local ent = ply:GetNWEntity("ragdoll")
		if ent:IsValid() then
			local vEyePos = ent:GetAttachment(ent:LookupAttachment('eyes'))
			local tr_forward = util.TraceHull( {
				start = vEyePos.Pos,
				endpos = vEyePos.Pos + ent:GetAngles():Forward()*10,
				maxs = Vector(1, 1, 1),
				mins = Vector(-1, -1, -1),
				filter = ent
			} )

			local tr_right = util.TraceHull( {
				start = vEyePos.Pos,
				endpos = vEyePos.Pos + ent:GetAngles():Right()*10,
				maxs = Vector(1, 1, 1),
				mins = Vector(-1, -1, -1),
				filter = ent
			} )

			local tr_left = util.TraceHull( {
				start = vEyePos.Pos,
				endpos = vEyePos.Pos + ent:GetAngles():Right()*-10,
				maxs = Vector(1, 1, 1),
				mins = Vector(-1, -1, -1),
				filter = ent
			} )

			local tr_behind = util.TraceHull( {
				start = vEyePos.Pos,
				endpos = vEyePos.Pos + ent:GetAngles():Forward()*-10,
				maxs = Vector(1, 1, 1),
				mins = Vector(-1, -1, -1),
				filter = ent
			} )

			local view = {
				origin = vEyePos.Pos + Vector(0, 0, 2),
				angles = vEyePos.Ang,
				fov = fov,
				drawviewer = true
			}

			if tr_forward.HitWorld then
				view.origin = view.origin - ent:GetAngles():Forward()*5
			end

			if tr_behind.HitWorld then
				view.origin = view.origin + ent:GetAngles():Forward()*5
			end

			if tr_right.HitWorld then
				view.origin = view.origin - ent:GetAngles():Right()*5
			end

			if tr_left.HitWorld then
				view.origin = view.origin + ent:GetAngles():Right()*5
			end

			return view
		end
	end
end)
local ScreenWidth = ScreenWidth or ScrW()
local ScreenHeight = ScreenHeight or ScrH()
local closebtnmatbdgrp = http.Material("https://imgur.com/k7XgOcz.png")
local materialtoko = http.Material("https://imgur.com/sEctqI6.png")
local function weight_source(x)
    return ScreenWidth / 1920  * x
end

local function hight_source(x)
    return ScreenHeight / 1080  * x
end

local function Alpha(pr)
    return (255 / 100) * pr
end
local PoseTable = {
	[1] = {
		name = "Назад",
		custom_size = weight_source(80),
		mat = http.Material("https://imgur.com/lszTmGe.png"),
		func = function() NewWheel(GlobalOptions) end,
	},
	[2] = {
		name = "Обычная",
		mat = Material("taunts/taunt3.png"),
		func = function()
			netstream.Start("dbt/change/sq", 1777)
		end
	},
	[3] = {
		name = "Испуг",
		mat = Material("taunts/taunt4.png"),
		func = function()
			netstream.Start("dbt/change/sq", 2027)
		end
	},
	[4] = {
		name = "Руки побокам",
		mat = Material("taunts/taunt2.png"),
		func = function()
			netstream.Start("dbt/change/sq", 2040)
		end
	},
	[5] = {
		name = "Скрещеные руки",
		mat = Material("taunts/taunt1.png"),
		func = function()
			netstream.Start("dbt/change/sq", 2039)
		end
	},
}




local AnimationsTable = {
	[1] = {
		name = "Назад",
		custom_size = weight_source(80),
		mat = http.Material("https://imgur.com/lszTmGe.png"),
		func = function() NewWheel(GlobalOptions) end,
	},
	[2] = {
		name = "Приветствие",
		func = function()
			netstream.Start("dbt/change/sq/anim", "f_charleston", true)

    		local time = LocalPlayer():SequenceDuration(LocalPlayer():LookupSequence("stand_up3"))

          	fp_enb = true
          	EmoteCamera = true
           	timer.Remove("fp_enb")
          	timer.Create("fp_enb",time,1,function()
       			EmoteCamera = false
          	 	fp_enb = false
          	end)
		end,
	},
	[3] = {
		name = "Почесть",
		func = function()
			netstream.Start("dbt/change/sq/anim", "f_accolades", true)

    		local time = LocalPlayer():SequenceDuration(LocalPlayer():LookupSequence("f_accolades"))

          	fp_enb = true
          	EmoteCamera = true
           	timer.Remove("fp_enb")
          	timer.Create("fp_enb",time,1,function()
       			EmoteCamera = false
          	 	fp_enb = false
          	end)
		end,
	},
	[4] = {
		name = "Демонстрация Силы",
		func = function()
			netstream.Start("dbt/change/sq/anim", "f_flex", true)

    		local time = LocalPlayer():SequenceDuration(LocalPlayer():LookupSequence("f_flex"))

          	fp_enb = true
          	EmoteCamera = true
           	timer.Remove("fp_enb")
          	timer.Create("fp_enb",time,1,function()
       			EmoteCamera = false
          	 	fp_enb = false
          	end)
		end,
	},
	[5] = {
		name = "Танец 1",
		func = function()
			netstream.Start("dbt/change/sq/anim", "f_banana", false)

    		local time = LocalPlayer():SequenceDuration(LocalPlayer():LookupSequence("f_banana"))

          	fp_enb = true
          	EmoteCamera = true
           	timer.Remove("fp_enb")
          	timer.Create("fp_enb",time,1,function()
       			EmoteCamera = false
          	 	fp_enb = false
          	end)
		end,
	},
	[6] = {
		name = "Танец 2",
		func = function()
			netstream.Start("dbt/change/sq/anim", "f_electroswing", false)

    		local time = LocalPlayer():SequenceDuration(LocalPlayer():LookupSequence("f_electroswing"))

          	fp_enb = true
          	EmoteCamera = true
           	timer.Remove("fp_enb")
          	timer.Create("fp_enb",time,1,function()
       			EmoteCamera = false
          	 	fp_enb = false
          	end)
		end,
	},
	[7] = {
		name = "Танец 3",
		func = function()
			netstream.Start("dbt/change/sq/anim", "f_break_dance_v2", false)

    		local time = LocalPlayer():SequenceDuration(LocalPlayer():LookupSequence("f_break_dance_v2"))

          	fp_enb = true
          	EmoteCamera = true
           	timer.Remove("fp_enb")
          	timer.Create("fp_enb",time,1,function()
       			EmoteCamera = false
          	 	fp_enb = false
          	end)
		end,
	},
	[8] = {
		name = "Танец 4",
		func = function()
			netstream.Start("dbt/change/sq/anim", "f_gothdance", false)

    		local time = LocalPlayer():SequenceDuration(LocalPlayer():LookupSequence("f_gothdance"))

          	fp_enb = true
          	EmoteCamera = true
           	timer.Remove("fp_enb")
          	timer.Create("fp_enb",time,1,function()
       			EmoteCamera = false
          	 	fp_enb = false
          	end)
		end,
	},
	[9] = {
		name = "Танец 5",
		func = function()
			netstream.Start("dbt/change/sq/anim", "f_boogie_down", false)
    		local time = LocalPlayer():SequenceDuration(LocalPlayer():LookupSequence("f_boogie_down"))
          	fp_enb = true
          	EmoteCamera = true
           	timer.Remove("fp_enb")
		end,
	},
	[10] = {
		name = "Танец пришельца",
		func = function()
			netstream.Start("dbt/change/sq/anim", "f_the_alien", true)

    		local time = LocalPlayer():SequenceDuration(LocalPlayer():LookupSequence("f_the_alien"))

          	fp_enb = true
          	EmoteCamera = true
           	timer.Remove("fp_enb")
          	timer.Create("fp_enb",time,1,function()
       			EmoteCamera = false
          	 	fp_enb = false
          	end)
		end,
	},
	[11] = {
		name = "Упражнение",
		func = function()
			netstream.Start("dbt/change/sq/anim", "f_jumpingjack", true)

    		local time = LocalPlayer():SequenceDuration(LocalPlayer():LookupSequence("f_jumpingjack"))

          	fp_enb = true
          	EmoteCamera = true
           	timer.Remove("fp_enb")
          	timer.Create("fp_enb",time,1,function()
       			EmoteCamera = false
          	 	fp_enb = false
          	end)
		end,
	},
}

local r, x, y = weight_source(300), ScreenWidth / 2, ScreenHeight / 2
local ply = LocalPlayer()
GlobalOptions = {
	[1] = {
		name = "Выбрать стойку",
		mat = Material("taunts/taunt2.png"),
		func = function()
			NewWheel(PoseTable)
		end,
	},
	[2] = {
		name = "Проиграть анимацию",
		mat = Material("taunts/taunt5.png"),
		func = function()
			NewWheel(AnimationsTable)
		end,
	},
	[3] = {
		name = "Бросить кубики",
		mat = http.Material("https://imgur.com/BKts6VJ.png"),
		func = function() RunConsoleCommand("say", "/roll") end,
	},
	[4] = {
		name = "Эмоции",
		mat = http.Material("https://imgur.com/0lkrRY8.png"),
		func = function()
			local EmoteList = {}
			id = 1
			EmoteList[id] = {
				name = "Назад",
				custom_size = weight_source(80),
				mat = http.Material("https://imgur.com/lszTmGe.png"),
				func = function() NewWheel(GlobalOptions) ShowEmotions = false  end
			}
			id = id + 1
			
			if facialEmote.face.data[LocalPlayer():GetModel()] then
				ShowEmotions = true
				model:SetModel(LocalPlayer():GetModel())
				for k, i in pairs(LocalPlayer():GetBodyGroups()) do 
					model:SetBodygroup(i.id, i.num)
				end
				local dance = model:LookupSequence("idle_all_01")
				model:SetSequence(dance)
				for k, v in pairs ( facialEmote.face.data[LocalPlayer():GetModel()] ) do
					EmoteList[id] = {
						data = v,
						name = v.name,
						mat = facialEmote.interface.emojis[v.image],
						index = k,
						func = function() CurrentEmote = v.name CurrentEmoteImg = facialEmote.interface.emojis[v.image] facialEmote.network.sendCommand( "applyEmotion", k ) ShowEmotions = false end
					}

					id = id + 1
				end
				NewWheel(EmoteList)
			else
				TipsText = "У персонажа нет эмоций!"
				TipsTime = CurTime() + 2
			end
		end,
	},
	[5] = {
	   name = "Отредактировать модель",
	   mat = http.Material("https://imgur.com/h9xNHpF.png"),
	   func = function() ChangeBodygroupsModel() end,
   },
	--[[
   [6] = {
	  name = "Упасть",
	  mat = http.Material("https://imgur.com/Fuho1GT.png"),
	  func = function() if CDRag > CurTime() then return end netstream.Start("RagdollPlayer", ply) CDRag = CurTime() + 2 end,
  },]]
}
CDRag = CurTime()
local background = circles.New(CIRCLE_OUTLINED, r, x, y, weight_source(150))
background:SetMaterial(true)
background:SetColor(Color(0,0,0,250))


local background2 = circles.New(CIRCLE_FILLED, weight_source(140), x, y, weight_source(100))
background2:SetMaterial(true)
background2:SetColor(Color(100,100,100,100))


local wedge = circles.New(CIRCLE_OUTLINED, r + 5, x, y, weight_source(210))
wedge:SetColor(Color(240, 225, 162, 255) )

local function FindSelected(x, y, segment_size)
	local mouse_pos = Vector(input.GetCursorPos())
	mouse_pos:Sub(Vector(x, y, 0))

	local mouse_ang = math.atan2(mouse_pos[2], mouse_pos[1]) * 180 / math.pi

	if mouse_ang < 0 then
		mouse_ang = 360 + mouse_ang
	end

	return math.floor(mouse_ang / segment_size)
end
CurrentEmote = ""
CurrentEmoteImg = false
NextClick = 0
local glow = http.Material("https://imgur.com/pymHUlA.png")
function NewWheel(opt)
	local options = opt
	background:SetRadius(450)
	dbt_emote.wheel = vgui.Create( "Panel" )
	dbt_emote.wheel:SetPos( 0, 0 )
	dbt_emote.wheel:SetSize( ScrW(), ScrH() )
	dbt_emote.wheel:MakePopup()
	dbt_emote.wheel:SetKeyboardInputEnabled(false)
	local segment_size = 360 / #options

	Wedge = circles.New(CIRCLE_OUTLINED, r + 5, x, y, weight_source(10))
	Wedge:SetColor(Color(240, 225, 162, 255) )
	Wedge:SetEndAngle(segment_size)
	Wedge2 = circles.New(CIRCLE_OUTLINED, r - 145, x, y, weight_source(10))
	Wedge2:SetColor(Color(240, 225, 162, 255) )
	Wedge2:SetEndAngle(segment_size)

	RotationWheel = 0
	dbt_emote.wheel.Paint = function( self, w, h )
		local selected = FindSelected(x, y, segment_size)
		if selected != LastSelected then PlayUiSound( "ui/ui_hovered.wav", 0.3) end
		if LastSelected == (#options - 1) and selected == 0 then
			RotationWheel = segment_size * -1
		end
		if LastSelected == 0 and selected == (#options - 1) then
			RotationWheel = segment_size * #options
		end

		if input.IsMouseDown( MOUSE_FIRST) and NextClick < CurTime() then dbt_emote.wheel:Remove() NextClick = CurTime() + 0.2 PlayUiSound("ui/ui_return.wav", 0.7)  options[selected + 1].func() end

		background:SetRadius(weight_source(400 - 100))


		RotationWheel = Lerp(FrameTime() * 10, RotationWheel, selected * segment_size)
		Wedge:SetRotation(RotationWheel)
		Wedge2:SetRotation(RotationWheel)
		Wedge()
		Wedge2()

		background()
		background2()



		for i = 0, #options - 1 do
			local option = options[i + 1]
			local a = math.rad(segment_size * i + segment_size / 2)

			if selected == i then
				if option.data then applyEmotin(model, option.data) end
				if option.data and CurrentEmoteImg then
					draw.SimpleText(
						option.name, "TL X40", ScreenWidth / 2, ScreenHeight / 2 - hight_source(20),
						color_white,
						TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
					)

					draw.SimpleText(
						CurrentEmote, "TL X40", ScreenWidth / 2, ScreenHeight / 2 + hight_source(20),
						Color(143, 37, 156, 255),
						TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
					)

					surface.SetDrawColor( 255, 255, 255, 255 ) -- Set the drawing color
					surface.SetMaterial( CurrentEmoteImg ) -- Use our cached material
					surface.DrawTexturedRectRotated( ScreenWidth / 2, ScreenHeight / 2 + hight_source(90), weight_source(60), weight_source(60), 0 )

									if option.mat then
					if option.mat.material then
						surface.SetDrawColor( 255, 255, 255, 255 )
						local size = option.custom_size or weight_source(120)
						option.mat:DrawR(ScreenWidth / 2, ScreenHeight / 2 - hight_source(90), weight_source(60), weight_source(60), 0)
					else
						surface.SetDrawColor( 255, 255, 255, 255 ) -- Set the drawing color
						surface.SetMaterial( option.mat ) -- Use our cached material
						surface.DrawTexturedRectRotated( ScreenWidth / 2, ScreenHeight / 2 - hight_source(90), weight_source(60), weight_source(60), 0 )
					end
				end


				else
					draw.SimpleText(
						option.name, "TL X40", ScreenWidth / 2, ScreenHeight / 2,
						color_white,
						TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
					)

				end

			end

			local x = x + math.cos(a) * ( background:GetRadius() * 0.75)
			local y = y + math.sin(a) * ( background:GetRadius() * 0.75)

			if option.mat then
				if option.mat.material then
					surface.SetDrawColor( 255, 255, 255, 255 )
					local size = option.custom_size or weight_source(120)
					if selected == i then
						option.mat:DrawR(x, y, size + 10, size + 10, 0)
					else
						option.mat:DrawR(x, y, size, size, 0)
					end
				else

					surface.SetDrawColor( 255, 255, 255, 255 ) -- Set the drawing color
					surface.SetMaterial( option.mat ) -- Use our cached material
					if selected == i then
						surface.DrawTexturedRectRotated( x, y, weight_source(120), weight_source(120), 0 )
					else
						surface.DrawTexturedRectRotated( x, y, weight_source(110), weight_source(110), 0 )
					end
				end
			else
				draw.SimpleText(
					option.name, "DermaLarge", x, y,
					color_white,
					TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
				)
			end

		end
		LastSelected = selected
	end
	dbt_emote.wheel.Think = function( self )
		if not input.IsButtonDown( KEY_F ) and not input.IsButtonDown( KEY_E ) then
			self:Remove()
			ShowEmotions = false
		end
	end
end


--[[
hook.Add( "PlayerButtonDown", "dbt.Emote.Wheel", function( ply, button )
	if ( IsFirstTimePredicted() and 16 == button and not IsValid(dbt_emote.wheel) and not IsClassTrial() and not IsValid(FUCKFRMAE)) then
		if spectator.IsSpectator(talker) then return end
       	EmoteCamera = false
        fp_enb = false
         netstream.Start("dbt/change/sq/anim", "idle_layer", true)

		 if ply:Pers() == "Токо Фукава" then
			 GlobalOptions[7] = {
		 		name = "Сменить модель",
		 		mat = materialtoko,
		 		func = function() netstream.Start("CharChangeModel", ply) end,
		 	}
		else
			GlobalOptions[7] = nil
		end

		NewWheel(GlobalOptions)
	end 
end)]]

function PlayUiSound(file, vol)
	sound.Play( file, LocalPlayer():GetPos(), 90, 100, vol or 0.2)
end

