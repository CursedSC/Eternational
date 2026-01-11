ITEMS_TEX = {}
ITEMS_TEX.main_tex = Material( "dos/items/Tex_0134.png", "smooth" )
ITEMS_TEX.text_item = GWEN.CreateTextureNormal( 0, 0, 63, 63, ITEMS_TEX.main_tex )

ITEMS_TEX.items = {}
 
for x = 0, 2048 - 63, 64 do  
    for y = 0, 2048 - 63, 64 do 
        ITEMS_TEX.items[#ITEMS_TEX.items + 1] = GWEN.CreateTextureNormal( x, y, 63, 63, ITEMS_TEX.main_tex )
    end
end
--Tex_0135
ITEMS_TEX.main_tex2 = Material( "dos/items/Tex_0135.png", "smooth" )
for x = 0, 1024 - 63, 64 do 
    for y = 0, 1024 - 63, 64 do 
        ITEMS_TEX.items[#ITEMS_TEX.items + 1] = GWEN.CreateTextureNormal( x, y, 63, 63, ITEMS_TEX.main_tex2 )
    end
end

ITEMS_TEX.main_tex3 = Material( "dos/items/Tex_0106.png", "smooth" )
for x = 0, 2048 - 63, 64 do 
    for y = 0, 2048 - 63, 64 do 
        ITEMS_TEX.items[#ITEMS_TEX.items + 1] = GWEN.CreateTextureNormal( x, y, 63, 63, ITEMS_TEX.main_tex3 )
    end
end
ITEMS_TEX.main_tex4 = Material( "dos/items/RPG-Swordsman-Skill-Icons2.png", "smooth" )
for x = 73, 1730, 166 do 
    for y = 75, 1125, 225 do 
        ITEMS_TEX.items[#ITEMS_TEX.items + 1] = GWEN.CreateTextureNormal( x, y, 163, 163, ITEMS_TEX.main_tex4 )
    end
end

ITEMS_TEX.main_tex5 = Material( "dos/items/talentsAndAbilities.png", "smooth" )
for x = 0, 1152 - 128, 128 do 
    for y = 0, 1152 - 128, 128 do 
        ITEMS_TEX.items[#ITEMS_TEX.items + 1] = GWEN.CreateTextureNormal( y, x, 128, 128, ITEMS_TEX.main_tex5 )
    end
end

ITEMS_TEX.main_tex6 = Material( "dos/items/Tex_0142.png", "smooth" )
for x = 0, 1216 - 63, 64 do 
    for y = 0, 2048 - 63, 64 do  
        ITEMS_TEX.items[#ITEMS_TEX.items + 1] = GWEN.CreateTextureNormal( y, x, 63, 63, ITEMS_TEX.main_tex6 )
    end
end

local function addTextures(main_tex_path, width, height, step_x, step_y, start_x, start_y, end_x, end_y)
    local main_tex = Material(main_tex_path, "smooth")
    for y = start_y or 0, end_y or (2048 - height), step_y do
            for x = start_x or 0, end_x or (2048 - width), step_x do
            table.insert(ITEMS_TEX.items, GWEN.CreateTextureNormal(x, y, width, height, main_tex))
        end
    end
end

addTextures("Icons_Items.png", 64, 64, 64, 64, 0, 0, 2048 - 64, 2048 - 64)
addTextures("Icons_Items_2.png", 64, 64, 64, 64, 0, 0, 2048 - 64, 2048 - 64)
addTextures("Icons_Items_3.png", 64, 64, 64, 64, 0, 0, 1024 - 64, 1024 - 64)
addTextures("Icons_Items_4.png", 64, 64, 64, 64, 0, 0, 512 - 64, 512 - 64)
addTextures("Icons_Items_5.png", 64, 64, 64, 64, 0, 0, 1024 - 64, 1024 - 64)

print(#ITEMS_TEX.items)
concommand.Add("ShowItems", function()
    local Frame = vgui.Create( "DFrame" ) -- Create a Frame to contain everything.
    Frame:SetTitle( "DIconLayout Example" )
    Frame:SetSize( ScrW() * 0.5, ScrH() * 0.5 )
    Frame:Center()
    Frame:MakePopup()

    local Scroll = vgui.Create( "DScrollPanel", Frame ) -- Create the Scroll panel
    Scroll:Dock( FILL )

    local List = vgui.Create( "DIconLayout", Scroll )
    List:Dock( FILL )
    List:SetSpaceY( 5 ) -- Sets the space in between the panels on the Y Axis by 5
    List:SetSpaceX( 5 ) -- Sets the space in between the panels on the X Axis by 5

    for i = 1, #ITEMS_TEX.items do -- Make a loop to create a bunch of panels inside of the DIconLayout
        local ListItem = List:Add( "DButton" ) 
        ListItem:SetSize( 60, 60 ) 
        ListItem:SetText( "" )
        ListItem.Paint = function(self, w, h)
            ITEMS_TEX.items[i](0,0,w,h)
            draw.DrawText( i, "DermaDefaultBold", 0, h * 0.6, color_white, TEXT_ALIGN_LEFT )
        end
        ListItem.DoClick = function()
            SetClipboardText( i )
        end
    end

end)