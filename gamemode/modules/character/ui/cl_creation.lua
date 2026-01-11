creation = creation or {}

local function overridedrawmodel(self)
    local curparent = self
	local leftx, topy = self:LocalToScreen( 0, 0 )
	local rightx, bottomy = self:LocalToScreen( self:GetWide(), self:GetTall() )
	while ( curparent:GetParent() != nil ) do
		curparent = curparent:GetParent()

		local x1, y1 = curparent:LocalToScreen( 0, 0 )
		local x2, y2 = curparent:LocalToScreen( curparent:GetWide(), curparent:GetTall() )

		leftx = math.max( leftx, x1 )
		topy = math.max( topy, y1 )
		rightx = math.min( rightx, x2 )
		bottomy = math.min( bottomy, y2 )
		previous = curparent
	end

	render.ClearDepth( false )

	render.SetScissorRect( leftx, topy, rightx, bottomy, true )

	local ret = self:PreDrawModel( self.Entity )
	if ( ret != false ) then
		self.Entity:DrawModel()
        self.Base:DrawModel()
		self:PostDrawModel( self.Entity )
	end

	render.SetScissorRect( 0, 0, 0, 0, false )
end

local function override(self, w, h )

	if ( !IsValid( self.Entity ) ) then return end

	local x, y = self:LocalToScreen( 0, 0 )

	self:LayoutEntity( self.Entity )

	local ang = self.aLookAngle
	if ( !ang ) then
		ang = ( self.vLookatPos - self.vCamPos ):Angle()
	end

	cam.Start3D( self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ )

	render.SuppressEngineLighting( true )
	render.SetLightingOrigin( self.Entity:GetPos() )
	render.ResetModelLighting( self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255 )
	render.SetColorModulation( self.colColor.r / 255, self.colColor.g / 255, self.colColor.b / 255 )
	render.SetBlend( ( self:GetAlpha() / 255 ) * ( self.colColor.a / 255 ) ) -- * surface.GetAlphaMultiplier()

	for i = 0, 4 do
		local col = self.DirectionalLight[ i ]
		if ( col ) then
			render.SetModelLighting( i, col.r / 255, col.g / 255, col.b / 255 )
		end
	end

	self:DrawModel()

	render.SuppressEngineLighting( false )
	cam.End3D()

	self.LastPaint = RealTime()

end

local posit = Vector(20, -13, 70)
local posit2 = Vector(-10, -15, 70)
local posit3 = Vector(5, 20, 70)

local lights = {
    {
        type = 1,
        color = Vector(200, 200, 200),
        pos = posit,
        dir = Vector(0, 0, 0),
        range = 1,
        angularFalloff = 5,
        innerAngle = 45,
        outerAngle = 45,
        fiftyPercentDistance = 2,
        zeroPercentDistance = 20,
        quadraticFalloff = 0,
        linearFalloff = 1,
        constantFalloff = 0
    },
    {
        type = 1,
        color = Vector(30, 144, 255),
        pos = posit2,
        dir = Vector(0, 0, 0),
        range = 1,
        angularFalloff = 5,
        innerAngle = 85,
        outerAngle = 45,
        fiftyPercentDistance = 1,
        zeroPercentDistance = 15,
        quadraticFalloff = 0,
        linearFalloff = 1,
        constantFalloff = 0
    },
    {
        type = 1,
        color = Vector(255, 191, 30) * 0.15,
        pos = posit3,
        dir = Vector(0, 0, 0),
        range = 1,
        angularFalloff = 5,
        innerAngle = 75,
        outerAngle = 45,
        fiftyPercentDistance = 5,
        zeroPercentDistance = 15,
        quadraticFalloff = 0,
        linearFalloff = 1,
        constantFalloff = 0
    }
}

local editHairVector = Vector(50, 0, 68)
local editBaseVector = Vector(210, 0, 45)

function doModelPanel(self)
    local ply = LocalPlayer()
    local _model = listRace[currentRace].models[currentGender]
    CurrentVactor = editBaseVector
    newCurrentVactor = editBaseVector

    if IsValid(randerModel) then randerModel:Remove() end
    randerModel = ClientsideModel(_model, RENDERGROUP_OTHER)
    randerModel:ResetSequence(randerModel:LookupSequence("menu_combine"))

    local charline6 = vgui.Create("EditablePanel", self)
    charline6:SetSize(ScrW(), ScrH())
    charline6:SetPos(0, 0)
    charline6:SetMouseInputEnabled(false)
    charline6.Paint = function(self, w, h)
        CurrentVactor = Lerp(FrameTime() * 10, CurrentVactor, newCurrentVactor)
        local model = {model = randerModel:GetModel(), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0)}

        cam.Start3D(CurrentVactor, Angle(0, 180, 0), 49, 0, 0, ScrW(), ScrH(), 5, 4096)
        render.SuppressEngineLighting(true)
        render.SetModelLighting(0, 0.05, 0.05, 0.05)
        render.SetModelLighting(1, 0, 0, 0)
        render.SetModelLighting(2, 0.1, 0.1, 0.2)
        render.SetModelLighting(3, 0, 0, 0)
        render.SetModelLighting(4, 0.1, 0.1, 0.1)
        render.SetModelLighting(5, 0, 0, 0)
        render.SetLocalModelLights(lights)
        render.Model(model, randerModel)
        randerModel:FrameAdvance()
        render.SuppressEngineLighting(false)
        cam.End3D()
    end
end
local materials = {
    bg = Material("materials/fantasy/bg.png"),
}
local function createPickerButton(min, max, callback, getText)
    local buttonPanel = vgui.Create("EditablePanel", creation.mainFrame)
    buttonPanel:SetSize(paintLib.WidthSource(500), paintLib.HightSource(50))
    buttonPanel:SetPos(paintLib.WidthSource(1300), paintLib.HightSource(200))
    buttonPanel.CurrentInt = min

    buttonPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, inventoryColors.semiTransparentBlack)
        draw.SimpleText(getText(self.CurrentInt), "TL X28", w / 2, h / 2, inventoryColors.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local function createNavButton(parent, x, text, onClick)
        local navButton = vgui.Create("DButton", parent)
        navButton:SetText("")
        navButton:SetSize(paintLib.WidthSource(50), paintLib.HightSource(50))
        navButton:SetPos(x, 0)
        navButton.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, inventoryColors.semiTransparentBlack)
            draw.SimpleText(text, "TL X28", w / 2, h / 2, inventoryColors.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        navButton.DoClick = onClick
    end

    createNavButton(buttonPanel, paintLib.WidthSource(450), ">", function()
        buttonPanel.CurrentInt = buttonPanel.CurrentInt + 1
        if buttonPanel.CurrentInt > max then buttonPanel.CurrentInt = min end
        callback(buttonPanel.CurrentInt)
    end)

    createNavButton(buttonPanel, 0, "<", function()
        buttonPanel.CurrentInt = buttonPanel.CurrentInt - 1
        if buttonPanel.CurrentInt < min then buttonPanel.CurrentInt = max end
        callback(buttonPanel.CurrentInt)
    end)

    return buttonPanel
end

local function pickmebutton(min, max, callback)
    return createPickerButton(min, max, callback, function(int) return "Вариант #" .. int end)
end

local function pickmebutton2(min, max, callback)
    return createPickerButton(min, max, callback, function(int) return HairColors[int][1] end)
end

local function pickmebutton3(min, max, callback)
    return createPickerButton(min, max, callback, function(int) return listRace[int].name end)
end
HairColors = {
    -- Натуральные цвета
    {"Чёрный", Color(30, 20, 10)},
    {"Тёмно-коричневый", Color(60, 40, 20)},
    {"Каштановый", Color(90, 60, 30)},
    {"Светло-коричневый", Color(140, 100, 50)},
    {"Русый", Color(180, 140, 90)},
    {"Блонд", Color(220, 180, 130)},
    {"Платиновый блонд", Color(255, 230, 170)},
    {"Белоснежный", Color(255, 255, 255)},

    -- Фэнтези и магические цвета
    {"Пылающий красный", Color(200, 0, 0)},
    {"Малиновый", Color(255, 90, 90)},
    {"Тёмно-фиолетовый", Color(120, 0, 200)},
    {"Лазурный", Color(0, 150, 255)},
    {"Мятный", Color(0, 255, 150)},
    {"Изумрудный", Color(0, 200, 0)},
    {"Золотой", Color(255, 200, 0)},
    {"Огненно-оранжевый", Color(255, 100, 0)},

    -- Редкие оттенки
    {"Угольный серый", Color(50, 50, 50)},
    {"Серебристый", Color(150, 150, 150)},
    {"Розовый неон", Color(166, 35, 131)},
    //{"Ледяной бирюзовый", Color(50, 255, 200)},
    //{"Ядовито-зелёный", Color(100, 255, 50)},
    {"Карминовый", Color(255, 0, 100)},
    {"Тёмная кровь", Color(90, 0, 0)}
}

local function DrawStatPentagon(x, y, size, attributes)
    local points = {}
    local angle = 360 / 5
    local rotation = -18

    local borderPoints = {}
    for i = 1, 5 do
        local rad = math.rad(i * angle + rotation)
        local pointX = x + math.cos(rad) * (size + 10)
        local pointY = y + math.sin(rad) * (size + 10)
        table.insert(borderPoints, {x = pointX, y = pointY})
    end

    surface.SetDrawColor(77, 0, 0)
    draw.NoTexture()
    surface.DrawPoly(borderPoints)

    for i = 1, 5 do
        local rad = math.rad(i * angle + rotation)
        local attributeValue = attributes[i] or 1
        local pointX = x + math.cos(rad) * (size - 1) * attributeValue
        local pointY = y + math.sin(rad) * (size - 1) * attributeValue
        table.insert(points, {x = pointX, y = pointY})
    end

    surface.SetDrawColor(32, 32, 32, 206)
    draw.NoTexture()
    surface.DrawPoly(points)
end

local function DrawStatPentagon2(x, y, size, attributes)
    local points = {}
    local angle = 360 / 5
    local rotation = -18

    for i = 1, 5 do
        local rad = math.rad(i * angle + rotation)
        local attributeValue = attributes[i] or 1
        local pointX = x + math.cos(rad) * size * attributeValue
        local pointY = y + math.sin(rad) * size * attributeValue

        table.insert(points, {x = pointX, y = pointY})
    end

    surface.SetDrawColor(165, 38, 38)
    draw.NoTexture()
    surface.DrawPoly(points)

    for i = 1, 5 do
        local rad = math.rad(i * angle + rotation)
        local attributeValue = attributes[i] or 1
        local pointX = x + math.cos(rad) * size * attributeValue
        local pointY = y + math.sin(rad) * size * attributeValue

        local pointX2 = x + math.cos(rad) * size
        local pointY2 = y + math.sin(rad) * size
        draw.RoundedBox(0, pointX - 2, pointY - 2, 4, 4, color_white)
        local str = namesAtributeByValue[i].." "..(20 * attributeValue)
        draw.SimpleText(str, "TL X12", pointX2, pointY2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

--f_break_dance_v2
function creation:Build()
    if IsValid(self.mainFrame) then self.mainFrame:Close() end
    currentRace = RACE_HUMAN
    currentGender = "Мужчина"

    local w, h = ScrW(), ScrH()
    local ply = LocalPlayer()
    local _model = ply:GetModel()
    self.mainFrame = vgui.Create("DFrame")
    self.mainFrame:SetTitle("")
    self.mainFrame:SetSize(w, h)
    self.mainFrame:Center()
    self.mainFrame:MakePopup()
    self.mainFrame:SetDraggable(false)
    self.mainFrame:ShowCloseButton(false)

    self.mainFrame.Paint = function(self, w, h)
        paintLib.DrawRect(materials.bg, 0, 0, w, h, inventoryColors.white)

        local texts = {
            {"Одежда", 1300, 210},
            {"Оттенок одежды", 1300, 315},
            {"Волосы", 1300, 420},
            {"Цвет волос", 1300, 530},
            {"Описание Внешнего Вида", 1300, 630},
            {"Имя Персонажа", 100, 200},
            --{"Создание Персонажа", w / 2, 70}
        }

        for _, text in ipairs(texts) do
            draw.SimpleText(text[1], "TL X28", paintLib.WidthSource(text[2]), paintLib.HightSource(text[3]), inventoryColors.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        draw.RoundedBox(0, paintLib.WidthSource(100), paintLib.HightSource(220), paintLib.WidthSource(500), paintLib.HightSource(50), inventoryColors.semiTransparentBlack)

        local centerX = paintLib.WidthSource(340)
        local centerY = paintLib.WidthSource(675)
        local radius = paintLib.WidthSource(120)

        local attributes = {
            listRace[currentRace].attributes["strength"] / 20,
            listRace[currentRace].attributes["agility"] / 20,
            listRace[currentRace].attributes["intelligence"] / 20,
            listRace[currentRace].attributes["vitality"] / 20,
            listRace[currentRace].attributes["luck"] / 20
        }

        DrawStatPentagon(centerX, centerY, radius, {})
        DrawStatPentagon2(centerX, centerY, radius, attributes)
    end

    local function createDanceButton(xOffset, sequence, label)
        local button = vgui.Create("DButton", self.mainFrame)
        button:SetPos(paintLib.WidthSource(110 + xOffset), paintLib.HightSource(199))
        button:SetSize(paintLib.WidthSource(20), paintLib.HightSource(20))
        button:SetText("")
        button.DoClick = function()
            local seq, dur = randerModel:LookupSequence(sequence)
            randerModel:ResetSequence(seq)
            timer.Create("resertimer", dur - 1, 1, function()
                if IsValid(randerModel) then
                    local seq, dur = randerModel:LookupSequence("menu_combine")
                    randerModel:ResetSequence(seq)
                end
            end)
        end
        button.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, inventoryColors.semiTransparentBlack)
            draw.SimpleText(label, "TL X10", w / 2, h / 2, inventoryColors.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    createDanceButton(426, "f_break_dance_v2", "1")
    createDanceButton(448, "f_breakboy", "2")
    createDanceButton(470, "f_cowboydance", "3")

    playerName = vgui.Create("DTextEntry", self.mainFrame)
    playerName:SetPos(paintLib.WidthSource(110), paintLib.HightSource(220))
    playerName:SetSize(paintLib.WidthSource(480), paintLib.HightSource(50))
    playerName:SetPaintBackground(false)
    playerName:SetTextColor(color_white)
    playerName:SetFont("TL X28")

    local function createGenderButton(xPos, gender, label)
        local button = vgui.Create("DButton", self.mainFrame)
        button:SetText("")
        button:SetSize(paintLib.WidthSource(240), paintLib.HightSource(50))
        button:SetPos(paintLib.WidthSource(xPos), paintLib.HightSource(280))
        button.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, inventoryColors.semiTransparentBlack)
            draw.RoundedBox(0, w - 1, 0, 1, paintLib.HightSource(20), inventoryColors.red)
            draw.RoundedBox(0, w - paintLib.WidthSource(20), 0, paintLib.WidthSource(20), 1, inventoryColors.red)
            draw.RoundedBox(0, 0, h - paintLib.HightSource(20), 1, paintLib.HightSource(20), inventoryColors.red)
            draw.RoundedBox(0, 0, h - 1, paintLib.WidthSource(20), 1, inventoryColors.red)
            draw.SimpleText(label, "TL X28", w / 2, h / 2, inventoryColors.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        button.DoClick = function()
            currentGender = gender
            randerModel:SetModel(listRace[currentRace].models[currentGender])
            local seq = randerModel:LookupSequence("menu_combine")
            randerModel:ResetSequence(seq)
        end
    end

    createGenderButton(100, "Мужчина", "Мужчина")
    createGenderButton(360, "Женщина", "Женщина")

    local raceToPick = {}
    for k, i in pairs(listRace) do
        table.insert(raceToPick, k)
    end

    local race = pickmebutton3(1, #raceToPick, function(int)
        currentRace = raceToPick[int]
        randerModel:SetModel(listRace[currentRace].models[currentGender])
        local seq = randerModel:LookupSequence("menu_combine")
        randerModel:ResetSequence(seq)
    end)
    race:SetPos(paintLib.WidthSource(100), paintLib.HightSource(380))

    doModelPanel(self.mainFrame)
    local descriptionPanel = vgui.Create("EditablePanel", self.mainFrame)
    descriptionPanel:SetPos(paintLib.WidthSource(1300), paintLib.HightSource(650))
    descriptionPanel:SetSize(paintLib.WidthSource(500), paintLib.HightSource(300))
    descriptionPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, inventoryColors.semiTransparentBlack)
    end

    playerDescription = vgui.Create("DTextEntry", self.mainFrame)
    playerDescription:SetPos(paintLib.WidthSource(1300), paintLib.HightSource(650))
    playerDescription:SetSize(paintLib.WidthSource(500), paintLib.HightSource(300))
    playerDescription:SetMultiline(true)
    playerDescription:SetPaintBackground(false)
    playerDescription:SetTextColor(color_white)
    playerDescription:SetFont("TL X22")
    playerDescription:SetPlaceholderText("Вводить описание персонажа не обязательно")

    local cloth = pickmebutton(1, 3, function(int)
        randerModel:SetBodygroup(1, int - 1)
        newCurrentVactor = editBaseVector
    end)
    cloth:SetPos(paintLib.WidthSource(1300), paintLib.HightSource(230))

    local clothSkin = pickmebutton(1, 5, function(int)
        randerModel:SetSkin(int - 1)
        newCurrentVactor = editBaseVector
    end)
    clothSkin:SetPos(paintLib.WidthSource(1300), paintLib.HightSource(335))

    local hair = pickmebutton(1, 7, function(int)
        randerModel:SetBodygroup(3, int - 1)
        newCurrentVactor = editHairVector
    end)
    hair:SetPos(paintLib.WidthSource(1300), paintLib.HightSource(440))

    CurrentColor = 1
    function randerModel:GetPlayerColor() return HairColors[CurrentColor][2]:ToVector() end
    local hairColor = pickmebutton2(1, #HairColors, function(int)
        CurrentColor = int
    end)
    hairColor:SetPos(paintLib.WidthSource(1300), paintLib.HightSource(550))

    local confirm = vgui.Create("DButton", self.mainFrame)
    confirm:SetText("")
    confirm:SetPos(paintLib.WidthSource(1550), paintLib.HightSource(970))
    confirm:SetSize(paintLib.WidthSource(250), paintLib.HightSource(50))
    confirm.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, inventoryColors.semiTransparentBlack)
        draw.RoundedBox(0, w - 1, 0, 1, paintLib.HightSource(20), inventoryColors.red)
        draw.RoundedBox(0, w - paintLib.WidthSource(20), 0, paintLib.WidthSource(20), 1, inventoryColors.red)
        draw.RoundedBox(0, 0, h - paintLib.HightSource(20), 1, paintLib.HightSource(20), inventoryColors.red)
        draw.RoundedBox(0, 0, h - 1, paintLib.WidthSource(20), 1, inventoryColors.red)
        draw.SimpleText("Закончить", "TL X28", w / 2, h / 2, inventoryColors.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    confirm.DoClick = function()
        local savedData = {
            name = playerName:GetValue(),
            description = playerDescription:GetValue(),
            cloth = cloth.CurrentInt - 1,
            clothSkin = clothSkin.CurrentInt - 1,
            hair = hair.CurrentInt,
            hairColor = HairColors[CurrentColor][2],
            gender = currentGender,
            race = currentRace
        }
        if savedData.name == "" then return end
        netstream.Start("saveCharacter", savedData)
        self.mainFrame:Close()
    end
end
concommand.Add("devOpen", function()
    creation:Build()
end)
netstream.Hook("openCharacterCreator", function()
    needOpenCreation = true 
    creation:Build()
end)