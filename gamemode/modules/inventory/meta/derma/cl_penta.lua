local PANEL = {}

function PANEL:Init()
    self.Stats = {
        Strength = 1,    -- Value from 0 to 1
        Agility = 0.8,
        Intelligence = 0.6,
        Stamina = 0.9,
        Charisma = 0.7
    }
end

function PANEL:Paint(w, h)
    --draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50, 200))

    local centerX, centerY = w / 2, h / 2
    local radius = math.min(w, h) / 2.5
    local angles = {
        math.rad(-90),        -- Top (Strength)
        math.rad(-18),        -- Right (Agility)
        math.rad(54),         -- Bottom-right (Intelligence)
        math.rad(126),        -- Bottom-left (Stamina)
        math.rad(198)         -- Left (Charisma)
    }

    -- Outline of the pentagon
    surface.SetDrawColor(255, 0, 0, 255)
    local borderPoints = {}
    for i = 1, #angles do
        local x = centerX + math.cos(angles[i]) * (radius + 10)
        local y = centerY + math.sin(angles[i]) * (radius + 10)
        table.insert(borderPoints, {x = x, y = y})
    end
    surface.DrawPoly(borderPoints)

    -- Filled pentagon
    local filled = {}
    local statKeys = { "Strength", "Agility", "Intelligence", "Stamina", "Charisma" }
    for i, key in ipairs(statKeys) do
        local statValue = self.Stats[key]
        table.insert(filled, {
            x = centerX + math.cos(angles[i]) * radius * statValue,
            y = centerY + math.sin(angles[i]) * radius * statValue
        })
    end
    -- Add the first point to the end to close the shape
    table.insert(filled, filled[1])

    surface.SetDrawColor(0, 150, 255, 150)
    surface.DrawPoly(filled)

    -- Draw vertex points
    for _, point in ipairs(filled) do
        draw.RoundedBox(3, point.x - 3, point.y - 3, 6, 6, Color(0, 200, 255))
    end
end

vgui.Register("StatPentagon", PANEL, "Panel")
