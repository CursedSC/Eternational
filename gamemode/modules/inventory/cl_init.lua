netstream.Start("fantasy/items/loadjson")
hook.Add("InitPostEntity", "fantasy/inventory/init", function()
    netstream.Start("fantasy/items/loadjson")
end)

netstream.Hook("fantasy/itemAdd", function(name, id, q)
	print(name, id, q)
	HINTS.print( name.." x"..q, color_white, {id = id, type = "item"}, 1 )
end)

netstream.Hook("fantasy/items/loadjson", function(listJson)
    for itemName, itemData in pairs(listJson) do
        local itemClass = itemList[itemData.class]
        local itemInstance = table.Copy(itemClass)
        for key, value in pairs(itemData) do
            itemInstance[key] = value
        end
        itemInstance.fromJSON = true
        itemList[itemName] = itemInstance
    end
    hook.Call("OnItemsLoadedJson", nil)
    refreshItemsQmenu()
end)

netstream.Hook("fantasy/inventory/sync", function(inv)
    playerInventory = Inventory:fromTable(inv)
    playerInventory.owner = LocalPlayer()
end)

local openInventoryKey = KEY_TAB

hook.Add("PlayerButtonDown", "OpenInventoryOnKeyPress", function(ply, key)
    if key == openInventoryKey then
        if not IsValid(playerInventoryFrame) then
            createInventoryFrame()
        end
    end
end)

concommand.Add("open_inventory", function()
    createInventoryFrame()
end)

local upgradeButtons = {}

local function DrawStatPentagon(x, y, size, attributes)
    local points = {}
    local angle = 360 / 5
    local rotation = -18

    local borderPoints = {}
    for i = 1, 5 do
        local rad = math.rad(i * angle + rotation)
        local pointX = x + math.cos(rad) * (size + 10)
        local pointY = y + math.sin(rad) * (size + 10)
        table.insert(borderPoints, {x = pointX, y = pointY})
    end

    surface.SetDrawColor(77, 0, 0)
    draw.NoTexture()
    surface.DrawPoly(borderPoints)

    for i = 1, 5 do
        local rad = math.rad(i * angle + rotation)
        local attributeValue = attributes[i] or 1
        local pointX = x + math.cos(rad) * (size - 1) * attributeValue
        local pointY = y + math.sin(rad) * (size - 1) * attributeValue
        table.insert(points, {x = pointX, y = pointY})
    end

    surface.SetDrawColor(32, 32, 32, 206)
    draw.NoTexture()
    surface.DrawPoly(points)
end


local postionsButtonsUp = {}

local function DrawStatPentagon2(x, y, size, attributes)
    local points = {}
    local angle = 360 / 5
    local rotation = -18

    for i = 1, 5 do
        local rad = math.rad(i * angle + rotation)
        local attributeValue = attributes[i] or 1
        local pointX = x + math.cos(rad) * size * attributeValue
        local pointY = y + math.sin(rad) * size * attributeValue

        table.insert(points, {x = pointX, y = pointY})
    end

    surface.SetDrawColor(165, 38, 38)
    draw.NoTexture()
    surface.DrawPoly(points)

    for i = 1, 5 do
        local rad = math.rad(i * angle + rotation)
        local attributeValue = attributes[i] or 1
        local pointX = x + math.cos(rad) * size * attributeValue
        local pointY = y + math.sin(rad) * size * attributeValue

        local pointX2 = x + math.cos(rad) * size
        local pointY2 = y + math.sin(rad) * size
            --↑
        draw.RoundedBox(0, pointX - 2, pointY - 2, 4, 4, color_white)
        local str = (playerPoints >= 1) and namesAtributeByValue[i].." "..(50 * attributeValue).." ↑" or namesAtributeByValue[i].." "..(50 * attributeValue)
        draw.SimpleText(str, "TL X12", pointX2, pointY2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        if playerPoints > 0  then
            postionsButtonsUp[i] = {x = pointX2, y = pointY2}
        end
    end
end

function BuildInventoryInformation(bnoSlots)
    inventorySubPanel.listSlots = {}
    inventoryGrid = vgui.Create( "DIconLayout", inventorySubPanel )
	inventoryGrid:SetPos(paintLib.WidthSource(56), paintLib.HightSource(169))
	inventoryGrid:SetSize(paintLib.WidthSource(650), paintLib.HightSource(820))
	inventoryGrid:SetSpaceY( paintLib.HightSource(0) )
	inventoryGrid:SetSpaceX( paintLib.WidthSource(0) )

    slots = {}
    BuildGridItems(inventoryGrid)
    BuildItems()
    print(bnoSlots)
    if !bnoSlots then BuildSlots() end
end

function clearInventorySubPanel()
    local childs = inventorySubPanel:GetChildren()
    for k, i in pairs(childs) do i:Remove() end
end

openInventoryTime = 0

local xpProgress = {
    {x = 0, y = paintLib.HightSource(1064)},
    {x = paintLib.WidthSource(1000), y = paintLib.HightSource(1064)},
    {x = paintLib.WidthSource(1000), y = paintLib.HightSource(1080)},
    {x = 0, y = paintLib.HightSource(1080)},
}


local posit = Vector(20,-13,70)
local posit2 = Vector(-10,-15,80)
local posit3 = Vector(5,20,70)
local light1 = { type = 1,
                color = Vector(200, 200, 200),
                pos = posit,
                dir = Vector(0,0,0),
                range = 1,
                angularFalloff = 5,
                innerAngle = 45,
                outerAngle = 45,
                fiftyPercentDistance = 2,
                zeroPercentDistance = 20,
                quadraticFalloff = 0,
                linearFalloff = 1,
                constantFalloff = 0}
local light2 = { type = 1,
                color = Vector(30,144,255),
                pos = posit2,
                dir = Vector(0,0,0),
                range = 1,
                angularFalloff = 5,
                innerAngle = 45,
                outerAngle = 45,
                fiftyPercentDistance = 1,
                zeroPercentDistance = 15,
                quadraticFalloff = 0,
                linearFalloff = 1,
                constantFalloff = 0}
local light3 = { type = 1,
                color = Vector(255,191,30)*0.15,
                pos = posit3,
                dir = Vector(0,0,0),
                range = 1,
                angularFalloff = 5,
                innerAngle = 45,
                outerAngle = 45,
                fiftyPercentDistance = 5,
                zeroPercentDistance = 15,
                quadraticFalloff = 0,
                linearFalloff = 1,
                constantFalloff = 0}
local lights = { light1 , light2, light3, {} }
local listButtons = {}
listButtons[1] = {
    name = "ПЕРСОНАЖ",
    icon = {
        img = Material("fantasy/character.png"),
        w = paintLib.WidthSource(31),
        h = paintLib.WidthSource(45),
    },
    show = function()
        local ply = LocalPlayer()
        local _model = ply:GetModel()

        if IsValid(randerModel) then randerModel:Remove() end
        randerModel = ClientsideModel( _model, RENDERGROUP_OTHER )
        local seq = randerModel:LookupSequence("menu_combine")
        randerModel:ResetSequence(seq)
        local charline6 = vgui.Create( "EditablePanel", inventorySubPanel )
        charline6:SetSize( ScrW(), ScrH() )
        charline6:SetPos( 0, 0 )
        charline6:SetMouseInputEnabled( false )
        charline6.Paint = function( self, w, h )
            model = {model=_model,pos=Vector(0,0,0),angle=Angle(0,0,0)}
            cam.Start3D( Vector(paintLib.WidthSource(230), 0, 45), Angle(0,180,0), 49, 0, 0, ScrW(), ScrH(), 5, 4096)
            render.SuppressEngineLighting( true )
            render.SetModelLighting( 0, 0.05, 0.05, 0.05 )
            render.SetModelLighting( 1, 0, 0, 0 )
            render.SetModelLighting( 2, 0.1, 0.1, 0.2 )
            render.SetModelLighting( 3, 0, 0, 0 )
            render.SetModelLighting( 4, 0.1, 0.1, 0.1 )
            render.SetModelLighting( 5, 0, 0, 0 )
            render.SetLocalModelLights( lights )
            render.Model( model , randerModel )
            randerModel:FrameAdvance()
            render.SuppressEngineLighting( false )
            cam.End3D()
        end
        function randerModel:GetPlayerColor() return ply:GetPlayerColor() end
        for i = 0, #ply:GetBodyGroups() - 1 do
            local bodygroupValue = ply:GetBodygroup(i)
            randerModel:SetBodygroup(i, bodygroupValue)
        end
        inventorySubPanel.model = charline6


        BuildInventoryInformation()
        if playerPoints <= 0 then return end
        timer.Simple(0.001, function()
            for i = 1, 5 do
                local id = trueNamesAtributeByValue[i]
                local pointX2 = postionsButtonsUp[i].x
                local pointY2 = postionsButtonsUp[i].y
                local skillUpButton = vgui.Create("DButton", inventorySubPanel)
                skillUpButton:SetSize(paintLib.WidthSource(60), paintLib.HightSource(20))
                skillUpButton:SetPos(pointX2 - paintLib.WidthSource(30), pointY2 - paintLib.HightSource(10))
                skillUpButton:SetText("")
                skillUpButton.Paint = function(self, w, h)
                    if self:IsHovered()then
                        draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 50))
                    end
                end
                skillUpButton.DoClick = function(self)
                    netstream.Start("fantasy/inventory/upgrade", id)
                    playerPoints = playerPoints - 1
                    ply:AddSkillPoints(-1)
                    if playerPoints <= 0 then
                        for k, i in pairs(postionsButtonsUp) do
                            if IsValid(upgradeButtons[k]) then upgradeButtons[k]:Remove() end
                        end
                    end
                end
                upgradeButtons[id] = skillUpButton
            end
        end)
    end,
    drawfunc = function(self, w, h)
        local ply = LocalPlayer()
        draw.SimpleText("Инвентарь", "TL X28", paintLib.WidthSource(59), paintLib.HightSource(137), inventoryColors.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        draw.SimpleText(playerInventory.weight.." / "..ply:GetWeight().." кг.", "TL X28", paintLib.WidthSource(59 + 650), paintLib.HightSource(137), inventoryColors.white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        draw.SimpleText("ОРУЖИЕ", "TL X28", paintLib.WidthSource(1355), paintLib.HightSource(175), inventoryColors.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("БРОНЯ", "TL X28", paintLib.WidthSource(1560), paintLib.HightSource(175), inventoryColors.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("АКСЕССУАРЫ", "TL X28", paintLib.WidthSource(1505), paintLib.HightSource(335), inventoryColors.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        playerPoints = ply:GetSkillPoints()
        local str = (playerPoints > 0) and "СТАТИСТИКА ("..playerPoints.." очков навыка)" or "СТАТИСТИКА"
        draw.SimpleText(str , "TL X28", paintLib.WidthSource(1505), paintLib.HightSource(515), inventoryColors.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        local centerX = paintLib.WidthSource(1500)
        local centerY = paintLib.HightSource(675)
        local radius = paintLib.HightSource(120)

        local attributes = {0.5, 0.2, 0.5, 0.5, 0.5}
        attributes[1] = ply:GetAttribute("strength") / 50
        attributes[2] = ply:GetAttribute("agility") / 50
        attributes[3] = ply:GetAttribute("intelligence") / 50
        attributes[4] = ply:GetAttribute("vitality") / 50
        attributes[5] = ply:GetAttribute("luck") / 50

        DrawStatPentagon(centerX, centerY, radius, {})
        DrawStatPentagon2(centerX, centerY, radius, attributes)

        draw.SimpleText("ЗДОРОВЬЕ:", "TL X28", paintLib.WidthSource(1237), paintLib.HightSource(875), inventoryColors.red, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(ply:Health(), "TL X28", paintLib.WidthSource(1397), paintLib.HightSource(875), inventoryColors.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)


        local damage = playerInventory:GetEquippedItem("weapon") and playerInventory:GetEquippedItem("weapon"):getItemData().baseDamage or 0
        draw.SimpleText("УРОН:", "TL X28", paintLib.WidthSource(1237), paintLib.HightSource(905), inventoryColors.red, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(damage, "TL X28", paintLib.WidthSource(1323), paintLib.HightSource(905), inventoryColors.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        local bArmor = 0
        local playerArmorBuff = ply:GetArmorStat("armor")
        bArmor = playerArmorBuff
        draw.SimpleText("ЗАЩИТА:", "TL X28", paintLib.WidthSource(1237), paintLib.HightSource(935), inventoryColors.red, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(bArmor, "TL X28", paintLib.WidthSource(1360), paintLib.HightSource(935), inventoryColors.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        draw.SimpleText("СКОРОСТЬ:", "TL X28", paintLib.WidthSource(1237), paintLib.HightSource(965), inventoryColors.red, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(math.floor(ply:GetRunSpeed()), "TL X28", paintLib.WidthSource(1397), paintLib.HightSource(965), inventoryColors.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        draw.RoundedBox(0, 0, paintLib.HightSource(1064), paintLib.WidthSource(1920), paintLib.HightSource(16), inventoryColors.darkGray)        --xpProgressay)


        draw.SimpleText("ДЕНЬГИ:", "TL X28", paintLib.WidthSource(1237 + 300), paintLib.HightSource(875), inventoryColors.red, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(ply:GetCharacterData("money"), "TL X28", paintLib.WidthSource(1397 + 270), paintLib.HightSource(875), inventoryColors.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        local xpLess = ply:GetCharacterData("xpLess", 0)
        local haveLess = (xpLess > 0)
        local xp = ply:GetExperience()
        if haveLess then
            xp = xpLess
        end
        local maxXP = ply:GetMaxExperience()
        local p = xp / maxXP
        xpProgress[2].x = paintLib.WidthSource(1920) * p
        xpProgress[3].x = paintLib.WidthSource(1920) * p - 10

        surface.SetDrawColor(haveLess and inventoryColors.red or inventoryColors.lightGray)
        draw.NoTexture()
        surface.DrawPoly(xpProgress)

        draw.SimpleText(haveLess and "Штраф Опыта: "..xp or (xp.."/"..maxXP), "TL X12", w * 0.5, paintLib.HightSource(1072), Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        local lvl = ply:GetLvl()
        draw.SimpleText("УРОВЕНЬ "..lvl, "TL X25", w * 0.5, paintLib.HightSource(1043), Color(240, 225, 162), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        local class = namesOfClass[ply.characterData.class]
        draw.SimpleText(class or "??", "TL X25", w * 0.5, paintLib.HightSource(230), Color(240, 225, 162), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(ply:GetName(), "TL X35", w * 0.5, paintLib.HightSource(200), Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
}


listButtons[2] = {
    name = "СПОСОБНОСТИ",
    icon = {
        img = Material("fantasy/skills.png"),
        w = paintLib.WidthSource(49),
        h = paintLib.WidthSource(49),
    },
    show = function()
        -- Создаем основную панель навыков с красивым скроллбаром
        skillPanel = vgui.Create("DScrollPanel", inventorySubPanel)
        skillPanel:SetPos(paintLib.WidthSource(56), paintLib.HightSource(169))
        skillPanel:SetSize(paintLib.WidthSource(650), paintLib.HightSource(820))
        skillPanel.Paint = function(self, w, h)
            -- Границы панели навыков
            surface.SetDrawColor(86, 53, 53, 200)
            surface.DrawOutlinedRect(0, 0, w, h, 1)


        end

        -- Стилизованный скроллбар
        local vbar = skillPanel:GetVBar()
        vbar:SetWide(8)
        vbar.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 100))
        end
        vbar.btnUp.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 70))
        end
        vbar.btnDown.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 70))
        end
        vbar.btnGrip.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(60, 60, 70))
        end

        -- Панель информации о выбранном навыке
        local skillInfoPanel = vgui.Create("DPanel", inventorySubPanel)
        skillInfoPanel:SetPos(paintLib.WidthSource(720), paintLib.HightSource(169))
        skillInfoPanel:SetSize(paintLib.WidthSource(500), paintLib.HightSource(400))
        skillInfoPanel.Paint = function(self, w, h)
            -- Фон и границы для панели информации
            draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 40, 200))
            surface.SetDrawColor(86, 53, 53, 200)
            surface.DrawOutlinedRect(0, 0, w, h, 1)

            -- Заголовок панели информации
            draw.RoundedBox(0, 0, 0, w, paintLib.HightSource(40), Color(40, 40, 50, 200))
            draw.SimpleText("ИНФОРМАЦИЯ О НАВЫКЕ", "TL X20", w/2, paintLib.HightSource(20), Color(240, 225, 162), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            -- Если навык не выбран
            if not self.selectedSkill then
                draw.SimpleText("Выберите навык для просмотра", "TL X18", w/2, h/2, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("подробной информации", "TL X18", w/2, h/2 + paintLib.HightSource(30), Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        -- Создаем панель для слотов быстрого доступа (хотбара)
        local hotbarPanel = vgui.Create("DPanel", inventorySubPanel)
        hotbarPanel:SetPos(paintLib.WidthSource(720), paintLib.HightSource(600))
        hotbarPanel:SetSize(paintLib.WidthSource(500), paintLib.HightSource(200))
        hotbarPanel.Paint = function(self, w, h)
            -- Фон и границы для панели хотбара
            draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 40, 200))
            surface.SetDrawColor(86, 53, 53, 200)
            surface.DrawOutlinedRect(0, 0, w, h, 1)

            -- Заголовок панели хотбара
            draw.RoundedBox(0, 0, 0, w, paintLib.HightSource(40), Color(40, 40, 50, 200))
            draw.SimpleText("ПАНЕЛЬ БЫСТРОГО ДОСТУПА", "TL X20", w/2, paintLib.HightSource(20), Color(240, 225, 162), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            -- Подсказки для кнопок
            draw.SimpleText(input.GetKeyName(playerSkillsBind[1]), "TL X25", paintLib.WidthSource(70), paintLib.HightSource(160), Color(240, 225, 162), TEXT_ALIGN_CENTER)
            draw.SimpleText(input.GetKeyName(playerSkillsBind[2]), "TL X25", paintLib.WidthSource(180), paintLib.HightSource(160), Color(240, 225, 162), TEXT_ALIGN_CENTER)
            draw.SimpleText(input.GetKeyName(playerSkillsBind[3]), "TL X25", paintLib.WidthSource(290), paintLib.HightSource(160), Color(240, 225, 162), TEXT_ALIGN_CENTER)
            draw.SimpleText(input.GetKeyName(playerSkillsBind[4]), "TL X25", paintLib.WidthSource(400), paintLib.HightSource(160), Color(240, 225, 162), TEXT_ALIGN_CENTER)
        end

        -- Сортируем навыки по типу оружия
        local counterX = 0
        local counterY = 0
        local sortedList = {}

        for k, i in pairs(skillList) do
            if !LocalPlayer().characterData.knowSkills[k] then continue end
            local t = i.WeaponType or "none"
            sortedList[t] = sortedList[t] or {}
            i.trueId = k
            table.insert(sortedList[t], i)
        end

        -- Функция для обновления отображения навыков при поиске
        local function UpdateSkillDisplay(searchText)

            for _, child in pairs(skillPanel:GetChildren()) do
                if child.CanDelete then
                    child:Remove()
                end
            end

            -- Переменные для позиционирования
            local yOffset = paintLib.HightSource(10)
            PrintTable(sortedList)
            print("UpdateSkillDisplay", table.Count(sortedList))
            -- Для каждого типа оружия
            for k, skills in pairs(sortedList) do
                print("UpdateSkillDisplay")
                local hasVisibleSkills = false
                local filteredSkills = {}

                -- Фильтруем навыки по поисковому запросу
                for _, skill in pairs(skills) do
                    if searchText == "" or string.find(string.lower(skill.name or ""), string.lower(searchText)) then
                        table.insert(filteredSkills, skill)
                        hasVisibleSkills = true
                    end
                end

                -- Если есть видимые навыки для этого типа, создаем заголовок и отображаем их
                if hasVisibleSkills then
                    -- Заголовок категории
                    local categoryHeader = vgui.Create("DPanel", skillPanel)
                    categoryHeader:SetSize(paintLib.WidthSource(630), paintLib.HightSource(50))
                    categoryHeader:SetPos(paintLib.WidthSource(10), yOffset)
                    categoryHeader.CanDelete = true
                    categoryHeader.Paint = function(self, w, h)
                        draw.RoundedBox(4, 0, 0, w, h, Color(60, 60, 70, 200))

                        -- Декоративный элемент слева
                        draw.RoundedBox(0, 0, 0, paintLib.WidthSource(5), h, Color(220, 170, 60))

                        -- Название категории
                        draw.SimpleText(namesOfWeapons[k] or "Прочие навыки", "TL X24", paintLib.WidthSource(20), h/2, Color(240, 225, 162), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    end

                    yOffset = yOffset + paintLib.HightSource(60)

                    -- Сетка для навыков этой категории
                    local skillGrid = vgui.Create("DIconLayout", skillPanel)
                    skillGrid.CanDelete = true
                    skillGrid:SetPos(paintLib.WidthSource(10), yOffset)
                    skillGrid:SetSize(paintLib.WidthSource(630), paintLib.HightSource(1000))
                    skillGrid:SetSpaceX(paintLib.WidthSource(5))
                    skillGrid:SetSpaceY(paintLib.HightSource(5))

                    -- Добавляем навыки в сетку
                    for _, v in pairs(filteredSkills) do
                        local skill = skillGrid:Add("DPanel")
                        skill:SetSize(paintLib.WidthSource(95), paintLib.HightSource(95))
                        skill:Droppable("skill")
                        skill.inf = v.trueId
                        skill.skillData = v

                        -- Анимации и эффекты
                        local hoverAlpha = 0
                        local isSelected = false

                        skill.Paint = function(self, w, h)
                            -- Фон навыка
                            draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 60))

                            -- Эффект при наведении
                            if self:IsHovered() then
                                hoverAlpha = math.min(hoverAlpha + 10, 100)
                            else
                                hoverAlpha = math.max(hoverAlpha - 5, 0)
                            end

                            -- Выделение выбранного навыка
                            if isSelected then
                                surface.SetDrawColor(220, 170, 60, 150 + math.sin(CurTime() * 3) * 50)
                                surface.DrawOutlinedRect(0, 0, w, h, 2)
                            end

                            -- Эффект свечения при наведении
                            if hoverAlpha > 0 then
                                surface.SetDrawColor(220, 170, 60, hoverAlpha)
                                surface.DrawOutlinedRect(0, 0, w, h, 1)
                            end

                            -- Иконка навыка
                            ITEMS_TEX.items[v.Icon](3, 3, w-6, h-6)

                            -- Рамка
                            surface.SetDrawColor(86, 53, 53, 200)
                            surface.DrawOutlinedRect(0, 0, w, h, 1)
                        end

                        -- Отображение информации при наведении
                        skill.OnCursorEntered = function()
                            -- Обновляем панель информации
                            skillInfoPanel.selectedSkill = v
                            skillInfoPanel.Paint = function(self, w, h)
                                -- Фон и границы
                                draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 40, 200))
                                surface.SetDrawColor(86, 53, 53, 200)
                                surface.DrawOutlinedRect(0, 0, w, h, 1)

                                -- Заголовок
                                draw.RoundedBox(0, 0, 0, w, paintLib.HightSource(40), Color(40, 40, 50, 200))
                                draw.SimpleText("ИНФОРМАЦИЯ О НАВЫКЕ", "TL X20", w/2, paintLib.HightSource(20), Color(240, 225, 162), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                                -- Иконка и название навыка
                                ITEMS_TEX.items[v.Icon](paintLib.WidthSource(30), paintLib.HightSource(60), paintLib.WidthSource(64), paintLib.HightSource(64))

                                -- Название с золотистым градиентом
                                for i = 0, 1 do
                                    draw.SimpleText(v.Name or "Неизвестный навык", "TL X24", paintLib.WidthSource(120), paintLib.HightSource(80) - i,
                                    Color(220 - i*30, 170 - i*30, 60 - i*30, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                                end

                                -- Разделитель
                                surface.SetDrawColor(220, 170, 60, 150)
                                surface.DrawRect(paintLib.WidthSource(20), paintLib.HightSource(130), w - paintLib.WidthSource(40), 2)

                                -- Описание навыка
                                local description = v.Description or "Нет описания"

                                local _, textHeight = surface.DrawMulticolorText(paintLib.WidthSource(20), paintLib.HightSource(150), "TL X16", description,
                                    w - paintLib.WidthSource(40), Color(200, 200, 200))
                                    textHeight = textHeight - paintLib.HightSource(130)
                                -- Тип оружия
                                draw.SimpleText("Тип оружия:", "TL X18", paintLib.WidthSource(20),
                                    paintLib.HightSource(160) + textHeight, Color(240, 225, 162), TEXT_ALIGN_LEFT)
                                draw.SimpleText(namesOfWeapons[v.WeaponType] or "Любое", "TL X18", paintLib.WidthSource(150),
                                    paintLib.HightSource(160) + textHeight, Color(255, 255, 255), TEXT_ALIGN_LEFT)

                                -- Перезарядка
                                if v.CoolDown then
                                    draw.SimpleText("Перезарядка:", "TL X18", paintLib.WidthSource(20),
                                        paintLib.HightSource(190) + textHeight, Color(240, 225, 162), TEXT_ALIGN_LEFT)
                                    draw.SimpleText(v.CoolDown.." сек.", "TL X18", paintLib.WidthSource(150),
                                        paintLib.HightSource(190) + textHeight, Color(255, 255, 255), TEXT_ALIGN_LEFT)
                                end

                                -- Стоимость маны
                                if v.Mana then
                                    draw.SimpleText("Стоимость маны:", "TL X18", paintLib.WidthSource(20),
                                        paintLib.HightSource(220) + textHeight, Color(240, 225, 162), TEXT_ALIGN_LEFT)
                                    draw.SimpleText(v.Mana, "TL X18", paintLib.WidthSource(180),
                                        paintLib.HightSource(220) + textHeight, Color(100, 150, 255), TEXT_ALIGN_LEFT)
                                end

                                -- Подсказка для использования
                                draw.RoundedBox(4, w/2 - paintLib.WidthSource(200), h - paintLib.HightSource(60), paintLib.WidthSource(400), paintLib.HightSource(40), Color(40, 40, 50, 200))
                                draw.SimpleText("Перетащите навык в панель быстрого доступа", "TL X16", w/2, h - paintLib.HightSource(40), Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                            end

                            -- Подсвечиваем выбранный навык
                            isSelected = true
                        end

                        skill.OnCursorExited = function()
                            isSelected = false
                        end

                        -- Начало перетаскивания - эффект
                        skill.OnStartDragging = function()

                        end
                    end

                    -- Обновляем смещение для следующей категории
                    yOffset = yOffset + math.ceil(#filteredSkills / 6) * paintLib.HightSource(100) + paintLib.HightSource(20)
                end
            end
        end


        -- Первоначальное отображение всех навыков
        UpdateSkillDisplay("")

        -- Создаем слоты быстрого доступа
        for k = 1, 4 do
            local accSlot = vgui.Create("DButton", hotbarPanel)
            accSlot:SetSize(paintLib.WidthSource(92), paintLib.HightSource(92))
            accSlot:SetPos(paintLib.WidthSource(25) + paintLib.WidthSource(110) * (k - 1), paintLib.HightSource(60))
            accSlot:SetText("")

            -- Анимация и визуальные эффекты для слота
            local hoverAlpha = 0

            accSlot.Paint = function(self, w, h)
                -- Базовый фон слота
                draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 50))

                -- Контент слота
                if hotbar[k].skill then
                    ITEMS_TEX.items[hotbar[k].skill.Icon](paintLib.WidthSource(5), paintLib.HightSource(5), w-paintLib.WidthSource(10), h-paintLib.HightSource(10))
                else
                    -- Отображение иконки "+" для пустого слота
                    draw.SimpleText("+", "TL X30", w/2, h/2, Color(120, 120, 120, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                -- Эффект при наведении
                if self:IsHovered() then
                    hoverAlpha = math.min(hoverAlpha + 10, 150)
                else
                    hoverAlpha = math.max(hoverAlpha - 5, 0)
                end

                if hoverAlpha > 0 then
                    surface.SetDrawColor(220, 170, 60, hoverAlpha)
                    surface.DrawOutlinedRect(0, 0, w, h, 2)

                    -- Показываем подсказку для удаления при наведении
                    if hotbar[k].skill then
                        draw.SimpleText("Клик для удаления", "TL X12", w/2, h + paintLib.HightSource(15), Color(200, 200, 200, hoverAlpha), TEXT_ALIGN_CENTER)
                    end
                end

                -- Красивая рамка
                surface.SetDrawColor(86, 53, 53, 200)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
            end

            -- Обработчик нажатия для удаления навыка
            accSlot.DoClick = function()
                if hotbar[k].skill then
                    -- Анимация и звук удаления


                    -- Удаление навыка
                    hotbar[k].skill = nil
                    hotbar[k].skillid = nil
                    SaveHotbarConfig()
                end
            end

            -- Реализация приема перетаскиваемого навыка
            accSlot:Receiver("skill", function(self, panels, bDoDrop, Command, x, y)
                if bDoDrop then
                    local skill = panels[1].inf

                    -- Анимация и звук успешного назначения
                    --surface.PlaySound("items/battery_pickup.wav")

                    -- Назначаем навык на слот
                    hotbar[k].skill = skillList[skill]
                    hotbar[k].skillid = skill
                    SaveHotbarConfig()

                end
            end)
        end

    end,
    drawfunc = function(self, w, h)
    end
}


listButtons[3] = {
    name = "РЕМЕСЛО",
    icon = {
        img = Material("fantasy/talants.png"),
        w = paintLib.WidthSource(38),
        h = paintLib.WidthSource(37),
    },
    show = function()
        skilltree()
    end,
    drawfunc = function(self, w, h)
        local playerJobs = LocalPlayer():GetCharacterData("jobs", {})
        local hasNoJobs = (table.Count(playerJobs) <= 0)
        if hasNoJobs then
            draw.SimpleText("ВЫ ЕЩЕ НЕ ИЗУЧИЛИ РЕМЕСЛО", "TL X50", w / 2, h / 2, Color(240, 225, 162), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            return
        end

        -- Отображаем информацию об очках навыков
        local skillPoints = LocalPlayer():GetAttributesSkillsPoints()
        local pointsText = "Доступно очков навыков: " .. skillPoints
        draw.SimpleText(pointsText, "TL X20", w - paintLib.WidthSource(59), paintLib.HightSource(137), skillPoints > 0 and Color(240, 225, 162) or Color(150, 150, 150), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
}



local materials = {
    bg = Material("materials/fantasy/bg.png"),
	tasks = Material("materials/fantasy/questsystem/icon_tasks.png", "smooth"),
	location = Material("materials/fantasy/questsystem/icon_location.png", "smooth"),
	description = Material("materials/fantasy/questsystem/icon_description.png", "smooth"),
	completed = Material("materials/fantasy/questsystem/icon_completed.png", "smooth"),
	navigate = Material("materials/fantasy/questsystem/icon_navigate.png", "smooth"),
}

local questsColors = {
	white = color_white,
	WhiteLowAlpha = Color(255, 255, 255, 255 * 0.6),
	black = color_black,
	BlackLowAlpha = Color(0, 0, 0, 255 * 0.3),
	semiTransparentBlack = Color(0, 0, 0, 255 * 0.5),
	YellowLight = Color(240, 225, 161, 255),
	YellowNotLight = Color(146, 137, 101, 255),
	YellowNotLightLowAlpha = Color(146, 137, 101, 255 * 0.6),
	gray = Color(128, 128, 128, 255),
	GrayLowAlpha = Color(128, 128, 128, 255 * 0.6),
	ButtonMain = Color(0, 0, 0, 255 * 0.33),
	QuestMain = Color(160, 32, 83, 255),
	QuestSide = Color(75, 103, 9, 255),
}

listButtons[4] = {
    name = "КВЕСТЫ",
    icon = {
        img = Material("fantasy/quests.png"),
        w = paintLib.WidthSource(39),
        h = paintLib.WidthSource(29),
    },
    show = function()
		CreateQuestTypeButtons(inventoryFrame)
		DrawQuestsFromType(inventoryFrame, "AllQuests")
	end,
	drawfunc = function(self, w, h)
		-- main menu start --
		surface.SetDrawColor(questsColors.BlackLowAlpha)
		surface.DrawRect(paintLib.WidthSource(16), paintLib.HightSource(106), paintLib.WidthSource(586), paintLib.HightSource(957))
		surface.DrawRect(paintLib.WidthSource(16), paintLib.HightSource(163), paintLib.WidthSource(586), paintLib.HightSource(44))
		surface.DrawMulticolorText(paintLib.WidthSource(165), paintLib.HightSource(124), "TL X28", {questsColors.WhiteLowAlpha, "СПИСОК КВЕСТОВ"})
		-- main menu end --

		-- number quests start --
		surface.DrawMulticolorText(paintLib.WidthSource(79), paintLib.HightSource(169), "TL X14", {questsColors.YellowNotLight, tostring(table.Count(LocalPlayer().Quests["Main"]) + table.Count(LocalPlayer().Quests["Side"]))})
		local mainquests = table.Count(LocalPlayer().Quests["Main"])
		local sidequests = table.Count(LocalPlayer().Quests["Side"])
		local completedquests = table.Count(LocalPlayer().Quests["Complete"])
		surface.DrawMulticolorText(paintLib.WidthSource(235), paintLib.HightSource(169), "TL X14", {questsColors.YellowNotLight, tostring(mainquests)})
		surface.DrawMulticolorText(paintLib.WidthSource(381), paintLib.HightSource(169), "TL X14", {questsColors.YellowNotLight, tostring(sidequests)})
		surface.DrawMulticolorText(paintLib.WidthSource(577), paintLib.HightSource(169), "TL X14", {questsColors.YellowNotLight, tostring(completedquests)})
		-- number quests end --

		-- quest description start --
		if self.pickedquest then
			local width, height = surface.DrawMulticolorText(0, 0, "TL X18", {Color(0, 0, 0, 0), self.pickedquest.data.description}, paintLib.WidthSource(1200))
			surface.DrawRect(paintLib.WidthSource(622), paintLib.HightSource(106), paintLib.WidthSource(1284), paintLib.HightSource(887))
			surface.SetFont("TL X30")
			local x, y = surface.GetTextSize(self.pickedquest.data.title)
			surface.DrawMulticolorText(paintLib.WidthSource(1261) - x*0.5, paintLib.HightSource(132), "TL X30", {questsColors.WhiteLowAlpha, self.pickedquest.data.title})
			surface.SetFont("TL X18")
			local x, y = self.pickedquest.data.type == "Main" and surface.GetTextSize('ОСНОВНОЙ КВЕСТ') or surface.GetTextSize('ПОБОЧНЫЙ КВЕСТ')
			surface.DrawMulticolorText(paintLib.WidthSource(1261) - x*0.5, paintLib.HightSource(169), "TL X18", {self.pickedquest.data.type == "Main" and questsColors.QuestMain or questsColors.QuestSide, self.pickedquest.data.type == "Main" and "ОСНОВНОЙ КВЕСТ" or "ПОБОЧНЫЙ КВЕСТ"})

			surface.SetDrawColor(questsColors.white)
			surface.SetMaterial(materials.tasks)
			surface.DrawTexturedRect(paintLib.WidthSource(665), paintLib.HightSource(217), paintLib.WidthSource(25), paintLib.HightSource(25))
			surface.DrawMulticolorText(paintLib.WidthSource(705), paintLib.HightSource(219), "TL X18", {questsColors.WhiteLowAlpha, "ЗАДАНИЯ"})
			surface.SetDrawColor(questsColors.ButtonMain)
			local i = 0
			for k, v in pairs(self.pickedquest.data.tasks) do
				local x, y = surface.GetTextSize(v.text)
				local posy = paintLib.HightSource(250) + paintLib.HightSource(55)*i
				surface.DrawRect(paintLib.WidthSource(651), posy, paintLib.WidthSource(42) + x, paintLib.HightSource(44))
				surface.DrawRect(paintLib.WidthSource(700) + x, posy, paintLib.WidthSource(67), paintLib.HightSource(44))
				surface.DrawMulticolorText(paintLib.WidthSource(672), posy + y*0.5, "TL X18", {v.current == v.need and questsColors.YellowLight or questsColors.gray, v.text})
				local x2, y2 = surface.GetTextSize('' .. v.current .. '/' .. v.need)
				surface.DrawMulticolorText(paintLib.WidthSource(721) + x, posy + y2*0.5, "TL X18", {v.current == v.need and questsColors.YellowLight or questsColors.gray, ''..v.current..'/'..v.need})

				i = i + 1
			end

			surface.SetDrawColor(questsColors.white)
			surface.SetMaterial(materials.location)
			surface.DrawTexturedRect(paintLib.WidthSource(665), paintLib.HightSource(255) + paintLib.HightSource(55)*i, paintLib.WidthSource(25), paintLib.HightSource(25))
			surface.DrawMulticolorText(paintLib.WidthSource(705), paintLib.HightSource(260) + paintLib.HightSource(55)*i, "TL X18", {questsColors.WhiteLowAlpha, "ЛОКАЦИЯ"})
			surface.SetDrawColor(questsColors.ButtonMain)
			surface.DrawRect(paintLib.WidthSource(651), paintLib.HightSource(293) + paintLib.HightSource(55)*i, paintLib.WidthSource(1227), paintLib.HightSource(45))
			local x, y = surface.GetTextSize(self.pickedquest.data.location)
			surface.DrawMulticolorText(paintLib.WidthSource(672), paintLib.HightSource(293) + paintLib.HightSource(55)*i + y*0.5, "TL X18", {questsColors.GrayLowAlpha, self.pickedquest.data.location})

			surface.SetDrawColor(questsColors.white)
			surface.SetMaterial(materials.description)
			surface.DrawTexturedRect(paintLib.WidthSource(665), paintLib.HightSource(364) + paintLib.HightSource(55)*i, paintLib.WidthSource(22), paintLib.HightSource(27))
			surface.DrawMulticolorText(paintLib.WidthSource(705), paintLib.HightSource(369) + paintLib.HightSource(55)*i, "TL X18", {questsColors.WhiteLowAlpha, "ПОДРОБНОСТИ"})
			surface.SetDrawColor(questsColors.ButtonMain)
			surface.DrawRect(paintLib.WidthSource(651), paintLib.HightSource(400) + paintLib.HightSource(55)*i, paintLib.WidthSource(1227), paintLib.HightSource(40) + height)
			local width, height = surface.DrawMulticolorText(paintLib.WidthSource(661), paintLib.HightSource(410) + paintLib.HightSource(55)*i, "TL X18", {questsColors.GrayLowAlpha, self.pickedquest.data.description}, paintLib.WidthSource(1200))
		end
		-- quest description end --
	end
}

listButtons[5] = {
    name = "ВЕРА",
    icon = {
        img = Material("fantasy/vera.png"),
        w = paintLib.WidthSource(33),
        h = paintLib.WidthSource(33),
    },
    show = function()

    end
}

listButtons[6] = {
    name = "ФРАКЦИЯ",
    icon = {
        img = Material("fantasy/frac.png"),
        w = paintLib.WidthSource(41),
        h = paintLib.WidthSource(26),
    },
    show = function()
        fractionPage()
    end,
    drawfunc = function(self, w, h)
        local ply = LocalPlayer()
        local fractionName = ply:GetFraction()

        if !fractionName then
            draw.SimpleText("ВЫ НЕ СОСТОИТЕ НИ В ОДНОЙ ФРАКЦИИ", "TL X50", w / 2, h / 2, Color(240, 225, 162), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            -- Title
        end
    end
}

local function BuildItemPanel(item, parent)
    local slot = vgui.Create("DPanel", parent)
    slot:Droppable("InventorySlot")
    slot:SetSize(paintLib.WidthSource(100), paintLib.HightSource(100))
    slot.item = item
    slot.ItemData = itemList[item.itemSource]
    slot.Paint = function(self, w, h)
        if self.item then
            ITEMS_TEX.items[self.ItemData.Icon](3,3,w - 6,h - 6)
        end
    end
    slot.oldOnMousePressed = slot.OnMousePressed
    slot.OnMousePressed = function(self, mouseCode)
        if mouseCode == MOUSE_RIGHT then
            local menu = DermaMenu()
            if self.item:CanDrop() then
                menu:AddOption("Выбросить", function()
                    if self.item.quantity == 1 then
                        netstream.Start("fantasy/inventory/dropItem", self.item.x, self.item.y, 1)
                        playerInventory:removeItem(self.item.x, self.item.y, 1)
                        BuildGridItems(inventoryGrid)
                        BuildItems()
                        BuildSlots()
                        return
                    end
                    Derma_NumRequest(
                        "Количество",
                        "Выберите число предмета:",
                        1,
                        1,
                        self.item.quantity,
                        0,
                        function(value)
                            local value = math.floor(value)
                            netstream.Start("fantasy/inventory/dropItem", self.item.x, self.item.y, value)
                            playerInventory:removeItem(self.item.x, self.item.y, value)
                            BuildGridItems(inventoryGrid)
                            BuildItems()
                            BuildSlots()
                        end,
                        function()
                            print("User canceled the request.")
                        end
                    )

                end):SetIcon("icon16/delete.png")

                menu:AddOption("Выбросить все", function()
                    netstream.Start("fantasy/inventory/dropItem", self.item.x, self.item.y, self.item.quantity)
                    playerInventory:removeItem(self.item.x, self.item.y, self.item.quantity)
                    BuildGridItems(inventoryGrid)
                    BuildItems()
                    BuildSlots()
                end):SetIcon("icon16/delete.png")
            end

            if self.ItemData.OnUse then

                local isBound = boundItemData and boundItemData.itemSource == item.itemSource
                if isBound then
                    menu:AddOption("Отвязать от быстрого использования", function()
                        boundItemData = nil
                        SaveBoundItem(nil)
                    end):SetIcon("icon16/cancel.png")
                else
                    menu:AddOption("Привязать к быстрому использованию", function()
                        boundItemData = {
                            itemSource = item.itemSource,
                            icon = item.Icon
                        }
                        SaveBoundItem(item)
                    end):SetIcon("icon16/key.png")
                end

                menu:AddOption("Использовать", function()
                    local deleteOnUse = self.ItemData:DeleteOnUse(inventory, item)
                    if deleteOnUse then playerInventory:removeItem(self.item.x, self.item.y, 1) end
                    BuildGridItems(inventoryGrid)
                    BuildItems()
                    BuildSlots()
                    netstream.Start("fantasy/inventory/useItem", self.item.x, self.item.y)
                end):SetIcon("icon16/accept.png")
            end

            menu:Open()
        end
        self.oldOnMousePressed(self, mouseCode)
    end

    local quantityLabel = vgui.Create("DLabel", slot)
    quantityLabel:SetText((slot.item.quantity == 1) and "" or "x"..slot.item.quantity)
    quantityLabel:SetFont("TLP X10")
    quantityLabel:SetColor(Color(255, 255, 255))
    quantityLabel:SizeToContents()
    quantityLabel:SetPos(5, paintLib.HightSource(75))
    parent.item = item

    slot.OnCursorEntered = function()
        showItemInfo(slot, slot.item)
    end

    slot.OnCursorExited = function()
        if IsValid(infoPanel) then
            infoPanel:Remove()
        end
    end
end

function BuildGridItems(grid)
    local items = grid:GetChildren()
    for k, i in pairs(items) do i:Remove() end
    local counterX = 1
    local counterY = 1
    for i = 1, playerInventory.maxCapacity do
        local slot = grid:Add("DPanel")
        slot:SetSize(paintLib.WidthSource(92), paintLib.HightSource(92))
        slot:SetBackgroundColor(Color(50, 50, 50, 255))
        slot.Position = {
            x = counterX,
            y = counterY
        }
        slot.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, 1, Color(86, 53, 53, 200))
            draw.RoundedBox(0, 0, 0, 1, h, Color(86, 53, 53, 200))
            draw.RoundedBox(0, 0, h - 1, w, 1, Color(86, 53, 53, 200))
            draw.RoundedBox(0, w - 1, 0, 1, h, Color(86, 53, 53, 200))
        end
        slot:Receiver("InventorySlot", function(receiver, panels, dropped)
            if dropped then
                local draggedPanel = panels[1]
                if receiver == draggedPanel:GetParent() then return end
                if draggedPanel.FromSlot then
                    local bSucc, str = playerInventory:unequipItem(draggedPanel.FromSlot, slot.Position)
                    netstream.Start("fantasy/inventory/unequip", draggedPanel.FromSlot, slot.Position)
                    --inventorySubPanel.listSlots[draggedPanel.FromSlot].itemPanel:Remove()
                    BuildGridItems(grid) BuildItems() BuildSlots()
                    timer.Simple(0.1, function()
                       -- playerModel:SetModel( LocalPlayer():GetModel() )
                    end)
                else
                    local fromStorage = (draggedPanel.FromStorage)

                    if fromStorage then
                        Derma_NumRequest(
                            "Количество",
                            "Выберите число предмета:",
                            1,
                            1,
                            draggedPanel.item.quantity,
                            0,
                            function(value)
                                local bSucc, str = storageInventory:transferToInventory(playerInventory, draggedPanel.item.x, draggedPanel.item.y, receiver.Position.x, receiver.Position.y, value)
                                if bSucc then draggedPanel:SetParent(receiver) BuildGridItemsStorage(grid) BuildItemsStorage() BuildGridItems(inventoryGrid) BuildItems() end
                            end,
                            function()
                                print("User canceled the request.")
                            end
                        )
                    else
                        local bSucc, str = playerInventory:transferItem(draggedPanel.item.x, draggedPanel.item.y, receiver.Position.x, receiver.Position.y)
                        if bSucc then draggedPanel:SetParent(receiver) BuildGridItems(grid) BuildItems() end
                    end
                end
            end
        end)
        local slotId = slot.Position.x.."_"..slot.Position.y
        slots[slotId] = slot

        counterX = counterX + 1
        if counterX > 7 then counterX = 1 counterY = counterY + 1 end
    end
end

function BuildItems()
    for _, item in ipairs(playerInventory.items) do
        local slotIndex = item.x.."_"..item.y
        BuildItemPanel(item, slots[slotIndex])
    end
end

function BuildSlots()

    for k, i in pairs(inventorySubPanel.listSlots) do if IsValid(i) then i:Remove() end end
    local weaponSlot = vgui.Create("DPanel", inventorySubPanel)
    weaponSlot:SetSize(paintLib.WidthSource(92), paintLib.HightSource(92))
    weaponSlot:SetPos(paintLib.WidthSource(1365), paintLib.HightSource(200))
    weaponSlot:SetBackgroundColor(Color(50, 50, 50, 255))
    weaponSlot.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, 1, Color(86, 53, 53, 200))
        draw.RoundedBox(0, 0, 0, 1, h, Color(86, 53, 53, 200))
        draw.RoundedBox(0, 0, h - 1, w, 1, Color(86, 53, 53, 200))
        draw.RoundedBox(0, w - 1, 0, 1, h, Color(86, 53, 53, 200))
    end
    local hasWeapon = playerInventory:GetEquippedItem("weapon")
    weaponSlot:Receiver("InventorySlot", function(receiver, panels, dropped)
        if dropped then
            local draggedPanel = panels[1]
            local item = draggedPanel.item
            local itemData = item:getItemData()
            if hasWeapon then return end
            if itemData.type == "weapon" then
                local canEquip, str = item:CheckNeedStat(LocalPlayer())
                if !canEquip then return end
                netstream.Start("fantasy/inventory/equip", item)
                draggedPanel:SetParent(receiver)
                receiver.item = item
                local bSucc, str = playerInventory:equipItem(item)
                if !bSucc then LocalPlayer():ChatPrint(str) end
                BuildGridItems(inventoryGrid)
                BuildItems()
                BuildSlots()
            end
        end
    end)

    if hasWeapon then
        local slot = vgui.Create("DPanel", weaponSlot)
        slot:Droppable("InventorySlot")
        slot:SetSize(paintLib.WidthSource(100), paintLib.HightSource(100))
        slot.item = hasWeapon
        slot.ItemData = hasWeapon:getItemData()
        slot.FromSlot = "weapon"
        slot.Paint = function(self, w, h)
            if self.item then
                ITEMS_TEX.items[self.ItemData.Icon](0, 0, w, h)
            end
        end
        slot.OnCursorEntered = function()
            showItemInfo(slot, slot.item)
        end
        slot.OnCursorExited = function()
            if IsValid(infoPanel) then
                infoPanel:Remove()
            end
        end
        weaponSlot.itemPanel = slot
        inventorySubPanel.listSlots["weaponSub"] = slot
    end
    inventorySubPanel.listSlots["weapon"] = weaponSlot

    local hasWeapon = playerInventory:GetEquippedItem("armor")
    -- Add a armor slot
    local armorSlot = vgui.Create("DPanel", inventorySubPanel)
    armorSlot:SetSize(paintLib.WidthSource(92), paintLib.HightSource(92))
    armorSlot:SetPos(paintLib.WidthSource(1495 + 65), paintLib.HightSource(200))
    armorSlot:SetBackgroundColor(Color(50, 50, 50, 255))
    armorSlot.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, 1, Color(86, 53, 53, 200))
        draw.RoundedBox(0, 0, 0, 1, h, Color(86, 53, 53, 200))
        draw.RoundedBox(0, 0, h - 1, w, 1, Color(86, 53, 53, 200))
        draw.RoundedBox(0, w - 1, 0, 1, h, Color(86, 53, 53, 200))
    end
    armorSlot:Receiver("InventorySlot", function(receiver, panels, dropped)
        if dropped then
            local draggedPanel = panels[1]
            local item = draggedPanel.item
            local itemData = item:getItemData()
            if hasWeapon then return end
            if itemData.type == "armor" then
                local canEquip, str = item:CheckNeedStat(LocalPlayer())
                if !canEquip then return end
                netstream.Start("fantasy/inventory/equip", item)
                --draggedPanel:SetParent(receiver)
                receiver.item = item
                local bSucc, str = playerInventory:equipItem(item)
                if !bSucc then LocalPlayer():ChatPrint(str) end
                BuildGridItems(inventoryGrid)
                BuildItems()
                BuildSlots()
                timer.Simple(0.1, function()
                    --playerModel:SetModel( LocalPlayer():GetModel() )
                end)
            end
        end
    end)

    if hasWeapon then
        local slot = vgui.Create("DPanel", armorSlot)
        slot:Droppable("InventorySlot")
        slot:SetSize(paintLib.WidthSource(100), paintLib.HightSource(100))
        slot.item = hasWeapon
        slot.ItemData = hasWeapon:getItemData()
        slot.FromSlot = "armor"
        slot.Paint = function(self, w, h)
            if self.item then
                ITEMS_TEX.items[self.ItemData.Icon](0, 0, w, h)
            end
        end
        weaponSlot.itemPanel = slot
        inventorySubPanel.listSlots["armorSub"] = slot
    end
    inventorySubPanel.listSlots["armor"] = weaponSlot

    for k = 1, 4 do
        local accSlot = vgui.Create("DPanel", inventorySubPanel)
        accSlot:SetSize(paintLib.WidthSource(92), paintLib.HightSource(92))
        accSlot:SetPos(paintLib.WidthSource(1237) + paintLib.WidthSource(92 + 60) * (k - 1), paintLib.HightSource(375))
        accSlot:SetBackgroundColor(Color(50, 50, 50, 255))
        accSlot.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, 1, Color(86, 53, 53, 200))
            draw.RoundedBox(0, 0, 0, 1, h, Color(86, 53, 53, 200))
            draw.RoundedBox(0, 0, h - 1, w, 1, Color(86, 53, 53, 200))
            draw.RoundedBox(0, w - 1, 0, 1, h, Color(86, 53, 53, 200))
        end
    end


end

local materials = {
    bg = Material("materials/fantasy/bg.png"),
}



function createInventoryFrame(bIgnoreTimer)
    if !bIgnoreTimer and openInventoryTime > CurTime() then return end
	cl_RefreshQuests()
    openInventoryTime = CurTime() + 0.5
    currentDrawFunc = nil
    currentPage = nil
    local ply = LocalPlayer()
    local w, h = ScrW(), ScrH()
    playerPoints = ply:GetSkillPoints()
    if IsValid(inventoryFrame) then inventoryFrame:Remove() end
    inventoryFrame = vgui.Create("DFrame")
    inventoryFrame:SetTitle("")
    inventoryFrame:ShowCloseButton(false)
    inventoryFrame:SetSize(w, h)
    inventoryFrame:Center()
    inventoryFrame:MakePopup()
    inventoryFrame:SetAlpha(0)
    inventoryFrame:AlphaTo(255, 0.2)
    inventoryFrame.Paint = function(self, w, h)
        local IskeyDown = input.IsKeyDown(openInventoryKey)
        if IskeyDown and openInventoryTime < CurTime() and !self.IsClosing then
            self.IsClosing = true
            timer.Simple(0.2, function()
                inventoryFrame:Remove()
            end)
            inventoryFrame:AlphaTo(0, 0.2)
            inventorySubPanel.model:Remove()
            if IsValid(infoPanel) then infoPanel:Close() end
            openInventoryTime = CurTime() + 0.5
        end

        paintLib.DrawRect(materials.bg, 0, 0, w, h, inventoryColors.white)
        if currentDrawFunc then currentDrawFunc(self, w, h) end
    end
	inventorySubPanel = vgui.Create("EditablePanel", inventoryFrame)
    inventorySubPanel:SetSize(w, h)

    navigationPanel = vgui.Create("EditablePanel", inventoryFrame)
    navigationPanel:SetSize(paintLib.WidthSource(1920), paintLib.HightSource(93))
    navigationPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, inventoryColors.semiTransparentBlack)
    end
    local pos = 0
    for k, i in pairs(listButtons) do
        surface.SetFont("TL X33")
        local textw, texth = surface.GetTextSize(i.name)

        textw = textw + paintLib.WidthSource(87)
        local button = vgui.Create("DButton", navigationPanel)
        button:SetSize(textw, paintLib.HightSource(93))
        button:SetPos(pos, 0)
        button:SetText("")
        button.Paint = function(self, w, h)
            local color = self:IsHovered() and inventoryColors.YellowNotLight or inventoryColors.YellowNotLightLowAlpha
            local color = (currentPage == k) and inventoryColors.YellowLight or color
            draw.SimpleText(i.name, "TL X33", w, h * 0.5, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

            if i.icon then
                surface.SetDrawColor(color)
                surface.SetMaterial(i.icon.img)
                local pos = paintLib.WidthSource(93) - (i.icon.w + paintLib.WidthSource(20))
                if k == 2 then pos = paintLib.WidthSource(93) - (i.icon.w + paintLib.WidthSource(10)) end
                surface.DrawTexturedRect(pos, h * 0.5 - i.icon.h * 0.5, i.icon.w, i.icon.h)
            end
        end
        button.DoClick = function(self)
            inventorySubPanel:Clear()
            currentPage = k
            local currentList = listButtons[k]
            currentList.show()
            currentDrawFunc = currentList.drawfunc
        end
        print(pos)
        pos = pos + textw
    end

    local currentList = listButtons[1]
    currentPage = 1
    currentList.show()
    currentDrawFunc = currentList.drawfunc
end

if IsValid(inventoryFrame) then openInventoryTime = 0 createInventoryFrame() end
