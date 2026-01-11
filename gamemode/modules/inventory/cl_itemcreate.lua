function OpenItemCreationMenu()
    if IsValid(itemCreationFrame) then
        itemCreationFrame:Remove()
    end
    
    local selectedItemData = nil

    local frame = vgui.Create("DFrame")
    itemCreationFrame = frame
    frame:SetSize(paintLib.WidthSource(1100), paintLib.HightSource(700))
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:ShowCloseButton(false)
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 40, 240))
        
        -- Decorative corners
        local corner_size = 50
        local corner_width = 3
        local glow = math.abs(math.sin(CurTime() * 1.5)) * 50
        local cornerColor = Color(220, 170, 60, 255 - glow)
        
        surface.SetDrawColor(cornerColor)
        
        -- Top left corner
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
        local titleText = "РЕДАКТОР ПРЕДМЕТОВ"
        local titleColor = Color(255, 215, 100)
        local glowAmount = math.abs(math.sin(CurTime() * 2)) * 55
        
        draw.SimpleText(titleText, "TL X28", w / 2, 40, Color(255, 215, 100, glowAmount), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(titleText, "TL X28", w / 2, 40, titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
         
        -- Decorative line under title
        surface.SetDrawColor(220, 170, 60, 150 + glowAmount)
        surface.DrawRect(w * 0.1, paintLib.HightSource(70), w * 0.8, 2)
    end
    
    local contentPanel = vgui.Create("DPanel", frame)
    contentPanel:SetPos(paintLib.WidthSource(50), paintLib.HightSource(90))
    contentPanel:SetSize(paintLib.WidthSource(1000), paintLib.HightSource(550))
    contentPanel.Paint = function() end
    
    -- Item list panel (left side)
    local itemListPanel = vgui.Create("DPanel", contentPanel)
    itemListPanel:SetPos(0, 0)
    itemListPanel:SetSize(paintLib.WidthSource(300), paintLib.HightSource(550))
    itemListPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 50, 180))
        draw.SimpleText("СПИСОК ПРЕДМЕТОВ", "TL X22", w/2, paintLib.HightSource(20), Color(220, 170, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(220, 170, 60, 150)
        surface.DrawRect(w * 0.1, paintLib.HightSource(35), w * 0.8, 2)
    end
    
    -- Search field for items
    local itemSearch = vgui.Create("DTextEntry", itemListPanel)
    itemSearch:SetPos(paintLib.WidthSource(15), paintLib.HightSource(50))
    itemSearch:SetSize(paintLib.WidthSource(270), paintLib.HightSource(30))
    itemSearch:SetPlaceholderText("Поиск предмета...")
    itemSearch:SetFont("TL X18")
    
    local itemScroll = vgui.Create("DScrollPanel", itemListPanel)
    itemScroll:SetPos(paintLib.WidthSource(15), paintLib.HightSource(85))
    itemScroll:SetSize(paintLib.WidthSource(270), paintLib.HightSource(450))
    
    local itemButtons = {}
    
    local function UpdateItemList(searchTerm)
        for _, entry in pairs(itemButtons) do
            if IsValid(entry) then entry:Remove() end
        end
        itemButtons = {}
        
        for itemName, itemData in pairs(itemList) do
            if not searchTerm or string.find(string.lower(itemName), string.lower(searchTerm)) then
                local entry = vgui.Create("DButton", itemScroll)
                entry:SetTall(paintLib.HightSource(60))
                entry:Dock(TOP)
                entry:DockMargin(0, 0, 0, paintLib.HightSource(4))
                entry:SetText("")
                entry.itemName = itemName
                entry.itemData = itemData
                entry.isSelected = false
                
                entry.Paint = function(self, w, h)
                    local bgColor = Color(60, 60, 70, 180)
                    
                    if self.isSelected then
                        bgColor = Color(80, 120, 160, 180)
                    elseif self:IsHovered() then
                        bgColor = Color(70, 70, 80, 180)
                    end
                    
                    draw.RoundedBox(6, 0, 0, w, h, bgColor)
                    
                    if itemData.Icon then
                        ITEMS_TEX.items[itemData.Icon](paintLib.WidthSource(10), paintLib.HightSource(5), paintLib.HightSource(50), paintLib.HightSource(50))
                    end
                    
                    draw.SimpleText(itemData.Name or itemName, "TL X18", paintLib.WidthSource(70), paintLib.HightSource(20), Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(itemData.Type or "misc", "TL X16", paintLib.WidthSource(70), paintLib.HightSource(40), Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    
                    if self.isSelected then
                        surface.SetDrawColor(220, 170, 60, 200)
                        surface.DrawRect(0, h - 2, w, 2)
                    end
                end
                
                entry.DoClick = function(self)
                    for _, e in pairs(itemButtons) do
                        if IsValid(e) then e.isSelected = false end
                    end
                    
                    self.isSelected = true
                    selectedItemData = self.itemData
                    
                    -- Update form with selected item data
                    baseItemCombo:SetValue(itemData.baseItem or itemName)
                    nameEntry:SetValue(itemData.Name or "")
                    classnameEntry:SetValue(itemName)
                    descriptionEntry:SetValue(itemData.Description or "")
                    iconEntry:SetValue(itemData.Icon or 1)
                    iconPreview.iconIndex = itemData.Icon
                    typeCombo:SetValue(itemData.Type or "misc")
                    stackableCheckbox:SetChecked(itemData.stackable or false)
                    weightEntry:SetValue(itemData.weight or 1)
                end
                
                table.insert(itemButtons, entry)
            end
        end
    end
    
    -- Initial item list population
    UpdateItemList()
    
    -- Search functionality
    itemSearch.OnChange = function(self)
        UpdateItemList(self:GetValue())
    end
    
    -- Item editor panel (right side)
    local itemEditorPanel = vgui.Create("DPanel", contentPanel)
    itemEditorPanel:SetPos(paintLib.WidthSource(310), 0)
    itemEditorPanel:SetSize(paintLib.WidthSource(690), paintLib.HightSource(550))
    itemEditorPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 50, 180))
        draw.SimpleText("СОЗДАНИЕ/РЕДАКТИРОВАНИЕ ПРЕДМЕТА", "TL X22", w/2, paintLib.HightSource(20), Color(220, 170, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(220, 170, 60, 150)
        surface.DrawRect(w * 0.1, paintLib.HightSource(35), w * 0.8, 2)
    end
    
    local editorScroll = vgui.Create("DScrollPanel", itemEditorPanel)
    editorScroll:SetPos(paintLib.WidthSource(20), paintLib.HightSource(50))
    editorScroll:SetSize(paintLib.WidthSource(650), paintLib.HightSource(485))
    
    local function CreateLabel(text)
        local label = vgui.Create("DLabel", editorScroll)
        label:SetText(text)
        label:SetTextColor(Color(255, 255, 255))
        label:SetFont("TL X18")
        label:Dock(TOP)
        label:DockMargin(paintLib.WidthSource(5), paintLib.HightSource(10), 0, 0)
        return label
    end
    
    local function CreateTextEntry()
        local entry = vgui.Create("DTextEntry", editorScroll)
        entry:SetFont("TL X18")
        entry:Dock(TOP)
        entry:DockMargin(paintLib.WidthSource(5), paintLib.HightSource(5), paintLib.WidthSource(5), 0)
        entry:SetHeight(paintLib.HightSource(35))
        entry.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 60, 180))
            self:DrawTextEntryText(Color(255, 255, 255), Color(180, 140, 60), Color(255, 255, 255))
        end
        return entry
    end
    
    local function CreateNumberWang()
        local entry = vgui.Create("DNumberWang", editorScroll)
        entry:SetFont("TL X18")
        entry:Dock(TOP)
        entry:DockMargin(paintLib.WidthSource(5), paintLib.HightSource(5), paintLib.WidthSource(5), 0)
        entry:SetHeight(paintLib.HightSource(35))
        entry.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 60, 180))
            self:DrawTextEntryText(Color(255, 255, 255), Color(180, 140, 60), Color(255, 255, 255))
        end
        return entry
    end
    
    local function CreateComboBox(choices)
        local combo = vgui.Create("DComboBox", editorScroll)
        combo:SetFont("TL X18")
        combo:Dock(TOP)
        combo:DockMargin(paintLib.WidthSource(5), paintLib.HightSource(5), paintLib.WidthSource(5), 0)
        combo:SetHeight(paintLib.HightSource(35))
        combo.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 60, 180))
        end
        
        for _, choice in ipairs(choices) do
            combo:AddChoice(choice)
        end
        return combo
    end
    
    -- Form fields
    CreateLabel("Базовый предмет:")
    baseItemCombo = CreateComboBox({})
    for itemName, _ in pairs(itemList) do
        baseItemCombo:AddChoice(itemName)
    end
    
    CreateLabel("Название:")
    nameEntry = CreateTextEntry()
    
    CreateLabel("ID Название:")
    classnameEntry = CreateTextEntry()
    
    CreateLabel("Описание:")
    descriptionEntry = CreateTextEntry()
    
    CreateLabel("Вес:")
    weightEntry = CreateNumberWang()
    
    -- Icon section
    CreateLabel("Иконка:")
    local iconRow = vgui.Create("DPanel", editorScroll)
    iconRow:Dock(TOP)
    iconRow:DockMargin(paintLib.WidthSource(5), paintLib.HightSource(5), paintLib.WidthSource(5), 0)
    iconRow:SetHeight(paintLib.HightSource(200))
    iconRow.Paint = function() end
    
    iconPreview = vgui.Create("DPanel", iconRow)
    iconPreview:SetSize(paintLib.HightSource(64), paintLib.HightSource(64))
    iconPreview:SetPos(paintLib.WidthSource(5), paintLib.HightSource(50))
    iconPreview.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 60, 180))
        if self.iconIndex then 
            ITEMS_TEX.items[self.iconIndex](0, 0, h, h)
        end
    end
    
    iconEntry = CreateNumberWang()
    iconEntry:SetParent(iconRow)
    iconEntry:SetPos(paintLib.WidthSource(80), paintLib.HightSource(3))
    iconEntry:SetSize(paintLib.WidthSource(150), paintLib.HightSource(35))
    iconEntry:Dock(TOP)
    iconEntry.OnValueChanged = function(self, value)
        iconPreview.iconIndex = tonumber(value)
    end
    
    local selectIconButton = vgui.Create("DButton", iconRow)
    selectIconButton:SetText("")
    selectIconButton:SetPos(paintLib.WidthSource(240), paintLib.HightSource(50))
    selectIconButton:SetSize(paintLib.WidthSource(200), paintLib.HightSource(35))
    selectIconButton.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and Color(70, 90, 110, 180) or Color(60, 80, 100, 180))
        draw.SimpleText("Выбрать иконку", "TL X18", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    selectIconButton.DoClick = function()
        local iconFrame = vgui.Create("DFrame")
        iconFrame:SetTitle("")
        iconFrame:SetSize(paintLib.WidthSource(800), paintLib.HightSource(600))
        iconFrame:Center()
        iconFrame:MakePopup()
        
        iconFrame.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 40, 240))
            draw.SimpleText("ВЫБОР ИКОНКИ", "TL X24", w/2, paintLib.HightSource(20), Color(220, 170, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            surface.SetDrawColor(220, 170, 60, 150)
            surface.DrawRect(w * 0.1, paintLib.HightSource(50), w * 0.8, 2)
        end
        
        local iconScroll = vgui.Create("DScrollPanel", iconFrame)
        iconScroll:SetPos(paintLib.WidthSource(20), paintLib.HightSource(60))
        iconScroll:SetSize(paintLib.WidthSource(760), paintLib.HightSource(520))
        
        local iconList = vgui.Create("DIconLayout", iconScroll)
        iconList:Dock(FILL)
        iconList:SetSpaceY(5)
        iconList:SetSpaceX(5)
        
        for i = 1, #ITEMS_TEX.items do
            local iconItem = iconList:Add("DButton")
            iconItem:SetSize(paintLib.WidthSource(64), paintLib.HightSource(64))
            iconItem:SetText("")
            iconItem.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and Color(70, 70, 80, 180) or Color(50, 50, 60, 180))
                ITEMS_TEX.items[i](2, 2, w-4, h-4)
            end
            iconItem.DoClick = function()
                iconEntry:SetValue(i)
                iconPreview.iconIndex = i
                iconFrame:Close()
            end
        end
    end
    
    CreateLabel("Тип:")
    typeCombo = CreateComboBox({"weapon", "armor", "consumable", "misc", "trava"})
    
    -- Stackable checkbox with custom look
    CreateLabel("Складируемый:")
    local stackablePanel = vgui.Create("DPanel", editorScroll)
    stackablePanel:Dock(TOP)
    stackablePanel:DockMargin(paintLib.WidthSource(5), paintLib.HightSource(5), paintLib.WidthSource(5), 0)
    stackablePanel:SetHeight(paintLib.HightSource(35))
    stackablePanel.Paint = function() end
    
    stackableCheckbox = vgui.Create("DCheckBox", stackablePanel)
    stackableCheckbox:SetPos(paintLib.WidthSource(10), paintLib.HightSource(5))
    stackableCheckbox:SetSize(paintLib.HightSource(25), paintLib.HightSource(25))
    
    local stackableLabel = vgui.Create("DLabel", stackablePanel)
    stackableLabel:SetPos(paintLib.WidthSource(45), paintLib.HightSource(5))
    stackableLabel:SetText("Да")
    stackableLabel:SetFont("TL X18")
    stackableLabel:SetTextColor(Color(255, 255, 255))
    stackableLabel:SizeToContents()
    
    -- Action buttons
    local buttonsPanel = vgui.Create("DPanel", editorScroll)
    buttonsPanel:Dock(TOP)
    buttonsPanel:DockMargin(paintLib.WidthSource(5), paintLib.HightSource(20), paintLib.WidthSource(5), 0)
    buttonsPanel:SetHeight(paintLib.HightSource(40))
    buttonsPanel.Paint = function() end
    
    local createNewBtn = vgui.Create("DButton", buttonsPanel)
    createNewBtn:SetText("")
    createNewBtn:SetPos(paintLib.WidthSource(10), 0)
    createNewBtn:SetSize(paintLib.WidthSource(200), paintLib.HightSource(40))
    createNewBtn.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Color(50, 100, 50, 180) or Color(40, 80, 40, 180))
        draw.SimpleText("Создать новый", "TL X18", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    createNewBtn.DoClick = function()
        -- Clear form fields
        baseItemCombo:SetValue("")
        nameEntry:SetValue("")
        classnameEntry:SetValue("")
        descriptionEntry:SetValue("")
        iconEntry:SetValue(1)
        iconPreview.iconIndex = 1
        typeCombo:SetValue("misc")
        stackableCheckbox:SetChecked(false)
        weightEntry:SetValue(1)
        
        -- Deselect all items
        for _, e in pairs(itemButtons) do
            if IsValid(e) then e.isSelected = false end
        end
        selectedItemData = nil
    end
    
    local saveButton = vgui.Create("DButton", buttonsPanel)
    saveButton:SetText("")
    saveButton:SetPos(paintLib.WidthSource(220), 0)
    saveButton:SetSize(paintLib.WidthSource(200), paintLib.HightSource(40))
    saveButton.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Color(60, 90, 140, 180) or Color(50, 80, 130, 180))
        draw.SimpleText("Сохранить", "TL X18", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    saveButton.DoClick = function()
        local id = classnameEntry:GetValue()
        -- Check if trying to modify a hardcoded item
        if itemList and itemList[id] and not itemList[id].fromJSON then 
            notification.AddLegacy("Нельзя изменять заскриптованые предметы", NOTIFY_ERROR, 3)
            return 
        end
        
        if id == "" then
            notification.AddLegacy("Укажите ID название предмета", NOTIFY_ERROR, 3)
            return
        end
        
        local data = {
            baseItem = baseItemCombo:GetValue(),
            Name = nameEntry:GetValue(),
            Description = descriptionEntry:GetValue(),
            Icon = iconEntry:GetValue(),
            Type = typeCombo:GetValue(),
            idname = id,
            stackable = stackableCheckbox:GetChecked(),
            weight = weightEntry:GetValue(),
        }
        
        net.Start("AdminCreateItem")
        net.WriteTable(data)
        net.SendToServer()
        
        notification.AddLegacy("Предмет сохранен", NOTIFY_SUCCESS, 3)
    end
    
    -- Close button
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetSize(paintLib.WidthSource(150), paintLib.HightSource(40))
    closeBtn:SetPos(frame:GetWide() - paintLib.WidthSource(200), paintLib.HightSource(650))
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Color(70, 30, 30, 180) or Color(50, 20, 20, 180))
        draw.SimpleText("Закрыть", "TL X20", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        frame:Remove()
    end
end

concommand.Add("fantasy_itemcreator", function(ply)
    if IsValid(ply) and (ply:IsAdmin() or ply:IsSuperAdmin()) then
        OpenItemCreationMenu()
    end
end)