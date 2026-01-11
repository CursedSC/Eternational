function OpenRPMenu(data)
    if IsValid(rpDataFrame) then
        rpDataFrame:Remove()
    end
    
    local editMode = false
    local editData = table.Copy(data)
    
    
    rpDataFrame = vgui.Create("DFrame")
    rpDataFrame:SetSize(paintLib.WidthSource(900), paintLib.HightSource(650))
    rpDataFrame:Center()
    rpDataFrame:SetTitle("")
    rpDataFrame:SetDraggable(true)
    rpDataFrame:MakePopup()
    rpDataFrame:ShowCloseButton(false)
    
    
    rpDataFrame.Paint = function(self, w, h)
        
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
        
        
        local titleText = editMode and "РЕДАКТИРОВАНИЕ ПЕРСОНАЖА" or "ИНФОРМАЦИЯ О ПЕРСОНАЖЕ"
        local titleColor = Color(255, 215, 100)
        local glowAmount = math.abs(math.sin(CurTime() * 2)) * 55
        
        
        draw.SimpleText(titleText, "TL X28", w / 2, 40, Color(255, 215, 100, glowAmount), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(titleText, "TL X28", w / 2, 40, titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
         
        
        surface.SetDrawColor(220, 170, 60, 150 + glowAmount)
        surface.DrawRect(w * 0.1, paintLib.HightSource(70), w * 0.8, 2)
        
    end
    
    
    local contentPanel = vgui.Create("DPanel", rpDataFrame)
    contentPanel:SetPos(paintLib.WidthSource(50), paintLib.HightSource(90))
    contentPanel:SetSize(paintLib.WidthSource(800), paintLib.HightSource(500))
    contentPanel.Paint = function() end
    
    
    local infoPanel = vgui.Create("DPanel", contentPanel)
    infoPanel:SetPos(0, 0)
    infoPanel:SetSize(paintLib.WidthSource(450), paintLib.HightSource(280))
    infoPanel.Paint = function(self, w, h)
        
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 50, 180))
        
        if not editMode then
            
            draw.SimpleText("Имя персонажа: " .. data.name, "TL X20", paintLib.WidthSource(20), paintLib.HightSource(20), Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Фракция: " .. data.fraction, "TL X20", paintLib.WidthSource(20), paintLib.HightSource(50), Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Описание персонажа:", "TL X20", paintLib.WidthSource(20), paintLib.HightSource(80), Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            local _, textHeight = surface.DrawMulticolorText2(paintLib.WidthSource(20), paintLib.HightSource(100), "TL X20", {color_white, data.description}, paintLib.WidthSource(410))
        end
    end
    
    
    local prefPanel = vgui.Create("DPanel", contentPanel)
    prefPanel:SetPos(0, paintLib.HightSource(290))
    prefPanel:SetSize(paintLib.WidthSource(450), paintLib.HightSource(200))
    prefPanel.Paint = function(self, w, h)
        
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 50, 180))
        
        
        draw.SimpleText("НАСТРОЙКИ ОТЫГРЫША", "TL X22", w/2, paintLib.HightSource(20), Color(220, 170, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        
        surface.SetDrawColor(220, 170, 60, 150)
        surface.DrawRect(w * 0.1, paintLib.HightSource(35), w * 0.8, 2)
        
        if not editMode then
            
            draw.SimpleText("Травмирование персонажа: " .. (data.RolePlayWounds and "Да" or "Нет"), "TL X20", w * 0.1, paintLib.HightSource(60), Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Роман с персонажом: " .. (data.RolePlayERP and "Да" or "Нет"), "TL X20",w * 0.1, paintLib.HightSource(90), Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Непротив смерти персонажа: " .. (data.RolePlayTorture and "Да" or "Нет"), "TL X20", w * 0.1, paintLib.HightSource(120), Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
    
    
    local statusPanel = vgui.Create("DPanel", contentPanel)
    statusPanel:SetPos(paintLib.WidthSource(460), 0)
    statusPanel:SetSize(paintLib.WidthSource(340), paintLib.HightSource(490))
    statusPanel.Paint = function(self, w, h)
        
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 50, 180))
        
        
        draw.SimpleText("СТАТУСЫ", "TL X22", w/2, paintLib.HightSource(20), Color(220, 170, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        
        surface.SetDrawColor(220, 170, 60, 150)
        surface.DrawRect(w * 0.1, paintLib.HightSource(35), w * 0.8, 2)
        
        if not editMode then
            
            local y = paintLib.HightSource(50)
            for k, v in pairs(data.statuses) do
                surface.SetDrawColor(220, 170, 60, 100)
                surface.DrawRect(w * 0.1, y, w * 0.8, 1)
                
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(Material(v.icon))
                surface.DrawTexturedRect(w * 0.1, y + paintLib.HightSource(10), paintLib.HightSource(32), paintLib.HightSource(32))
                
                draw.SimpleText(v.text, "TL X20", w * 0.1 + paintLib.HightSource(40), y + paintLib.HightSource(27), Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                y = y + paintLib.HightSource(55)
            end
        end
    end
     
    
    local nameEntry, fractionEntry, descEntry
    local woundsCheck, erpCheck, tortureCheck
    
    
    local function toggleEditMode()
        editMode = not editMode
        
        if editMode then

            descEntry = vgui.Create("DTextEntry", infoPanel)
            descEntry:SetPos(paintLib.WidthSource(20), paintLib.HightSource(100))
            descEntry:SetSize(paintLib.WidthSource(410), paintLib.HightSource(160))
            descEntry:SetText(data.description)
            descEntry:SetMultiline(true)
            descEntry:SetFont("TL X18")
            
            
            local nameLabel = vgui.Create("DLabel", infoPanel)
            nameLabel:SetPos(paintLib.WidthSource(20), paintLib.HightSource(20))
            nameLabel:SetSize(paintLib.WidthSource(230), paintLib.HightSource(25))
            nameLabel:SetText("Имя персонажа: "..data.name)
            nameLabel:SetFont("TL X20")
            nameLabel:SetTextColor(Color(255, 255, 255))
            
            local fractionLabel = vgui.Create("DLabel", infoPanel)
            fractionLabel:SetPos(paintLib.WidthSource(20), paintLib.HightSource(50))
            fractionLabel:SetSize(paintLib.WidthSource(230), paintLib.HightSource(25))
            fractionLabel:SetText("Фракция: "..data.fraction)
            fractionLabel:SetFont("TL X20")
            fractionLabel:SetTextColor(Color(255, 255, 255))
            
            local descLabel = vgui.Create("DLabel", infoPanel)
            descLabel:SetPos(paintLib.WidthSource(20), paintLib.HightSource(80))
            descLabel:SetSize(paintLib.WidthSource(200), paintLib.HightSource(25))
            descLabel:SetText("Описание персонажа:")
            descLabel:SetFont("TL X20")
            descLabel:SetTextColor(Color(255, 255, 255))
            
            
            woundsCheck = vgui.Create("DCheckBox", prefPanel)
            woundsCheck:SetPos(paintLib.WidthSource(20), paintLib.HightSource(60))
            woundsCheck:SetValue(data.RolePlayWounds)
            
            erpCheck = vgui.Create("DCheckBox", prefPanel)
            erpCheck:SetPos(paintLib.WidthSource(20), paintLib.HightSource(90))
            erpCheck:SetValue(data.RolePlayERP)
            
            tortureCheck = vgui.Create("DCheckBox", prefPanel)
            tortureCheck:SetPos(paintLib.WidthSource(20), paintLib.HightSource(120))
            tortureCheck:SetValue(data.RolePlayTorture)
            
            
            local woundsLabel = vgui.Create("DLabel", prefPanel)
            woundsLabel:SetPos(paintLib.WidthSource(40), paintLib.HightSource(60))
            woundsLabel:SetSize(paintLib.WidthSource(300), paintLib.HightSource(25))
            woundsLabel:SetText("Травмирование персонажа")
            woundsLabel:SetFont("TL X20")
            woundsLabel:SetTextColor(Color(255, 255, 255))
            
            local erpLabel = vgui.Create("DLabel", prefPanel)
            erpLabel:SetPos(paintLib.WidthSource(40), paintLib.HightSource(90))
            erpLabel:SetSize(paintLib.WidthSource(300), paintLib.HightSource(25))
            erpLabel:SetText("Роман с персонажом")
            erpLabel:SetFont("TL X20")
            erpLabel:SetTextColor(Color(255, 255, 255))
            
            local tortureLabel = vgui.Create("DLabel", prefPanel)
            tortureLabel:SetPos(paintLib.WidthSource(40), paintLib.HightSource(120))
            tortureLabel:SetSize(paintLib.WidthSource(300), paintLib.HightSource(25))
            tortureLabel:SetText("Непротив смерти персонажа")
            tortureLabel:SetFont("TL X20")
            tortureLabel:SetTextColor(Color(255, 255, 255))
            
            
            local statusNote = vgui.Create("DLabel", statusPanel)
            statusNote:SetPos(paintLib.WidthSource(20), paintLib.HightSource(60))
            statusNote:SetSize(paintLib.WidthSource(300), paintLib.HightSource(50))
            statusNote:SetText("Статусы устанавливаются\nадминистратором")
            statusNote:SetFont("TL X20")
            statusNote:SetTextColor(Color(200, 200, 200))
            statusNote:SetContentAlignment(5)  
        else
            if IsValid(descEntry) then descEntry:Remove() end
            if IsValid(woundsCheck) then woundsCheck:Remove() end
            if IsValid(erpCheck) then erpCheck:Remove() end
            if IsValid(tortureCheck) then tortureCheck:Remove() end
            
            
            for _, child in pairs(infoPanel:GetChildren()) do
                child:Remove()
            end
            for _, child in pairs(prefPanel:GetChildren()) do
                child:Remove()
            end
            for _, child in pairs(statusPanel:GetChildren()) do
                child:Remove()
            end
        end
    end
    
    
    local function saveChanges()
        if not editMode then return end
        
        editData.description = descEntry:GetValue()
        editData.RolePlayWounds = woundsCheck:GetChecked()
        editData.RolePlayERP = erpCheck:GetChecked()
        editData.RolePlayTorture = tortureCheck:GetChecked()
        
        
        data = table.Copy(editData)
        
        netstream.Start("fantasy/rpdata/save", editData)
        toggleEditMode()
    end
    
    
    local closeBtn = vgui.Create("DButton", rpDataFrame)
    closeBtn:SetSize(paintLib.WidthSource(120), paintLib.HightSource(40))
    closeBtn:SetPos(paintLib.WidthSource(450) - paintLib.WidthSource(60), paintLib.HightSource(600))
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Color(70, 30, 30, 180) or Color(50, 20, 20, 180))
        draw.SimpleText("Закрыть", "TL X20", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        rpDataFrame:Remove()
    end
    
    local editBtn = vgui.Create("DButton", rpDataFrame)
    editBtn:SetSize(paintLib.WidthSource(120), paintLib.HightSource(40))
    editBtn:SetPos(paintLib.WidthSource(450) - paintLib.WidthSource(190), paintLib.HightSource(600))
    editBtn:SetText("")
    editBtn.Paint = function(self, w, h)
        local btnColor = editMode and Color(60, 70, 30, 180) or Color(30, 60, 70, 180)
        if self:IsHovered() then
            btnColor = editMode and Color(80, 90, 40, 180) or Color(40, 80, 90, 180)
        end
        draw.RoundedBox(6, 0, 0, w, h, btnColor)
        draw.SimpleText(editMode and "Сохранить" or "Изменить", "TL X20", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    editBtn.DoClick = function()
        if editMode then
            saveChanges()
        else
            toggleEditMode()
        end
    end 
    
    local cancelBtn = vgui.Create("DButton", rpDataFrame)
    cancelBtn:SetSize(paintLib.WidthSource(120), paintLib.HightSource(40))
    cancelBtn:SetPos(paintLib.WidthSource(450) - paintLib.WidthSource(320), paintLib.HightSource(600))
    cancelBtn:SetText("")
    cancelBtn:SetVisible(false)
    cancelBtn.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Color(70, 50, 30, 180) or Color(60, 40, 20, 180))
        draw.SimpleText("Отмена", "TL X20", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    cancelBtn.DoClick = function()
        toggleEditMode()
    end
    
    
    rpDataFrame.Think = function()
        cancelBtn:SetVisible(editMode)
    end
end

netstream.Hook("fantasy/rpdata/open", function(data)
    OpenRPMenu(data)
end)

