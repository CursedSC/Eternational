paintLib = paintLib or {}
local standartColor = Color(255,255,255)

// Fonts

paintLib.DrawRect = function(mat, x, y, w, h, col)
    local col = col or standartColor
    surface.SetDrawColor( col )
    surface.SetMaterial( mat )
    surface.DrawTexturedRect(x, y, w, h)
end

paintLib.DrawRectR = function(mat, x, y, w, h, r, col)
    local col = col or standartColor
    surface.SetDrawColor( col )
    surface.SetMaterial( mat )
    surface.DrawTexturedRectRotated(x, y, w, h, r)
end

function paintLib.WidthSource(x, custom)
    local a = custom or 1920
    return ScrW() / a  * x
end

function paintLib.HightSource(x, custom)
    local a = custom or 1080 
    return ScrH() / a  * x
end

function paintLib.Color(r, g, b, a)
    r = r < 90 and (0.916 * r + 7.8252) or r
    g = g < 90 and (0.916 * g + 7.8252) or g
    b = b < 90 and (0.916 * b + 7.8252) or b
    return Color(r, g, b, a)
end

for k = 1, 128 do
	surface.CreateFont( "TL X"..k, {
		font = "TL header RUS",
		extended = true,
		size =  paintLib.WidthSource(k),
		weight = paintLib.WidthSource(100),
	} )
end

-- WORKER 0.625

for k = 1, 128 do
	surface.CreateFont( "TLP X"..k, {
		font = "TL header RUS",
		extended = true,
		size =  math.floor(paintLib.WidthSource(k) * 1.625),
		weight = paintLib.WidthSource(400),
	} )
end

for k = 1, 128 do
	surface.CreateFont( "outline TLP X"..k, {
		font = "TL header RUS",
		extended = true,
		size =  math.floor(paintLib.WidthSource(k) * 1.625),
		weight = paintLib.WidthSource(400),
        outline = true,
	} )
end

local lerpCounter = 0
local timerList = {}
paintLib.CreateLerp = function(time, callback)
    lerpCounter = lerpCounter + 1
    timerList[lerpCounter] = {
        timeEnd = time + CurTime(),
        time = time,
        callback = callback
    }
    return lerpCounter
end

paintLib.GetLerp = function(id)
    if !timerList[id] then return 1 end
    local info = timerList[id]
    local timeLeft = info.timeEnd - CurTime()
    local x = timeLeft / info.time
    return 1 - x
end

paintLib.LerpExist = function(id)
    return timerList[id]
end

paintLib.StartStencil = function()
	render.SetStencilWriteMask( 0xFF )
	render.SetStencilTestMask( 0xFF )
	render.SetStencilReferenceValue( 0 )
	render.SetStencilPassOperation( STENCIL_KEEP )
	render.SetStencilZFailOperation( STENCIL_KEEP )
	render.ClearStencil()


	render.SetStencilEnable( true )
	render.SetStencilReferenceValue( 1 )
	render.SetStencilCompareFunction( STENCIL_NEVER )
	render.SetStencilFailOperation( STENCIL_REPLACE )
end

paintLib.ApllyStencil = function()
	render.SetStencilCompareFunction( STENCIL_EQUAL )
	render.SetStencilFailOperation( STENCIL_KEEP )
end


local listOfCircles = {}
function paintLib.Circle( x, y, radius, seg, bNotUseList )
    local uid = x.."_"..y.."_"..radius.."_"..seg
    local cir = {}
    if listOfCircles[uid] and !bNotUseList then 
        cir = listOfCircles[uid]
    else
	    table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	    for i = 0, seg do
	    	local a = math.rad( ( i / seg ) * -360 )
	    	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	    end

	    local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	    table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

        listOfCircles[uid] = cir
    end
	surface.DrawPoly( cir )
end

hook.Add("HUDPaint", "paintLib.lerp", function()
    for k, i in pairs(timerList) do
        if CurTime() > i.timeEnd then  if i.callback then i.callback() end timerList[k] = nil end
    end
end)
--[[
local old_Material = Material
local chacheMats = {}
function Material(path, pngParameters)
	pngParameters = pngParameters or ""
	if chacheMats[path.."_"..pngParameters] then return chacheMats[path.."_"..pngParameters] end 
	chacheMats[path.."_"..pngParameters] = old_Material(path, pngParameters)
	return chacheMats[path.."_"..pngParameters]
end]]

--[[
    Derma_NumRequest: Creates a dialog window with a DNumSlider for numerical input.
    
    Parameters:
        title (string)      - The title of the dialog window.
        text (string)       - The message or instructions displayed to the user.
        default (number)    - The default value of the slider.
        min (number)        - The minimum value allowed on the slider.
        max (number)        - The maximum value allowed on the slider.
        decimal (number)    - The number of decimal places (optional, default is 0).
        callback (function) - Function to call when the user clicks OK, with the chosen number.
        cancelCallback (function) - (Optional) Function to call if the user cancels the dialog.
]]
--[[
    Derma_NumRequest: Создает диалоговое окно с DNumSlider для ввода числового значения.
    
    Параметры:
        title (string)         - Заголовок окна.
        text (string)          - Текст с инструкциями для пользователя.
        default (number)       - Значение по умолчанию для слайдера.
        min (number)           - Минимальное значение слайдера.
        max (number)           - Максимальное значение слайдера.
        decimal (number)       - Количество десятичных знаков (опционально, по умолчанию 0).
        callback (function)    - Функция, вызываемая при нажатии кнопки "OK", получает выбранное значение.
        cancelCallback (function) - (Опционально) Функция, вызываемая при отмене диалога.
]]
function Derma_NumRequest(title, text, default, min, max, decimal, callback, cancelCallback)
    local frame = vgui.Create("DFrame")
    frame:SetSize(350, 200)
    frame:Center()
	frame:ShowCloseButton(false)
    frame:SetTitle("") 
    frame:MakePopup()
    frame.Paint = function(self, w, h)
        local escDown = input.IsKeyDown(KEY_ESCAPE)
        if escDown then
            self:Close()
            gui.HideGameUI()
        end
		
        draw.RoundedBox(8, 0, 0, w, h, Color(45, 45, 45, 230))
        draw.SimpleText(title, "DermaLarge", w / 2, 10, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    -- Надпись с инструкцией
    local label = vgui.Create("DLabel", frame)
    label:SetPos(20, 50)
    label:SetSize(310, 20)
    label:SetText(text)
    label:SetContentAlignment(5) 
    label:SetTextColor(Color(220, 220, 220))
    label:SetFont("DermaDefaultBold")

    local numSlider = vgui.Create("DNumSlider", frame)
    numSlider:SetPos(20, 80)
    numSlider:SetSize(310, 50)
    numSlider:SetMin(min)
    numSlider:SetMax(max)
    numSlider:SetDecimals(decimal or 0)
    numSlider:SetValue(default or min)
    numSlider:SetText("") 
    numSlider:InvalidateLayout(true)


    numSlider.Slider.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, h/2 - 2, w, 4, Color(60, 60, 60))
    end
    numSlider.Slider.Knob.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(90, 90, 90))
    end

    local okButton = vgui.Create("DButton", frame)
    okButton:SetSize(100, 30)
    okButton:SetPos(40, 150)
    okButton:SetText("OK")
    okButton:SetTextColor(Color(255, 255, 255))
    okButton:SetFont("DermaDefaultBold")
    okButton.Paint = function(self, w, h)
        if self:IsHovered() then
            draw.RoundedBox(6, 0, 0, w, h, Color(80, 150, 80))
        else
            draw.RoundedBox(6, 0, 0, w, h, Color(70, 130, 70))
        end
    end
    okButton.DoClick = function()
        if callback then
            callback(math.Round( numSlider:GetValue() ))
        end
        frame:Close()
    end

    local cancelButton = vgui.Create("DButton", frame)
    cancelButton:SetSize(100, 30)
    cancelButton:SetPos(210, 150)
    cancelButton:SetText("Отмена")
    cancelButton:SetTextColor(Color(255, 255, 255))
    cancelButton:SetFont("DermaDefaultBold")
    cancelButton.Paint = function(self, w, h)
        if self:IsHovered() then
            draw.RoundedBox(6, 0, 0, w, h, Color(150, 80, 80))
        else
            draw.RoundedBox(6, 0, 0, w, h, Color(130, 70, 70))
        end
    end
    cancelButton.DoClick = function()
        if cancelCallback then
            cancelCallback()
        end
        frame:Close()
    end
end

function Derma_KeyBindRequest(title, text, defaultKey, callback, cancelCallback)

    local frame = vgui.Create("DFrame")
    frame:SetSize(350, 200)
    frame:Center()
    frame:ShowCloseButton(false)
    frame:SetTitle("") 
    frame:MakePopup()
    frame.Paint = function(self, w, h)
        local escDown = input.IsKeyDown(KEY_ESCAPE)
        if escDown then
            self:Close()
            gui.HideGameUI()
        end
        
        draw.RoundedBox(8, 0, 0, w, h, Color(45, 45, 45, 230))
        draw.SimpleText(title, "DermaLarge", w / 2, 10, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    local label = vgui.Create("DLabel", frame)
    label:SetPos(20, 50)
    label:SetSize(310, 20)
    label:SetText(text)
    label:SetContentAlignment(5)
    label:SetTextColor(Color(220, 220, 220))
    label:SetFont("DermaDefaultBold")

    local keyBinder = vgui.Create("DBinder", frame)
    keyBinder:SetPos(20, 80)
    keyBinder:SetSize(310, 50)
    keyBinder:SetValue(defaultKey or KEY_NONE)
    keyBinder:SetText("")
    keyBinder:InvalidateLayout(true)

    local okButton = vgui.Create("DButton", frame)
    okButton:SetSize(100, 30)
    okButton:SetPos(40, 150)
    okButton:SetText("OK")
    okButton:SetTextColor(Color(255, 255, 255))
    okButton:SetFont("DermaDefaultBold")
    okButton.Paint = function(self, w, h)
        if self:IsHovered() then
            draw.RoundedBox(6, 0, 0, w, h, Color(80, 150, 80))
        else
            draw.RoundedBox(6, 0, 0, w, h, Color(70, 130, 70))
        end
    end
    okButton.DoClick = function()
        if callback then
            callback(keyBinder:GetValue())
        end
        frame:Close()
    end

    local cancelButton = vgui.Create("DButton", frame)
    cancelButton:SetSize(100, 30)
    cancelButton:SetPos(210, 150)
    cancelButton:SetText("Отмена")
    cancelButton:SetTextColor(Color(255, 255, 255))
    cancelButton:SetFont("DermaDefaultBold")
    cancelButton.Paint = function(self, w, h)
        if self:IsHovered() then
            draw.RoundedBox(6, 0, 0, w, h, Color(150, 80, 80))
        else
            draw.RoundedBox(6, 0, 0, w, h, Color(130, 70, 70))
        end
    end
    cancelButton.DoClick = function()
        if cancelCallback then
            cancelCallback()
        end
        frame:Close()
    end
end

--[[
    Derma_YesNoRequest: Creates a dialog window with Yes and No buttons.
    
    Parameters:
        title (string)      - The title of the dialog window.
        text (string)       - The message or question displayed to the user.
        yesCallback (function) - Function to call when the user clicks Yes.
        noCallback (function)  - (Optional) Function to call when the user clicks No.
]]
function Derma_YesNoRequest(title, text, yesCallback, noCallback)
    local frame = vgui.Create("DFrame")
    frame:SetSize(350, 180)
    frame:Center()
    frame:ShowCloseButton(false)
    frame:SetTitle("")
    frame:MakePopup()
    frame.Paint = function(self, w, h)
        local escDown = input.IsKeyDown(KEY_ESCAPE)
        if escDown then
            self:Close()
            gui.HideGameUI()
        end
        
        draw.RoundedBox(8, 0, 0, w, h, Color(45, 45, 45, 230))
        draw.SimpleText(title, "DermaLarge", w / 2, 10, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    local label = vgui.Create("DLabel", frame)
    label:SetPos(20, 50)
    label:SetSize(310, 40)
    label:SetText(text)
    label:SetContentAlignment(5) -- Center text
    label:SetTextColor(Color(220, 220, 220))
    label:SetFont("DermaDefaultBold")
    label:SetWrap(true)

    local yesButton = vgui.Create("DButton", frame)
    yesButton:SetSize(100, 30)
    yesButton:SetPos(40, 120)
    yesButton:SetText("Да")
    yesButton:SetTextColor(Color(255, 255, 255))
    yesButton:SetFont("DermaDefaultBold")
    yesButton.Paint = function(self, w, h)
        if self:IsHovered() then
            draw.RoundedBox(6, 0, 0, w, h, Color(80, 150, 80))
        else
            draw.RoundedBox(6, 0, 0, w, h, Color(70, 130, 70))
        end
    end
    yesButton.DoClick = function()
        if yesCallback then
            yesCallback(true)
        end
        frame:Close()
    end

    local noButton = vgui.Create("DButton", frame)
    noButton:SetSize(100, 30)
    noButton:SetPos(210, 120)
    noButton:SetText("Нет")
    noButton:SetTextColor(Color(255, 255, 255))
    noButton:SetFont("DermaDefaultBold")
    noButton.Paint = function(self, w, h)
        if self:IsHovered() then
            draw.RoundedBox(6, 0, 0, w, h, Color(150, 80, 80))
        else
            draw.RoundedBox(6, 0, 0, w, h, Color(130, 70, 70))
        end
    end
    noButton.DoClick = function()
        if noCallback then
            noCallback(false)
        end
        frame:Close()
    end
end
