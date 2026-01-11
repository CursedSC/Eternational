function skilltree(arguments)
    local playerJobs = LocalPlayer():GetCharacterData("jobs", {})
    local hasNoJobs = (table.Count(playerJobs) <= 0)
    if hasNoJobs then
        return
    end
    -- Основная панель для древа навыков с прокруткой
    local skillTreePanel = vgui.Create("DScrollPanel", inventorySubPanel)
    skillTreePanel:SetPos(paintLib.WidthSource(56), paintLib.HightSource(169))
    skillTreePanel:SetSize(paintLib.WidthSource(1150), paintLib.HightSource(820))

    -- Настройка скроллбара
    local vbar = skillTreePanel:GetVBar()
    vbar:SetWide(8)
    vbar.Paint = function(self, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 100)) end
    vbar.btnUp.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 70)) end
    vbar.btnDown.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 70)) end
    vbar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(60, 60, 70)) end

    -- Панель для отображения выбранного навыка
    local skillInfoPanel = vgui.Create("DPanel", inventorySubPanel)
    skillInfoPanel:SetPos(paintLib.WidthSource(1237), paintLib.HightSource(169))
    skillInfoPanel:SetSize(paintLib.WidthSource(627), paintLib.HightSource(820))
    skillInfoPanel.Paint = function(self, w, h)
        -- Фон для информации о навыке
        draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 40, 200))

        -- Рамка
        draw.RoundedBox(0, 0, 0, w, 1, Color(86, 53, 53, 200))
        draw.RoundedBox(0, 0, 0, 1, h, Color(86, 53, 53, 200))
        draw.RoundedBox(0, 0, h - 1, w, 1, Color(86, 53, 53, 200))
        draw.RoundedBox(0, w - 1, 0, 1, h, Color(86, 53, 53, 200))

        if not skillInfoPanel.selectedSkill then
            draw.SimpleText("Выберите навык для просмотра информации", "TL X20", w/2, h/2, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    -- Переменные для позиционирования и отслеживания
    local skillNodes = {}
    local skillConnections = {}
    local skillCategories = {}

    -- Функция для обновления информации о выбранном навыке
    local function UpdateSkillInfo(skillData, category, skillId)
        skillInfoPanel.selectedSkill = skillData
        skillInfoPanel.category = category
        skillInfoPanel.skillId = skillId

        -- Очистим предыдущие элементы, если они существуют
        if skillInfoPanel.content then
            skillInfoPanel.content:Remove()
        end

        -- Создаем контент для информации о навыке
        local content = vgui.Create("DPanel", skillInfoPanel)
        content:SetPos(paintLib.WidthSource(20), paintLib.HightSource(20))
        content:SetSize(skillInfoPanel:GetWide() - paintLib.WidthSource(40), skillInfoPanel:GetTall() - paintLib.HightSource(40))
        content:SetPaintBackground(false)
        skillInfoPanel.content = content

        -- Название навыка
        local nameLabel = vgui.Create("DLabel", content)
        nameLabel:SetPos(0, 0)
        nameLabel:SetFont("TL X28")
        nameLabel:SetText(skillData.name)
        nameLabel:SetTextColor(Color(240, 225, 162))
        nameLabel:SizeToContents()

        -- Описание навыка
        local descLabel = vgui.Create("DLabel", content)
        descLabel:SetPos(0, paintLib.HightSource(50))
        descLabel:SetFont("TL X18")
        descLabel:SetText(skillData.description)
        descLabel:SetTextColor(Color(200, 200, 200))
        descLabel:SetWrap(true)
        descLabel:SetSize(content:GetWide(), paintLib.HightSource(100))
        descLabel:SetAutoStretchVertical(true)
        -- Секция требуемых навыков
        local requiredY = descLabel:GetTall() + paintLib.HightSource(70)

        if table.Count(skillData.needSkills) > 0 then
            local reqTitle = vgui.Create("DLabel", content)
            reqTitle:SetPos(0, requiredY)
            reqTitle:SetFont("TL X20")
            reqTitle:SetText("ТРЕБУЕМЫЕ НАВЫКИ:")
            reqTitle:SetTextColor(Color(200, 200, 200))
            reqTitle:SizeToContents()

            requiredY = requiredY + reqTitle:GetTall() + paintLib.HightSource(10)

            for reqCategory, reqSkillId in pairs(skillData.needSkills) do
                local reqSkill = listAttributeSkill[reqCategory][reqSkillId]
                local playerHasSkill = LocalPlayer():GetAttributesSkills()[reqCategory] and LocalPlayer():GetAttributesSkills()[reqCategory][reqSkillId]

                local reqPanel = vgui.Create("DPanel", content)
                reqPanel:SetPos(0, requiredY)
                reqPanel:SetSize(content:GetWide(), paintLib.HightSource(40))
                reqPanel.Paint = function(self, w, h)
                    -- Фон с индикацией наличия навыка
                    local bgColor = playerHasSkill and Color(60, 80, 60, 150) or Color(80, 60, 60, 150)
                    draw.RoundedBox(4, 0, 0, w, h, bgColor)

                    -- Индикатор статуса
                    local statusColor = playerHasSkill and Color(100, 255, 100) or Color(255, 100, 100)
                    draw.RoundedBox(0, 0, 0, 4, h, statusColor)

                    -- Название навыка
                    draw.SimpleText(reqSkill.name, "TL X18", 15, h/2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                    -- Статус
                    local statusText = playerHasSkill and "Изучено" or "Не изучено"
                    draw.SimpleText(statusText, "TL X16", w - 10, h/2, statusColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                end

                requiredY = requiredY + reqPanel:GetTall() + paintLib.HightSource(5)
            end
        end

        -- Секция блокируемых навыков
        local blockedY = requiredY + paintLib.HightSource(20)

        if table.Count(skillData.blockedSkills) > 0 then
            local blockTitle = vgui.Create("DLabel", content)
            blockTitle:SetPos(0, blockedY)
            blockTitle:SetFont("TL X20")
            blockTitle:SetText("БЛОКИРУЕТ НАВЫКИ:")
            blockTitle:SetTextColor(Color(200, 200, 200))
            blockTitle:SizeToContents()

            blockedY = blockedY + blockTitle:GetTall() + paintLib.HightSource(10)

            for blockCategory, blockSkillId in pairs(skillData.blockedSkills) do
                local blockSkill = listAttributeSkill[blockCategory][blockSkillId]

                local blockPanel = vgui.Create("DPanel", content)
                blockPanel:SetPos(0, blockedY)
                blockPanel:SetSize(content:GetWide(), paintLib.HightSource(40))
                blockPanel.Paint = function(self, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, Color(80, 60, 60, 150))
                    draw.RoundedBox(0, 0, 0, 4, h, Color(255, 150, 150))
                    draw.SimpleText(blockSkill.name, "TL X18", 15, h/2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end

                blockedY = blockedY + blockPanel:GetTall() + paintLib.HightSource(5)
            end
        end
        -- Проверяем, можно ли изучить этот навык
        local playerSkills = LocalPlayer():GetAttributesSkills() or {}
        local canLearn = true
        local reasonCantLearn = ""

        -- Проверяем, изучен ли уже навык
        if playerSkills[category] and playerSkills[category][skillId] then
            canLearn = false
            reasonCantLearn = "Навык уже изучен"
        end

        -- Проверяем требуемые навыки
        for reqCategory, reqSkillId in pairs(skillData.needSkills) do
            if not playerSkills[reqCategory] or not playerSkills[reqCategory][reqSkillId] then
                canLearn = false
                reasonCantLearn = "Не изучены требуемые навыки"
                break
            end
        end

        -- Проверяем блокирующие навыки
        for category, skills in pairs(playerSkills) do
            for playerSkillId, _ in pairs(skills) do
                local blockingSkill = listAttributeSkill[category] and listAttributeSkill[category][playerSkillId]
                if blockingSkill and blockingSkill.blockedSkills and
                   blockingSkill.blockedSkills[category] == skillId then
                    canLearn = false
                    reasonCantLearn = "Заблокировано навыком " .. blockingSkill.name
                    break
                end
            end
        end

        -- Проверяем очки навыков
        if LocalPlayer():GetAttributesSkillsPoints() <= 0 then
            canLearn = false
            reasonCantLearn = "Недостаточно очков навыков"
        end

        -- Кнопка изучения навыка
        local learnButton = vgui.Create("DButton", content)
        learnButton:SetPos(paintLib.WidthSource(0), content:GetTall() - paintLib.HightSource(60))
        learnButton:SetSize(content:GetWide(), paintLib.HightSource(50))
        learnButton:SetText("")

        local buttonHovered = false
        local buttonGlow = 0

        learnButton.Paint = function(self, w, h)
            -- Обновляем состояние наведения
            buttonHovered = self:IsHovered() and canLearn

            -- Анимация свечения
            if buttonHovered then
                buttonGlow = math.min(buttonGlow + 0.05, 1)
            else
                buttonGlow = math.max(buttonGlow - 0.05, 0)
            end

            -- Цвета кнопки в зависимости от возможности изучения
            local baseColor = canLearn and Color(60 + 40 * buttonGlow, 60 + 30 * buttonGlow, 80 + 20 * buttonGlow) or Color(80, 70, 70)
            local borderColor = canLearn and Color(220, 170, 60, 150 + 105 * buttonGlow) or Color(150, 100, 100)
            local textColor = canLearn and Color(220, 170, 60, 200 + 55 * buttonGlow) or Color(150, 150, 150)

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

            -- Текст кнопки
            local buttonText = canLearn and "ИЗУЧИТЬ НАВЫК" or "НЕДОСТУПНО: " .. reasonCantLearn
            draw.SimpleText(buttonText, "TL X20", w/2, h/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        learnButton.DoClick = function()
            if canLearn then
                -- Звуковой эффект при нажатии
                surface.PlaySound("ui/buttonclick.wav")

                -- Отправить запрос на изучение навыка
                netstream.Start("fantasy/skill/learn", category, skillId)

                -- Обновить информацию и визуализацию
                timer.Simple(0.2, function()
                    if IsValid(skillTreePanel) then
                        UpdateSkillInfo(skillData, category, skillId)
                        CreateSkillTreeVisualization()
                    end
                end)
            else
                surface.PlaySound("buttons/button8.wav")
            end
        end
    end
    -- Функция для создания визуализации дерева навыков
    function CreateSkillTreeVisualization()
        -- Очистим предыдущие элементы
        for _, node in pairs(skillNodes) do
            if IsValid(node) then node:Remove() end
        end

        skillNodes = {}
        skillConnections = {}

       -- Внутри функции CreateSkillTreeVisualization()
-- Заменить существующее группирование и позиционирование на следующее:

-- Получаем текущие навыки игрока
local playerSkills = LocalPlayer():GetAttributesSkills() or {}

-- Определяем категории навыков
local categories = {}
for categoryName, _ in pairs(listAttributeSkill) do
    if playerJobs[categoryName] then
        table.insert(categories, categoryName)
    end
end

-- Размеры и отступы для узлов дерева
local nodeWidth = paintLib.WidthSource(150)
local nodeHeight = paintLib.HightSource(100)
local horizontalSpacing = paintLib.WidthSource(100)
local verticalSpacing = paintLib.HightSource(70) -- Увеличенный вертикальный отступ
local startX = paintLib.WidthSource(50)
local startY = paintLib.HightSource(50)

-- Для каждой категории
for categoryIndex, category in ipairs(categories) do
    -- Создаем заголовок для категории
    local categoryTitle = vgui.Create("DLabel", skillTreePanel)
    categoryTitle:SetPos(startX, startY)
    categoryTitle:SetFont("TL X24")
    categoryTitle:SetText(namesOfCraftSkills[category] or category:upper())
    categoryTitle:SetTextColor(Color(240, 225, 162))
    categoryTitle:SizeToContents()

    skillCategories[category] = {
        title = categoryTitle,
        y = startY + categoryTitle:GetTall() + paintLib.HightSource(20)
    }

    -- Для каждого навыка в категории
    local categorySkills = listAttributeSkill[category]
    local skillsByY = {} -- Группируем по Y значению из таблицы
    local maxY = 0

    -- Сначала группируем навыки по Y значению
    for skillId, skillData in pairs(categorySkills) do
        local yValue = skillData.y or 1 -- Используем Y из данных навыка
        if yValue > maxY then maxY = yValue end

        skillsByY[yValue] = skillsByY[yValue] or {}
        table.insert(skillsByY[yValue], {id = skillId, data = skillData})
    end

    -- Отображаем навыки по уровням Y
    for y = 1, maxY do
        if not skillsByY[y] then continue end

        local ySkills = skillsByY[y]
        local skillCount = #ySkills
        local totalWidth = skillCount * nodeWidth + (skillCount - 1) * horizontalSpacing

        -- Вычисляем начальную X координату для центрирования группы навыков
        local centerStartX = startX + paintLib.WidthSource(450) - totalWidth / 2
        local levelY = skillCategories[category].y + (y - 1) * (nodeHeight + verticalSpacing)

        -- Отображаем навыки текущего Y уровня
        for skillIndex, skillInfo in ipairs(ySkills) do
            local skillId = skillInfo.id
            local skillData = skillInfo.data

            -- Вычисляем позицию с учетом центрирования
            local nodeX = centerStartX + (skillIndex - 1) * (nodeWidth + horizontalSpacing)

            -- Создаем узел навыка
            local node = vgui.Create("DButton", skillTreePanel)
            node:SetPos(nodeX, levelY)
            node:SetSize(nodeWidth, nodeHeight)
            node:SetText("")

            -- Определяем статус навыка
            local isLearned = playerSkills[category] and playerSkills[category][skillId]
            local canLearn = true

            -- Проверяем требования
            for reqCategory, reqSkillId in pairs(skillData.needSkills) do
                if not playerSkills[reqCategory] or not playerSkills[reqCategory][reqSkillId] then
                    canLearn = false
                    break
                end
            end

            -- Проверяем блокирующие навыки
            for cat, skills in pairs(playerSkills) do
                for playerSkillId, _ in pairs(skills) do
                    local blockingSkill = listAttributeSkill[cat] and listAttributeSkill[cat][playerSkillId]
                    if blockingSkill and blockingSkill.blockedSkills and
                       blockingSkill.blockedSkills[category] == skillId then
                        canLearn = false
                        break
                    end
                end
            end

            node.Paint = function(self, w, h)
                -- Определяем цвет узла
                local nodeColor
                if isLearned then
                    nodeColor = Color(60, 120, 60) -- Зеленый для изученных
                elseif canLearn then
                    nodeColor = Color(60, 60, 120) -- Синий для доступных
                else
                    nodeColor = Color(100, 60, 60) -- Красный для недоступных
                end

                -- Дополнительное свечение при наведении
                if self:IsHovered() then
                    nodeColor = Color(nodeColor.r + 30, nodeColor.g + 30, nodeColor.b + 30)
                end

                -- Основной фон
                draw.RoundedBox(8, 0, 0, w, h, nodeColor)

                -- Рамка
                surface.SetDrawColor(240, 225, 162, 200)
                for i = 0, 1 do
                    surface.DrawOutlinedRect(i, i, w-i*2, h-i*2, 1)
                end

                -- Название навыка
                draw.SimpleText(skillData.name, "TL X16", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            node.DoClick = function()
                UpdateSkillInfo(skillData, category, skillId)
                surface.PlaySound("ui/buttonclickrelease.wav")
            end

            node.OnCursorEntered = function()
                surface.PlaySound("ui/buttonrollover.wav")
            end

            -- Сохраняем информацию о узле
            skillNodes[category .. "_" .. skillId] = node

            -- Создаем соединения между узлами
            for reqCategory, reqSkillId in pairs(skillData.needSkills) do
                table.insert(skillConnections, {
                    from = reqCategory .. "_" .. reqSkillId,
                    to = category .. "_" .. skillId
                })
            end
        end
    end

    -- Увеличиваем Y для следующей категории
    startY = skillCategories[category].y + (maxY * (nodeHeight + verticalSpacing)) + paintLib.HightSource(50)
end
    end

    -- Функция отрисовки соединений между узлами
    skillTreePanel.PaintOver = function(self, w, h)
        for _, connection in ipairs(skillConnections) do
            local fromNode = skillNodes[connection.from]
            local toNode = skillNodes[connection.to]

            if IsValid(fromNode) and IsValid(toNode) then
                local fromX = fromNode:GetX() + fromNode:GetWide()/2
                local fromY = fromNode:GetY() + fromNode:GetTall()
                local toX = toNode:GetX() + toNode:GetWide()/2
                local toY = toNode:GetY()

                -- Определяем цвет линии
                local playerSkills = LocalPlayer():GetAttributesSkills() or {}
                local fromParts = string.Split(connection.from, "_")
                local fromCategory = fromParts[1]
                local fromSkillId = fromParts[2]

                local toParts = string.Split(connection.to, "_")
                local toCategory = toParts[1]
                local toSkillId = toParts[2]

                local fromLearned = playerSkills[fromCategory] and playerSkills[fromCategory][fromSkillId]
                local toLearned = playerSkills[toCategory] and playerSkills[toCategory][toSkillId]

                local lineColor
                if fromLearned and toLearned then
                    lineColor = Color(100, 255, 100) -- Зеленый для полностью изученного пути
                elseif fromLearned then
                    lineColor = Color(255, 215, 0) -- Золотой для доступного пути
                else
                    lineColor = Color(150, 150, 150) -- Серый для недоступного пути
                end

                -- Рисуем линию
                surface.SetDrawColor(lineColor)
                surface.DrawLine(fromX, fromY, toX, toY)

                -- Рисуем стрелку
                local arrowSize = paintLib.WidthSource(5)
                local angle = math.atan2(toY - fromY, toX - fromX)
                local arrowX1 = toX - arrowSize * math.cos(angle - math.rad(30))
                local arrowY1 = toY - arrowSize * math.sin(angle - math.rad(30))
                local arrowX2 = toX - arrowSize * math.cos(angle + math.rad(30))
                local arrowY2 = toY - arrowSize * math.sin(angle + math.rad(30))

                surface.DrawLine(toX, toY, arrowX1, arrowY1)
                surface.DrawLine(toX, toY, arrowX2, arrowY2)
            end
        end
    end

    -- Создаем визуализацию дерева навыков
    CreateSkillTreeVisualization()

    -- Обработчик сетевых сообщений для обновления дерева навыков
end

netstream.Hook("fantasy/skill/update", function()
    if IsValid(skillTreePanel) then
        CreateSkillTreeVisualization()
        if skillInfoPanel.selectedSkill then
            UpdateSkillInfo(skillInfoPanel.selectedSkill, skillInfoPanel.category, skillInfoPanel.skillId)
        end
    end
end)
