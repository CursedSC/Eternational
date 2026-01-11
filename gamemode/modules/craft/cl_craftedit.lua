
local function CreateCraftRecipeMenu()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("")
    frame:SetSize(800, 600)
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:SetBackgroundBlur(true)
    frame:SetSizable(true)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 40, 230))
        draw.RoundedBox(8, 0, 0, w, 50, Color(30, 30, 30, 255))
        draw.SimpleText("Редактор Рецептов Крафта", "Trebuchet24", w / 2, 15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Left panel for recipe list
    local leftPanel = vgui.Create("DPanel", frame)
    leftPanel:Dock(LEFT)
    leftPanel:SetWidth(250)
    leftPanel:DockPadding(10, 10, 10, 10)
    leftPanel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 255))
    end

    -- Dropdown for selecting craft table type
    local craftTableSelector = vgui.Create("DComboBox", leftPanel)
    craftTableSelector:Dock(TOP)
    craftTableSelector:DockMargin(0, 0, 0, 10)
    craftTableSelector:SetFont("Trebuchet18")
    craftTableSelector:SetValue("Выберите тип верстака")
    craftTableSelector:SetTextColor(Color(255, 255, 255))
    craftTableSelector.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 255))
        self:DrawTextEntryText(Color(255, 255, 255), Color(30, 130, 255), Color(255, 255, 255))
    end

    -- Add default craft table types
    local craftTableTypes = {"workbench", "furnice"}
    for _, tableType in pairs(craftTableTypes) do
        craftTableSelector:AddChoice(tableType)
    end

    -- Allow adding custom craft table types
    local addTableTypePanel = vgui.Create("DPanel", leftPanel)
    addTableTypePanel:Dock(TOP)
    addTableTypePanel:DockMargin(0, 5, 0, 10)
    addTableTypePanel:SetHeight(30)
    addTableTypePanel:SetPaintBackground(false)

    local customTableEntry = vgui.Create("DTextEntry", addTableTypePanel)
    customTableEntry:Dock(LEFT)
    customTableEntry:SetWide(160)
    customTableEntry:SetPlaceholderText("Новый тип верстака")
    customTableEntry:SetFont("Trebuchet18")
    customTableEntry:SetTextColor(Color(255, 255, 255))
    customTableEntry.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 255))
        self:DrawTextEntryText(Color(255, 255, 255), Color(30, 130, 255), Color(255, 255, 255))
    end

    local addTableBtn = vgui.Create("DButton", addTableTypePanel)
    addTableBtn:Dock(RIGHT)
    addTableBtn:SetWide(60)
    addTableBtn:SetText("Добавить")
    addTableBtn.DoClick = function()
        local newType = customTableEntry:GetValue()
        if newType and newType ~= "" then
            craftTableSelector:AddChoice(newType)
            customTableEntry:SetValue("")
            
            -- Initialize table if it doesn't exist
            if not CraftableItems[newType] then
                CraftableItems[newType] = {}
            end
        end
    end

    -- Recipe list
    local recipeScrollPanel = vgui.Create("DScrollPanel", leftPanel)
    recipeScrollPanel:Dock(FILL)
    
    -- Customize scrollbar
    local vbar = recipeScrollPanel:GetVBar()
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

    -- Right panel for recipe details
    local rightPanel = vgui.Create("DPanel", frame)
    rightPanel:Dock(FILL)
    rightPanel:DockPadding(10, 10, 10, 10)
    rightPanel.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 255))
    end

    local detailsScroll = vgui.Create("DScrollPanel", rightPanel)
    detailsScroll:Dock(FILL)
    
    -- Customize scrollbar
    local rightVBar = detailsScroll:GetVBar()
    rightVBar.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50, 255))
    end
    rightVBar.btnUp.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(70, 70, 70, 255))
    end
    rightVBar.btnDown.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(70, 70, 70, 255))
    end
    rightVBar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(100, 100, 100, 255))
    end

    -- Variables to track current editing state
    local currentCraftTable = nil
    local currentRecipe = nil
    local currentRecipeIndex = nil
    local ingredientsList = {}
    
    -- Helper functions for the UI elements
    local function CreateLabel(parent, text)
        local label = vgui.Create("DLabel", parent)
        label:SetText(text)
        label:Dock(TOP)
        label:DockMargin(10, 10, 10, 0)
        label:SetTextColor(Color(255, 255, 255))
        label:SetFont("Trebuchet18")
        return label
    end

    local function CreateTextEntry(parent)
        local entry = vgui.Create("DTextEntry", parent)
        entry:Dock(TOP)
        entry:DockMargin(10, 5, 10, 10)
        entry:SetFont("Trebuchet18")
        entry:SetTextColor(Color(255, 255, 255))
        entry.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 255))
            self:DrawTextEntryText(Color(255, 255, 255), Color(30, 130, 255), Color(255, 255, 255))
        end
        return entry
    end

    local function CreateNumberWang(parent, max)
        local entry = vgui.Create("DNumberWang", parent)
        entry:Dock(TOP)
        entry:DockMargin(10, 5, 10, 10)
        entry:SetMax(max or 99)
        entry:SetMin(1)
        entry:SetValue(1)
        entry:SetFont("Trebuchet18")
        entry:SetTextColor(Color(255, 255, 255))
        entry.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 255))
            self:DrawTextEntryText(Color(255, 255, 255), Color(30, 130, 255), Color(255, 255, 255))
        end
        return entry
    end

    local function CreateComboBox(parent)
        local combo = vgui.Create("DComboBox", parent)
        combo:Dock(TOP)
        combo:DockMargin(10, 5, 10, 10)
        combo:SetFont("Trebuchet18")
        combo:SetTextColor(Color(255, 255, 255))
        combo.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 255))
            self:DrawTextEntryText(Color(255, 255, 255), Color(30, 130, 255), Color(255, 255, 255))
        end
        return combo
    end

    -- Function to display recipe details for editing
    local function DisplayRecipeDetails()
        detailsScroll:Clear()
        ingredientsList = {}
        
        if not currentCraftTable then return end
        
        -- Output item selection
        CreateLabel(detailsScroll, "Создаваемый предмет:")
        local outputItemCombo = CreateComboBox(detailsScroll)
        
        -- Populate with all available items
        for itemName, _ in pairs(itemList) do
            outputItemCombo:AddChoice(itemName)
        end
        
        -- Items count
        CreateLabel(detailsScroll, "Количество создаваемых предметов:")
        local countWang = CreateNumberWang(detailsScroll, 100)
        
        -- Set values if editing an existing recipe
        if currentRecipe then
            outputItemCombo:SetValue(currentRecipe.item)
            countWang:SetValue(currentRecipe.craftedItemsCount or 1)
        end
        
        -- Ingredients section
        CreateLabel(detailsScroll, "Ингредиенты:")
        
        -- Container for ingredients
        local ingredientsContainer = vgui.Create("DPanel", detailsScroll)
        ingredientsContainer:Dock(TOP)
        ingredientsContainer:SetHeight(200)
        ingredientsContainer:DockMargin(10, 5, 10, 10)
        ingredientsContainer.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 50, 255))
        end
        
        -- Scroll panel for ingredients
        local ingredientsScroll = vgui.Create("DScrollPanel", ingredientsContainer)
        ingredientsScroll:Dock(FILL)
        ingredientsScroll:DockMargin(5, 5, 5, 5)
        
        -- Function to add ingredient row
        local function AddIngredientRow(item, quantity)
            local ingredientPanel = vgui.Create("DPanel", ingredientsScroll)
            ingredientPanel:Dock(TOP)
            ingredientPanel:DockMargin(0, 0, 0, 5)
            ingredientPanel:SetHeight(40)
            ingredientPanel.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(60, 60, 70, 255))
            end
            
            local itemCombo = vgui.Create("DComboBox", ingredientPanel)
            itemCombo:SetPos(5, 5)
            itemCombo:SetSize(200, 30)
            itemCombo:SetFont("Trebuchet18")
            itemCombo:SetTextColor(Color(255, 255, 255))
            itemCombo.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 255))
                self:DrawTextEntryText(Color(255, 255, 255), Color(30, 130, 255), Color(255, 255, 255))
            end
            
            for itemName, _ in pairs(itemList) do
                itemCombo:AddChoice(itemName)
            end
            
            if item then
                itemCombo:SetValue(item)
            end
            
            local quantityWang = vgui.Create("DNumberWang", ingredientPanel)
            quantityWang:SetPos(210, 5)
            quantityWang:SetSize(70, 30)
            quantityWang:SetMin(1)
            quantityWang:SetMax(99)
            quantityWang:SetValue(quantity or 1)
            quantityWang:SetFont("Trebuchet18")
            quantityWang:SetTextColor(Color(255, 255, 255))
            quantityWang.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 255))
                self:DrawTextEntryText(Color(255, 255, 255), Color(30, 130, 255), Color(255, 255, 255))
            end
            
            local removeBtn = vgui.Create("DButton", ingredientPanel)
            removeBtn:SetPos(290, 5)
            removeBtn:SetSize(30, 30)
            removeBtn:SetText("X")
            removeBtn:SetTextColor(Color(255, 100, 100))
            removeBtn.DoClick = function()
                table.RemoveByValue(ingredientsList, ingredientPanel)
                ingredientPanel:Remove()
            end
            
            table.insert(ingredientsList, ingredientPanel)
            
            -- Store references to controls for saving
            ingredientPanel.itemCombo = itemCombo
            ingredientPanel.quantityWang = quantityWang
            
            return ingredientPanel
        end
        
        -- Add existing ingredients if editing
        if currentRecipe and currentRecipe.ingredients then
            for _, ing in ipairs(currentRecipe.ingredients) do
                AddIngredientRow(ing.item, ing.quantity)
            end
        end
        
        -- Add ingredient button
        local addIngredientBtn = vgui.Create("DButton", detailsScroll)
        addIngredientBtn:Dock(TOP)
        addIngredientBtn:DockMargin(10, 5, 10, 10)
        addIngredientBtn:SetHeight(30)
        addIngredientBtn:SetText("Добавить ингредиент")
        addIngredientBtn:SetFont("Trebuchet18")
        addIngredientBtn.DoClick = function()
            AddIngredientRow()
        end
        
        -- Save button
        local saveBtn = vgui.Create("DButton", detailsScroll)
        saveBtn:Dock(TOP)
        saveBtn:DockMargin(10, 20, 10, 10)
        saveBtn:SetHeight(40)
        saveBtn:SetText("Сохранить рецепт")
        saveBtn:SetFont("Trebuchet18")
        saveBtn.DoClick = function()
            -- Validate fields
            local outputItem = outputItemCombo:GetValue()
            if not outputItem or outputItem == "" then
                notification.AddLegacy("Выберите предмет для крафта", NOTIFY_ERROR, 3)
                return
            end
            
            -- Collect ingredients
            local ingredients = {}
            for _, panel in ipairs(ingredientsList) do
                local itemName = panel.itemCombo:GetValue()
                local quantity = panel.quantityWang:GetValue()
                
                if itemName and itemName ~= "" then
                    table.insert(ingredients, {
                        item = itemName,
                        quantity = quantity
                    })
                end
            end
            
            if #ingredients == 0 then
                notification.AddLegacy("Добавьте хотя бы один ингредиент", NOTIFY_ERROR, 3)
                return
            end
            
            -- Create recipe data
            local recipe = {
                item = outputItem,
                craftedItemsCount = countWang:GetValue(),
                ingredients = ingredients
            }
            
            -- Save the recipe
            if currentRecipeIndex then
                -- Update existing recipe
                CraftableItems[currentCraftTable][currentRecipeIndex] = recipe
            else
                -- Add new recipe
                table.insert(CraftableItems[currentCraftTable], recipe)
            end
            
            notification.AddLegacy("Рецепт сохранен", NOTIFY_GENERIC, 3)
            
            -- Save to server if needed
            netstream.Start("fantasy/craft/saveRecipes", CraftableItems)
            
            -- Refresh the list
            LoadRecipeList(currentCraftTable)
            
            -- Clear editing state
            currentRecipe = nil
            currentRecipeIndex = nil
            DisplayRecipeDetails()
        end
        
        -- Delete button (only for existing recipes)
        if currentRecipe then
            local deleteBtn = vgui.Create("DButton", detailsScroll)
            deleteBtn:Dock(TOP)
            deleteBtn:DockMargin(10, 5, 10, 10)
            deleteBtn:SetHeight(40)
            deleteBtn:SetText("Удалить рецепт")
            deleteBtn:SetTextColor(Color(255, 100, 100))
            deleteBtn.DoClick = function()
                Derma_Query(
                    "Вы уверены, что хотите удалить этот рецепт?",
                    "Подтверждение удаления",
                    "Да",
                    function()
                        if currentCraftTable and currentRecipeIndex then
                            table.remove(CraftableItems[currentCraftTable], currentRecipeIndex)
                            
                            -- Save to server if needed
                            netstream.Start("fantasy/craft/saveRecipes", CraftableItems)
                            
                            notification.AddLegacy("Рецепт удален", NOTIFY_GENERIC, 3)
                            
                            -- Refresh the list
                            LoadRecipeList(currentCraftTable)
                            
                            -- Clear editing state
                            currentRecipe = nil
                            currentRecipeIndex = nil
                            DisplayRecipeDetails()
                        end
                    end,
                    "Нет"
                )
            end
        end
        
        -- New recipe button
        local newBtn = vgui.Create("DButton", detailsScroll)
        newBtn:Dock(TOP)
        newBtn:DockMargin(10, 5, 10, 10)
        newBtn:SetHeight(40)
        newBtn:SetText("Новый рецепт")
        newBtn.DoClick = function()
            currentRecipe = nil
            currentRecipeIndex = nil
            DisplayRecipeDetails()
        end
    end
    
    -- Function to load recipe list for selected craft table
    function LoadRecipeList(tableType)
        recipeScrollPanel:Clear()
        
        if not tableType or not CraftableItems[tableType] then return end
        
        for i, recipe in ipairs(CraftableItems[tableType]) do
            local recipeBtn = vgui.Create("DButton", recipeScrollPanel)
            recipeBtn:Dock(TOP)
            recipeBtn:DockMargin(0, 0, 0, 5)
            recipeBtn:SetHeight(60)
            recipeBtn:SetText("")
            recipeBtn.Paint = function(self, w, h)
                local bgColor = Color(60, 60, 70)
                
                -- Highlight if this is the currently selected recipe
                if currentRecipeIndex == i and currentCraftTable == tableType then
                    bgColor = Color(80, 70, 100)
                elseif self:IsHovered() then
                    bgColor = Color(70, 70, 80)
                end
                
                draw.RoundedBox(4, 0, 0, w, h, bgColor)
                
                -- Draw item icon
                if itemList[recipe.item] and itemList[recipe.item].Icon and ITEMS_TEX and ITEMS_TEX.items[itemList[recipe.item].Icon] then
                    ITEMS_TEX.items[itemList[recipe.item].Icon](5, 5, 50, 50)
                else
                    draw.RoundedBox(4, 5, 5, 50, 50, Color(100, 100, 100))
                    draw.SimpleText("?", "DermaLarge", 30, 30, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                
                -- Draw item name and count
                local itemName = itemList[recipe.item] and itemList[recipe.item].Name or recipe.item
                draw.SimpleText(itemName, "Trebuchet18", 65, 20, Color(255, 255, 255), TEXT_ALIGN_LEFT)
                
                if recipe.craftedItemsCount > 1 then
                    draw.SimpleText("x" .. recipe.craftedItemsCount, "Trebuchet18", 65, 40, Color(200, 200, 200), TEXT_ALIGN_LEFT)
                end
                
                -- Draw ingredient count
                draw.SimpleText(#recipe.ingredients .. " ингр.", "Trebuchet18", w - 10, h - 10, Color(170, 170, 170), TEXT_ALIGN_RIGHT)
            end
            
            recipeBtn.DoClick = function()
                currentCraftTable = tableType
                currentRecipe = recipe
                currentRecipeIndex = i
                DisplayRecipeDetails()
            end
        end
        
        -- Add new recipe button
        local addBtn = vgui.Create("DButton", recipeScrollPanel)
        addBtn:Dock(TOP)
        addBtn:DockMargin(0, 5, 0, 0)
        addBtn:SetHeight(40)
        addBtn:SetText("+ Добавить новый рецепт")
        addBtn:SetFont("Trebuchet18")
        addBtn.DoClick = function()
            currentCraftTable = tableType
            currentRecipe = nil
            currentRecipeIndex = nil
            DisplayRecipeDetails()
        end
    end
    
    -- Handle craft table selection
    craftTableSelector.OnSelect = function(_, _, value)
        currentCraftTable = value
        currentRecipe = nil
        currentRecipeIndex = nil
        
        -- Initialize table if it doesn't exist
        if not CraftableItems[value] then
            CraftableItems[value] = {}
        end
        
        LoadRecipeList(value)
        DisplayRecipeDetails()
    end
    
    -- Initialize with first table type if available
    if #craftTableTypes > 0 then
        craftTableSelector:ChooseOptionID(1)
    end
end

-- Create netstream hooks for saving
netstream.Hook("fantasy/craft/saveRecipes", function(recipes)
    -- This would be handled by the server
    print("Recipes saved to server")
    -- In a real implementation, this would be saved to a file or database
end)

-- Add command to open the craft editor
concommand.Add("open_craft_edito2r", CreateCraftRecipeMenu)