netstream.Hook("fantasy/craft/create", function(ply, type, id)
    local recipe = CraftableItems[type][id]
    if not recipe then return end
    local playerInventory = ply.inventory
    local canCraft = true
    for _, ingredient in ipairs(recipe.ingredients) do
        print("recipe.ingredients", ingredient.quantity)
        print(playerInventory:hasItems(ingredient.item, ingredient.quantity))
        if not playerInventory:hasItems(ingredient.item, ingredient.quantity) then
            canCraft = false
            break
        end
    end
    local skills = ply:GetAttributesSkills()
    if canCraft and recipe.needSkills then
        for skillCtagory, skillTable in pairs(recipe.needSkills) do
            skills[skillCtagory] = skills[skillCtagory] or {}
            for skillName, skillLevel in pairs(skillTable) do
                local playerSkill = skills[skillCtagory][skillName] or 0
                if playerSkill < skillLevel then
                    canCraft = false
                    break
                end
            end
        end
    end

    if canCraft then
        for _, ingredient in ipairs(recipe.ingredients) do
            print(ingredient.item, ingredient.quantity)
            playerInventory:removeItemsBySource(ingredient.item, ingredient.quantity)
        end
		PrintTable(recipe)
		if recipe.needrecipe then ply:RemoveKnowRecipe(recipe.needrecipe) end
        playerInventory:addItem(recipe.item, recipe.craftedItemsCount)
    end
end)
