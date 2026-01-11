local meta = FindMetaTable("Player")

function DrawQuestBoard(quests)
    if IsValid(QuestPanel) then return end

    -- Create main panel
    QuestPanel = vgui.Create("DFrame")
    QuestPanel:SetSize(paintLib.WidthSource(1200), paintLib.HightSource(800))
    QuestPanel:Center()
    QuestPanel:SetTitle("")
    QuestPanel:MakePopup()
    QuestPanel:SetDraggable(false)
    QuestPanel:ShowCloseButton(false)

    -- Main panel paint function
    QuestPanel.Paint = function(self, w, h)
        -- Base background (worn wooden board)
        draw.RoundedBox(0, 0, 0, w, h, Color(40, 35, 30, 250))

        -- Draw wood texture/grain lines
        for i = 0, h, 20 do
            surface.SetDrawColor(30, 25, 20, 100)
            surface.DrawLine(0, i, w, i)
        end

        -- Panel border (nailed metal frame)
        surface.SetDrawColor(60, 55, 50, 255)
        surface.DrawOutlinedRect(0, 0, w, h, 4)

        -- Title area
        draw.RoundedBox(0, 50, 20, w-100, 60, Color(50, 45, 40, 200))
        draw.SimpleText("ДОСКА ЗАДАНИЙ", "TL X38", w/2, 50, Color(220, 210, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Weathered effect on edges
        for i = 0, 10 do
            surface.SetDrawColor(20, 15, 10, 5)
            surface.DrawOutlinedRect(i, i, w-i*2, h-i*2, 1)
        end

        -- Nail decorations in corners
        local nailPositions = {
            {20, 20}, {w-20, 20}, {20, h-20}, {w-20, h-20},
            {w/2, 15}, {w/2, h-15}
        }

        for _, pos in pairs(nailPositions) do
            draw.RoundedBox(8, pos[1]-5, pos[2]-5, 10, 10, Color(70, 70, 70))
            draw.RoundedBox(4, pos[1]-2, pos[2]-2, 4, 4, Color(120, 120, 120))
        end
    end

    -- Create scroll panel for quest cards
    local scrollPanel = vgui.Create("DScrollPanel", QuestPanel)
    scrollPanel:SetSize(paintLib.WidthSource(1100), paintLib.HightSource(650))
    scrollPanel:SetPos(paintLib.WidthSource(50), paintLib.HightSource(100))

    -- Customize scrollbar
    local scrollBar = scrollPanel:GetVBar()
    scrollBar:SetHideButtons(true)
    scrollBar.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(40, 35, 30, 100))
    end
    scrollBar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(6, 2, 0, w-4, h, Color(80, 75, 70, 150))
    end

    -- Create quest layout
    local questLayout = vgui.Create("DIconLayout", scrollPanel)
    questLayout:Dock(FILL)
    questLayout:SetSpaceX(paintLib.WidthSource(20))
    questLayout:SetSpaceY(paintLib.HightSource(20))

    -- Create quest cards
    for k, v in pairs(quests) do
        if not v then continue end

        local questCard = questLayout:Add("DPanel")
        questCard:SetSize(paintLib.WidthSource(330), paintLib.HightSource(200))
        questCard.data = v
		questCard.num = k
        questCard.isFlipped = false
        questCard.isAnimating = false

        -- Paint function for the quest card
        questCard.Paint = function(self, w, h)
            -- Card background
            draw.RoundedBox(4, 0, 0, w, h, Color(60, 55, 50, 255))

            -- Card border
            surface.SetDrawColor(80, 75, 70, 200)
            surface.DrawOutlinedRect(0, 0, w, h, 2)

            -- Worn paper texture effect
            for i = 1, 5 do
                local x, y = math.random(5, w-5), math.random(5, h-5)
                local size = math.random(2, 5)
                draw.RoundedBox(0, x, y, size, size, Color(230, 220, 200, math.random(5, 15)))
            end

            -- Content based on flip state
            if self.isFlipped then
                -- Show quest details when flipped
                draw.RoundedBox(0, 5, 5, w-10, 30, Color(50, 45, 40, 150))
                draw.SimpleText("ОПИСАНИЕ:", "TL X20", 15, 20, Color(220, 210, 180), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                -- Draw quest description
                local descText = self.data.description or "Нет описания"
                local wrap = 35
                local lines = {}
                local words = string.Explode(" ", descText)
                local currentLine = ""

                for _, word in pairs(words) do
                    if string.len(currentLine) + string.len(word) > wrap then
                        table.insert(lines, currentLine)
                        currentLine = word .. " "
                    else
                        currentLine = currentLine .. word .. " "
                    end
                end
                if currentLine ~= "" then table.insert(lines, currentLine) end

                for lineNum, line in pairs(lines) do
                    draw.SimpleText(line, "TL X18", 15, 40 + (lineNum * 20), Color(200, 200, 180), TEXT_ALIGN_LEFT)
                end

                -- Accept button
                draw.RoundedBox(4, w/2-70, h-45, 140, 35, Color(40, 70, 40, 180))
                draw.SimpleText("ПРИНЯТЬ", "TL X20", w/2, h-27, Color(220, 220, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            else
                -- Show quest name when not flipped
                local questName = self.data.title or "Неизвестный квест"

                -- Draw difficulty indicators (stars)
                for i = 1, self.data.difficulty do  -- Random difficulty for demo
                    draw.SimpleText("★", "TL X18", 10 + (i * 15), 20, Color(220, 180, 60), TEXT_ALIGN_CENTER)
                end

                -- Draw quest name with shadow for better readability
                draw.SimpleText(questName, "TL X24", w/2+1, h/2+1, Color(0, 0, 0, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(questName, "TL X24", w/2, h/2, Color(220, 210, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                -- Draw "click to view" text
                draw.SimpleText("Нажмите для подробностей", "TL X14", w/2, h-25, Color(180, 180, 160), TEXT_ALIGN_CENTER)
            end
        end

        -- Add click functionality
        local clickPanel = vgui.Create("DButton", questCard)
        clickPanel:SetSize(paintLib.WidthSource(330), paintLib.HightSource(200))
        clickPanel:SetText("")
        clickPanel:SetPaintBackground(false)

        clickPanel.DoClick = function()
			netstream.Start("questsystem/pickdaily", questCard.data, questCard.num)
            surface.PlaySound("buttons/button9.wav")
            QuestPanel:Remove()
        end
    end

    -- Add a close button with custom styling
    local closeButton = vgui.Create("DButton", QuestPanel)
    closeButton:SetSize(paintLib.WidthSource(100), paintLib.HightSource(30))
    closeButton:SetPos(paintLib.WidthSource(1050), paintLib.HightSource(30))
    closeButton:SetText("")
    closeButton.Paint = function(self, w, h)
        local bgColor = self:IsHovered() and Color(80, 30, 30, 200) or Color(60, 55, 50, 200)
        draw.RoundedBox(4, 0, 0, w, h, bgColor)
        draw.SimpleText("ЗАКРЫТЬ", "TL X18", w/2, h/2, Color(220, 210, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeButton.DoClick = function()
        QuestPanel:Remove()
    end
end

netstream.Hook("questsystem/questboard_use", function()
	DrawQuestBoard(meta.Quests["Pick"])
end)
