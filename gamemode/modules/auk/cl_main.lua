local COMMISSION_RATE = 0.15 -- 15% commission fee
local AUCTION_DURATIONS = {
    {name = "12 часов", hours = 12},
    {name = "1 день", hours = 24},
    {name = "3 дня", hours = 72},
    {name = "7 дней", hours = 168}
}


local auctionFrame = nil
local activeTab = "browse"
local currentListings = {}
local myListings = {}
local selectedItem = nil

local function FormatMoney(amount)
    return amount .. " м."
end

local function FormatTime(timeLeft)
    if timeLeft < 3600 then -- less than 1 hour
        return math.floor(timeLeft / 60) .. " мин."
    elseif timeLeft < 86400 then -- less than 1 day
        return math.floor(timeLeft / 3600) .. " ч."
    else
        return math.floor(timeLeft / 86400) .. " д."
    end
end

function OpenAuctionHouse()
    if IsValid(auctionFrame) then
        auctionFrame:Remove()
    end
    
    netstream.Start("auk_request_listings")
    netstream.Start("auk_request_my_listings")
    
    auctionFrame = vgui.Create("DFrame")
    auctionFrame:SetTitle("")
    auctionFrame:SetSize(ScrW() * 0.8, ScrH() * 0.8)
    auctionFrame:Center()
    auctionFrame:MakePopup()
    auctionFrame:ShowCloseButton(true)
    auctionFrame.Paint = function(self, w, h)

        draw.RoundedBox(8, 0, 0, w, h, inventoryColors.semiTransparentBlack2)

        draw.RoundedBox(0, 0, 0, w, 50, inventoryColors.semiTransparentBlack2)
        draw.SimpleText("Аукцион", "TL X38", 20, 20, inventoryColors.YellowLight, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        local escapeText = "ESC - Закрыть"
        surface.SetFont("DermaDefault")
        local textW = surface.GetTextSize(escapeText)
        draw.SimpleText(escapeText, "DermaDefault", w - textW - 10, 15, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    

    auctionFrame.OnKeyCodePressed = function(self, key)
        if key == KEY_ESCAPE then
            self:Close()
            gui.HideGameUI()
            return true
        end
    end

    local buttonWidth = 150
    local buttonHeight = 40
    local buttonY = 60
    local tabButtons = {}
    
    local tabs = {
        {name = "browse", text = "Обзор товаров", func = DisplayAuctionListings},
        {name = "sell", text = "Выставить товар", func = DisplaySellInterface},
        {name = "myitems", text = "Мои лоты", func = DisplayMyItemsInterface}
    }
    
    for i, tab in ipairs(tabs) do
        local button = vgui.Create("DButton", auctionFrame)
        button:SetSize(buttonWidth, buttonHeight)
        button:SetPos(20 + (i-1) * (buttonWidth + 10), buttonY)
        button:SetText("")
        button.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, inventoryColors.semiTransparentBlack)
            draw.RoundedBox(0, w - 1, 0, 1, paintLib.HightSource(20), inventoryColors.red)
            draw.RoundedBox(0, w - paintLib.WidthSource(20), 0, paintLib.WidthSource(20), 1, inventoryColors.red)
            draw.RoundedBox(0, 0, h - paintLib.HightSource(20), 1, paintLib.HightSource(20), inventoryColors.red)
            draw.RoundedBox(0, 0, h - 1, paintLib.WidthSource(20), 1, inventoryColors.red)
            draw.SimpleText(tab.text, "TL X18", w / 2, h / 2, inventoryColors.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        end
        button.DoClick = function()
            activeTab = tab.name
            tab.func()
        end
        tabButtons[tab.name] = button
    end
    

    local contentPanel = vgui.Create("DPanel", auctionFrame)
    contentPanel:SetPos(20, buttonY + buttonHeight + 20)
    contentPanel:SetSize(auctionFrame:GetWide() - 40, auctionFrame:GetTall() - (buttonY + buttonHeight + 40))
    contentPanel:SetPaintBackground(false)
    auctionFrame.ContentPanel = contentPanel
    

    DisplayAuctionListings()
end


function DisplayAuctionListings()
    local contentPanel = auctionFrame.ContentPanel
    contentPanel:Clear()
    

    local headerPanel = vgui.Create("DPanel", contentPanel)
    headerPanel:Dock(TOP)
    headerPanel:SetTall(40)
    headerPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, inventoryColors.lightGray)
        

        local columns = {
            {text = "Предмет", x = 10},
            {text = "Продавец", x = 200},
            {text = "Цена", x = 350},
            {text = "Количество", x = 500},
            {text = "Оставшееся время", x = 650}
        }
        
        for _, col in ipairs(columns) do
            draw.SimpleText(col.text, "TL X15", col.x, h/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end

    local listingsScroll = vgui.Create("DScrollPanel", contentPanel)
    listingsScroll:Dock(FILL)
    
    local filterPanel = vgui.Create("DPanel", contentPanel)
    filterPanel:Dock(BOTTOM)
    filterPanel:SetTall(50)
    filterPanel:DockPadding(10, 10, 10, 10)
    filterPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, inventoryColors.semiTransparentBlack)
        draw.RoundedBox(0, w - 1, 0, 1, paintLib.HightSource(20), inventoryColors.red)
        draw.RoundedBox(0, w - paintLib.WidthSource(20), 0, paintLib.WidthSource(20), 1, inventoryColors.red)
        draw.RoundedBox(0, 0, h - paintLib.HightSource(20), 1, paintLib.HightSource(20), inventoryColors.red)
        draw.RoundedBox(0, 0, h - 1, paintLib.WidthSource(20), 1, inventoryColors.red)
    end
    --[[
    local searchEntry = vgui.Create("DTextEntry", filterPanel)
    searchEntry:Dock(LEFT)
    searchEntry:SetWide(200)
    searchEntry:SetPlaceholderText("Поиск предметов...")
    searchEntry.OnChange = function(self)
        local searchText = self:GetValue()
        local filteredListings = FilterListings(currentListings, searchText)
        DisplayFilteredListings(filteredListings, listingsScroll)
    end]]

    local refreshButton = vgui.Create("DButton", filterPanel)
    refreshButton:Dock(RIGHT)
    refreshButton:SetWide(100)
    refreshButton:SetText("")
    refreshButton.DoClick = function()
        netstream.Start("auk_request_listings")
    end
    refreshButton.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, inventoryColors.semiTransparentBlack)
        draw.RoundedBox(0, w - 1, 0, 1, paintLib.HightSource(20), inventoryColors.red)
        draw.RoundedBox(0, w - paintLib.WidthSource(20), 0, paintLib.WidthSource(20), 1, inventoryColors.red)
        draw.RoundedBox(0, 0, h - paintLib.HightSource(20), 1, paintLib.HightSource(20), inventoryColors.red)
        draw.RoundedBox(0, 0, h - 1, paintLib.WidthSource(20), 1, inventoryColors.red)

        draw.SimpleText("Обновить", "TL X15", w / 2, h / 2, inventoryColors.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local listings = currentListings
    if #listings == 0 then listings = {} end
    
    for i, listing in ipairs(listings) do
        listing.item = Item:fromTable(listing.item)
        local itemPanel = vgui.Create("DPanel", listingsScroll)
        itemPanel:Dock(TOP)
        itemPanel:SetTall(60)
        itemPanel:DockMargin(0, 10, 0, 5)
        itemPanel.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, inventoryColors.lightGray)
            draw.SimpleText(listing.item.name, "TL X15", 70, 20, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(listing.seller, "TL X15", 200, 20, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(FormatMoney(listing.price * listing.quantity), "TL X15", 350, 20, Color(255, 215, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(listing.quantity, "TL X15", 500, 20, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(FormatTime(listing.timeLeft), "TL X15", 650, 20, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        end
        
        local iconPanel = vgui.Create("DPanel", itemPanel)
        iconPanel:SetPos(10, 5)
        iconPanel:SetSize(50, 50)
        iconPanel.Paint = function(self, w, h)
            local icon = listing.item.itemSource and itemList[listing.item.itemSource].Icon
            if icon then
                ITEMS_TEX.items[icon](0, 0, w, h)
            else
                draw.RoundedBox(4, 0, 0, w, h, Color(80, 80, 90))
            end
        end

        iconPanel.OnCursorEntered = function()
            showItemInfo(iconPanel, listing.item)
        end
    
        iconPanel.OnCursorExited = function()
            if IsValid(infoPanel) then
                infoPanel:Remove()
            end
        end

        local buyButton = vgui.Create("DButton", itemPanel)
        buyButton:SetPos(contentPanel:GetWide() - 120, 15)
        buyButton:SetSize(100, 30)
        buyButton:SetText("")
        buyButton.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, inventoryColors.semiTransparentBlack)
            draw.RoundedBox(0, w - 1, 0, 1, paintLib.HightSource(20), inventoryColors.red)
            draw.RoundedBox(0, w - paintLib.WidthSource(20), 0, paintLib.WidthSource(20), 1, inventoryColors.red)
            draw.RoundedBox(0, 0, h - paintLib.HightSource(20), 1, paintLib.HightSource(20), inventoryColors.red)
            draw.RoundedBox(0, 0, h - 1, paintLib.WidthSource(20), 1, inventoryColors.red)
    
            draw.SimpleText("Купить", "TL X15", w / 2, h / 2, inventoryColors.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        buyButton.DoClick = function()
            BuyAuctionItem(listing.id, 1)
        end
    end
end

function DisplaySellInterface()
    local contentPanel = auctionFrame.ContentPanel
    contentPanel:Clear()
    
    local inventoryPanel = vgui.Create("DPanel", contentPanel)
    inventoryPanel:SetPos(0, 0)
    inventoryPanel:SetSize(contentPanel:GetWide() * 0.6, contentPanel:GetTall())
    inventoryPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, inventoryColors.lightGray)
        draw.SimpleText("Ваш инвентарь", "TL X28", 20, 20, Color(255, 255, 255), TEXT_ALIGN_LEFT)
    end
    
    local inventoryScroll = vgui.Create("DScrollPanel", inventoryPanel)
    inventoryScroll:SetPos(10, 60)
    inventoryScroll:SetSize(inventoryPanel:GetWide() - 20, inventoryPanel:GetTall() - 70)
    
    local inventory = playerInventory and playerInventory.items or {}
        local itemGrid = vgui.Create("DIconLayout", inventoryScroll)
        itemGrid:Dock(FILL)
        itemGrid:SetSpaceX(5)
        itemGrid:SetSpaceY(5)
        
        for _, item in ipairs(inventory) do
            local itemData = itemList[item.itemSource]
            if itemData then
                local itemPanel = itemGrid:Add("DButton")
                itemPanel:SetText("")
                itemPanel:SetSize(80, 80)
                itemPanel.Paint = function(self, w, h)
                    local bgColor = selectedItem == item and Color(70, 100, 70) or Color(60, 60, 70, 0)
                    draw.RoundedBox(4, 0, 0, w, h, bgColor)
                    draw.RoundedBox(0, 0, 0, w, 1, Color(86, 53, 53, 200))
                    draw.RoundedBox(0, 0, 0, 1, h, Color(86, 53, 53, 200))
                    draw.RoundedBox(0, 0, h - 1, w, 1, Color(86, 53, 53, 200))
                    draw.RoundedBox(0, w - 1, 0, 1, h, Color(86, 53, 53, 200))
                    
                    if itemData.Icon and ITEMS_TEX and ITEMS_TEX.items[itemData.Icon] then
                        ITEMS_TEX.items[itemData.Icon](5, 5, w-10, h-10)
                    end
                    
                    if item.quantity > 1 then
                        draw.SimpleText("x" .. item.quantity, "DermaDefault", w - 10, h - 10, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
                    end
                end
                itemPanel.OnCursorEntered = function()
                    showItemInfo(itemPanel, item)
                end
            
                itemPanel.OnCursorExited = function()
                    if IsValid(infoPanel) then
                        infoPanel:Remove()
                    end
                end
                itemPanel.DoClick = function()
                    selectedItem = item
                    UpdateSellDetails()
                end
            end
        end
    local sellPanel = vgui.Create("DPanel", contentPanel)
    sellPanel:SetPos(contentPanel:GetWide() * 0.6 + 10, 0)
    sellPanel:SetSize(contentPanel:GetWide() * 0.4 - 10, contentPanel:GetTall())
    sellPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, inventoryColors.lightGray)
        draw.SimpleText("Детали продажи", "TL X28", 20, 20, Color(255, 255, 255), TEXT_ALIGN_LEFT)
        
        if not selectedItem then
            draw.SimpleText("Выберите предмет из инвентаря", "TL X28", w/2, h/2, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    auctionFrame.sellPanel = sellPanel
    function UpdateSellDetails()
        if not IsValid(auctionFrame) or not IsValid(auctionFrame.sellPanel) then return end
        
        local sellPanel = auctionFrame.sellPanel
        sellPanel:Clear()
        
        if not selectedItem then return end
        
        local itemData = itemList[selectedItem.itemSource]
        if not itemData then return end
        
        local itemPreview = vgui.Create("DPanel", sellPanel)
        itemPreview:SetPos(20, 60)
        itemPreview:SetSize(80, 80)
        itemPreview.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(60, 60, 70))
            
            if itemData.Icon and ITEMS_TEX and ITEMS_TEX.items[itemData.Icon] then
                ITEMS_TEX.items[itemData.Icon](5, 5, w-10, h-10)
            end
        end
        
        local nameLabel = vgui.Create("DLabel", sellPanel)
        nameLabel:SetPos(110, 70)
        nameLabel:SetText(itemData.Name)
        nameLabel:SetFont("TL X28")
        nameLabel:SizeToContents()
        local quantityLabel = vgui.Create("DLabel", sellPanel)
        quantityLabel:SetPos(20, 160)
        quantityLabel:SetText("Количество:")
        quantityLabel:SetFont("TL X20")
        quantityLabel:SizeToContents()

        local quantitySlider = vgui.Create("DNumSlider", sellPanel)
        quantitySlider:SetPos(20, 180)
        quantitySlider:SetSize(sellPanel:GetWide() - 40, 50)
        quantitySlider:SetMin(1)
        quantitySlider:SetMax(selectedItem.quantity)
        quantitySlider:SetDecimals(0)
        quantitySlider:SetValue(1)
        

        local priceLabel = vgui.Create("DLabel", sellPanel)
        priceLabel:SetPos(20, 230)
        priceLabel:SetText("Цена за единицу:")
        priceLabel:SizeToContents()
        priceLabel:SetFont("TL X20")
        priceLabel:SizeToContents()
        
        local priceEntry = vgui.Create("DNumberWang", sellPanel)
        priceEntry:SetPos(180, 230)
        priceEntry:SetSize(100, 25)
        priceEntry:SetMin(1)
        priceEntry:SetMax(99999)
        priceEntry:SetValue(10)
        

        local durationLabel = vgui.Create("DLabel", sellPanel)
        durationLabel:SetPos(20, 270)
        durationLabel:SetText("Длительность:")
        durationLabel:SizeToContents()
        durationLabel:SetFont("TL X20")
        durationLabel:SizeToContents()

        local durationCombo = vgui.Create("DComboBox", sellPanel)
        durationCombo:SetPos(170, 270)
        durationCombo:SetSize(150, 25)
        
        for _, duration in ipairs(AUCTION_DURATIONS) do
            durationCombo:AddChoice(duration.name, duration.hours)
        end
        durationCombo:ChooseOptionID(1)

        local commissionPanel = vgui.Create("DPanel", sellPanel)
        commissionPanel:SetPos(20, 320)
        commissionPanel:SetSize(sellPanel:GetWide() - 40, 100)
        commissionPanel.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, inventoryColors.semiTransparentBlack)
            
            local price = priceEntry:GetValue()
            local quantity = math.floor(quantitySlider:GetValue())
            local totalPrice = price * quantity
            local commission = math.floor(totalPrice * COMMISSION_RATE)
            
            draw.SimpleText("Итоговая стоимость: " .. FormatMoney(totalPrice), "TL X20", 10, 20, Color(255, 255, 255))
            draw.SimpleText("Комиссия (15%): " .. FormatMoney(commission), "TL X20", 10, 40, Color(255, 215, 0))
            draw.SimpleText("Вы получите: " .. FormatMoney(totalPrice - commission), "TL X20", 10, 60, Color(100, 255, 100))
        end
        
        local listButton = vgui.Create("DButton", sellPanel)
        listButton:SetPos(sellPanel:GetWide()/2 - 100, sellPanel:GetTall() - 60)
        listButton:SetSize(200, 40)
        listButton:SetText("")
        listButton.DoClick = function()
            local price = priceEntry:GetValue()
            local quantity = math.floor(quantitySlider:GetValue())
            local _, durationHours = durationCombo:GetSelected()
            
            local commission = math.floor(price * quantity * COMMISSION_RATE)
            local playerMoney = LocalPlayer():GetCharacterData("money") or 0
            
            if playerMoney < commission then
                Derma_Message("Недостаточно денег для оплаты комиссии!", "Ошибка", "Понятно")
                return
            end
            
            ListItemForSale(selectedItem, price, quantity, durationHours)
            selectedItem = nil
            timer.Simple(0.5, function() DisplaySellInterface() end)
        end
        listButton.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, inventoryColors.semiTransparentBlack)
            draw.RoundedBox(0, w - 1, 0, 1, paintLib.HightSource(20), inventoryColors.red)
            draw.RoundedBox(0, w - paintLib.WidthSource(20), 0, paintLib.WidthSource(20), 1, inventoryColors.red)
            draw.RoundedBox(0, 0, h - paintLib.HightSource(20), 1, paintLib.HightSource(20), inventoryColors.red)
            draw.RoundedBox(0, 0, h - 1, paintLib.WidthSource(20), 1, inventoryColors.red)
            draw.SimpleText("Выставить на аукцион", "TL X18", w / 2, h / 2, inventoryColors.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end


function DisplayMyItemsInterface()
    local contentPanel = auctionFrame.ContentPanel
    contentPanel:Clear()
    

    local propertySheet = vgui.Create("DPropertySheet", contentPanel)
    propertySheet:Dock(FILL)
    propertySheet.Paint = function(self, w, h) end
    

    local activePanel = vgui.Create("DPanel", propertySheet)
    activePanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 60))
    end
    
    local completedPanel = vgui.Create("DPanel", propertySheet)
    completedPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 60))
    end
    
    propertySheet:AddSheet("Активные лоты", activePanel, "icon16/money.png")
    propertySheet:AddSheet("История продаж", completedPanel, "icon16/time.png")
    
    local activeScroll = vgui.Create("DScrollPanel", activePanel)
    activeScroll:Dock(FILL)
    activeScroll:DockMargin(10, 10, 10, 10)
    
    local completedScroll = vgui.Create("DScrollPanel", completedPanel)
    completedScroll:Dock(FILL)
    completedScroll:DockMargin(10, 10, 10, 10)

    local activeListings = myListings.active or {}
    
    for i, listing in ipairs(activeListings) do
        local itemPanel = vgui.Create("DPanel", activeScroll)
        itemPanel:Dock(TOP)
        itemPanel:SetTall(60)
        itemPanel:DockMargin(0, 0, 0, 5)
        itemPanel.Paint = function(self, w, h)
            if !self.canacel then 
                local cancelButton = vgui.Create("DButton", itemPanel)
                cancelButton:SetPos(w - 120, 15)
                cancelButton:SetSize(100, 30)
                cancelButton:SetText("Отменить")
                cancelButton.DoClick = function()
                    Derma_Query(
                        "Вы уверены, что хотите отменить этот лот? Комиссия не будет возвращена.",
                        "Подтверждение",
                        "Да", function() CancelListing(listing.id) end,
                        "Нет", function() end
                    )
                end
                self.canacel = cancelButton
            end
            draw.RoundedBox(4, 0, 0, w, h, Color(60, 60, 70))
            draw.SimpleText(listing.item.name, "DermaDefault", 70, 15, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Цена: " .. FormatMoney(listing.price * listing.quantity), "DermaDefault", 70, 35, Color(255, 215, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Кол-во: " .. listing.quantity, "DermaDefault", 200, 35, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Время: " .. FormatTime(listing.timeLeft), "DermaDefault", 300, 35, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Комиссия: " .. FormatMoney(listing.commission), "DermaDefault", 450, 35, Color(255, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        end
        

        local iconPanel = vgui.Create("DPanel", itemPanel)
        iconPanel:SetPos(10, 5)
        iconPanel:SetSize(50, 50)
        iconPanel.Paint = function(self, w, h)
            local icon = listing.item.itemSource and itemList[listing.item.itemSource].Icon
            if icon then
                ITEMS_TEX.items[icon](0, 0, w, h)
            else
                draw.RoundedBox(4, 0, 0, w, h, Color(80, 80, 90))
            end
        end
        
    end
    local completedListings = myListings.completed or sampleMyListings.completed
    
    for i, listing in ipairs(completedListings) do
        local itemPanel = vgui.Create("DPanel", completedScroll)
        itemPanel:Dock(TOP)
        itemPanel:SetTall(60)
        itemPanel:DockMargin(0, 0, 0, 5)
        itemPanel.Paint = function(self, w, h)
            local bgColor = listing.sold and Color(60, 70, 60) or Color(70, 60, 60)
            draw.RoundedBox(4, 0, 0, w, h, bgColor)
            
            local statusText = listing.sold and "ПРОДАНО" or "НЕ ПРОДАНО"
            local statusColor = listing.sold and Color(100, 255, 100) or Color(255, 100, 100)
            draw.SimpleText(statusText, "DermaDefault", w - 20, 15, statusColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

            draw.SimpleText(listing.item.name, "DermaDefault", 70, 15, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Цена: " .. FormatMoney(listing.price * listing.quantity), "DermaDefault", 70, 35, Color(255, 215, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Кол-во: " .. listing.quantity, "DermaDefault", 200, 35, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Дата: " .. listing.date, "DermaDefault", 300, 35, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        

        local iconPanel = vgui.Create("DPanel", itemPanel)
        iconPanel:SetPos(10, 5)
        iconPanel:SetSize(50, 50)
        iconPanel.Paint = function(self, w, h)
            local icon = listing.item.itemSource and itemList[listing.item.itemSource].Icon
            if icon then
                ITEMS_TEX.items[icon](0, 0, w, h)
            else
                draw.RoundedBox(4, 0, 0, w, h, Color(80, 80, 90))
            end
        end
        
        
        if listing.sold then
            draw.SimpleText("Прибыль: " .. FormatMoney(listing.profit), "DermaDefault", 450, 35, Color(100, 255, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
end

function BuyAuctionItem(id, quantity)
    netstream.Start("auk_buy_item", id, quantity)
end

function ListItemForSale(item, price, quantity, duration)
    netstream.Start("auk_list_item", {
        item = item,
        itemSource = item.itemSource,
        itemId = item.id,
        price = price,
        quantity = quantity,
        duration = duration
    })
end

function CancelListing(id)
    netstream.Start("auk_cancel_listing", id)
end


netstream.Hook("auk_listings", function(data)
    currentListings = data
    if IsValid(auctionFrame) and activeTab == "browse" then
        DisplayAuctionListings()
    end
end)

netstream.Hook("auk_my_listings", function(data)
    myListings = data
    if IsValid(auctionFrame) and activeTab == "myitems" then
        DisplayMyItemsInterface()
    end
end)

netstream.Hook("auk_notification", function(message, msgType)
    local color = Color(255, 255, 255)
    
    if msgType == "success" then
        color = Color(100, 255, 100)
    elseif msgType == "error" then
        color = Color(255, 100, 100)
    elseif msgType == "info" then
        color = Color(100, 200, 255)
    end
    
    chat.AddText(Color(255, 215, 0), "[Аукцион] ", color, message)
    
    if IsValid(auctionFrame) then
        netstream.Start("auk_request_listings")
        netstream.Start("auk_request_my_listings")
    end
end)

netstream.Hook("auk_sold_notification", function(itemName, price)
    local notification = vgui.Create("DNotify")
    notification:SetPos(ScrW() - 300, ScrH() - 100)
    notification:SetSize(250, 80)
    
    local panel = notification:AddItem(vgui.Create("DPanel"))
    panel:SetTall(80)
    panel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 230))
        draw.RoundedBox(4, 0, 0, w, 5, Color(255, 215, 0))
        draw.SimpleText("Аукцион: Продажа", "DermaDefault", 10, 15, Color(255, 215, 0))
        draw.SimpleText("Ваш предмет " .. itemName .. " был продан", "DermaDefault", 10, 35, Color(255, 255, 255))
        draw.SimpleText("Получено: " .. FormatMoney(price), "DermaDefault", 10, 55, Color(100, 255, 100))
    end
    
    notification:SetLife(6)
end)

function SortListings(listings, sortType, isAscending)
    table.sort(listings, function(a, b)
        if sortType == "price" then
            return isAscending and (a.price < b.price) or (a.price > b.price)
        elseif sortType == "time" then
            return isAscending and (a.timeLeft < b.timeLeft) or (a.timeLeft > b.timeLeft)
        elseif sortType == "name" then
            return isAscending and (a.item.name < b.item.name) or (a.item.name > b.item.name)
        else
            return true
        end
    end)
    return listings
end


function FilterListings(listings, searchText)
    if not searchText or searchText == "" then
        return listings
    end
    
    local filtered = {}
    searchText = string.lower(searchText)
    
    for _, listing in ipairs(listings) do
        local name = string.lower(listing.item.name)
        if string.find(name, searchText) then
            table.insert(filtered, listing)
        end
    end
    
    return filtered
end

function CreateItemTooltip(panel, itemData)
    panel.OnCursorEntered = function()
        if not itemData then return end
        
        local tooltip = vgui.Create("DPanel")
        tooltip:SetSize(200, 120)
        tooltip:SetPos(gui.MouseX() + 10, gui.MouseY() + 10)
        tooltip.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 230))
            draw.SimpleText(itemData.name, "DermaDefault", 10, 10, Color(255, 255, 255))

            if itemData.desc then
                local descWrapped = string.Wrap("DermaDefault", itemData.desc, w - 20)
                for i, line in ipairs(descWrapped) do
                    draw.SimpleText(line, "DermaDefault", 10, 30 + (i-1) * 15, Color(200, 200, 200))
                end
            end
        end
        panel.Tooltip = tooltip
    end
    
    panel.OnCursorExited = function()
        if IsValid(panel.Tooltip) then
            panel.Tooltip:Remove()
        end
    end
end

netstream.Hook("auk_commission_return", function(amount)
    local notification = vgui.Create("DNotify")
    notification:SetPos(ScrW() - 300, ScrH() - 100)
    notification:SetSize(250, 80)
    
    local panel = vgui.Create("DPanel") --notification:AddItem(vgui.Create("DPanel"))
    panel:SetTall(80)
    panel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 230))
        draw.RoundedBox(4, 0, 0, w, 5, Color(255, 215, 0))
        draw.SimpleText("Аукцион: Возврат комиссии", "DermaDefault", 10, 15, Color(255, 215, 0))
        draw.SimpleText("Лот был отменен или не продан", "DermaDefault", 10, 35, Color(255, 255, 255))
        draw.SimpleText("Возвращено: " .. FormatMoney(amount), "DermaDefault", 10, 55, Color(100, 255, 100))
    end
    notification:AddItem(panel)
    notification:SetLife(6)
end)
