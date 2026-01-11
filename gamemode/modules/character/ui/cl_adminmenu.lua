netstream.Hook("fantasy/player/getAll", function(data)
    for k, i in pairs(data) do
        k.characterData = i
    end
end)

local function CreateCharacterEditMenu()
    if IsValid(characterEditFrame) then
        characterEditFrame:Remove()
    end
    
    netstream.Start("fantasy/player/getAll")
    local selectedPlayer = nil
    
    local frame = vgui.Create("DFrame")
    characterEditFrame = frame
    frame:SetSize(paintLib.WidthSource(1100), paintLib.HightSource(700))
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:ShowCloseButton(false)
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 40, 240))
        
        local corner_size = 50
        local corner_width = 3
        local glow = math.abs(math.sin(CurTime() * 1.5)) * 50
        local cornerColor = Color(220, 170, 60, 255 - glow)
        
        surface.SetDrawColor(cornerColor)
        
        surface.DrawRect(0, 0, corner_size, corner_width)
        surface.DrawRect(0, 0, corner_width, corner_size)
        
        surface.DrawRect(w - corner_size, 0, corner_size, corner_width)
        surface.DrawRect(w - corner_width, 0, corner_width, corner_size)
        
        surface.DrawRect(0, h - corner_width, corner_size, corner_width)
        surface.DrawRect(0, h - corner_size, corner_width, corner_size)
        
        surface.DrawRect(w - corner_size, h - corner_width, corner_size, corner_width)
        surface.DrawRect(w - corner_width, h - corner_size, corner_width, corner_size)
        
        local titleText = "РЕДАКТОР ПЕРСОНАЖЕЙ"
        local titleColor = Color(255, 215, 100)
        local glowAmount = math.abs(math.sin(CurTime() * 2)) * 55
        
        draw.SimpleText(titleText, "TL X28", w / 2, 40, Color(255, 215, 100, glowAmount), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(titleText, "TL X28", w / 2, 40, titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
         
        surface.SetDrawColor(220, 170, 60, 150 + glowAmount)
        surface.DrawRect(w * 0.1, paintLib.HightSource(70), w * 0.8, 2)
    end
    
    local contentPanel = vgui.Create("DPanel", frame)
    contentPanel:SetPos(paintLib.WidthSource(50), paintLib.HightSource(90))
    contentPanel:SetSize(paintLib.WidthSource(1000), paintLib.HightSource(550))
    contentPanel.Paint = function() end
    
    local playerPanel = vgui.Create("DPanel", contentPanel)
    playerPanel:SetPos(0, 0)
    playerPanel:SetSize(paintLib.WidthSource(300), paintLib.HightSource(550))
    playerPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 50, 180))
        draw.SimpleText("ВЫБОР ИГРОКА", "TL X22", w/2, paintLib.HightSource(20), Color(220, 170, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(220, 170, 60, 150)
        surface.DrawRect(w * 0.1, paintLib.HightSource(35), w * 0.8, 2)
    end
    
    local playerSearch = vgui.Create("DTextEntry", playerPanel)
    playerSearch:SetPos(paintLib.WidthSource(15), paintLib.HightSource(50))
    playerSearch:SetSize(paintLib.WidthSource(270), paintLib.HightSource(30))
    playerSearch:SetPlaceholderText("Поиск игрока...")
    playerSearch:SetFont("TL X18")
    
    local playerScroll = vgui.Create("DScrollPanel", playerPanel)
    playerScroll:SetPos(paintLib.WidthSource(15), paintLib.HightSource(85))
    playerScroll:SetSize(paintLib.WidthSource(270), paintLib.HightSource(450))
    
    local playerEntries = {}
    
    local function UpdatePlayerList(searchTerm)
        for _, entry in pairs(playerEntries) do
            if IsValid(entry) then entry:Remove() end
        end
        playerEntries = {}
        
        for i, ply in ipairs(player.GetAll()) do
            if not searchTerm or string.find(string.lower(ply:Nick()), string.lower(searchTerm)) then
                local entry = vgui.Create("DButton", playerScroll)
                entry:SetTall(paintLib.HightSource(50))
                entry:Dock(TOP)
                entry:DockMargin(0, 0, 0, paintLib.HightSource(4))
                entry:SetText("")
                entry.ply = ply
                entry.isSelected = false
                
                local avatar = vgui.Create("AvatarImage", entry)
                avatar:SetSize(paintLib.HightSource(40), paintLib.HightSource(40))
                avatar:SetPos(paintLib.WidthSource(5), paintLib.HightSource(5))
                avatar:SetPlayer(ply, 64)
                
                entry.Paint = function(self, w, h)
                    local bgColor = Color(60, 60, 70, 180)
                    
                    if self.isSelected then
                        bgColor = Color(80, 120, 160, 180)
                    elseif self:IsHovered() then
                        bgColor = Color(70, 70, 80, 180)
                    end
                    
                    draw.RoundedBox(6, 0, 0, w, h, bgColor)
                    
                    draw.SimpleText(ply:GetName(), "TL X18", paintLib.WidthSource(55), paintLib.HightSource(14), Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(ply:SteamID(), "TL X16", paintLib.WidthSource(55), paintLib.HightSource(32), Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    
                    if self.isSelected then
                        surface.SetDrawColor(220, 170, 60, 200)
                        surface.DrawRect(0, h - 2, w, 2)
                    end
                end
                
                entry.DoClick = function(self)
                    for _, e in pairs(playerEntries) do
                        if IsValid(e) then e.isSelected = false end
                    end
                    
                    self.isSelected = true
                    selectedPlayer = self.ply
                    
                    if selectedPlayer then
                        nameEntry:SetValue(selectedPlayer:GetName())
                        genderCombo:SetValue(selectedPlayer:GetGender())
                        raceCombo:SetValue(listRace[selectedPlayer:GetRace()].name)
                        levelEntry:SetValue(selectedPlayer:GetLvl())
                        experienceEntry:SetValue(selectedPlayer:GetExperience())
                        skillPointsEntry:SetValue(selectedPlayer:GetSkillPoints())
                        for attribute, value in pairs(selectedPlayer:GetAttributes()) do
                            attributeEntries[attribute]:SetValue(value)
                        end
                        customModelEntry:SetValue(selectedPlayer:GetCharacterData("customModel") or "")
                    end
                end
                
                table.insert(playerEntries, entry)
            end
        end
    end
    
    UpdatePlayerList()
    
    playerSearch.OnChange = function(self)
        UpdatePlayerList(self:GetValue())
    end
    
    local characterPanel = vgui.Create("DPanel", contentPanel)
    characterPanel:SetPos(paintLib.WidthSource(310), 0)
    characterPanel:SetSize(paintLib.WidthSource(690), paintLib.HightSource(550))
    characterPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 50, 180))
        draw.SimpleText("РЕДАКТИРОВАНИЕ ПЕРСОНАЖА", "TL X22", w/2, paintLib.HightSource(20), Color(220, 170, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(220, 170, 60, 150)
        surface.DrawRect(w * 0.1, paintLib.HightSource(35), w * 0.8, 2)
        
        if not selectedPlayer then
            draw.SimpleText("Выберите игрока для редактирования", "TL X20", w/2, h/2, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    local characterScroll = vgui.Create("DScrollPanel", characterPanel)
    characterScroll:SetPos(paintLib.WidthSource(20), paintLib.HightSource(50))
    characterScroll:SetSize(paintLib.WidthSource(650), paintLib.HightSource(485))
    
    local function CreateLabel(text)
        local label = vgui.Create("DLabel", characterScroll)
        label:SetText(text)
        label:SetTextColor(Color(255, 255, 255))
        label:SetFont("TL X18")
        label:Dock(TOP)
        label:DockMargin(paintLib.WidthSource(5), paintLib.HightSource(10), 0, 0)
        return label
    end
    
    local function CreateTextEntry()
        local entry = vgui.Create("DTextEntry", characterScroll)
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
        local entry = vgui.Create("DNumberWang", characterScroll)
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
        local combo = vgui.Create("DComboBox", characterScroll)
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
    
    CreateLabel("Имя персонажа:")
    nameEntry = CreateTextEntry()
    
    CreateLabel("Пол:")
    genderCombo = CreateComboBox({"Мужчина", "Женщина"})
    
    CreateLabel("Раса:")
    raceCombo = CreateComboBox({})
    for race, data in pairs(listRace) do
        raceCombo:AddChoice(data.name)
    end
    
    CreateLabel("Уровень:")
    levelEntry = CreateNumberWang()
    
    CreateLabel("Опыт:")
    experienceEntry = CreateNumberWang()
    
    CreateLabel("Очки навыков:")
    skillPointsEntry = CreateNumberWang()
    
    local attributeSeparator = vgui.Create("DPanel", characterScroll)
    attributeSeparator:Dock(TOP)
    attributeSeparator:DockMargin(paintLib.WidthSource(0), paintLib.HightSource(15), 0, paintLib.HightSource(5))
    attributeSeparator:SetHeight(paintLib.HightSource(30))
    attributeSeparator.Paint = function(self, w, h)
        draw.SimpleText("АТРИБУТЫ ПЕРСОНАЖА", "TL X18", w/2, h/2, Color(220, 170, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(220, 170, 60, 150)
        surface.DrawRect(w * 0.05, h - 2, w * 0.9, 2)
    end
    
    local attributes = {"strength", "agility", "intelligence", "vitality", "luck"}
    attributeEntries = {}
    
    for _, attribute in ipairs(attributes) do
        CreateLabel(string.upper(attribute) .. ":")
        local entry = CreateNumberWang()
        attributeEntries[attribute] = entry
    end
    
    CreateLabel("Кастомная модель (если есть):")
    customModelEntry = CreateTextEntry()
    
    local buttonPanel = vgui.Create("DPanel", characterScroll)
    buttonPanel:Dock(TOP)
    buttonPanel:DockMargin(paintLib.WidthSource(0), paintLib.HightSource(20), 0, 0)
    buttonPanel:SetHeight(paintLib.HightSource(40))
    buttonPanel.Paint = function() end
    
    local saveButton = vgui.Create("DButton", buttonPanel)
    saveButton:SetText("")
    saveButton:SetSize(paintLib.WidthSource(200), paintLib.HightSource(40))
    saveButton:SetPos(paintLib.WidthSource(225), 0)
    saveButton.Paint = function(self, w, h)
        local canSave = selectedPlayer ~= nil
        local btnColor = canSave and (self:IsHovered() and Color(40, 100, 50, 180) or Color(30, 80, 40, 180)) or Color(60, 60, 60, 180)
        
        draw.RoundedBox(6, 0, 0, w, h, btnColor)
        draw.SimpleText("Сохранить", "TL X20", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    saveButton.DoClick = function()
        if not selectedPlayer then return end
        
        local data = {
            player = selectedPlayer,
            name = nameEntry:GetValue(),
            gender = genderCombo:GetValue(),
            race = raceCombo:GetValue(),
            level = levelEntry:GetValue(),
            experience = experienceEntry:GetValue(),
            skillPoints = skillPointsEntry:GetValue(),
            customModel = customModelEntry:GetValue(),
            attributes = {}
        }
        
        for attribute, entry in pairs(attributeEntries) do
            data.attributes[attribute] = entry:GetValue()
        end
        
        net.Start("AdminSaveCharacterData")
        net.WriteTable(data)
        net.SendToServer()
        
        frame:Close()
    end
    
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

concommand.Add("fantasy_charedit", function(ply)
    if IsValid(ply) and (ply:IsAdmin() or ply:IsSuperAdmin()) then
        CreateCharacterEditMenu()
    end
end)

-- Add this function to be accessible from external files
function OpenCharacterEditMenu()
    CreateCharacterEditMenu()
end