local skillLoaded = false
local itemsLoaded = false

local weoTypesIcons = {
    ["sword"] = 1119,
    ["axe"] = 1120,
    ["bow"] = 1121,
    ["catalisator"] = 1278,
    ["staff"] = 1123,
    ["knife"] = 1087,
    ["none"] = 1125,
    ["swordbig"] = 1055,
}

local function init()
    local baseItem = itemList["skillbook"]
    for k, v in pairs(skillList) do
        local item = table.Copy(baseItem)
        item.Name = "Книга навыка: "..v.Name
        item.Icon = weoTypesIcons[v.WeaponType] or 1119
        item.skill = k
        item.notShow = false
        item.stackable = false
        item.Type = "skillbook"
        item.idname = k
        itemList[k] = item

        print("Created skillbook: " .. k)
    end

	local baseItem = itemList["recipe"]
    for k, v in pairs(recipesList) do
        local item = table.Copy(baseItem)
        item.Name = "Рецепт: "..v.Name
        item.Icon = v.Icon or 1119
        item.recipe = k
		item.typeWorld = v.typeWorld or "none"
		item.Description = v.Description
        item.notShow = false
        item.stackable = false
        item.Type = "recipe"
        item.idname = k
        itemList[k] = item

        print("Created recipe: " .. k)
    end
    if CLIENT then refreshItemsQmenu() end
end


function checkParams()
    if skillLoaded and itemsLoaded then
        init()
    end
end

init()
hook.Add("OnGamemodeLoaded", "fantasy/init/skillbooks", function()
    init()
end)
