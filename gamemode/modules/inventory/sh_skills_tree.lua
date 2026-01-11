listAttributeSkill = {}
listAttributeSkill["smithing"] = {}
listAttributeSkill["smithing"]["smithing"] = {
    name = "Кузнечное дело",
    description = "Кузнечное дело - это искусство создания оружия и брони. С помощью этого навыка вы сможете создавать и улучшать оружие и броню.",
    needSkills = {},
    blockedSkills = {},
    y = 1,
}

listAttributeSkill["smithing"]["fire_work"] = {
    name = "Жаркое дело",
    description = "Жаркое дело",
    needSkills = {
        ["smithing"] = "smithing",
    },
    blockedSkills = {},
    y = 2,
}

listAttributeSkill["smithing"]["weapon_creating"] = {
    name = "Создание Оружия",
    description = "Создание Оружия",
    needSkills = {
        ["smithing"] = "fire_work",
    },
    blockedSkills = {
        ["smithing"] = "armor_creating",
    },
    y = 3,
}

listAttributeSkill["smithing"]["armor_creating"] = {
    name = "Создание Брони",
    description = "Создание Брони",
    needSkills = {
        ["smithing"] = "fire_work",
    },
    blockedSkills = {
        ["smithing"] = "weapon_creating",
    },
    y = 3,
}
