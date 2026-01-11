local Item = {}
Item.Name = "Рецепт"
Item.Description = ""
Item.Icon = 4000
Item.stackable = false
Item.type = "recipe"
Item.notShow = true
Item.weight = 0.1
function Item:OnUse(inventory, item)
	recipesList[self.recipe]:OnUse(inventory, item)
end

function Item:DeleteOnUse(inventory, item)
    return true
end

function Item:GetDescription(arguments)
    return {color_white, "Рецепт позволяющий изучить ", Color(181, 88, 89), " "..recipesList[self.recipe].Name or "???"}
end


return Item
