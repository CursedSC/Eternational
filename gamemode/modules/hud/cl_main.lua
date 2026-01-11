local percent2 = 0
local curprogress = 0
local percent3 = 0
print("HUD LOADED")
hook.Add("HUDPaint", "hpShow2", function()
    if HideUI then return end
    if IsValid(TestModel) then return end

    local ply = LocalPlayer()
    local hp = ply:Health()
    local hpMax = ply:GetMaxHealth()
    local percent = hp / hpMax
    
    -- Smooth trailing effect for the delayed health bar
    percent2 = Lerp(FrameTime() * 3, percent2, percent)
    
    -- Background boxes
    draw.RoundedBox(0, paintLib.WidthSource(94), paintLib.HightSource(938), paintLib.WidthSource(313), paintLib.HightSource(25), Color(0, 0, 0, 190))
    draw.RoundedBox(0, paintLib.WidthSource(98), paintLib.HightSource(935), paintLib.WidthSource(317), paintLib.HightSource(25), Color(91, 15, 7, 150))
    
    -- Trailing health bar (drawn first so it appears behind)
    draw.RoundedBox(0, paintLib.WidthSource(98), paintLib.HightSource(935), paintLib.WidthSource(317) * percent2, paintLib.HightSource(25), Color(121, 40, 31, 200))
    
    -- Main health bar
    draw.RoundedBox(0, paintLib.WidthSource(98), paintLib.HightSource(935), paintLib.WidthSource(317) * percent, paintLib.HightSource(25), Color(187, 48, 36))
    
    draw.RoundedBox(0, paintLib.WidthSource(413), paintLib.HightSource(935), paintLib.WidthSource(2), paintLib.HightSource(25), Color(151, 60, 51, 255))

    draw.SimpleText(hp .. "/" .. hpMax, "TLP X12", paintLib.WidthSource(105), paintLib.HightSource(946), Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    local mana = ply:GetMana()
    local int = ply:GetAttribute("intelligence")
    local maxSize = 100 + (int * 5) 
    local percent = math.Clamp(mana / maxSize, 0, 1)
    percent3 = Lerp(FrameTime() * 3, percent3, percent)

    draw.RoundedBox(0, paintLib.WidthSource(94), paintLib.HightSource(972), paintLib.WidthSource(295), paintLib.HightSource(18), Color(0, 0, 0, 190))
    draw.RoundedBox(0, paintLib.WidthSource(98), paintLib.HightSource(969), paintLib.WidthSource(295), paintLib.HightSource(18), Color(18, 102, 95, 150))
    
    -- Trailing health bar (drawn first so it appears behind)
    draw.RoundedBox(0, paintLib.WidthSource(98), paintLib.HightSource(969), paintLib.WidthSource(295) * percent3, paintLib.HightSource(18), Color(27, 150, 139, 150))
    
    -- Main health bar
    draw.RoundedBox(0, paintLib.WidthSource(98), paintLib.HightSource(969), paintLib.WidthSource(295) * percent, paintLib.HightSource(18), Color(81, 92, 192))
    
    draw.RoundedBox(0, paintLib.WidthSource(393), paintLib.HightSource(969), paintLib.WidthSource(2), paintLib.HightSource(18), Color(81, 92, 192, 255))

    draw.SimpleText(mana .. "/" .. maxSize, "TLP X10", paintLib.WidthSource(105), paintLib.HightSource(978), Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)


    -- Show Fast Use item 
    if boundItemData then
        local itemData = itemList[boundItemData.itemSource]
        if itemData then
            local icon = itemData.Icon
            local x, y = paintLib.WidthSource(430), paintLib.HightSource(935)
            local size = paintLib.WidthSource(50)
            ITEMS_TEX.items[icon](x, y, size, size)

            --DRAW BUTTON 
            draw.RoundedBox(8, x + paintLib.WidthSource(10), y + paintLib.WidthSource(55), paintLib.WidthSource(24), paintLib.WidthSource(24), color_white)
            draw.SimpleText(string.upper(input.GetKeyName(fastUseBindKey)), "TLP X10", x + paintLib.WidthSource(21), y + paintLib.WidthSource(67), Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end)
