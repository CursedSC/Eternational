HINTS = {}
HINTS.msg = {}
HINTS.print = function( text, col, tags, time )
	local debugMsg = { 
		text = tostring( text ),
		col = col,
		bornTime = CurTime(),
		expireTime = ( time or 10 )
	}
		
	debugMsg.tags = tags
	--surface.PlaySound( "facial_emote/debug.wav" )	
	table.insert( HINTS.msg, debugMsg )
end

 
 
HINTS.DrawOverlay = function()
	local yPos = ScrH() - 35
	for k , v in pairs ( HINTS.msg ) do
		surface.SetFont( "DermaDefaultBold" )
		local w = surface.GetTextSize( v.text )
		local sizeW = math.Clamp( w + 35, 100, 2000 )
		if v.tags.type == "item" then  
			sizeW = sizeW + 10
		end
		surface.SetDrawColor( 0, 0, 0, 200 )
		surface.DrawRect( 5, yPos, sizeW, 30 )

		if v.tags.type == "item" then 
			if ( v.col ) then
				ITEMS_TEX.items[itemList[v.tags.id].Icon](7, yPos + 2, 21, 21)
				draw.SimpleText( v.text, "DermaDefaultBold", 33, yPos + 12, color_white, 0, 1 )
			else
				draw.SimpleText( v.text, "DermaDefaultBold", 20, yPos + 12, color_white, 0, 1 )
			end
		elseif v.tags.type == "custom" then 
			if ( v.col ) then
				ITEMS_TEX.items[v.tags.id](7, yPos + 2, 21, 21)
				draw.SimpleText( v.text, "DermaDefaultBold", 33, yPos + 12, color_white, 0, 1 )
			else
				draw.SimpleText( v.text, "DermaDefaultBold", 20, yPos + 12, color_white, 0, 1 )
			end
		else 
			if ( v.col ) then
				surface.SetDrawColor( v.col )
				surface.DrawRect( 7, yPos + 2, 10, 21 )
				draw.SimpleText( v.text, "DermaDefaultBold", 23, yPos + 12, color_white, 0, 1 )
			else
				draw.SimpleText( v.text, "DermaDefaultBold", 10, yPos + 12, color_white, 0, 1 )
			end
		end
		
		local timeAlive = CurTime() - v.bornTime 
		local timeLeftRatio = ( v.expireTime - timeAlive )/v.expireTime
	
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect( 5, yPos+25, sizeW, 5 )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawRect( 5, yPos+25, sizeW * timeLeftRatio, 5 )
		
		surface.SetDrawColor( Color( 115, 115, 115, 255 ) ) 
		surface.DrawOutlinedRect( 5, yPos, sizeW, 30 )
		
		if ( timeAlive > v.expireTime ) then
			HINTS.msg[k] = nil
		end
		 
		yPos = yPos - 32
	end
end

hook.Add("HUDPaint", "HINTS.DrawOverlay", HINTS.DrawOverlay)

local character_img = Material("dos/ui/Tex_0101.png", "smooth")
local character_img_bg = Material("dos/ui/Tex_0075.png", "smooth")
local character_img_bg_shadow = Material("dos/ui/Tex_0076.png", "smooth")

function ReqIntValue( strTitle, max, fnEnter )

	local Window = vgui.Create( "DFrame" )
	Window:SetTitle( "" )
	Window:SetDraggable( false )
	Window:ShowCloseButton( false )
	Window:SetBackgroundBlur( true )
	Window:SetDrawOnTop( true )
	Window.Paint = function(self, w, h)
		surface.SetDrawColor( 255, 255, 255, 255 ) 
	    surface.SetMaterial( character_img_bg )  
	    surface.DrawTexturedRect( 0,0,w, h * 2 ) 	

	    draw.DrawText( strTitle, "Barkentina X24", w * 0.5, h * 0.05, color_black, TEXT_ALIGN_CENTER )

	end

	local InnerPanel = vgui.Create( "DPanel", Window )
	InnerPanel:SetPaintBackground( false )

	local Text = vgui.Create( "DLabel", InnerPanel )
	Text:SetText( "Message Text (Second Parameter)" )
	Text:SizeToContents()
	Text:SetContentAlignment( 5 )
	Text:SetTextColor( color_white )

	local TextEntry = vgui.Create( "DNumSlider", InnerPanel )
	TextEntry:SetText( "" )
 	TextEntry:SetMin( 1)				 	
	TextEntry:SetMax( max or 1 )				
	TextEntry:SetDecimals( 0 )	
	TextEntry:SetValue(1)

	local ButtonPanel = vgui.Create( "DPanel", Window )
	ButtonPanel:SetTall( 30 )
	ButtonPanel:SetPaintBackground( false )

	local Button = vgui.Create( "DButton", ButtonPanel )
	Button:SetText( "OK" )
	Button:SizeToContents()
	Button:SetTall( 20 )
	Button:SetWide( Button:GetWide() + 20 )
	Button:SetPos( 5, 5 )
	Button.DoClick = function() Window:Close() fnEnter( math.Round(TextEntry:GetValue()) ) end

	local ButtonCancel = vgui.Create( "DButton", ButtonPanel )
	ButtonCancel:SetText( "Отмена" )
	ButtonCancel:SizeToContents()
	ButtonCancel:SetTall( 20 )
	ButtonCancel:SetWide( Button:GetWide() + 20 )
	ButtonCancel:SetPos( 5, 5 )
	ButtonCancel.DoClick = function() Window:Close() if ( fnCancel ) then fnCancel( TextEntry:GetValue() ) end end
	ButtonCancel:MoveRightOf( Button, 5 )

	ButtonPanel:SetWide( Button:GetWide() + 5 + ButtonCancel:GetWide() + 10 )

	local w, h = Text:GetSize()
	w = math.max( w, 400 )

	Window:SetSize( w + 50, h + 25 + 75 + 10 )
	Window:Center()

	InnerPanel:StretchToParent( 5, 25, 5, 45 )

	Text:StretchToParent( 5, 5, 5, 35 )
	Text:Remove()

	TextEntry:StretchToParent( 5, nil, 5, nil )
	TextEntry:AlignBottom( 5 )

	TextEntry:RequestFocus()
	TextEntry:SelectAllText( true )

	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom( 8 )

	Window:MakePopup()
	Window:DoModal()

	return Window

end
