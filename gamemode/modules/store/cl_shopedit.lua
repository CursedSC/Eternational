Shops = {}

function OpenShopEditMenu()
    if IsValid(shopEditFrame) then
        shopEditFrame:Remove()
    end
    
    local selectedShopIndex = nil
    local selectedShopData = nil

    shopEditFrame = vgui.Create("DFrame")
    shopEditFrame:SetSize(paintLib.WidthSource(1100), paintLib.HightSource(700))
    shopEditFrame:Center()
    shopEditFrame:SetTitle("")
    shopEditFrame:SetDraggable(true)
    shopEditFrame:MakePopup()
    shopEditFrame:ShowCloseButton(false)
    
    shopEditFrame.Paint = function(self, w, h)
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
        
        local titleText = "РЕДАКТОР МАГАЗИНОВ"
        local titleColor = Color(255, 215, 100)
        local glowAmount = math.abs(math.sin(CurTime() * 2)) * 55
        
        draw.SimpleText(titleText, "TL X28", w / 2, 40, Color(255, 215, 100, glowAmount), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(titleText, "TL X28", w / 2, 40, titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
         
        surface.SetDrawColor(220, 170, 60, 150 + glowAmount)
        surface.DrawRect(w * 0.1, paintLib.HightSource(70), w * 0.8, 2)
    end
    
    local contentPanel = vgui.Create("DPanel", shopEditFrame)
    contentPanel:SetPos(paintLib.WidthSource(50), paintLib.HightSource(90))
    contentPanel:SetSize(paintLib.WidthSource(1000), paintLib.HightSource(550))
    contentPanel.Paint = function() end
    
    local shopListPanel = vgui.Create("DPanel", contentPanel)
    shopListPanel:SetPos(0, 0)
    shopListPanel:SetSize(paintLib.WidthSource(300), paintLib.HightSource(550))
    shopListPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 50, 180))
        draw.SimpleText("СПИСОК МАГАЗИНОВ", "TL X22", w/2, paintLib.HightSource(20), Color(220, 170, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(220, 170, 60, 150)
        surface.DrawRect(w * 0.1, paintLib.HightSource(35), w * 0.8, 2)
    end
    
    local shopScroll = vgui.Create("DScrollPanel", shopListPanel)
    shopScroll:SetPos(paintLib.WidthSource(10), paintLib.HightSource(50))
    shopScroll:SetSize(paintLib.WidthSource(280), paintLib.HightSource(440))
    
    
    local shopButtons = {}
    
    function PopulateShopList()
        shopScroll:Clear()
        shopButtons = {}
        
        for shopId, shopData in pairs(Shops) do
            local shopButton = vgui.Create("DButton", shopScroll)
            shopButton:SetSize(paintLib.WidthSource(270), paintLib.HightSource(40))
            shopButton:Dock(TOP)
            shopButton:DockMargin(0, 0, 0, paintLib.HightSource(5))
            shopButton:SetText("")
            
            shopButton.Paint = function(self, w, h)
                local color = self:IsHovered() and Color(60, 60, 80, 200) or Color(50, 50, 70, 180)
                if self.Selected then
                    color = Color(70, 90, 120, 200)
                end
                
                draw.RoundedBox(4, 0, 0, w, h, color)
                
                if self.Selected then
                    surface.SetDrawColor(220, 170, 60, 255)
                    surface.DrawRect(0, 0, 3, h)
                end
                
                draw.SimpleText("Магазин #" .. shopId, "TL X20", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            
            shopButton.DoClick = function(self)
                for _, btn in ipairs(shopButtons) do
                    btn.Selected = false
                end
                self.Selected = true
                selectedShopIndex = shopId
                selectedShopData = shopData
                LoadShopItems()
            end
            
            table.insert(shopButtons, shopButton)
        end
    end
    
    PopulateShopList()
    
    local shopEditPanel = vgui.Create("DPanel", contentPanel)
    shopEditPanel:SetPos(paintLib.WidthSource(310), 0)
    shopEditPanel:SetSize(paintLib.WidthSource(690), paintLib.HightSource(550))
    shopEditPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 50, 180))
        
        local title = "РЕДАКТИРОВАНИЕ ТОВАРОВ"
        if selectedShopIndex then
            title = "МАГАЗИН #" .. selectedShopIndex
        end
        
        draw.SimpleText(title, "TL X22", w/2, paintLib.HightSource(20), Color(220, 170, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(220, 170, 60, 150)
        surface.DrawRect(w * 0.1, paintLib.HightSource(35), w * 0.8, 2)
        
        if not selectedShopIndex then
            draw.SimpleText("Выберите магазин для редактирования", "TL X20", w/2, h/2, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    local propertySheet = vgui.Create("DPropertySheet", shopEditPanel)
    propertySheet:SetPos(paintLib.WidthSource(10), paintLib.HightSource(50))
    propertySheet:SetSize(paintLib.WidthSource(670), paintLib.HightSource(435))
    
    local sellTab = vgui.Create("DPanel", propertySheet)
    sellTab.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(50, 50, 60, 100))
    end
    
    local buyTab = vgui.Create("DPanel", propertySheet)
    buyTab.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(50, 50, 60, 100))
    end
    
    propertySheet:AddSheet("Товары на продажу", sellTab, "icon16/cart.png")
    propertySheet:AddSheet("Товары на покупку", buyTab, "icon16/money.png")
    
    local sellScroll = vgui.Create("DScrollPanel", sellTab)
    sellScroll:Dock(FILL)
    sellScroll:DockMargin(5, 5, 5, 5)
    
    local buyScroll = vgui.Create("DScrollPanel", buyTab)
    buyScroll:Dock(FILL)
    buyScroll:DockMargin(5, 5, 5, 5)
    
    local function CreateItemPanel(parent, itemData, itemIndex, itemType)
        local itemPanel = vgui.Create("DPanel", parent)
        itemPanel:SetTall(paintLib.HightSource(60))
        itemPanel:Dock(TOP)
        itemPanel:DockMargin(0, 0, 0, paintLib.HightSource(5))
        itemPanel.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(60, 60, 70, 180))
        end
        
        local idCombo = vgui.Create("DComboBox", itemPanel)
        idCombo:SetPos(paintLib.WidthSource(10), paintLib.HightSource(15))
        idCombo:SetSize(paintLib.WidthSource(300), paintLib.HightSource(30))
        idCombo:SetValue(itemData.id or "")
        idCombo:SetFont("TL X18")
        
        for key, _ in pairs(itemList) do
            idCombo:AddChoice(key)
        end
        
        local costLabel = vgui.Create("DLabel", itemPanel)
        costLabel:SetPos(paintLib.WidthSource(320), paintLib.HightSource(15))
        costLabel:SetSize(paintLib.WidthSource(70), paintLib.HightSource(30))
        costLabel:SetText("Цена:")
        costLabel:SetFont("TL X18")
        costLabel:SetTextColor(Color(255, 255, 255))
        
        local costEntry = vgui.Create("DNumberWang", itemPanel)
        costEntry:SetPos(paintLib.WidthSource(390), paintLib.HightSource(15))
        costEntry:SetSize(paintLib.WidthSource(100), paintLib.HightSource(30))
        costEntry:SetMinMax(0, 10000)
        costEntry:SetValue(itemData.cost or 0)
        costEntry:SetFont("TL X18")
        costEntry:SetTextColor(Color(255, 255, 255))
        
        costEntry.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 60, 180))
            self:DrawTextEntryText(Color(255, 255, 255), Color(180, 140, 60), Color(255, 255, 255))
        end
        
        local removeBtn = vgui.Create("DButton", itemPanel)
        removeBtn:SetSize(paintLib.WidthSource(100), paintLib.HightSource(30))
        removeBtn:SetPos(paintLib.WidthSource(500), paintLib.HightSource(15))
        removeBtn:SetText("")
        removeBtn.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and Color(150, 30, 30, 180) or Color(120, 30, 30, 180))
            draw.SimpleText("Удалить", "TL X18", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        removeBtn.DoClick = function()
            if itemType == "Sell" then
                table.remove(selectedShopData.Sell, itemIndex)
            elseif itemType == "Buy" then
                table.remove(selectedShopData.Buy, itemIndex)
            end
            LoadShopItems()
        end
        
        itemPanel.UpdateData = function()
            itemData.id = idCombo:GetValue()
            itemData.cost = costEntry:GetValue()
        end
        
        return itemPanel
    end
    
    local function UpdateShopDataFromUI()
        for _, child in ipairs(sellScroll:GetCanvas():GetChildren()) do
            if child.UpdateData then
                child:UpdateData()
            end
        end
        for _, child in ipairs(buyScroll:GetCanvas():GetChildren()) do
            if child.UpdateData then
                child:UpdateData()
            end
        end
    end
    
    function LoadShopItems()
        if not selectedShopData then return end
        
        sellScroll:Clear()
        buyScroll:Clear()
        
        if selectedShopData.Sell then
            for i, item in ipairs(selectedShopData.Sell) do
                CreateItemPanel(sellScroll, item, i, "Sell")
            end
        else
            selectedShopData.Sell = {}
        end
        
        local addSellBtn = vgui.Create("DButton", sellScroll)
        addSellBtn:SetSize(paintLib.WidthSource(630), paintLib.HightSource(40))
        addSellBtn:Dock(TOP)
        addSellBtn:DockMargin(0, paintLib.HightSource(10), 0, 0)
        addSellBtn:SetText("")
        addSellBtn.Paint = function(self, w, h)
            local color = self:IsHovered() and Color(40, 80, 40, 180) or Color(30, 60, 30, 180)
            draw.RoundedBox(6, 0, 0, w, h, color)
            draw.SimpleText("Добавить товар для продажи", "TL X18", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        addSellBtn.DoClick = function()
            table.insert(selectedShopData.Sell, {id = "", cost = 0})
            LoadShopItems()
        end
        
        if selectedShopData.Buy then
            for i, item in ipairs(selectedShopData.Buy) do
                CreateItemPanel(buyScroll, item, i, "Buy")
            end
        else
            selectedShopData.Buy = {}
        end
        
        local addBuyBtn = vgui.Create("DButton", buyScroll)
        addBuyBtn:SetSize(paintLib.WidthSource(630), paintLib.HightSource(40))
        addBuyBtn:Dock(TOP)
        addBuyBtn:DockMargin(0, paintLib.HightSource(10), 0, 0)
        addBuyBtn:SetText("")
        addBuyBtn.Paint = function(self, w, h)
            local color = self:IsHovered() and Color(40, 60, 80, 180) or Color(30, 50, 70, 180)
            draw.RoundedBox(6, 0, 0, w, h, color)
            draw.SimpleText("Добавить товар для покупки", "TL X18", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        addBuyBtn.DoClick = function()
            table.insert(selectedShopData.Buy, {id = "", cost = 0})
            LoadShopItems()
        end
    end
    
    local saveBtn = vgui.Create("DButton", shopEditPanel)
    saveBtn:SetSize(paintLib.WidthSource(150), paintLib.HightSource(40))
    saveBtn:SetPos(paintLib.WidthSource(530), paintLib.HightSource(500))
    saveBtn:SetText("")
    saveBtn.Paint = function(self, w, h)
        local canSave = selectedShopIndex ~= nil
        local color = canSave and (self:IsHovered() and Color(40, 100, 50, 180) or Color(30, 80, 40, 180)) or Color(60, 60, 60, 180)
        
        draw.RoundedBox(6, 0, 0, w, h, color)
        draw.SimpleText("Сохранить", "TL X20", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    saveBtn.DoClick = function()
        if not selectedShopIndex then return end
        
        UpdateShopDataFromUI()
        
        local data = {
            shopIndex = selectedShopIndex,
            shopData = selectedShopData
        }
        
        netstream.Start("fantasy/store/editShop", data)
    end
    
    
    local closeBtn = vgui.Create("DButton", shopEditFrame)
    closeBtn:SetSize(paintLib.WidthSource(150), paintLib.HightSource(40))
    closeBtn:SetPos(shopEditFrame:GetWide() - paintLib.WidthSource(200), paintLib.HightSource(650))
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Color(70, 30, 30, 180) or Color(50, 20, 20, 180))
        draw.SimpleText("Закрыть", "TL X20", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        shopEditFrame:Remove()
    end
end

concommand.Add("fantasy_shopedit", function(ply)
    if IsValid(ply) and (ply:IsAdmin() or ply:IsSuperAdmin()) then
        OpenShopEditMenu()
    end
end)

netstream.Hook("fantasy/store/updateShops", function(data)
    Shops = data
    if IsValid(shopEditFrame) then
        PopulateShopList()
    end
end)