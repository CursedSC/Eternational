local iconList = {}

for k = 1, 174 do
    table.insert(iconList, "icons_/2/"..k..".png")
end

function OpenStatusAdminMenu()
    if IsValid(statusAdminFrame) then
        statusAdminFrame:Remove()
    end
    
    local selectedPlayer = nil
    local players = player.GetAll()
    local selectedIcon = iconList[1]
    local statusText = ""
    
    
    statusAdminFrame = vgui.Create("DFrame")
    statusAdminFrame:SetSize(paintLib.WidthSource(1000), paintLib.HightSource(700))
    statusAdminFrame:Center()
    statusAdminFrame:SetTitle("")
    statusAdminFrame:SetDraggable(true)
    statusAdminFrame:MakePopup()
    statusAdminFrame:ShowCloseButton(false)
    
    
    statusAdminFrame.Paint = function(self, w, h)
        
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
        
        
        local titleText = "УПРАВЛЕНИЕ СТАТУСАМИ RP"
        local titleColor = Color(255, 215, 100)
        local glowAmount = math.abs(math.sin(CurTime() * 2)) * 55
        
        
        draw.SimpleText(titleText, "TL X28", w / 2, 40, Color(255, 215, 100, glowAmount), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(titleText, "TL X28", w / 2, 40, titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
         
        
        surface.SetDrawColor(220, 170, 60, 150 + glowAmount)
        surface.DrawRect(w * 0.1, paintLib.HightSource(70), w * 0.8, 2)
    end
    
    
    local contentPanel = vgui.Create("DPanel", statusAdminFrame)
    contentPanel:SetPos(paintLib.WidthSource(50), paintLib.HightSource(90))
    contentPanel:SetSize(paintLib.WidthSource(900), paintLib.HightSource(550))
    contentPanel.Paint = function() end
    
    
    local playerPanel = vgui.Create("DPanel", contentPanel)
    playerPanel:SetPos(0, 0)
    playerPanel:SetSize(paintLib.WidthSource(300), paintLib.HightSource(250))
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
    playerScroll:SetSize(paintLib.WidthSource(270), paintLib.HightSource(150))
    
    local playerEntries = {}
    
    local function UpdatePlayerList(searchTerm)
        for _, entry in pairs(playerEntries) do
            if IsValid(entry) then entry:Remove() end
        end
        playerEntries = {}
        
        for i, ply in ipairs(players) do
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
                    
                    if IsValid(selectedPlayer) then
                        netstream.Start("fantasy/rpdata/admin/request", selectedPlayer:SteamID())
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
    
    local refreshListBtn = vgui.Create("DButton", playerPanel)
    refreshListBtn:SetSize(paintLib.WidthSource(30), paintLib.HightSource(30))
    refreshListBtn:SetPos(paintLib.WidthSource(255), paintLib.HightSource(50))
    refreshListBtn:SetText("")
    refreshListBtn.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and Color(70, 90, 110, 180) or Color(60, 80, 100, 180))
        draw.SimpleText("↻", "TL X20", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    refreshListBtn.DoClick = function()
        players = player.GetAll()
        UpdatePlayerList(playerSearch:GetValue())
    end
    
    
    local statusCreationPanel = vgui.Create("DPanel", contentPanel)
    statusCreationPanel:SetPos(0, paintLib.HightSource(260))
    statusCreationPanel:SetSize(paintLib.WidthSource(300), paintLib.HightSource(290))
    statusCreationPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 50, 180))
        draw.SimpleText("СОЗДАНИЕ СТАТУСА", "TL X22", w/2, paintLib.HightSource(20), Color(220, 170, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(220, 170, 60, 150)
        surface.DrawRect(w * 0.1, paintLib.HightSource(35), w * 0.8, 2)
        
        
        draw.SimpleText("ПРЕДПРОСМОТР:", "TL X18", w/2, paintLib.HightSource(155), Color(220, 170, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        
        draw.RoundedBox(4, w * 0.1, paintLib.HightSource(170), w * 0.8, paintLib.HightSource(50), Color(30, 30, 40, 180))
        
        
        if selectedIcon then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(Material(selectedIcon))
            surface.DrawTexturedRect(w * 0.15, paintLib.HightSource(180), paintLib.HightSource(32), paintLib.HightSource(32))
            
            local displayText = statusText ~= "" and statusText or "Введите текст статуса"
            draw.SimpleText(displayText, "TL X18", w * 0.15 + paintLib.HightSource(40), paintLib.HightSource(196), Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
    
    
    local iconLabel = vgui.Create("DLabel", statusCreationPanel)
    iconLabel:SetPos(paintLib.WidthSource(15), paintLib.HightSource(50))
    iconLabel:SetSize(paintLib.WidthSource(270), paintLib.HightSource(25))
    iconLabel:SetText("Выберите иконку:")
    iconLabel:SetFont("TL X18")
    iconLabel:SetTextColor(Color(255, 255, 255))
    
    local iconSelector = vgui.Create("DComboBox", statusCreationPanel)
    iconSelector:SetPos(paintLib.WidthSource(15), paintLib.HightSource(75))
    iconSelector:SetSize(paintLib.WidthSource(270), paintLib.HightSource(30))
    iconSelector:SetValue("Выберите иконку")
    
    
    for i, icon in ipairs(iconList) do
        iconSelector:AddChoice(icon, icon, i == 1)
    end
    
    iconSelector.OnSelect = function(_, _, _, data)
        selectedIcon = data
    end
    
    
    local textLabel = vgui.Create("DLabel", statusCreationPanel)
    textLabel:SetPos(paintLib.WidthSource(15), paintLib.HightSource(110))
    textLabel:SetSize(paintLib.WidthSource(270), paintLib.HightSource(25))
    textLabel:SetText("Текст статуса:")
    textLabel:SetFont("TL X18")
    textLabel:SetTextColor(Color(255, 255, 255))
    
    local textEntry = vgui.Create("DTextEntry", statusCreationPanel)
    textEntry:SetPos(paintLib.WidthSource(15), paintLib.HightSource(130))
    textEntry:SetSize(paintLib.WidthSource(270), paintLib.HightSource(30))
    textEntry:SetFont("TL X18")
    textEntry:SetPlaceholderText("Введите текст статуса")
    
    textEntry.OnChange = function()
        statusText = textEntry:GetValue()
    end
    
    
    local addButton = vgui.Create("DButton", statusCreationPanel)
    addButton:SetSize(paintLib.WidthSource(270), paintLib.HightSource(40))
    addButton:SetPos(paintLib.WidthSource(15), paintLib.HightSource(235))
    addButton:SetText("")
    addButton.Paint = function(self, w, h)
        local canAdd = selectedPlayer and selectedIcon and statusText ~= ""
        local btnColor = canAdd and Color(30, 80, 40, 180) or Color(60, 60, 60, 180)
        
        if canAdd and self:IsHovered() then
            btnColor = Color(40, 100, 50, 180)
        end
        
        draw.RoundedBox(6, 0, 0, w, h, btnColor)
        draw.SimpleText("Добавить статус", "TL X20", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    addButton.DoClick = function()
        if IsValid(selectedPlayer) and selectedIcon and statusText ~= "" then
            netstream.Start("fantasy/rpdata/admin/addstatus", {
                steamid = selectedPlayer:SteamID(),
                status = {
                    icon = selectedIcon,
                    text = statusText
                }
            })
            
            textEntry:SetValue("")
            statusText = ""
        end
    end
    
    
    local statusPanel = vgui.Create("DPanel", contentPanel)
    statusPanel:SetPos(paintLib.WidthSource(310), 0)
    statusPanel:SetSize(paintLib.WidthSource(590), paintLib.HightSource(550))
    statusPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 50, 180))
        draw.SimpleText("ТЕКУЩИЕ СТАТУСЫ", "TL X22", w/2, paintLib.HightSource(20), Color(220, 170, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(220, 170, 60, 150)
        surface.DrawRect(w * 0.1, paintLib.HightSource(35), w * 0.8, 2)
        
        if not IsValid(selectedPlayer) then
            draw.SimpleText("Выберите игрока для просмотра статусов", "TL X20", w/2, h/2, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    
    local statusScroll = vgui.Create("DScrollPanel", statusPanel)
    statusScroll:SetPos(paintLib.WidthSource(15), paintLib.HightSource(50))
    statusScroll:SetSize(paintLib.WidthSource(560), paintLib.HightSource(485))
    
    
    local function RefreshStatusList(statuses)
        statusScroll:Clear()
        
        if not statuses or table.Count(statuses) == 0 then
            local noStatusLabel = vgui.Create("DLabel", statusScroll)
            noStatusLabel:Dock(TOP)
            noStatusLabel:SetHeight(paintLib.HightSource(30))
            noStatusLabel:SetText("У игрока нет статусов")
            noStatusLabel:SetFont("TL X20")
            noStatusLabel:SetTextColor(Color(200, 200, 200))
            noStatusLabel:SetContentAlignment(5) 
            return
        end
        
        for k, v in pairs(statuses) do
            local statusEntry = vgui.Create("DPanel", statusScroll)
            statusEntry:Dock(TOP)
            statusEntry:SetHeight(paintLib.HightSource(60))
            statusEntry:DockMargin(0, 0, 0, paintLib.HightSource(5))
            
            statusEntry.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 60, 180))
                
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(Material(v.icon))
                surface.DrawTexturedRect(paintLib.WidthSource(10), h/2 - paintLib.HightSource(16), paintLib.HightSource(32), paintLib.HightSource(32))
                
                draw.SimpleText(v.text, "TL X20", paintLib.WidthSource(50), h/2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
            
            
            local removeBtn = vgui.Create("DButton", statusEntry)
            removeBtn:SetSize(paintLib.WidthSource(100), paintLib.HightSource(40))
            removeBtn:SetPos(paintLib.WidthSource(450), paintLib.HightSource(10))
            removeBtn:SetText("")
            
            removeBtn.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and Color(150, 30, 30, 180) or Color(120, 30, 30, 180))
                draw.SimpleText("Удалить", "TL X18", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            
            removeBtn.DoClick = function()
                netstream.Start("fantasy/rpdata/admin/removestatus", {
                    steamid = selectedPlayer:SteamID(),
                    statusKey = k
                })
            end
        end
    end
    
    
    netstream.Hook("fantasy/rpdata/admin/data", function(data)
        RefreshStatusList(data)
    end)
    
    
    local closeBtn = vgui.Create("DButton", statusAdminFrame)
    closeBtn:SetSize(paintLib.WidthSource(150), paintLib.HightSource(40))
    closeBtn:SetPos(paintLib.WidthSource(500) - paintLib.WidthSource(75), paintLib.HightSource(650))
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Color(70, 30, 30, 180) or Color(50, 20, 20, 180))
        draw.SimpleText("Закрыть", "TL X20", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        statusAdminFrame:Remove()
    end
    
    
    local refreshBtn = vgui.Create("DButton", statusAdminFrame)
    refreshBtn:SetSize(paintLib.WidthSource(150), paintLib.HightSource(40))
    refreshBtn:SetPos(paintLib.WidthSource(500) - paintLib.WidthSource(235), paintLib.HightSource(650))
    refreshBtn:SetText("")
    refreshBtn.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Color(30, 70, 90, 180) or Color(30, 60, 80, 180))
        draw.SimpleText("Обновить", "TL X20", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    refreshBtn.DoClick = function()
        if IsValid(selectedPlayer) then
            netstream.Start("fantasy/rpdata/admin/request", selectedPlayer:SteamID())
        end
    end
end

concommand.Add("fantasy_statusadmin", function(ply)
    if not IsValid(ply) or ply:IsAdmin() then
        OpenStatusAdminMenu()
    end
end)

netstream.Hook("fantasy/rpdata/admin/open", function()
    OpenStatusAdminMenu()
end)

