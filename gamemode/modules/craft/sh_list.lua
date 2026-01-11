namesOfCraftableItems = {
    ["furnice"] = "Печь",
    ["workbench"] = "Верстак",
}

CraftableItems = {}
CraftableItems["furnice"] = {
    {
        item = "iron_ingot",
        craftedItemsCount = 1,
        needSkills = {
            ["smithing"] = {
                ["smithing"] = 1,
                ["fire_work"] = 1,
            }
        },
        ingredients = {
            { item = "iron_ore", quantity = 4 },
            { item = "coal", quantity = 1 },
        },
    },
}
CraftableItems["workbench"] = {
    {
        item = "handle",
        craftedItemsCount = 1,
        --needSkills = {
        --    ["smithing"] = 1,
        --    ["fire_work"] = 1,
        --},
        ingredients = {
            { item = "stick", quantity = 1 },
            { item = "fiber", quantity = 4 },
        },
    },
	{
        item = "student_sword",
        craftedItemsCount = 1,
        ingredients = {
			{ item = "handle", quantity = 1 },
            { item = "iron_ingot", quantity = 2 },
        },
		needrecipe = "studentsword",
    },
	{
        item = "student_potion",
        craftedItemsCount = 1,
        ingredients = {
			{ item = "jeltic", quantity = 1 },
            { item = "folencia", quantity = 1 },
			{ item = "sarphan", quantity = 1 },
            { item = "dryaha", quantity = 1 },
        },
		needrecipe = "studentpotion",
    },
    {
        item = "knife",
        craftedItemsCount = 1,
        needSkills = {
            ["smithing"] = {
                ["smithing"] = 2,
                ["weapon_creating"] = 1,
            }
        },
        ingredients = {
            { item = "handle", quantity = 1 },
            { item = "iron_ingot", quantity = 1 },
        },
    },
    {
        item = "sword",
        craftedItemsCount = 1,
        needSkills = {
            ["smithing"] = {
                ["smithing"] = 2,
                ["weapon_creating"] = 1,
            }
        },
        ingredients = {
            { item = "handle", quantity = 1 },
            { item = "iron_ingot", quantity = 2 },
        },
    },
    {
        item = "twohandlesword",
        craftedItemsCount = 1,
        needSkills = {
            ["smithing"] = {
                ["smithing"] = 2,
                ["weapon_creating"] = 1,
            }
        },
        ingredients = {
            { item = "handle", quantity = 1 },
            { item = "iron_ingot", quantity = 4 },
        },
    },
    {
        item = "heal_potion",
        craftedItemsCount = 1,
        needSkills = {
            ["alchemy"] = {
                ["alchemy"] = 1,
                ["starting_potion"] = 1,
            }
        },
        ingredients = {
            { item = "jeltic", quantity = 2 },
            { item = "folencia", quantity = 2 },
        },
    },
    {
        item = "mana_potion",
        craftedItemsCount = 1,
        needSkills = {
            ["alchemy"] = {
                ["alchemy"] = 1,
                ["starting_potion"] = 1,
            }
        },
        ingredients = {
            { item = "sarphan", quantity = 2 },
            { item = "dryaha", quantity = 2 },
        },
    },
    {
        item = "dangeon_ruin",
        craftedItemsCount = 1,
        ingredients = {
            { item = "temple_dangeon_ruin", quantity = 1 },
            { item = "fragmet_story", quantity = 10 },
        },
    },
}
