local stringResultSharp = nil
local sharpAnimation = nil
local animationStage = 0
local particleEmitters = {}
local sparkParticles = {}
local hammerAngle = 0
local sharpingSound = nil

local function createParticles(pos, count, color, size, lifetime)
    local emitter = ParticleEmitter(pos)
    for i = 1, count do
        local particle = emitter:Add("effects/spark", pos)
        if particle then
            particle:SetVelocity(VectorRand() * math.random(10, 50))
            particle:SetDieTime(math.Rand(0.5, lifetime))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(size * 0.5)
            particle:SetEndSize(size)
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-2, 2))
            particle:SetColor(color.r, color.g, color.b)
        end
    end
    table.insert(particleEmitters, emitter)
    return emitter
end

local function sharpFrame()
    sharpingItem = nil
    currentSharpTool = itemsForSharp[1]
    animationStage = 0
    
    -- Clean up any existing particles
    for _, emitter in ipairs(particleEmitters) do
        emitter:Finish()
    end
    particleEmitters = {}
    
    -- Create the main frame
    sharpingFrmae = vgui.Create("DFrame")
    sharpingFrmae:SetSize(ScrW() * 0.5, ScrH() * 0.7)
    sharpingFrmae:Center()
    sharpingFrmae:SetTitle("")
    sharpingFrmae:SetDraggable(false)
    sharpingFrmae:MakePopup()
    sharpingFrmae:ShowCloseButton(false)
    
    -- Animation for opening the frame
    sharpingFrmae:SetAlpha(0)
    sharpingFrmae:AlphaTo(255, 0.5, 0)
    
    -- Frame background with fantasy theme
    local background = Material("fantasy/ui/anvil_bg.jpg", "smooth")
    if not background or background:IsError() then
        background = nil
    end
    
    sharpingFrmae.Paint = function(self, w, h)
        -- Fantasy style background
        draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 30, 240))
        
        if background then
            surface.SetDrawColor(255, 255, 255, 100)
            surface.SetMaterial(background)
            surface.DrawTexturedRect(0, 0, w, h)
        end
        
        -- Fancy corners
        local corner_size = 40
        local corner_width = 3
        
        -- Top left corner
        surface.SetDrawColor(220, 170, 60, 255)
        surface.DrawRect(0, 0, corner_size, corner_width)
        surface.DrawRect(0, 0, corner_width, corner_size)
        
        -- Top right corner
        surface.DrawRect(w - corner_size, 0, corner_size, corner_width)
        surface.DrawRect(w - corner_width, 0, corner_width, corner_size)
        
        -- Bottom left corner
        surface.DrawRect(0, h - corner_width, corner_size, corner_width)
        surface.DrawRect(0, h - corner_size, corner_width, corner_size)
        
        -- Bottom right corner
        surface.DrawRect(w - corner_size, h - corner_width, corner_size, corner_width)
        surface.DrawRect(w - corner_width, h - corner_size, corner_width, corner_size)
        
        -- Title with glow effect
        local titleText = stringResultSharp or "ЗАТОЧКА КЛИНКА"
        local titleColor = Color(255, 215, 100)
        

        -- Main title
        draw.SimpleText(titleText, "TL X28", w / 2, 40, titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Draw divider
        surface.SetDrawColor(220, 170, 60, 150)
        surface.DrawRect(w * 0.1, 80, w * 0.8, 2)
        
        -- Weapon info
        if sharpingItem then 
            local item = sharpingItem
            local name = item.name
            local sharpBonusText = "Нет"
            local shatpLvl = item:getMeta("sharp") or 0
            if item:getMeta("sharp") then
                name = name.." + "..item:getMeta("sharp")
            end
            
            if item:getMeta("sharpBonus") then
                local bonus = item:getMeta("sharpBonus") or {}
                sharpBonusText = ""
                for k, v in pairs(bonus) do
                    sharpBonusText = sharpBonusText.." "..namesOfSharpBonus[k]..";"
                end
            end
            
            -- Weapon name with golden gradient
            local nameY = h * 0.2
            for i = 0, 1 do
                draw.SimpleText(name, "TL X30", w * 0.5, nameY - i, Color(220 - i*30, 170 - i*30, 60 - i*30, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            
            -- Stats panel
            local statsPanelX = w * 0.55
            local statsPanelY = h * 0.3
            local statsPanelW = w * 0.4
            local statsPanelH = h * 0.25
            
            -- Stats background
            draw.RoundedBox(8, statsPanelX, statsPanelY, statsPanelW, statsPanelH, Color(30, 30, 40, 200))
            
            -- Stats panel borders
            surface.SetDrawColor(180, 130, 50, 150)
            for i = 0, 2 do
                surface.DrawOutlinedRect(statsPanelX + i, statsPanelY + i, statsPanelW - i*2, statsPanelH - i*2)
            end
            
            -- Success chance with color based on probability
            local successChance = upgradeChances[shatpLvl + 1]
            local chanceColor = Color(255, 0, 0) -- Red for low chance
            if successChance > 50 then
                chanceColor = Color(0, 255, 0) -- Green for high chance
            elseif successChance > 25 then
                chanceColor = Color(255, 255, 0) -- Yellow for medium chance
            end
            
            draw.SimpleText("Характеристики оружия:", "TL X20", statsPanelX + 20, statsPanelY + 20, Color(220, 170, 60), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Шанс успеха: ", "TL X18", statsPanelX + 20, statsPanelY + 60, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(successChance.."%", "TL X18", statsPanelX + 170, statsPanelY + 60, chanceColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            draw.SimpleText("Бонусы заточки:", "TL X18", statsPanelX + 20, statsPanelY + 90, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(sharpBonusText, "TL X18", statsPanelX + 170, statsPanelY + 90, Color(100, 200, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        -- Draw animation elements
        if animationStage > 0 then
            local centerX = w * 0.3
            local centerY = h * 0.4
            
            if animationStage == 1 then -- Hammer swinging
                
            elseif animationStage == 2 then -- Success animation
                -- Draw success effects
                local radius = 100 + math.sin(CurTime() * 5) * 20
                local segments = 32
                local color1 = Color(255, 223, 100, 150)
                local color2 = Color(255, 255, 255, 0)
                
                for i = 0, segments do
                    local angle = (i / segments) * math.pi * 2
                    local x1 = centerX + math.cos(angle) * radius
                    local y1 = centerY + math.sin(angle) * radius
                    local x2 = centerX + math.cos(angle + math.pi/segments) * radius
                    local y2 = centerY + math.sin(angle + math.pi/segments) * radius
                    
                    surface.SetDrawColor(ColorAlpha(color1, 150 * math.abs(math.sin(CurTime() * 3 + i/5))))
                    surface.DrawLine(centerX, centerY, x1, y1)
                end
            elseif animationStage == 3 then -- Failure animation
                local shake = math.sin(CurTime() * 20) * 5
                draw.RoundedBox(0, centerX - 50 + shake, centerY - 50, 100, 100, Color(255, 0, 0, 100))
            end
        end
    end
    
    -- Close button
    local closeButton = vgui.Create("DButton", sharpingFrmae)
    closeButton:SetSize(30, 30)
    closeButton:SetPos(sharpingFrmae:GetWide() - 40, 10)
    closeButton:SetText("")
    closeButton.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(60, 60, 80, self:IsHovered() and 180 or 100))
        draw.SimpleText("X", "TL X20", w/2, h/2, self:IsHovered() and Color(255, 100, 100) or Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeButton.DoClick = function()
        -- Fade out animation
        sharpingFrmae:AlphaTo(0, 0.3, 0, function()
            sharpingFrmae:Close()
        end)
        
        -- Stop any sounds
        if sharpingSound then
            sharpingSound:Stop()
            sharpingSound = nil
        end
    end
    
    -- Weapon slot with glowing effect
    local weaponSlot = vgui.Create("DPanel", sharpingFrmae)
    local slotSize = sharpingFrmae:GetTall() * 0.2
    weaponSlot:SetSize(slotSize, slotSize)
    weaponSlot:SetPos(sharpingFrmae:GetWide() * 0.3 - slotSize/2, sharpingFrmae:GetTall() * 0.4 - slotSize/2)
    
    local slotGlow = 0
    local glowDir = 1
    
    weaponSlot.Paint = function(self, w, h)
        -- Animate the glow
        slotGlow = slotGlow + (0.01 * glowDir)
        if slotGlow > 1 then
            slotGlow = 1
            glowDir = -1
        elseif slotGlow < 0.5 then
            slotGlow = 0.5
            glowDir = 1
        end
        
        -- Draw the slot with glow
       -- draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 50, 200))
        
        -- Inner slot
        draw.RoundedBox(4, 5, 5, w-10, h-10, Color(30, 30, 40, 200))
        
        -- Glowing border
        local borderColor = Color(220 * slotGlow, 170 * slotGlow, 60 * slotGlow, 255)
        surface.SetDrawColor(borderColor)
        for i = 0, 2 do
           -- surface.DrawOutlinedRect(i, i, w-i*2, h-i*2, 1)
        end
        
    end
    
    weaponSlot:Receiver("InventorySlot", function(receiver, panels, dropped)
        if dropped then
            local draggedPanel = panels[1]
            local item = draggedPanel.item
            local itemData = item:getItemData()
            if itemData.type == "weapon" then 
                local canEquip, str = item:CheckNeedStat(LocalPlayer())
                if not canEquip then return end
                
                -- Animation for weapon arrival
                draggedPanel:MoveTo(weaponSlot:GetX(), weaponSlot:GetY(), 0.3, 0, -1, function()
                    netstream.Start("fantasy/inventory/equip", item)
                    draggedPanel:SetParent(receiver)
                    receiver.item = item
                    local bSucc, str = playerInventory:equipItem(item)
                    if not bSucc then LocalPlayer():ChatPrint(str) end 
                    BuildGridItems(inventoryGrid)     
                    BuildItems()
                    BuildSlots()
                    
                    -- Set sharpingItem
                    sharpingItem = item
                end)
                
                -- Play sound effect
                surface.PlaySound("items/ammo_pickup.wav")
            end
        end
    end)
    
    -- Check if player has a weapon equipped
    local hasWeapon = playerInventory:GetEquippedItem("weapon")
    if hasWeapon then
        sharpingItem = hasWeapon
        local slot = vgui.Create("DPanel", weaponSlot)
        weaponSlotToUpdate = slot
        slot:SetSize(slotSize, slotSize)
        slot.item = hasWeapon
        slot.ItemData = hasWeapon:getItemData()
        slot.FromSlot = "weapon"
        
        -- Cool weapon display with floating effect
        local floatOffset = 0
        
        slot.Paint = function(self, w, h)
            floatOffset = math.sin(CurTime() * 2) * 5
            
            if self.item then
                -- Draw weapon with slight float animation
                
                
                -- Add subtle glow effect
                local glowColor = Color(255, 255, 255, 20)
                draw.RoundedBox(8, 0, 0, w, h, glowColor)

                ITEMS_TEX.items[self.ItemData.Icon](5, 5, w-10, h-10)
            end
        end
        
        slot.OnCursorEntered = function()
            showItemInfo(slot, slot.item)
            surface.PlaySound("ui/buttonrollover.wav")
        end
        
        slot.OnCursorExited = function()
            if IsValid(infoPanel) then
                infoPanel:Remove()
            end
        end
        
        weaponSlot.itemPanel = slot
    end
    
    -- Sharpen button with fantasy style
    local sharpButton = vgui.Create("DButton", sharpingFrmae)
    sharpButton:SetSize(sharpingFrmae:GetWide() * 0.3, sharpingFrmae:GetTall() * 0.08)
    sharpButton:SetPos(sharpingFrmae:GetWide() * 0.5 - sharpButton:GetWide() * 0.5, sharpingFrmae:GetTall() * 0.7)
    sharpButton:SetText("")
    
    local buttonHovered = false
    local buttonGlow = 0
    
    sharpButton.Paint = function(self, w, h)
        -- Update hover state
        buttonHovered = self:IsHovered()
        
        -- Glow animation
        if buttonHovered then
            buttonGlow = math.min(buttonGlow + 0.05, 1)
        else
            buttonGlow = math.max(buttonGlow - 0.05, 0)
        end
        
        -- Button background with fancy gradient
        local color1 = Color(60 + 40 * buttonGlow, 40 + 20 * buttonGlow, 80 + 20 * buttonGlow, 255)
        local color2 = Color(40 + 20 * buttonGlow, 30 + 10 * buttonGlow, 60 + 10 * buttonGlow, 255)
        
        draw.RoundedBox(8, 0, 0, w, h, color1)
        
        -- Inner gradient
        for i = 0, h do
            local a = i / h
            local color = Color(
                Lerp(a, color1.r, color2.r),
                Lerp(a, color1.g, color2.g),
                Lerp(a, color1.b, color2.b),
                255
            )
            draw.RoundedBox(0, 2, 2 + i, w - 4, 1, color)
        end
        
        -- Button glow
        if buttonGlow > 0 then
            for i = 1, 3 do
                draw.RoundedBox(8 + i, -i, -i, w + i*2, h + i*2, Color(220, 170, 60, 30 * buttonGlow))
            end
        end
        
        -- Button border
        local borderColor = Color(220, 170, 60, 150 + 105 * buttonGlow)
        surface.SetDrawColor(borderColor)
        for i = 0, 2 do
            surface.DrawOutlinedRect(i, i, w-i*2, h-i*2, 1)
        end
        
        -- Button text with shadow
        draw.SimpleText("ЗАТОЧИТЬ ОРУЖИЕ", "TL X20", w/2 + 1, h/2 + 1, Color(0, 0, 0, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("ЗАТОЧИТЬ ОРУЖИЕ", "TL X20", w/2, h/2, Color(220, 170, 60, 200 + 55 * buttonGlow), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Floating magic particles at button edges
        if buttonGlow > 0 then
            for i = 1, 5 do
                local particleX = math.sin(CurTime() * 2 + i) * w/2 + w/2
                local particleSize = 3 + math.sin(CurTime() * 3 + i*2) * 2
                draw.RoundedBox(particleSize, particleX - particleSize/2, -particleSize/2, particleSize, particleSize, Color(220, 170, 60, 150 * buttonGlow))
                draw.RoundedBox(particleSize, particleX - particleSize/2, h - particleSize/2, particleSize, particleSize, Color(220, 170, 60, 150 * buttonGlow))
            end
        end
    end
    
    sharpButton.OnCursorEntered = function(self)
        surface.PlaySound("ui/buttonrollover.wav")
    end
    
    sharpButton.DoClick = function()
        if not sharpingItem then
            surface.PlaySound("buttons/button10.wav")
            return
        end

        local hasSharpingItem = playerInventory:hasItems("grindstone_tier1")
        if not hasSharpingItem then
            stringResultSharp = "Нет Эссенций Заточки!"
            surface.PlaySound("buttons/button10.wav")
            return
        end
        
        -- Start the sharpening animation
        animationStage = 1
        hammerAngle = -45
        
        -- Play sharpening sound
        --surface.PlaySound("physics/metal/metal_box_scrape_rough_loop1.wav")
        
        -- Start the animation sequence
        timer.Create("SharpingAnimation", 0.05, 0, function()
            if not IsValid(sharpingFrmae) then 
                timer.Remove("SharpingAnimation")
                return
            end
            
            -- Continue hammer swinging for 3 seconds
            if CurTime() > timer.TimeLeft("SharpingAnimation") + 3 then
                timer.Remove("SharpingAnimation")
                
                -- Send the actual sharpening request to server
                netstream.Start("fantasy/inventory/sharp", "weapon", currentSharpTool)
                stringResultSharp = "Заточка..."
                
                -- Wait for server response
                timer.Simple(1.5, function()
                    if not IsValid(sharpingFrmae) then return end
                    
                end)
            end
        end)
    end
    
    
    -- Initial animation
    sharpingFrmae:SetAlpha(0)
    sharpingFrmae:AlphaTo(255, 0.5, 0)
end

-- Event handler for sharpening result
netstream.Hook("fantasy/inventory/sharp", function(b)
    stringResultSharp = b and "Заточка успешна!" or "Заточка не удалась!"
    
    if IsValid(sharpingFrmae) then 
        if b then
            animationStage = 2 -- Success animation
            --surface.PlaySound("garrysmod/save_load1.wav")
        else
            animationStage = 3 -- Failure animation
            --surface.PlaySound("buttons/button10.wav")
        end
        timer.Simple(1, function()
            animationStage = 0
        end)
        local hasWeapon = playerInventory:GetEquippedItem("weapon")
        sharpingItem = hasWeapon
    end
end)

netstream.Hook("fantasy/inventory/sharpopen", function(slotid, tool)
    print("sharp", ply, slotid, tool)
    if slotid == "weapon" then
        sharpFrame()
    end
end)