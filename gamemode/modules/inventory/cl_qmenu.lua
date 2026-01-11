function refreshItemsQmenu()
    if !IsValid(qmenuItemPanel) then return end
    qmenuItemPanel.itemScrollPanel:Clear() 
    local sortedItems = {}
    for itemName, itemData in pairs(itemList) do
        if itemData.notShow then continue end
        itemData.type = itemData.type or "misc"
        table.insert(sortedItems, {name = itemName, data = itemData})
    end 
    table.sort(sortedItems, function(a, b) return a.data.type < b.data.type end)
    for _, item in ipairs(sortedItems) do
        local itemButton = vgui.Create("DButton", qmenuItemPanel.itemScrollPanel)
        itemButton:SetText("")
        itemButton:Dock(TOP)
        itemButton:DockMargin(0, 0, 0, 5)
        itemButton:SetHeight(64)
        itemButton.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50, 255))
            if item.data.Icon then
                ITEMS_TEX.items[item.data.Icon](5, 5, 54, 54)
            end
            draw.SimpleText(item.data.Name, "Trebuchet18", 70, h / 2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        itemButton.DoClick = function()
            RunConsoleCommand("add_item", item.name)
        end
        itemButton.DoRightClick = function()
            local menu = DermaMenu()
            menu:AddOption("Copy name", function() SetClipboardText(item.name) end)
            menu:Open()
        end
    end
end

function CreateAdminItemMenu()
    local frame = vgui.Create("DPanel")
    qmenuItemPanel = frame
    frame:Dock(FILL)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 40, 230))
        draw.RoundedBox(8, 0, 0, w, 50, Color(30, 30, 30, 255))
    end

    local itemScrollPanel = vgui.Create("DScrollPanel", frame)
    itemScrollPanel:Dock(FILL)
    frame.itemScrollPanel = itemScrollPanel
    local vbar = itemScrollPanel:GetVBar()
    vbar.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50, 255))
    end
    vbar.btnUp.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(70, 70, 70, 255))
    end
    vbar.btnDown.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(70, 70, 70, 255))
    end
    vbar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(100, 100, 100, 255))
    end
    refreshItemsQmenu()
    return frame
end

spawnmenu.AddCreationTab("Admin Item Menu", CreateAdminItemMenu, "icon16/box.png", 0)