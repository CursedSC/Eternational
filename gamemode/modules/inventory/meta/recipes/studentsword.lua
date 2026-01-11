local recipe = {}
recipe.Name = "Меч новичка"
recipe.Icon = 4000
recipe.typeWorld = "quest"
recipe.stackable = false
recipe.weight = 0.5
recipe.craft = "studentsword"
recipe.type = "recipe"

function recipe:GetDescription(arguments)
    return {color_white, self.Description}
end

function recipe:OnUse(inventory, item)
	local ply = inventory.owner
    local quests = questsystem.getQuestsType(ply, "specialization_blacksmith_thirdstage")
	if quests then
		for _, quest in pairs(quests) do
			quest:OnProgress("userecipe", "studentsword", 1, false, nil)
		end
	end

	ply:AddKnowRecipe(recipe.craft)
end


return recipe
