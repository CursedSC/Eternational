local Item = {}
Item.Name = "Дерево"
Item.Description = "Обычное дерево."
Item.Icon = 1012
Item.stackable = true
Item.weight = 0.1
function Item:GetDescription(arguments)
    return {color_white, self.Description}
end


return Item 