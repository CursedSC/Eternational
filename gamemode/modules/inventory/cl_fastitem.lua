fastUseBindKey = KEY_H
boundItemData = boundItemData

local function LoadBoundItem()
    boundItemInfo = settings.Get("fast_use_item", nil)
end

local function FindItemInInventory(itemSource)
    if not playerInventory or not playerInventory.items then return nil end
    
    for _, item in ipairs(playerInventory.items) do
        if item.itemSource == itemSource then
            return item
        end
    end

    return nil
end

function SaveBoundItem(item)
    print(item)
    print("SaveBoundItem")
    if item then
        settings.Set("fast_use_item", {
            itemSource = item.itemSource,
            icon = itemList[item.itemSource].Icon
        })
    else
        settings.Set("fast_use_item", nil)
    end
end

local function UseBoundItem()
    if not boundItemData then return end

    local item = FindItemInInventory(boundItemData.itemSource)
    if not item then
        return
    end
    
    local itemData = itemList[item.itemSource]
    if not itemData or not itemData.OnUse then return end
    
    local deleteOnUse = itemData:DeleteOnUse(playerInventory, item)
    if deleteOnUse then
        playerInventory:removeItem(item.x, item.y, 1)
    end
    netstream.Start("fantasy/inventory/useItem", item.x, item.y)
    
    if IsValid(inventoryFrame) then
        BuildGridItems(inventoryGrid)
        BuildItems()
        BuildSlots()
    end
end

hook.Add("PlayerButtonDown", "FastUseItemOnHPress", function(ply, key)
    if key == fastUseBindKey and not IsValid(inventoryFrame) and IsFirstTimePredicted() then
        UseBoundItem()
    end
end)