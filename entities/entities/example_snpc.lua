AddCSLuaFile()

ENT.Base = "base_snpc"

ENT.PrintName = "Массовка"
ENT.Author = "Demit"
ENT.Category = "Dev"

ENT.Spawnable 	= true
ENT.AdminOnly 	= true

ENT.Model = "models/player/kleiner.mdl"
ENT.Sequence = "idle_all_02"

--
if CLIENT then
	function ENT:OnUse()
		if not LocalPlayer():IsAdmin() then return end
		local data = self:GetBodyGroups()

		local body = {}

		local tr = util.TraceLine( util.GetPlayerTrace( LocalPlayer() ) )

		enttt = tr.Entity

		for i = 1, #data do 
			body[i] = {
				id = data[i].id,
				num = self:GetBodygroup( data[i].id )
			}
		end

		local DFrame = vgui.Create( "DFrame" ) 	-- The name of the panel we don't have to parent it.
		DFrame:SetPos( 100, 100 ) 				-- Set the position to 100x by 100y. 
		DFrame:SetSize( 500, 400 ) 				-- Set the size to 300x by 200y.
		DFrame:SetTitle( "Настрйока НПС" ) 		-- Set the title in the top left to "Derma Frame".
		DFrame:MakePopup() 	
		y = 30
		sliders = {}
		for i = 1, #data do 
			local sliders = vgui.Create( "DNumSlider", DFrame )
			sliders:SetPos( 50, y )				
			sliders:SetSize( 300, 20 )			
			sliders:SetText( data[i].name )	
			sliders:SetMin( 0 )				 	
			sliders:SetMax( data[i].num )	
			sliders:SetDecimals( 0 )	
			sliders:SetValue(self:GetBodygroup( data[i].id ))					

			sliders.OnValueChanged = function( self, value )
				body[i] = {
					id = body[i].id,
					num = math.Round( value )
				}
				net.Start("SetBGNPC")
					net.WriteTable(body)
					net.WriteEntity(enttt)
				net.SendToServer()
			end
			y = y + 30
		end

		local DermaButton = vgui.Create( "DButton", DFrame ) 
		DermaButton:SetText( "PERMA SAVE" )					
		DermaButton:SetPos( 360, 30 )				
		DermaButton:SetSize( 90, 30 )					
		DermaButton.DoClick = function()				
			net.Start("SaveNPC")
				net.WriteEntity(enttt)
			net.SendToServer()
		end

		local TextEntry = vgui.Create( "DTextEntry", DFrame ) -- create the form as a child of frame
		TextEntry:SetPos( 50, y )				
		TextEntry:SetSize( 300, 20 )
		TextEntry:SetPlaceholderText( "Анимация" )
		TextEntry.OnEnter = function( self )
			net.Start("SetSQNPC")
				net.WriteString(self:GetValue())
				net.WriteEntity(enttt)
			net.SendToServer()
		end

		local DermaButton = vgui.Create( "DButton", DFrame ) 
		DermaButton:SetText( "+" )					
		DermaButton:SetPos( 360, y )				
		DermaButton:SetSize( 20, 20 )					
		DermaButton.DoClick = function()				
			local menu = DermaMenu() 
			menu:AddOption( "Сидя", function() net.Start("SetSQNPC") net.WriteString("sit") net.WriteEntity(enttt) net.SendToServer() end )
			menu:AddOption( "Стоя 1", function() net.Start("SetSQNPC") net.WriteString("idle_all_01") net.WriteEntity(enttt) net.SendToServer() end )
			menu:AddOption( "Стоя 2", function() net.Start("SetSQNPC") net.WriteString("idle_all_02") net.WriteEntity(enttt) net.SendToServer() end )
			menu:Open()		
		end


		y = y + 30

		local TextEntry = vgui.Create( "DTextEntry", DFrame ) -- create the form as a child of frame
		TextEntry:SetPos( 50, y )				
		TextEntry:SetSize( 300, 20 )
		TextEntry:SetPlaceholderText( "Модель" )
		TextEntry.OnEnter = function( self )
			net.Start("SetMDLNPC")
				net.WriteString(self:GetValue())
				net.WriteEntity(enttt)
			net.SendToServer()
		end

		y = y + 30

		local TextEntry = vgui.Create( "DTextEntry", DFrame ) -- create the form as a child of frame
		TextEntry:SetPos( 50, y )				
		TextEntry:SetSize( 300, 20 )
		TextEntry:SetPlaceholderText( "Имя" )
		TextEntry.OnEnter = function( self )
			net.Start("SetNAMENPC")
				net.WriteString(self:GetValue())
				net.WriteEntity(enttt)
			net.SendToServer()
		end

		y = y + 30

		local TextEntry = vgui.Create( "DTextEntry", DFrame ) -- create the form as a child of frame
		TextEntry:SetPos( 50, y )				
		TextEntry:SetSize( 300, 20 )
		TextEntry:SetPlaceholderText( "Работа" )
		TextEntry.OnEnter = function( self )
			net.Start("SetJOBNPC")
				net.WriteString(self:GetValue())
				net.WriteEntity(enttt)
			net.SendToServer()
		end

		y = y + 30

		DFrame:SetSize( 500, y )

	end
end

if SERVER then 
	util.AddNetworkString("SetBGNPC")
	util.AddNetworkString("SetSQNPC")
	util.AddNetworkString("SetMDLNPC")
	util.AddNetworkString("SetNAMENPC")
	util.AddNetworkString("SetJOBNPC")
	util.AddNetworkString("SaveNPC")

	net.Receive("SetBGNPC", function()
		local bg_data = net.ReadTable()
		local ent = net.ReadEntity()

		for i = 1, #bg_data do 
			ent:SetBodygroup(bg_data[i].id, bg_data[i].num)
		end	

		ent.bg = bg_data
	end)
	net.Receive("SetSQNPC", function()
		local anim = net.ReadString()
		local ent = net.ReadEntity()

		ent:RunAnimation(anim)
		ent.anim = anim
	end)
	net.Receive("SetMDLNPC", function()
		local mdl = net.ReadString()
		local ent = net.ReadEntity()

		ent:SetModel(mdl)
		ent.mdl = mdl
		ent:RunAnimation(ent.anim)
	end)
	net.Receive("SetNAMENPC", function()
		local str = net.ReadString()
		local ent = net.ReadEntity()

		ent:SetNWString("Name", str)
	end)
	net.Receive("SetJOBNPC", function()
		local str = net.ReadString()
		local ent = net.ReadEntity()

		ent:SetNWString("Job", str)
	end)

	net.Receive("SaveNPC", function()
		local ent = net.ReadEntity()

		SaveBGNPC(ent) 
	end)

	function SaveBGNPC(ent) 
		local f = file.Read( "npc_table.json", "DATA")
		local tbl = util.JSONToTable(f)
		if tbl == nil then tbl = {} end

		tbl[ent.seed] = {
			bg = ent.bg,
			anim = ent.anim,
			model = ent:GetModel(), 
			name = ent:GetNWString("Name"),
			job = ent:GetNWString("Job"),
			ft = {
				pos = ent:GetPos(),
				ang = ent:GetAngles(),	
			}
		}


		local data = util.TableToJSON(tbl)

		file.Write( "npc_table.json", data) 

	end


	function LoadBGNPC() 
		local f = file.Read( "npc_table.json", "DATA")
		local tbl = util.JSONToTable(f)
		if tbl == nil then return end

		for i, k in pairs( tbl ) do
			local ent = k
			local nps = ents.Create( "example_snpc" )
			nps:SetModel( ent.model )
			nps:SetPos( ent.ft.pos )
			nps:SetAngles( ent.ft.ang )
			nps:Spawn()

			nps:SetNWString("Job", ent.job)
			nps:SetNWString("Name", ent.name)

			for i = 1, #ent.bg do 
				nps:SetBodygroup(ent.bg[i].id, ent.bg[i].num)
			end		
			nps.bg = ent.bg	

			nps:RunAnimation(ent.anim)
			nps.anim = ent.anim

			nps:SetModel(ent.model)
			nps.mdl = ent.mdl
			nps:RunAnimation(ent.anim)

			nps.seed = i
		end
	end

	concommand.Add("LoadAllNPC", LoadBGNPC)

end