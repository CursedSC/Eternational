storageInventory = Inventory:new(ply, 63)

function BuildInventoryInformationStorage()
    inventorySubPanel.listSlots = {}
    inventoryStorageGrid = vgui.Create( "DIconLayout", inventorySubPanel )
	inventoryStorageGrid:SetPos(paintLib.WidthSource(1920 - (56 + 650)), paintLib.HightSource(169))
	inventoryStorageGrid:SetSize(paintLib.WidthSource(650), paintLib.HightSource(820))
	inventoryStorageGrid:SetSpaceY( paintLib.HightSource(0) )
	inventoryStorageGrid:SetSpaceX( paintLib.WidthSource(0) )
    inventoryStorageGrid.OnRemove = function()
        netstream.Start("fantasy/storage/close")
    end

    slotsStorage = {}
    BuildGridItemsStorage(inventoryStorageGrid)
    BuildItemsStorage()
end

function BuildItemPanelStorage(item, parent)
    local slot = vgui.Create("DPanel", parent)
    slot:Droppable("InventorySlot")
    slot.FromStorage = true
    slot:SetSize(paintLib.WidthSource(100), paintLib.HightSource(100))
    slot.item = item
    slot.ItemData = itemList[item.itemSource]
    slot.Paint = function(self, w, h)
        if self.item then
            ITEMS_TEX.items[self.ItemData.Icon](3,3,w - 6,h - 6)
        end
    end
    slot.oldOnMousePressed = slot.OnMousePressed
    slot.OnMousePressed = function(self, mouseCode)
        self.oldOnMousePressed(self, mouseCode)
    end

    local quantityLabel = vgui.Create("DLabel", slot)
    quantityLabel:SetText((slot.item.quantity == 1) and "" or "x"..slot.item.quantity)
    quantityLabel:SetFont("TLP X10")
    quantityLabel:SetColor(Color(255, 255, 255))
    quantityLabel:SizeToContents()
    quantityLabel:SetPos(5, paintLib.HightSource(75))
    parent.item = item

    slot.OnCursorEntered = function()
        showItemInfo(slot, slot.item)
    end

    slot.OnCursorExited = function()
        if IsValid(infoPanel) then
            infoPanel:Remove()
        end
    end
end

function BuildGridItemsStorage(grid)
    local items = grid:GetChildren()
    for k, i in pairs(items) do i:Remove() end
    local counterX = 1
    local counterY = 1
    for i = 1, storageInventory.maxCapacity do
        local slot = grid:Add("DPanel")
        slot:SetSize(paintLib.WidthSource(92), paintLib.HightSource(92))
        slot:SetBackgroundColor(Color(50, 50, 50, 255))
        slot.Position = {
            x = counterX,
            y = counterY
        }
        slot.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, 1, Color(86, 53, 53, 200))
            draw.RoundedBox(0, 0, 0, 1, h, Color(86, 53, 53, 200))
            draw.RoundedBox(0, 0, h - 1, w, 1, Color(86, 53, 53, 200))
            draw.RoundedBox(0, w - 1, 0, 1, h, Color(86, 53, 53, 200))
        end
        slot:Receiver("InventorySlot", function(receiver, panels, dropped)
            if dropped then
                local draggedPanel = panels[1]
                if receiver == draggedPanel:GetParent() then return end
                local fromStorage = (draggedPanel.FromStorage)

                if fromStorage then
                    local bSucc, str = storageInventory:transferItem(draggedPanel.item.x, draggedPanel.item.y, receiver.Position.x, receiver.Position.y)
                    print(bSucc, str)
                    if bSucc then draggedPanel:SetParent(receiver) BuildGridItemsStorage(grid) BuildItemsStorage() end
                else
                    Derma_NumRequest(
                        "Количество",
                        "Выберите число предмета:",
                        1,
                        1,
                        draggedPanel.item.quantity,
                        0,
                        function(value)
                            local bSucc, str = playerInventory:transferToInventory(storageInventory, draggedPanel.item.x, draggedPanel.item.y, receiver.Position.x, receiver.Position.y, value)
                            if bSucc then draggedPanel:SetParent(receiver) BuildGridItemsStorage(grid) BuildItemsStorage() BuildGridItems(inventoryGrid) BuildItems() end
                        end,
                        function()
                            print("User canceled the request.")
                        end
                    )
                end
            end
        end)
        local slotId = slot.Position.x.."_"..slot.Position.y
        slotsStorage[slotId] = slot

        counterX = counterX + 1
        if counterX > 7 then counterX = 1 counterY = counterY + 1 end
    end
end

function BuildItemsStorage()
    for _, item in ipairs(storageInventory.items) do
        local slotIndex = item.x.."_"..item.y
        BuildItemPanelStorage(item, slotsStorage[slotIndex])
    end
end

netstream.Hook("fantasy/storage/sync", function(data)
    print(data)
    storageInventory = Inventory:fromTable(data)
    BuildGridItemsStorage(inventoryStorageGrid) BuildItemsStorage()
end)

netstream.Hook("fantasy/storage/open", function(data)
    storageInventory = Inventory:fromTable(data)
    createInventoryFrame(true)
    inventorySubPanel:Clear()
    currentDrawFunc = nil
    BuildInventoryInformationStorage()
    BuildInventoryInformation(true)
end)
