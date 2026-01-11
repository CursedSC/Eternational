dbt = {}
net.Receive("Chat_say", function(len,ply)
    local data = net.ReadString()
    local playerr = net.ReadEntity()

    dbt:AddPlayerSay(playerr, {COLOR_WHITE_DEM, data}, " говорит:")

   -- local color = dbt.chr[playerr:Pers()].color or Color( 89, 255, 6)
    --chat.AddText(color, dbt.chr[playerr:Pers()].name.. ' говорит: ' ,Color( 255, 255, 255), '"'..data..'"')
end)

net.Receive("rp.Chat.Command", function(len,ply)
    RP.chat.commands[net.ReadString()].client()
end)


if SERVER then
    AddCSLuaFile()
    return
end
CHAT_dbt = {}
function surface.DrawMulticolorText(x, y, font, text, maxW)
    surface.SetTextColor(255, 255, 255)
    surface.SetFont(font)
    surface.SetTextPos(x, y)
    local baseX = x
    local w, h = surface.GetTextSize("W")
    local lineHeight = h

    if maxW and x > 0 then
        maxW = maxW + x
    end

    for _, v in ipairs(text) do
        if isstring(v) then
            w, h = surface.GetTextSize(v)

            if maxW and x + w > maxW then
                v:gsub("(%s?[%S]+)", function(word)
                    w, h = surface.GetTextSize(word)

                    if x + w >= maxW then
                        x, y = baseX, y + lineHeight
                        word = word:gsub("^%s+", "")
                        w, h = surface.GetTextSize(word)

                        if x + w >= maxW then
                            word:gsub("[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]*", function(char)
                                w, h = surface.GetTextSize(char)

                                if x + w >= maxW then
                                    x, y = baseX, y + lineHeight
                                end

                                surface.SetTextPos(x, y)
                                surface.DrawText(char)

                                x = x + w
                            end)

                            return
                        end
                    end

                    surface.SetTextPos(x, y)
                    surface.DrawText(word)

                    x = x + w
                end)
            else
                surface.SetTextPos(x, y)
                surface.DrawText(v)

                x = x + w
            end
        elseif isbool(v) then 
            x, y = baseX, y + lineHeight
        else
            surface.SetTextColor(v.r, v.g, v.b, v.a)
        end
    end

    return x, y
end
local ScreenWidth = ScreenWidth or ScrW()
local ScreenHeight = ScreenHeight or ScrH()

function weight_source(x)
    return ScreenWidth / 1920  * x
end
function hight_source(x)
    return ScreenHeight / 1080  * x
end

local function Alpha(pr)
    return (255 / 100) * pr
end

CHAT_dbt = CHAT_dbt or {}

CHAT_dbt.config = {
    timeStamps = true,
    position = 1,
    fadeTime = 12,
}

surface.CreateFont( "CHAT_dbt_18", {
    font = "Roboto Lt",
    size = 18,
    extended = true,
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

surface.CreateFont( "CHAT_dbt_16", {
    font = "Roboto Lt",
    size = 16,
    extended = true,
    weight = 500,
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
 
function CHAT_dbt.hideBox()
netstream.Start("dbt/chat/bool", false)
    CHAT_dbt.frame.Paint = function() end
    CHAT_dbt.chatLog.Paint = function() end

    CHAT_dbt.chatLog:SetVerticalScrollbarEnabled( false )
    CHAT_dbt.chatLog:GotoTextEnd()

    CHAT_dbt.lastMessage = CHAT_dbt.lastMessage or CurTime() - CHAT_dbt.config.fadeTime

    local children = CHAT_dbt.frame:GetChildren()
    for _, pnl in pairs( children ) do
        if pnl == CHAT_dbt.frame.btnMaxim or pnl == CHAT_dbt.frame.btnClose or pnl == CHAT_dbt.frame.btnMinim then continue end

        if pnl != CHAT_dbt.chatLog then
            pnl:SetVisible( false )
        end
    end

    CHAT_dbt.frame:SetMouseInputEnabled( false )
    CHAT_dbt.frame:SetKeyboardInputEnabled( false )
    gui.EnableScreenClicker( false )

    gamemode.Call("FinishChat")


    CHAT_dbt.entry:SetText( "" )
    gamemode.Call( "ChatTextChanged", "" )
end

function CHAT_dbt.showBox()
    netstream.Start("dbt/chat/bool", true)

    CHAT_dbt.frame.Paint = CHAT_dbt.oldPaint
    CHAT_dbt.chatLog.Paint = CHAT_dbt.oldPaint2

    CHAT_dbt.chatLog:SetVerticalScrollbarEnabled( true )
    CHAT_dbt.lastMessage = nil

 
    local children = CHAT_dbt.frame:GetChildren()
    for _, pnl in pairs( children ) do
        if pnl == CHAT_dbt.frame.btnMaxim or pnl == CHAT_dbt.frame.btnClose or pnl == CHAT_dbt.frame.btnMinim then continue end

        pnl:SetVisible( true )
    end

    -- MakePopup calls the input functions so we don't need to call those
    CHAT_dbt.frame:MakePopup()
    CHAT_dbt.entry:RequestFocus()

    -- Make sure other addons know we are chatting
    gamemode.Call("StartChat")
end


local blur = Material( "pp/blurscreen" )
function CHAT_dbt.blur( panel, layers, density, alpha )
    local x, y = panel:LocalToScreen(0, 0)

    surface.SetDrawColor( 255, 255, 255, alpha )
    surface.SetMaterial( blur )

    for i = 1, 3 do
        blur:SetFloat( "$blur", ( i / layers ) * density )
        blur:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
    end
end

local oldAddText = chat.AddText

hook.Remove( "ChatText", "CHAT_dbt_joinleave")
hook.Add( "ChatText", "CHAT_dbt_joinleave", function( index, name, text, type )
    --if type != "chat" then
     --   CHAT_dbt.chatLog:InsertColorChange( 0, 128, 255, 255 )
    --    CHAT_dbt.chatLog:AppendText( "\n"..text )
    --    CHAT_dbt.chatLog:SetVisible( true )
    --    CHAT_dbt.lastMessage = CurTime()
   --     return true
   -- end
end)

hook.Remove("PlayerBindPress", "CHAT_dbt_hijackbind")
hook.Add("PlayerBindPress", "CHAT_dbt_hijackbind", function(ply, bind, pressed)
    if string.sub( bind, 1, 11 ) == "messagemode" then
        CHAT_dbt.showBox()
        return true
    end
end)

hook.Remove("HUDShouldDraw", "CHAT_dbt_hidedefault")
hook.Add("HUDShouldDraw", "CHAT_dbt_hidedefault", function( name )
    if name == "CHudChat" then
        return false
    end
end)

local oldGetChatBoxPos = chat.GetChatBoxPos
function chat.GetChatBoxPos()
    return CHAT_dbt.frame:GetPos()
end

function chat.GetChatBoxSize()
    return CHAT_dbt.frame:GetSize()
end

chat.Open = CHAT_dbt.showBox
function chat.Close(...)
    if IsValid( CHAT_dbt.frame ) then
        CHAT_dbt.hideBox(...)
    else
        CHAT_dbt.buildBox()
        CHAT_dbt.showBox()
    end
end


local sampletext = [[
Объем текста в качестве жанрообразующего признака ни в одной из работ не упоминается. При этом подразумевается, что некоторые жанры (очерк, специальный репортаж, журналистское расследование) предполагают скорее объемные тексты, нежели короткие. Объем текста традиционно считается производным от количества и качества собранной журналистом информации с учетом формата издания и принятых в нем размеров материалов.
]]

function SetDragLimit(vgui_panel)
    local old_think = vgui_panel.Think
    function vgui_panel:Think()
        old_think(self)

        local mousex = math.Clamp( gui.MouseX(), 1, ScrW()-1 )
        local mousey = math.Clamp( gui.MouseY(), 1, ScrH()-1 )

        if (self.Dragging) then
            local x = mousex -self.Dragging[1]
            local y = mousey -self.Dragging[2]

            x = math.Clamp(x, 0, ScrW() -self:GetWide())
            y = math.Clamp(y, 0, ScrH() -self:GetTall())

            self:SetPos(x, y)
        end
    end



end

ChatMessege =  {}
APLHA_PERCENT = 0
APLHA_PERCENT_TO = 0
LastMessege = {}
function BuildNewChat()
    if IsValid(ChatTextFrame) then ChatTextFrame:Close() end
    ChatTextFrame = vgui.Create("DFrame")
    ChatTextFrame:SetSize( ScrW()*0.375, ScrH()*0.25 )
    ChatTextFrame:SetTitle("")
    ChatTextFrame:ShowCloseButton( false )
    ChatTextFrame:SetDraggable( true )
    ChatTextFrame:SetSizable( false )
    ChatTextFrame:SetPos( 0, 0)
    ChatTextFrame.Paint = function(self, w, h)
        --CHAT_dbt.blur( self, 10, 20, 255 )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 200 * APLHA_PERCENT ) )

        if CHAT_IS_SHOW then draw.RoundedBox( 0, 5, ScrH()*0.22-4, ScrW()*0.375-10, ScrH()*0.03, Color( 20, 20, 20, 200 * APLHA_PERCENT ) ) end
        APLHA_PERCENT = Lerp(FrameTime() * 9, APLHA_PERCENT, APLHA_PERCENT_TO)
    end
   -- ChatTextFrame:MakePopup()
SetDragLimit(ChatTextFrame)
    local DScrollPanel = vgui.Create( "DScrollPanel", ChatTextFrame )
    DScrollPanel:SetPos(5,5)
    DScrollPanel:SetSize(ScrW()*0.375+5, ScrH()*0.22 - 10)

    local sbar = DScrollPanel:GetVBar()
    function sbar:Paint(w, h)

    end
    function sbar.btnUp:Paint(w, h)

    end
    function sbar.btnDown:Paint(w, h)

    end
    function sbar.btnGrip:Paint(w, h)

    end
    ChatScroll = DScrollPanel
    y_chat = 0

    IdTextLast = #LastMessege
    ChatTextEntry = vgui.Create( "DTextEntry", ChatTextFrame )
    local TextEntry = ChatTextEntry
    TextEntry:SetPos(5, ScrH()*0.22-4)
    TextEntry:SetSize(ScrW()*0.375-10, ScrH()*0.03)
    TextEntry:SetDrawBackground(false)
    TextEntry:SetDrawLanguageID( false )
    TextEntry:SetTextColor(COLOR_WHITE_DEM)
    TextEntry:SetFont("TL X18")
    TextEntry:RequestFocus()
    TextEntry.OnKeyCodeTyped = function( self, code )
        if code == KEY_ESCAPE then
            CHAT_dbt.hideBox()
        elseif code == KEY_UP and #LastMessege > 0 then
            IdTextLast = IdTextLast - 1
            if IdTextLast < 1 then IdTextLast = 1 end
            TextEntry:SetText(LastMessege[IdTextLast])

        elseif code == KEY_DOWN and #LastMessege > 0 then
            IdTextLast = IdTextLast + 1
            if IdTextLast > #LastMessege then IdTextLast = #LastMessege end
            TextEntry:SetText(LastMessege[IdTextLast])

        elseif code == KEY_ENTER then
            if string.Trim( self:GetText() ) == "" or self:GetText() == nil then CHAT_dbt.hideBox() return end
            netstream.Start("dbt/chat/start", self:GetText())
            table.insert(LastMessege,  self:GetText())
            IdTextLast = #LastMessege + 1
            TextEntry:SetText("")
            CHAT_dbt.hideBox()
        end
    end
    TextEntry:SetCursorColor(Color(255,255,255,255))
end
color_white = Color(255,255,255,255)
COLOR_WHITE_DEM = Color(255,255,255,255)
function dbt:AddPlayerSay(ply, text, action, IsSpy, IsLooc, CustomDraw, UseSteamName, IsPM)
    ChatMessege[#ChatMessege + 1] = {
        ply = ply,
        text = text,
        IsSpy = IsSpy,
        action = action,
        IsLooc = IsLooc,
        CustomDraw = CustomDraw,
        UseSteamName = UseSteamName,
    }

    local i = ChatMessege[#ChatMessege]
    local TextPanel = vgui.Create( "DButton", ChatScroll )
    TextPanel:SetText("")
    TextPanel:SetPos(0,y_chat)
    local x, y = surface.DrawMulticolorText(weight_source(5), weight_source(15), "TL X18", i.text, 700)
    TextPanel:SetSize(ScrW()*0.375-10, y + weight_source(15))
    if IsValid(ply) then
        TextPanel.ply = ply
        local tempcolor = Color(77,0,0,21155)
        P_color = Color(tempcolor.r, tempcolor.g, tempcolor.b) or Color( 89, 255, 6)
        P_color.a = P_color.a * APLHA_PERCENT
        TextPanel.P_color = P_color
        TextPanel:SetSize(ScrW()*0.375-10, y + weight_source(30))
    end
    local ColWhite = COLOR_WHITE_DEM
    TextPanel.DoClick = function(self)
        if not IsValid(self.ply) then return end
        local menu = DermaMenu()
        menu:AddOption( "Написать личное сообщение", function()
            if not IsValid(self.ply) then return end
            ChatTextEntry:SetText('!pm "'..self.ply:Name()..'" ')
             ChatTextEntry:RequestFocus()
        end )
        if LocalPlayer():IsAdmin() then
            menu:AddOption( "Телепортироваться к игроку", function()
                if not IsValid(self.ply) then return end
               netstream.Start("telepormeto", self.ply)
            end )
        end

        menu:Open()
    end
    local steamname = i.ply and i.ply:Name()
    local rpname = i.ply and i.ply:GetName()
    TextPanel.Paint = function(self, w, h)
        ColWhite.a  = 255 * APLHA_PERCENT
        if self.P_color then self.P_color.a = 255 * APLHA_PERCENT end
        if APLHA_PERCENT_TO != 0.5 and APLHA_PERCENT_TO != 0 then
            if i.UseSteamName then
                draw.RoundedBox( 0, 0, 0, w, h, Color( self.P_color.r, self.P_color.g, self.P_color.b, 10 * APLHA_PERCENT ) )
            else
                draw.RoundedBox( 0, 0, 0, w, h, Color( 20, 20, 20, 100 * APLHA_PERCENT ) )
            end
        end
		if IsPM then ColWhite = Color(255, 0, 0, 255 * APLHA_PERCENT) end
        surface.SetFont("TL X18")
        if i.IsSpy then
            local ww, hh = surface.GetTextSize("Неизвестный")
            draw.SimpleText( "Неизвестный", "TL X18", weight_source(5), 0, self.P_color )
            draw.SimpleText( i.action, "TL X18", weight_source(5) + ww, 0, ColWhite )
            local x, y =  surface.DrawMulticolorText(weight_source(5), weight_source(20), "TL X18", i.text, 700, APLHA_PERCENT)
        elseif i.IsLooc then
            local ww, hh = surface.GetTextSize("[LOOC] "..steamname)
            draw.SimpleText( "[LOOC] "..i.ply:Name(), "TL X18", weight_source(5), 0, self.P_color )
            draw.SimpleText( i.action, "TL X18", weight_source(5) + ww, 0, ColWhite )
            local x, y =  surface.DrawMulticolorText(weight_source(5), weight_source(20), "TL X18", i.text, 700, APLHA_PERCENT)
        elseif i.CustomDraw then
            i.CustomDraw(self, w, h, i, APLHA_PERCENT)
            return
        elseif not ply then
            local x, y =  surface.DrawMulticolorText(weight_source(5), weight_source(5), "TL X18", i.text, 700, APLHA_PERCENT)
        else
            if i.UseSteamName and !IsPM then
                ww, hh = surface.GetTextSize(steamname)
                draw.SimpleText( steamname, "TL X18", weight_source(5), 0, self.P_color )
			elseif i.UseSteamName and IsPM then
				ww, hh = surface.GetTextSize(steamname)
                draw.SimpleText( steamname, "TL X18", weight_source(5), 0, self.P_color )
            else
                ww, hh = surface.GetTextSize(rpname)
                draw.SimpleText( rpname, "TL X18", weight_source(5), 0, self.P_color )
            end

            draw.SimpleText( i.action, "TL X18", weight_source(5) + ww, 0, ColWhite )
            local x, y =  surface.DrawMulticolorText(weight_source(5), weight_source(20), "TL X18", i.text, 700, APLHA_PERCENT)
        end

    end
    y_chat = y_chat + TextPanel:GetTall() + 2

    if CHAT_IS_SHOW then else
        APLHA_PERCENT_TO = 0.5
        timer.Create("FadeChat", 6, 1, function()
            if APLHA_PERCENT_TO != 1 then APLHA_PERCENT_TO = 0 end
        end)
    end
    ChatScroll:GetVBar():AnimateTo( y_chat, 0.5, 0, 0.5 )
end

function CHAT_dbt.hideBox()
    APLHA_PERCENT_TO = 0
    netstream.Start("dbt/chat/bool", false)
    CHAT_IS_SHOW = false
    ChatScroll:SetSize(ScrW()*0.375+5, ScrH()*0.25 - 10)
    ChatTextFrame:SetMouseInputEnabled( false )
    ChatTextFrame:SetKeyboardInputEnabled( false )
    ChatTextEntry:SetKeyboardInputEnabled( false )
    gui.EnableScreenClicker( false )
    gamemode.Call("FinishChat")
end

function CHAT_dbt.showBox()
    ChatScroll:GetVBar():AnimateTo( y_chat, 0.5, 0, 0.5 )
    CHAT_IS_SHOW = true
    APLHA_PERCENT_TO = 1
    netstream.Start("dbt/chat/bool", true)
    ChatScroll:SetSize(ScrW()*0.375+5, ScrH()*0.22 - 10)
    ChatTextFrame:MakePopup()
    ChatTextEntry:RequestFocus()
end

function chat.AddText(...)
    local TextTable  = {...}
    dbt:AddPlayerSay(nil, TextTable, " ", false, false, false)
end


BuildNewChat()

local function CreateRay(startPos, endPos, filter)
    local trace = {}
    trace.start = startPos 
    trace.endpos = endPos
    trace.filter = function(ent)
      if filter[1] == ent then return false end
      if filter[2] == ent then return true end
      if "func_door_rotating" == ent:GetClass() and string.StartsWith(ent:GetModel(), "*") then  return true end
      if "func_door" == ent:GetClass() and string.StartsWith(ent:GetModel(), "*") then return true end
    end
    local r = util.TraceLine(trace)
    return r
end
local poses = {}
netstream.Hook("ShowHear", function(pos)
    poses = pos
end)
local color_red = Color(255, 0, 0)
local color_red2 = Color(0, 255, 21)
hook.Add( "PostDrawTranslucentRenderables", "MySuper3DRenderingHook", function()
    for k, i in pairs(poses) do 
        render.DrawLine( i.pos1_1, i.pos1_2, i.b2 and color_red2 or color_red )
        render.DrawLine( i.pos2_1, i.pos2_2, i.b2 and color_red2 or color_red )
    end
end )