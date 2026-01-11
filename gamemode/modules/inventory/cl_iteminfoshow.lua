local wepTypesName = {
    sword = "Меч",
    axe = "Топор",
    bow = "Лук",
    catalisator = "Катализатор",
    knife = "Кинжал",
    none = "Ничего",
    swordbig = "Большой меч",
}

function showItemInfo(slot, item)
            if IsValid(infoPanel) then
                infoPanel:Remove()
            end
    infoPanel = vgui.Create("DFrame")
    infoPanel:SetSize(paintLib.WidthSource(350), paintLib.HightSource(100))
    infoPanel:ShowCloseButton(false)
    infoPanel:SetTitle("")
    local ScreenXPos, ScreenYPos = slot:LocalToScreen()
    local screenWidth = ScrW()
    local panelWidth = infoPanel:GetWide()

    if ScreenXPos + panelWidth > screenWidth / 2 then
        -- Если панель справа от середины экрана, ставим слева от слота
        infoPanel:SetPos(ScreenXPos - panelWidth, ScreenYPos)
    else
        -- Иначе ставим справа от слота
        infoPanel:SetPos(ScreenXPos + paintLib.WidthSource(95), ScreenYPos)
    end
    local itemData = item:getItemData()
    local height = paintLib.HightSource(65)
    local description = itemData:GetDescription()
    local name = item.name
    local sharpDamage = 0
    if item:getMeta("sharp") then
        name = name.." + "..item:getMeta("sharp")
        sharpDamage = item:getMeta("sharp")
    end
    local x, y = surface.DrawMulticolorText(10, 10, "TLP X18", {color_white, name}, weight_source(350))
    y = y + paintLib.HightSource(55)
    local x2, y2 = surface.DrawMulticolorText(10, y, "TLP X10", description, weight_source(330))
    y = y2 + paintLib.HightSource(20)

    -- для типа предлмета мирового
    y = y  + paintLib.HightSource(20)

    height = y
    endOfDesc = height
    if itemData.Stats then
        height = height + paintLib.HightSource(20)
        height = height + paintLib.HightSource(20) * table.Count(itemData.Stats)
    end
    if itemData.NeedStats then
        height = height + paintLib.HightSource(20)
        if itemData.NeedStats.Class then
            height = height + paintLib.HightSource(20)
        end
        if itemData.NeedStats.Attributes then
            height = height + paintLib.HightSource(20) * table.Count(itemData.NeedStats.Attributes)
        end
    end
    local isWeaponItem = (itemData.type == "weapon")
    if isWeaponItem then
        height = height + paintLib.HightSource(100)
    end
    if sharpDamage >= 3 then
        local bonus = item:getMeta("sharpBonus") or {}
        height = height + paintLib.HightSource(25)
        height = height + paintLib.HightSource(20) * table.Count(bonus)
    end
    if itemData.skill then
        height = height + paintLib.HightSource(20)
    end

    height = height + paintLib.HightSource(10)
    infoPanel:SetSize(paintLib.WidthSource(350), height)

    infoPanel.Paint = function(self, w, h)
        if !IsValid(slot) then self:Remove() return end
        draw.RoundedBox(0, 0, 0, w, h, Color(49, 49, 49, 255))

        draw.RoundedBox(0, 0, 0, 1, paintLib.HightSource(30), inventoryColors.red)
        draw.RoundedBox(0, 0, 0, paintLib.WidthSource(30), 1, inventoryColors.red)

        draw.RoundedBox(0, w - 1, 0, 1, paintLib.HightSource(30), inventoryColors.red)
        draw.RoundedBox(0, w - paintLib.WidthSource(30), 0, paintLib.WidthSource(30), 1, inventoryColors.red)

        draw.RoundedBox(0, 0, h - paintLib.HightSource(30), 1, paintLib.HightSource(30), inventoryColors.red)
        draw.RoundedBox(0, 0, h - 1, paintLib.WidthSource(30), 1, inventoryColors.red)

        draw.RoundedBox(0, w - 1, h - paintLib.HightSource(30), 1, paintLib.HightSource(30), inventoryColors.red)
        draw.RoundedBox(0, w - paintLib.WidthSource(30), h - 1, paintLib.WidthSource(30), 1, inventoryColors.red)

        local x, y = surface.DrawMulticolorText(10, 10, "TLP X18", {color_white, name}, weight_source(350))
        local y = y + paintLib.HightSource(30)

        draw.SimpleText(itemsTypeWorld[item.typeWorld], "TLP X10", 10, y, Color(255, 255, 255), TEXT_ALIGN_LEFT)
        local y = y + paintLib.HightSource(20)

        --draw.SimpleText(itemData.Name, "TLP X18", 10, 10, Color(255, 255, 255), TEXT_ALIGN_LEFT)
        draw.RoundedBox(2, 10, y, paintLib.HightSource(280), 2, Color(255, 255, 255)) --paintLib.HightSource(280)
        local y = y + paintLib.HightSource(5)
        draw.SimpleText("Тип предмета: " .. (namesOfTyper[itemData.type] or "Ингредиент"), "TLP X10", 10, y, Color(255, 255, 255), TEXT_ALIGN_LEFT)
        local y = y + paintLib.HightSource(20)
        local x, y = surface.DrawMulticolorText(10, y, "TLP X10", description, weight_source(330))
        local y = y + paintLib.HightSource(20)
        if itemData.skill then
            local wepType = skillList[itemData.skill].WeaponType or "none"
            draw.RoundedBox(2, 10, y, paintLib.WidthSource(280), 2, Color(255, 255, 255))
            y = y + paintLib.HightSource(5)
            draw.SimpleText("Оружие: " .. wepTypesName[wepType], "TLP X10", 10, y, Color(255, 255, 255), TEXT_ALIGN_LEFT)
            y = y + paintLib.HightSource(20)
        end

        if itemData.Stats then
            draw.SimpleText("Дополнительые параметры предмета: ", "TLP X10", 10, y, Color(255, 255, 255), TEXT_ALIGN_LEFT)
            y = y + paintLib.HightSource(20)
            for stat, value in pairs(itemData.Stats) do
                draw.SimpleText(" | "..namesOfStats[stat] .. ": " .. value, "TLP X10", 10, y, Color(0, 112, 28), TEXT_ALIGN_LEFT)
                y = y + paintLib.HightSource(20)
            end
        end
        if itemData.NeedStats then
            draw.SimpleText("Требования предмета: ", "TLP X10", 10, y, Color(255, 255, 255), TEXT_ALIGN_LEFT)
            if itemData.NeedStats.Class then
                y = y + paintLib.HightSource(20)
                draw.SimpleText(" | Класс: " .. namesOfClass[itemData.NeedStats.Class], "TLP X10", 10, y, Color(255, 255, 255), TEXT_ALIGN_LEFT)
                y = y + paintLib.HightSource(20)
            end
            if itemData.NeedStats.Attributes then
                for stat, value in pairs(itemData.NeedStats.Attributes) do
                    draw.SimpleText(" | "..namesOfStats[stat] .. ": " .. value .. " ("..LocalPlayer():GetAttribute(stat)..")", "TLP X10", 10, y, Color(255, 255, 255), TEXT_ALIGN_LEFT)
                    y = y + paintLib.HightSource(20)
                end
            end
        end
        if isWeaponItem then
            draw.RoundedBox(2, 10, y, paintLib.WidthSource(280), 2, Color(255, 255, 255))
            y = y + paintLib.HightSource(5)
            draw.SimpleText("Характеристики оружия: ", "TLP X10", 10, y, Color(255, 255, 255), TEXT_ALIGN_LEFT)
            y = y + paintLib.HightSource(20)
            draw.SimpleText(" | Урон: " .. itemData.baseDamage + sharpDamage, "TLP X10", 10, y, Color(255, 255, 255), TEXT_ALIGN_LEFT)
            y = y + paintLib.HightSource(20)
            draw.SimpleText(" | Скорость атаки: " .. itemData.attackSpeed, "TLP X10", 10, y, Color(255, 255, 255), TEXT_ALIGN_LEFT)
            y = y + paintLib.HightSource(20)
            draw.SimpleText(" | Дальность атаки: " .. itemData.attackRange, "TLP X10", 10, y, Color(255, 255, 255), TEXT_ALIGN_LEFT)
            y = y + paintLib.HightSource(20)
            draw.SimpleText(" | Основной Атрибут: " .. namesOfStats[itemData.attribute], "TLP X10", 10, y, Color(255, 255, 255), TEXT_ALIGN_LEFT)
            y = y + paintLib.HightSource(20)
        end
        if sharpDamage >= 3 then
            local bonus = item:getMeta("sharpBonus") or {}
            draw.RoundedBox(2, 10, y, paintLib.WidthSource(280), 2, Color(255, 255, 255))
            y = y + paintLib.HightSource(5)
            draw.SimpleText("Дополнительые бонусы: ", "TLP X10", 10, y, Color(255, 255, 255), TEXT_ALIGN_LEFT)
            y = y + paintLib.HightSource(20)
            for stat, value in pairs(bonus) do
                draw.SimpleText(" | "..namesOfSharpBonus[stat] .. ": " .. sharpBonus[stat], "TLP X10", 10, y, Color(0, 112, 28), TEXT_ALIGN_LEFT)
                y = y + paintLib.HightSource(20)
            end
        end
    end

    infoPanel:MakePopup()
end
