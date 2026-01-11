local CLASS_NAMES = {
    [CLASS_MAGIC] = "Маг",
    [CLASS_WARRIOR] = "Воин",
    [CLASS_DEFENDER] = "Защитник",
    [CLASS_NOMAD] = "Кочевник", 
    [CLASS_PRIEST] = "Жрец"
}

local CLASS_DESCRIPTIONS = {
    [CLASS_MAGIC] = "Мастер мистических искусств, владеющий разрушительной магией и древними знаниями.",
    [CLASS_WARRIOR] = "Бесстрашный боец, превосходно владеющий оружием и техниками ближнего боя.",
    [CLASS_DEFENDER] = "Несокрушимый щит, способный выдержать даже самые сильные удары.",
    [CLASS_NOMAD] = "Ловкий путешественник, мастер выживания и скрытности.",
    [CLASS_PRIEST] = "Служитель высших сил, обладающий силой исцеления и благословения."
}

local CLASS_ICONS = {
    [CLASS_MAGIC] = Material("fantasy/classes/mage.png", "smooth"),
    [CLASS_WARRIOR] = Material("fantasy/classes/warrior.png", "smooth"),
    [CLASS_DEFENDER] = Material("fantasy/classes/defender.png", "smooth"),
    [CLASS_NOMAD] = Material("fantasy/classes/nomad.png", "smooth"),
    [CLASS_PRIEST] = Material("fantasy/classes/priest.png", "smooth")
}

local CLASS_RARITIES = {
    [CLASS_MAGIC] = {name = "Редкий", color = Color(0, 50, 255)},
    [CLASS_WARRIOR] = {name = "Обычный", color = Color(176, 195, 217)},
    [CLASS_DEFENDER] = {name = "Обычный", color = Color(176, 195, 217)},
    [CLASS_NOMAD] = {name = "Редкий", color = Color(0, 50, 255)},
    [CLASS_PRIEST] = {name = "Обычный", color = Color(176, 195, 217)},
}

local DEFAULT_ICON = Material("gui/silkicons/shield", "smooth")

local SOUNDS = {
    start = "ui/csgo/ui/panorama/case_ticker.wav",
    scroll = "ui/csgo/ui/panorama/itemtile_rollover.wav",
    slowdown = "ui/csgo/ui/panorama/case_ticker_01.wav",
    reveal = "ui/csgo/ui/panorama/case_drop.wav",
    click = "ui/csgo/ui/panorama/inventory_inspect_violator.wav"
}

local currentFrame = nil

function OpenClassRevealWindow(finalClass)
    -- Close any existing reveal window
    if IsValid(currentFrame) then
        currentFrame:Close()
    end

    local frame = vgui.Create("DFrame")
    currentFrame = frame
    frame:SetTitle("")
    frame:SetSize(ScrW(), ScrH())
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    
    -- Animation state variables
    local itemWidth = 400
    local itemHeight = 140
    local numVisibleItems = 7 -- Fewer visible items for vertical scroll
    local centerIdx = math.floor(numVisibleItems / 2) + 1
    
    local scrollOffset = 0
    local scrollSpeed = 25
    local targetScrollSpeed = 0
    local scrollDeceleration = 0.98
    local minSpeed = 0.5
    
    local isScrolling = false
    local isRevealed = false
    local animationStage = 0
    local totalItems = 200 -- Number of random classes to show during animation
    
    local selectedItemY = ScrH() / 2
    local highlightIntensity = 0
    local contentAlpha = 0
    local rerollEnabled = false
    
    -- Generate a sequence of random classes for the scroll effect
    local classSequence = {}
    for i = 1, totalItems do
        local randomClassIdx = math.random(1, 5)
        local ttt = {
            [1] = "MAGIC",
            [2] = "WARRIOR",
            [3] = "DEFENDER",
            [4] = "NOMAD",
            [5] = "PRIEST"
        }
        local classEnum = _G["CLASS_" .. string.upper(ttt[randomClassIdx])]
        
        table.insert(classSequence, classEnum)
    end
    
    -- Make sure the final class is at the right position to stop in the middle
    IIIid = (totalItems / 2) - math.random(1, 50)
    classSequence[IIIid] = finalClass
    targetOffset = IIIid * itemHeight - (itemHeight * 3)
    -- Animation timer logic
    timer.Create("CSGOClassRevealAnimation", 0, 0, function()
        if not IsValid(frame) then 
            timer.Remove("CSGOClassRevealAnimation")
            return
        end
        
        -- State machine for animation
        if animationStage == 0 then
            -- Initial spin up
            isScrolling = true
            surface.PlaySound(SOUNDS.start)
            animationStage = 1
            
        elseif animationStage == 1 then
            -- Fast scrolling stage
            if scrollSpeed < 40 then
                scrollSpeed = scrollSpeed + 1
            end
            
            -- After some time, begin slowing down
            timer.Simple(2.5, function()
                if IsValid(frame) and animationStage == 1 then
                    animationStage = 2
                    surface.PlaySound(SOUNDS.slowdown)
                    targetScrollSpeed = 0
                end
            end)
            
        elseif animationStage == 2 then
            scrollSpeed = scrollSpeed * scrollDeceleration
            if math.floor(scrollOffset / itemHeight) ~= math.floor((scrollOffset + scrollSpeed) / itemHeight) then
                surface.PlaySound(SOUNDS.scroll)
            end
            if scrollSpeed < minSpeed and not isRevealed then
                --targetOffset = (totalItems - centerIdx) * itemHeight
                local remainingScroll = targetOffset - scrollOffset
                local smoothingTimer, smoothingDuration = 0, 0.5
                timer.Create("ClassSmoothSnap", 0.01, 0, function()
                    if not IsValid(frame) then
                        timer.Remove("ClassSmoothSnap")
                        return
                    end
                    smoothingTimer = smoothingTimer + 0.01
                    local progress = math.min(smoothingTimer / smoothingDuration, 1)
                    local easedProgress = 1 - (1 - progress) * (1 - progress)
                    scrollOffset = targetOffset
                    if progress >= 1 then
                        timer.Remove("ClassSmoothSnap")
                        scrollSpeed, isScrolling, isRevealed, rerollEnabled = 0, false, true, true
                        surface.PlaySound(SOUNDS.reveal)
                        timer.Create("ClassHighlightPulse", 0.01, 0, function()
                            if IsValid(frame) then
                                highlightIntensity = 0.5 + math.sin(CurTime() * 4) * 0.5
                            else
                                timer.Remove("ClassHighlightPulse")
                            end 
                        end)
                        timer.Create("ClassDescriptionFade", 0.01, 0, function()
                            if IsValid(frame) then
                                contentAlpha = math.min(contentAlpha + 0.02, 1)
                                if contentAlpha >= 1 then
                                    timer.Remove("ClassDescriptionFade")
                                end
                            else
                                timer.Remove("ClassDescriptionFade")
                            end
                        end)
                    end
                end)
                animationStage = 3
            end
        end
        
        -- Update scroll position
        if isScrolling and targetOffset then
            scrollOffset = Lerp(FrameTime(), scrollOffset, targetOffset)
        end
    end)
    
    -- Draw the case opening animation
    frame.Paint = function(self, w, h)
        -- Dark background with gradient
        draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 25, 255))
        
        -- Top gradient
        for i = 0, 100 do
            local alpha = 255 - i*2.5
            draw.RoundedBox(0, 0, i, w, 1, Color(40, 40, 50, alpha))
        end
        
        -- Bottom gradient
        for i = 0, 100 do
            local alpha = 255 - i*2.5
            draw.RoundedBox(0, 0, h-i, w, 1, Color(40, 40, 50, alpha))
        end
        
        -- Top title
        draw.SimpleText("ВЫБОР КЛАССА", "TL X40", w / 2, 50, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        
        -- Control panel section (right side)
        local panelWidth = 350
        local centerX = w / 2
        local centerY = h / 2
        
        -- Main content section
        local containerHeight = numVisibleItems * itemHeight
        local containerY = centerY - containerHeight / 2
        
        -- Side decoration lines
        surface.SetDrawColor(60, 60, 70, 255)
        surface.DrawRect(centerX - 300, 100, 2, h - 200)
        surface.DrawRect(centerX + 300, 100, 2, h - 200)
        
        -- Center selection area background
        draw.RoundedBox(0, centerX - 180, centerY - itemHeight/2 - 20, 360, itemHeight + 40, Color(40, 40, 50, 100))
        
        -- Center highlight marker (horizontal lines)
        surface.SetDrawColor(255, 215, 0, 100)
        surface.DrawRect(centerX - 180, centerY - itemHeight/2, 360, 2)
        surface.DrawRect(centerX - 180, centerY + itemHeight/2, 360, 2)
        
        -- Draw scrolling case items (vertically)
        local targetClass = finalClass -- Укажи здесь нужный класс, например CLASS_MAGIC

        for i = 0, numVisibleItems do
            local itemIndex = math.floor(scrollOffset / itemHeight) + i
            if itemIndex >= 1 and itemIndex <= #classSequence then
                local classType = classSequence[itemIndex]
                local className = CLASS_NAMES[classType]
                local rarity = CLASS_RARITIES[classType]
                local y = containerY + (i * itemHeight) - (scrollOffset % itemHeight)
                local x = centerX - itemWidth/2
                
                -- Item background
                local bgColor = Color(50, 50, 60)
                local isSelectedItem = math.abs(y + itemHeight/2 - centerY) < 10
                if isSelectedItem then print("Выбран класс: " .. className) end
                
                -- Проверка, является ли текущий элемент целевым классом
                if targetClass and classType == targetClass then
                    isSelectedItem = true
                end
                
                -- Border around the center selected item
                if isSelectedItem and isRevealed and IIIid == itemIndex then
                    -- Gold highlight animation
                    local glowSize = 6 + (highlightIntensity * 4)
                    local glowAlpha = 100 + (highlightIntensity * 155)
                    draw.RoundedBox(8, x - glowSize, y - glowSize, itemWidth + glowSize * 2, itemHeight + glowSize * 2, 
                        Color(255, 215, 0, glowAlpha))
                end
                
                -- Item card
                draw.RoundedBox(8, x, y, itemWidth, itemHeight, bgColor)
                
                -- Rarity color at the left
                local rarityColor = rarity.color
                draw.RoundedBoxEx(8, x, y, 6, itemHeight, rarityColor, true, false, true, false)
                
                -- Class icon
                local iconMat = CLASS_ICONS[classType] or DEFAULT_ICON
                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(iconMat)
                surface.DrawTexturedRect(x + 20, y + itemHeight/2 - 40, 80, 80)
                
                -- Class name and rarity
                draw.SimpleText(className, "TL X24", x + 110, y + 40, Color(255, 255, 255), TEXT_ALIGN_LEFT)
                draw.SimpleText(rarity.name, "TL X18", x + 110, y + 70, rarityColor, TEXT_ALIGN_LEFT)
            end
        end
        
        
        -- Show selected class details once revealed
        if isRevealed then
            local selectedClass = classSequence[totalItems - centerIdx + 1]
            local descX = centerX + 200
            local descWidth = 300
            --[[
            -- Class description section
            draw.RoundedBox(8, descX, centerY - 180, descWidth, 360, 
                ColorAlpha(Color(60, 60, 70), 255 * contentAlpha))
            
            -- Description title
            draw.SimpleText("ОПИСАНИЕ", "TL X28", descX + descWidth/2, centerY - 150, 
                ColorAlpha(Color(255, 215, 0), 255 * contentAlpha), TEXT_ALIGN_CENTER)
            
            -- Class description text
            local description = CLASS_DESCRIPTIONS[selectedClass] or "Описание недоступно."
            
            -- Break description into multiple lines
            local descLines = {}
            local curLine = ""
            local maxWidth = descWidth - 40
            local words = string.Explode(" ", description)
            
            for _, word in ipairs(words) do
                local testLine = curLine .. " " .. word
                surface.SetFont("TL X16")
                local testW, _ = surface.GetTextSize(testLine)
                
                if testW > maxWidth then
                    table.insert(descLines, curLine)
                    curLine = word
                else
                    curLine = testLine
                end
            end
            
            if curLine ~= "" then
                table.insert(descLines, curLine)
            end
            
            for i, line in ipairs(descLines) do
                draw.SimpleText(line, "TL X16", descX + 20, centerY - 100 + (i-1)*25, 
                    ColorAlpha(Color(255, 255, 255), 255 * contentAlpha), TEXT_ALIGN_LEFT)
            end]]
            
            
            -- Show buttons when content is fully faded in
            if contentAlpha >= 1 then
                -- Continue button
                local contBtnW, contBtnH = 200, 50
                local contBtnX = centerX - 250 - contBtnW/2
                local contBtnY = centerY + 150
                
                -- Hover effect for continue button
                local contBtnColor = Color(70, 70, 80)
                if self.contBtnHovered then
                    contBtnColor = Color(100, 100, 120)
                end
                
                draw.RoundedBox(8, contBtnX, contBtnY, contBtnW, contBtnH, contBtnColor)
                draw.SimpleText("ПРОДОЛЖИТЬ", "TL X22", contBtnX + contBtnW/2, contBtnY + contBtnH/2, 
                    Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                -- Re-roll button
                if rerollEnabled then
                    local rerollBtnW, rerollBtnH = 200, 50
                    local rerollBtnX = centerX + 250 - rerollBtnW/2
                    local rerollBtnY = centerY + 150
                    
                    -- Hover effect for reroll button
                    local rerollBtnColor = Color(70, 50, 50)
                    if self.rerollBtnHovered then
                        rerollBtnColor = Color(120, 70, 70)
                    end
                    
                    draw.RoundedBox(8, rerollBtnX, rerollBtnY, rerollBtnW, rerollBtnH, rerollBtnColor)
                    draw.SimpleText("ПЕРЕВЫБРАТЬ", "TL X22", rerollBtnX + rerollBtnW/2, rerollBtnY + rerollBtnH/2, 
                        Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    
                    -- Handle reroll button interaction
                    local mx, my = gui.MousePos()
                    if mx >= rerollBtnX and mx <= rerollBtnX + rerollBtnW and my >= rerollBtnY and my <= rerollBtnY + rerollBtnH then
                        self.rerollBtnHovered = true
                        if input.IsMouseDown(MOUSE_LEFT) and not self.rerollClicked then
                            self.rerollClicked = true
                            surface.PlaySound(SOUNDS.click)
                            timer.Simple(0.1, function()
                                if IsValid(frame) then
                                    netstream.Start("rerollClass")
                                end
                            end)
                        end
                    else
                        self.rerollBtnHovered = false
                    end
                end
                
                -- Handle continue button interaction
                local mx, my = gui.MousePos()
                if mx >= contBtnX and mx <= contBtnX + contBtnW and my >= contBtnY and my <= contBtnY + contBtnH then
                    self.contBtnHovered = true
                    if input.IsMouseDown(MOUSE_LEFT) and not self.contClicked then
                        self.contClicked = true
                        surface.PlaySound(SOUNDS.click)
                        timer.Simple(0.1, function()
                            if IsValid(frame) then
                                -- Clean up all timers
                                timer.Remove("CSGOClassRevealAnimation")
                                timer.Remove("ClassHighlightPulse")
                                timer.Remove("ClassDescriptionFade")
                                timer.Remove("ClassSmoothSnap")
                                frame:Close()
                                currentFrame = nil
                            end
                        end)
                    end
                else
                    self.contBtnHovered = false
                end
            end
        end
    end
end

-- Receive the class choice from the server
netstream.Hook("showClassReveal", function(class)
    OpenClassRevealWindow(class)
end)

local availableClasses = {
    {class = CLASS_MAGIC, chance = 0.2},
    {class = CLASS_WARRIOR, chance = 0.3},
    {class = CLASS_DEFENDER, chance = 0.25},
    {class = CLASS_NOMAD, chance = 0.15},
    {class = CLASS_PRIEST, chance = 0.1}
}

local function getRandomClass()
    local totalChance = 0
    for _, classData in ipairs(availableClasses) do
        totalChance = totalChance + classData.chance
    end

    local randomValue = math.Rand(0, totalChance)
    local cumulativeChance = 0

    for _, classData in ipairs(availableClasses) do
        cumulativeChance = cumulativeChance + classData.chance
        if randomValue <= cumulativeChance then
            return classData.class
        end
    end
end
netstream.Hook("rerollClass", function(class)
    OpenClassRevealWindow(class)
end)
