inventoryColors = {
    main = Color(11,11,11,240),
    white = Color(255, 255, 255),
    red = Color(181, 88, 89),
    darkGray = Color(42, 42, 42, 255),
    lightGray = Color(125, 119, 92, 255),
    semiTransparentBlack = Color(0, 0, 0, 255 * 0.5),
    semiTransparentBlack2 = Color(0, 0, 0, 255 * 0.8),
    YellowLight = Color(240, 225, 161, 255),
	YellowNotLight = Color(146, 137, 101, 255),
	YellowNotLightLowAlpha = Color(146, 137, 101, 255 * 0.6),
}

namesOfStats = {
    ["speed"] = "Скорость",
    ["strength"] = "Сила",
    ["agility"] = "Ловкость",
    ["intelligence"] = "Интеллект",
    ["vitality"] = "Живучесть",
    ["luck"] = "Удача",
    ["armor"] = "Броня",
}

namesOfClass = {
    [1] = "Маг",
    [2] = "Воин",
    [3] = "Защитник",
    [4] = "Кочевник",
    [5] = "Священник",
}

namesOfTyper = {
    ["weapon"] = "Оружие",
    ["armor"] = "Броня",
    ["accessory"] = "Аксессуар",
    ["skillbook"] = "Книга навыка",
    ["potion"] = "Зелье",
    ["quest"] = "Квестовый предмет",
    ["misc"] = "Ингредиент",
    ["trava"] = "Трава"
}

namesOfClass = {
    [0] = "Отсуствует",
    [1] = "Маг",
    [2] = "Воин",
    [3] = "Защитник",
    [4] = "Кочевник",
    [5] = "Жрец",
}

namesAtributeByValue = {
    [1] = "Сила",
    [2] = "Ловкость",
    [3] = "Интеллект",
    [4] = "Живучесть",
    [5] = "Удача",
}

trueNamesAtributeByValue = {
    [1] = "strength",
    [2] = "agility",
    [3] = "intelligence",
    [4] = "vitality",
    [5] = "luck",
}

namesOfWeapons = {
    ["sword"] = "Меч",
    ["knife"] = "Кинжал",
    ["swordbig"] = "Двуручный меч",
    ["catalisator"] = "Катализатор",
    ["none"] = "Отсуствует",
}

itemsForSharp = {
    "grindstone_tier1",
    "s_grindstone_tier3",
}

sharpBonusId = {
    "playerDamage",
    "npcDamage",
    "armor",
    "speed",
    "distantion",
}
 
sharpBonus = {
    ["playerDamage"] = 10, -- Дополнительный урон по игрокам
    ["npcDamage"] = 10, -- Дополнительный урон по NPC
    ["armor"] = 10, -- Дополнительная броня
    ["speed"] = 10, -- Дополнительная скорость
    ["distantion"] = 10, -- Дополнительная дистанция 
}

namesOfSharpBonus = {
    ["playerDamage"] = "Урон по игрокам",
    ["npcDamage"] = "Урон по NPC",
    ["armor"] = "Броня",
    ["speed"] = "Скорость",
    ["distantion"] = "Дистанция",
}

upgradeChances = {
    [1] = 100,
    [2] = 100,
    [3] = 100,
    [4] = 70,
    [5] = 40,
    [6] = 30,
    [7] = 10,
    [8] = 7,
    [9] = 5,
    [10] = 2
}

lvlOdAddBonus = {
    [4] = true, 
    [8] = true, 
    [10] = true
}

itemsTypeWorld = {
    ["none"] = "Выпадающий предмет",
    ["quest"] = "Квестовый предмет",
    ["personal"] = "Персональный предмет",
    ["protected"] = "Защищенный предмет",
} 

craftSkills = {
    "smithing",
    "alchemy",
}

namesOfCraftSkills = {
    ["smithing"] = "Кузнечное дело",
    ["alchemy"] = "Алхимия",
    ["fire_work"] = "Жаркое Дело",
    ["weapon_creating"] = "Создание Оружия",
    ["armor_creating"] = "Создание Брони",
    ["accessory_creating"] = "Создание Аксессуаров",
    ["starting_potion"] = "Начинающий зельевар",
    ["misc_creating"] = "Создание Ингредиентов",
}

