local function OpenCraftingMenu(craftingTable)
    if IsValid(craftFrame) then
        craftFrame:Remove()
    end

    -- Основная рамка меню
    craftFrame = vgui.Create("DFrame")
    craftFrame:SetSize(ScrW() * 0.7, ScrH() * 0.7)
    craftFrame:Center()
    craftFrame:SetTitle("")
    craftFrame:SetDraggable(false)
    craftFrame:MakePopup()
    craftFrame:ShowCloseButton(false)

    -- Настраиваем внешний вид меню
    craftFrame.Paint = function(self, w, h)
        -- Фэнтезийный фон
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 40, 240))

        -- Декоративные углы
        local corner_size = 40
        local corner_width = 3

        -- Верхний левый угол
        surface.SetDrawColor(220, 170, 60, 255)
        surface.DrawRect(0, 0, corner_size, corner_width)
        surface.DrawRect(0, 0, corner_width, corner_size)

        -- Верхний правый угол
        surface.DrawRect(w - corner_size, 0, corner_size, corner_width)
        surface.DrawRect(w - corner_width, 0, corner_width, corner_size)

        -- Нижний левый угол
        surface.DrawRect(0, h - corner_width, corner_size, corner_width)
        surface.DrawRect(0, h - corner_size, corner_width, corner_size)

        -- Нижний правый угол
        surface.DrawRect(w - corner_size, h - corner_width, corner_size, corner_width)
        surface.DrawRect(w - corner_width, h - corner_size, corner_width, corner_size)

        -- Заголовок с эффектом свечения
        local titleText = "СОЗДАНИЕ ПРЕДМЕТОВ"
        local titleColor = Color(255, 215, 100)

        -- Основной заголовок
        draw.SimpleText(titleText, "TL X28", w / 2, 40, titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Разделительная линия
        surface.SetDrawColor(220, 170, 60, 150)
        surface.DrawRect(w * 0.1, 80, w * 0.8, 2)


        draw.SimpleText(namesOfCraftableItems[craftingTable], "TL X24", w * 0.5, 100, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Кнопка закрытия
    local closeButton = vgui.Create("DButton", craftFrame)
    closeButton:SetSize(30, 30)
    closeButton:SetPos(craftFrame:GetWide() - 40, 10)
    closeButton:SetText("")
    closeButton.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(60, 60, 80, self:IsHovered() and 180 or 100))
        draw.SimpleText("X", "TL X20", w/2, h/2, self:IsHovered() and Color(255, 100, 100) or Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeButton.DoClick = function()
        craftFrame:AlphaTo(0, 0.3, 0, function()
            craftFrame:Close()
        end)
    end

    -- Левая панель со списком рецептов
    local recipeList = vgui.Create("DScrollPanel", craftFrame)
    recipeList:SetSize(craftFrame:GetWide() * 0.3 - 20, craftFrame:GetTall() - 140)
    recipeList:SetPos(10, 120)

    -- Настраиваем стиль скроллбара
    local scrollBar = recipeList:GetVBar()
    scrollBar:SetWide(10)
    scrollBar.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(50, 50, 60, 100))
    end
    scrollBar.btnUp.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(70, 70, 80, 100))
    end
    scrollBar.btnDown.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(70, 70, 80, 100))
    end
    scrollBar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(100, 100, 120, 150))
    end

    -- Правая панель для отображения деталей рецепта
    local detailsPanel = vgui.Create("DPanel", craftFrame)
    detailsPanel:SetSize(craftFrame:GetWide() * 0.65 - 20, craftFrame:GetTall() - 140)
    detailsPanel:SetPos(craftFrame:GetWide() * 0.3 + 10, 120)
    detailsPanel:SetPaintBackground(false)

    -- Заголовок списка рецептов
    local recipesTitle = vgui.Create("DLabel", craftFrame)
    recipesTitle:SetPos(20, 100)
    recipesTitle:SetSize(craftFrame:GetWide() * 0.3 - 20, 20)
    recipesTitle:SetText("ДОСТУПНЫЕ РЕЦЕПТЫ")
    recipesTitle:SetFont("TL X20")
    recipesTitle:SetTextColor(Color(220, 170, 60))

    -- Переменная для хранения выбранного рецепта
    local selectedRecipe = nil

    -- Функция обновления деталей рецепта
    local function UpdateRecipeDetails(recipe, id)
        detailsPanel:Clear()

        if not recipe then return end

        -- Название предмета
        local itemName = vgui.Create("DLabel", detailsPanel)
        itemName:SetPos(10, 10)
        itemName:SetSize(detailsPanel:GetWide() - 20, 30)
        itemName:SetText(itemList[recipe.item] and itemList[recipe.item].Name or recipe.item)
        itemName:SetFont("TL X26")
        itemName:SetTextColor(Color(255, 215, 100))

        -- Изображение предмета
        local itemIcon = vgui.Create("DPanel", detailsPanel)
        itemIcon:SetPos(10, 50)
        itemIcon:SetSize(120, 120)
        itemIcon.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(60, 60, 70))

            if itemList[recipe.item] and itemList[recipe.item].Icon and ITEMS_TEX and ITEMS_TEX.items[itemList[recipe.item].Icon] then
                ITEMS_TEX.items[itemList[recipe.item].Icon](10, 10, w-20, h-20)
            else
                draw.SimpleText("?", "TL X40", w/2, h/2, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        -- Заголовок списка ингредиентов
        local ingredientsTitle = vgui.Create("DLabel", detailsPanel)
        ingredientsTitle:SetPos(150, 50)
        ingredientsTitle:SetSize(detailsPanel:GetWide() - 170, 30)
        ingredientsTitle:SetText("ТРЕБУЕМЫЕ ИНГРЕДИЕНТЫ:")
        ingredientsTitle:SetFont("TL X20")
        ingredientsTitle:SetTextColor(Color(200, 200, 200))

        -- Список ингредиентов
        local yPos = 90
        for _, ingredient in ipairs(recipe.ingredients) do
            local hasEnough = playerInventory:hasItems(ingredient.item, ingredient.quantity)

            -- Панель ингредиента
            local ingredientPanel = vgui.Create("DPanel", detailsPanel)
            ingredientPanel:SetPos(150, yPos)
            ingredientPanel:SetSize(detailsPanel:GetWide() - 170, 40)
            ingredientPanel.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, Color(50, 50, 60, 150))

                -- Индикатор наличия ингредиентов
                local statusColor = hasEnough and Color(100, 255, 100, 100) or Color(255, 100, 100, 100)
                draw.RoundedBox(0, 0, 0, 5, h, statusColor)
            end

            -- Иконка ингредиента
            local ingredientIcon = vgui.Create("DPanel", ingredientPanel)
            ingredientIcon:SetPos(10, 5)
            ingredientIcon:SetSize(30, 30)
            ingredientIcon.Paint = function(self, w, h)
                if itemList[ingredient.item] and itemList[ingredient.item].Icon and ITEMS_TEX and ITEMS_TEX.items[itemList[ingredient.item].Icon] then
                    ITEMS_TEX.items[itemList[ingredient.item].Icon](0, 0, w, h)
                else
                    draw.RoundedBox(4, 0, 0, w, h, Color(70, 70, 80))
                end
            end

            -- Название ингредиента
            local ingredientName = vgui.Create("DLabel", ingredientPanel)
            ingredientName:SetPos(50, 5)
            ingredientName:SetSize(ingredientPanel:GetWide() - 120, 30)
            ingredientName:SetText(itemList[ingredient.item] and itemList[ingredient.item].Name or ingredient.item)
            ingredientName:SetFont("TL X18")
            ingredientName:SetTextColor(hasEnough and Color(255, 255, 255) or Color(255, 150, 150))

            -- Количество ингредиента
            local ingredientCount = vgui.Create("DLabel", ingredientPanel)
            ingredientCount:SetPos(ingredientPanel:GetWide() - 60, 5)
            ingredientCount:SetSize(50, 30)
            ingredientCount:SetText("x" .. ingredient.quantity)
            ingredientCount:SetFont("TL X18")
            ingredientCount:SetTextColor(hasEnough and Color(255, 255, 255) or Color(255, 150, 150))

            yPos = yPos + 45
        end

        if recipe.needSkills then
            -- Title for skill requirements
            local skillsTitle = vgui.Create("DLabel", detailsPanel)
            skillsTitle:SetPos(150, yPos)
            skillsTitle:SetSize(detailsPanel:GetWide() - 170, 30)
            skillsTitle:SetText("ТРЕБУЕМЫЕ НАВЫКИ:")
            skillsTitle:SetFont("TL X20")
            skillsTitle:SetTextColor(Color(200, 200, 200))

            yPos = yPos + 35
            local skills = LocalPlayer():GetAttributesSkills()
            -- List each required skill
            for skillCategory, skillTable in pairs(recipe.needSkills) do
                skills[skillCategory] = skills[skillCategory] or {}
                for skillName, skillLevel in pairs(skillTable) do
                    local playerSkill = skills[skillCategory][skillName] or 0
                    local hasSkill = playerSkill >= skillLevel

                    -- Skill panel
                    local skillPanel = vgui.Create("DPanel", detailsPanel)
                    skillPanel:SetPos(150, yPos)
                    skillPanel:SetSize(detailsPanel:GetWide() - 170, 40)
                    skillPanel.Paint = function(self, w, h)
                        draw.RoundedBox(6, 0, 0, w, h, Color(50, 50, 60, 150))

                        -- Indicator for skill requirement
                        local statusColor = hasSkill and Color(100, 255, 100, 100) or Color(255, 100, 100, 100)
                        draw.RoundedBox(0, 0, 0, 5, h, statusColor)
                    end

                    -- Skill icon (you might want to replace this with actual skill icons)
                    local skillIcon = vgui.Create("DPanel", skillPanel)
                    skillIcon:SetPos(10, 5)
                    skillIcon:SetSize(30, 30)
                    skillIcon.Paint = function(self, w, h)
                        draw.RoundedBox(4, 0, 0, w, h, Color(70, 70, 80))
                        local firstLetter = string.upper(string.sub(skillName, 1, 1))
                        draw.SimpleText(firstLetter, "TL X20", w/2, h/2, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end

                    -- Skill name
                    local formattedSkillName = skillName:gsub("^%l", string.upper) -- Capitalize first letter
                    local skillNameLabel = vgui.Create("DLabel", skillPanel)
                    skillNameLabel:SetPos(50, 5)
                    skillNameLabel:SetSize(skillPanel:GetWide() - 120, 30)
                    skillNameLabel:SetText(namesOfCraftSkills[skillName])
                    skillNameLabel:SetFont("TL X18")
                    skillNameLabel:SetTextColor(hasSkill and Color(255, 255, 255) or Color(255, 150, 150))

                    -- Skill requirement
                    local skillReqLabel = vgui.Create("DLabel", skillPanel)
                    skillReqLabel:SetPos(skillPanel:GetWide() - 60, 5)
                    skillReqLabel:SetSize(90, 30)
                    local reqText = playerSkill .. "/" .. skillLevel
                    skillReqLabel:SetText(reqText)
                    skillReqLabel:SetFont("TL X18")
                    skillReqLabel:SetTextColor(hasSkill and Color(255, 255, 255) or Color(255, 150, 150))

                    yPos = yPos + 45

                    -- Update canCraft flag based on skill requirements
                    if not hasSkill then
                        canCraft = false
                    end
                end
            end

            -- Add some spacing before ingredients
            yPos = yPos + 10
        end

        -- Then position the ingredients title at the current yPos
        yPos = yPos + 35

        -- Кнопка крафта
        local craftButton = vgui.Create("DButton", detailsPanel)
        craftButton:SetPos(detailsPanel:GetWide() / 2 - 100, detailsPanel:GetTall() - 60)
        craftButton:SetSize(200, 50)
        craftButton:SetText("")

        -- Проверяем, достаточно ли ингредиентов для крафта
        local canCraft = true
        for _, ingredient in ipairs(recipe.ingredients) do
            if not playerInventory:hasItems(ingredient.item, ingredient.quantity) then
                canCraft = false
                break
            end
        end
        local skills = LocalPlayer():GetAttributesSkills()
        if canCraft and recipe.needSkills then
            for skillCtagory, skillTable in pairs(recipe.needSkills) do
                skills[skillCtagory] = skills[skillCtagory] or {}
                for skillName, skillLevel in pairs(skillTable) do
                    local playerSkill = skills[skillCtagory][skillName] or 0
                    if playerSkill < skillLevel then
                        canCraft = false
                        break
                    end
                end
            end
        end

        -- Анимации для кнопки
        local buttonHovered = false
        local buttonGlow = 0

        craftButton.Paint = function(self, w, h)
            -- Обновляем состояние наведения
            buttonHovered = self:IsHovered() and canCraft

            -- Анимация свечения
            if buttonHovered then
                buttonGlow = math.min(buttonGlow + 0.05, 1)
            else
                buttonGlow = math.max(buttonGlow - 0.05, 0)
            end

            -- Цвета кнопки в зависимости от возможности крафта
            local baseColor = canCraft and Color(60 + 40 * buttonGlow, 60 + 30 * buttonGlow, 80 + 20 * buttonGlow) or Color(80, 70, 70)
            local borderColor = canCraft and Color(220, 170, 60, 150 + 105 * buttonGlow) or Color(150, 100, 100)
            local textColor = canCraft and Color(220, 170, 60, 200 + 55 * buttonGlow) or Color(150, 150, 150)

            -- Фон кнопки
            draw.RoundedBox(8, 0, 0, w, h, baseColor)

            -- Свечение при наведении
            if buttonGlow > 0 then
                for i = 1, 3 do
                    draw.RoundedBox(8 + i, -i, -i, w + i*2, h + i*2, Color(220, 170, 60, 30 * buttonGlow))
                end
            end

            -- Рамка кнопки
            surface.SetDrawColor(borderColor)
            for i = 0, 1 do
                surface.DrawOutlinedRect(i, i, w-i*2, h-i*2, 1)
            end

            -- Текст кнопки с тенью
            draw.SimpleText("СОЗДАТЬ ПРЕДМЕТ", "TL X18", w/2 + 1, h/2 + 1, Color(0, 0, 0, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("СОЗДАТЬ ПРЕДМЕТ", "TL X18", w/2, h/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            -- Индикатор количества создаваемых предметов
            if recipe.craftedItemsCount > 1 then
                draw.SimpleText("(x" .. recipe.craftedItemsCount .. ")", "TL X14", w/2, h/2 + 20, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        craftButton.DoClick = function()
            if canCraft then
                surface.PlaySound("ui/buttonclick.wav")

                netstream.Start("fantasy/craft/create", craftingTable, id)

                timer.Simple(0.2, function()
                    if IsValid(craftFrame) then
                        UpdateRecipeDetails(recipe, id)
                    end
                end)
            else
                surface.PlaySound("buttons/button8.wav")
            end
        end
    end

    -- Заполняем список рецептов
    if CraftableItems[craftingTable] then
        for i, recipe in ipairs(CraftableItems[craftingTable]) do
			if recipe.needrecipe then
				if not table.HasValue(LocalPlayer().characterData["knowRecipes"] or {}, recipe.needrecipe) then
					continue
				end
			end
            local recipeButton = vgui.Create("DButton", recipeList)
            recipeButton:SetSize(recipeList:GetWide() - 20, 60)
            recipeButton:SetText("")
            recipeButton:Dock(TOP)
            recipeButton:DockMargin(5, 5, 5, 5)

            -- Проверяем, достаточно ли ингредиентов для крафта
            local canCraft = true
            for _, ingredient in ipairs(recipe.ingredients) do
                if not playerInventory:hasItems(ingredient.item, ingredient.quantity) then
                    canCraft = false
                    break
                end
            end
            local skills = LocalPlayer():GetAttributesSkills()
            if canCraft and recipe.needSkills then
                for skillCtagory, skillTable in pairs(recipe.needSkills) do
                    skills[skillCtagory] = skills[skillCtagory] or {}
                    for skillName, skillLevel in pairs(skillTable) do
                        local playerSkill = skills[skillCtagory][skillName] or 0
                        if playerSkill < skillLevel then
                            canCraft = false
                            break
                        end
                    end
                end
            end

            recipeButton.Paint = function(self, w, h)
                local bgColor = (selectedRecipe == recipe) and Color(70, 70, 90) or Color(60, 60, 70)
                if self:IsHovered() then
                    bgColor = Color(80, 80, 100)
                end

                draw.RoundedBox(6, 0, 0, w, h, bgColor)

                -- Индикатор возможности крафта
                local craftColor = canCraft and Color(100, 255, 100, 100) or Color(255, 100, 100, 100)
                draw.RoundedBox(0, 0, 0, 4, h, craftColor)

                -- Иконка предмета
                if itemList[recipe.item] and itemList[recipe.item].Icon and ITEMS_TEX and ITEMS_TEX.items[itemList[recipe.item].Icon] then
                    ITEMS_TEX.items[itemList[recipe.item].Icon](10, 5, 50, 50)
                else
                    draw.RoundedBox(4, 10, 5, 50, 50, Color(70, 70, 80))
                    draw.SimpleText("?", "TL X28", 35, 30, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                -- Название предмета
                draw.SimpleText(itemList[recipe.item] and itemList[recipe.item].Name or recipe.item, "TL X18", 70, 30, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                -- Индикатор количества крафта
                if recipe.craftedItemsCount > 1 then
                    draw.SimpleText("x" .. recipe.craftedItemsCount, "TL X16", w - 15, 30, Color(200, 200, 200), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                end
            end

            recipeButton.OnCursorEntered = function()
                surface.PlaySound("ui/buttonrollover.wav")
            end

            recipeButton.DoClick = function()
                surface.PlaySound("ui/buttonclickrelease.wav")
                selectedRecipe = recipe
                UpdateRecipeDetails(recipe, i)
            end

            -- Выбираем первый рецепт по умолчанию
            if i == 1 then
                selectedRecipe = recipe
                UpdateRecipeDetails(recipe, i)
            end
        end
    else
        -- Если нет доступных рецептов
        local noRecipesLabel = vgui.Create("DLabel", recipeList)
        noRecipesLabel:Dock(TOP)
        noRecipesLabel:SetTall(50)
        noRecipesLabel:SetText("Нет доступных рецептов")
        noRecipesLabel:SetFont("TL X18")
        noRecipesLabel:SetTextColor(Color(200, 200, 200))
        noRecipesLabel:SetContentAlignment(5) -- По центру
    end

    -- Анимация открытия
    craftFrame:SetAlpha(0)
    craftFrame:AlphaTo(255, 0.3, 0)
end

netstream.Hook("fnt/craft", function(arg)
    OpenCraftingMenu(arg)
end)
