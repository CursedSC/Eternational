local PANEL = {}
local anim_time = 0.3
local button_height = 100  -- Высота для кнопок
local isMenuOpen = false

-- Цвета для соответствия общему стилю
local colors = {
    background = Color(30, 30, 40, 220),
    button = Color(50, 50, 60, 180),
    buttonHover = Color(60, 60, 70, 200),
    text = Color(240, 225, 162),
    border = Color(86, 53, 53, 200)
}

-- Кнопки меню - легко добавлять новые
local menuButtons = {
    {
        name = "Настройки",
        icon = 112,
        func = function()  end
    },
    {
        name = "Вид от 3-го лица",
        icon = 42,
        func = function() OpenThirdPersonSettings() end
    },
}

function PANEL:Init()
    -- Начальные размеры будут обновлены в CreateButtons
    self:SetSize(ScrW(), button_height)
    self:SetPos(0, ScrH())
    self:SetKeyboardInputEnabled(false)
    
    -- Контейнер для кнопок
    self.buttonContainer = vgui.Create("DPanel", self)
    self.buttonContainer:Dock(FILL)
    self.buttonContainer:DockMargin(10, 10, 10, 10)
    self.buttonContainer.Paint = function() end
    
    -- Создание кнопок и обновление размера панели
    self:CreateButtons()
end

function PANEL:CreateButtons()
    -- Удаляем существующие кнопки при пересоздании
    if self.buttons then
        for _, btn in pairs(self.buttons) do
            if IsValid(btn) then btn:Remove() end
        end
    end
    self.buttons = {}

    local buttonCount = #menuButtons
    local buttonSize = paintLib.WidthSource(80)
    local spacing = paintLib.WidthSource(5)
    
    -- Вычисляем общую ширину для всех кнопок и отступов
    local totalWidth = buttonCount * buttonSize + (buttonCount - 1) * spacing
    -- Добавляем боковые отступы панели
    local panelWidth = totalWidth + paintLib.WidthSource(20)
    
    -- Обновляем размер панели
    self:SetSize(panelWidth, button_height)
    -- Центрируем панель по горизонтали
    self:SetPos((ScrW() - panelWidth) / 2, ScrH())
    
    -- Обновляем контейнер кнопок
    self.buttonContainer:SetSize(totalWidth, button_height - paintLib.WidthSource(20))
    
    -- Создаем кнопки
    for i, btnData in ipairs(menuButtons) do
        local btn = vgui.Create("DButton", self.buttonContainer)
        btn:SetSize(buttonSize, buttonSize)
        btn:SetPos((i-1) * (buttonSize + spacing), 0)
        btn:SetText("")
        table.insert(self.buttons, btn)
        
        btn.Paint = function(btn, w, h)
            local isHovered = btn:IsHovered()
            
            -- Фон кнопки
            draw.RoundedBox(6, 0, 0, w, h, isHovered and colors.buttonHover or colors.button)
            
            -- Рамка кнопки
            surface.SetDrawColor(colors.border)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
            
            -- Иконка (если есть)
            if btnData.icon then
                local iconSize = 40
                local iconX = (w - iconSize) / 2
                ITEMS_TEX.items[btnData.icon](iconX, 10, iconSize, iconSize)
            end
            
            -- Текст
            draw.SimpleText(btnData.name, "TL X14", w/2, h - 25, colors.text, TEXT_ALIGN_CENTER)
        end
        
        btn.DoClick = function()
            surface.PlaySound("ui/buttonclickrelease.wav")
            if btnData.func then
                btnData.func()
            end 
            self:SlideDown()
        end
    end
end

function PANEL:SlideUp()
    if isMenuOpen then return end
    isMenuOpen = true
    gui.EnableScreenClicker(true)
    surface.PlaySound("ui/buttonclick.wav")
    self:MoveTo((ScrW() - self:GetWide()) / 2, ScrH() - self:GetTall(), anim_time, 0, -1)
end

function PANEL:SlideDown()
    if not isMenuOpen then return end
    isMenuOpen = false
    gui.EnableScreenClicker(false)
    
    surface.PlaySound("ui/buttonclickrelease.wav")
    self:MoveTo((ScrW() - self:GetWide()) / 2, ScrH() + self:GetTall(), anim_time, 0, -1)
end

function PANEL:Paint(w, h)
    -- Фон меню
    draw.RoundedBoxEx(6, 0, 0, w, h, colors.background, true, true, false, false)
    
end

function PANEL:Think()
    -- Закрытие по ESC
    if isMenuOpen and input.IsKeyDown(KEY_ESCAPE) then
        self:SlideDown()
    end
end

vgui.Register("FantasyContextMenu", PANEL, "DPanel")

-- Создание и управление меню
local contextMenu = nil

local function CreateContextMenu()
    if IsValid(contextMenu) then contextMenu:Remove() end
    
    contextMenu = vgui.Create("FantasyContextMenu")
    contextMenu:SetMouseInputEnabled(true)
    
    return contextMenu
end

-- Перехват стандартного контекстного меню
hook.Add("ContextMenuOpen", "FantasyCustomContextMenu", function()
    local ply = LocalPlayer()
    local isPhysGun = ply:GetActiveWeapon() and ply:GetActiveWeapon():GetClass() == "weapon_physgun"
    if isPhysGun then
        return true
    end
    if not IsValid(contextMenu) then
        contextMenu = CreateContextMenu()
    end
    
    if isMenuOpen then
        contextMenu:SlideDown()
    else
        contextMenu:SlideUp()
    end
    
    -- Блокируем стандартное контекстное меню
    return false
end)

-- Инициализация меню при загрузке
hook.Add("InitPostEntity", "FantasyCreateContextMenu", function()
    CreateContextMenu()
end)

-- Добавление новой кнопки в меню (пример API)
function AddContextMenuButton(name, icon, func)
    table.insert(menuButtons, {
        name = name,
        icon = Material(icon, "noclamp smooth"),
        func = func
    })
    
    -- Пересоздаем меню если оно уже существует
    if IsValid(contextMenu) then
        CreateContextMenu()
    end
end

local thirdPersonFrame = nil

function OpenThirdPersonSettings()
    if IsValid(thirdPersonFrame) then thirdPersonFrame:Remove() end
    
    thirdPersonFrame = vgui.Create("DFrame")
    thirdPersonFrame:SetSize(500, 650)
    thirdPersonFrame:Center()
    thirdPersonFrame:SetTitle("Настройки вида от третьего лица")
    thirdPersonFrame:SetDraggable(true)
    thirdPersonFrame:ShowCloseButton(true)
    thirdPersonFrame:MakePopup()
    
    thirdPersonFrame.Paint = function(self, w, h)
       -- draw.RoundedBox(8, 0, 0, w, h, colors.panel)
        surface.SetDrawColor(colors.border)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end
    
    -- Создаем прокручиваемую панель для настроек
    local scroll = vgui.Create("DScrollPanel", thirdPersonFrame)
    scroll:Dock(FILL)
    scroll:DockMargin(5, 5, 5, 5)
    
    -- Создаем контейнер для настроек
    local panel = vgui.Create("DPanel", scroll)
    panel:Dock(TOP)
    panel:DockPadding(10, 10, 10, 10)
    panel:SetTall(1200) -- Автоматически увеличится с содержимым
    panel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(60, 60, 70, 100))
    end
    
    -- Функция для создания заголовков категорий
    local function AddCategoryTitle(parent, text)
        local label = vgui.Create("DLabel", parent)
        label:SetText(text)
        label:SetFont("TL X18")
        label:SetTextColor(colors.text)
        label:Dock(TOP)
        label:DockMargin(0, 5, 0, 5)
        label:SetContentAlignment(5) -- Центрировать текст
        label:SetTall(30)
        
        return label
    end
    
    -- Функция для добавления подсказки
    local function AddHelp(parent, text)
        local help = vgui.Create("DLabel", parent)
        help:SetText(text)
        help:SetFont("TL X14")
        help:SetTextColor(Color(200, 200, 200))
        help:Dock(TOP)
        help:DockMargin(20, 0, 0, 10)
        help:SetWrap(true)
        help:SetAutoStretchVertical(true)
        
        return help
    end
    
    -- Добавляем заголовок основных настроек
    AddCategoryTitle(panel, "ОСНОВНЫЕ НАСТРОЙКИ")
    
    -- Функция для создания чекбокса
    local function AddCheckbox(parent, text, convar)
        local checkbox = vgui.Create("DCheckBoxLabel", parent)
        checkbox:SetText(text)
        checkbox:SetFont("TL X14")
        checkbox:SetTextColor(colors.text)
        checkbox:SetConVar(convar)
        checkbox:Dock(TOP)
        checkbox:DockMargin(10, 5, 0, 5)
        checkbox:SetTall(25)
        
        return checkbox
    end
    
    -- Функция для создания слайдера
    local function AddSlider(parent, text, convar, min, max, decimals)
        decimals = decimals or 0
        
        local container = vgui.Create("DPanel", parent)
        container:Dock(TOP)
        container:DockMargin(10, 5, 10, 5)
        container:SetTall(50)
        container.Paint = function() end
        
        local label = vgui.Create("DLabel", container)
        label:SetText(text)
        label:SetFont("TL X14")
        label:SetTextColor(colors.text)
        label:Dock(TOP)
        
        local slider = vgui.Create("DNumSlider", container)
        slider:SetMin(min)
        slider:SetMax(max)
        slider:SetDecimals(decimals)
        slider:SetConVar(convar)
        slider:Dock(FILL)
        slider:SetTall(30)
        slider:SetDark(false)
        --slider:SetTextColor(colors.text)
        
        return container
    end
    
    -- Функция для привязки клавиши
    local function AddKeyBinder(parent, text, convar)
        local container = vgui.Create("DPanel", parent)
        container:Dock(TOP)
        container:DockMargin(10, 5, 10, 5)
        container:SetTall(50)
        container.Paint = function() end
        
        local label = vgui.Create("DLabel", container)
        label:SetText(text)
        label:SetFont("TL X14")
        label:SetTextColor(colors.text)
        label:Dock(TOP)
        
        local binder = vgui.Create("DBinder", container)
        binder:SetConVar(convar)
        binder:Dock(TOP)
        binder:SetTall(25)
        binder:DockMargin(0, 5, 0, 0)
        
        return container
    end
    
    -- Добавляем элементы управления
    
    AddCheckbox(panel, "Использовать позицию головы", "simple_thirdperson_shoulderview")
    
    -- Добавляем заголовок настроек позиции камеры
    AddCategoryTitle(panel, "НАСТРОЙКИ ПОЗИЦИИ КАМЕРЫ")
    
    AddSlider(panel, "Смещение по X", "simple_thirdperson_cam_right", -30.0, 30.0, 1)
    AddSlider(panel, "Смещение по Y", "simple_thirdperson_cam_up", -30.0, 30.0, 1)
    AddSlider(panel, "Смещение по Z", "simple_thirdperson_cam_distance", -30.0, 30.0, 1)
    
    
    -- Кнопки Сохранить/Отмена
    local buttonPanel = vgui.Create("DPanel", thirdPersonFrame)
    buttonPanel:Dock(BOTTOM)
    buttonPanel:SetTall(40)
    buttonPanel:DockMargin(0, 5, 0, 5)
    buttonPanel.Paint = function() end
    
    local saveButton = vgui.Create("DButton", buttonPanel)
    saveButton:SetText("Сохранить")
    saveButton:SetFont("TL X16")
    saveButton:SetTextColor(colors.text)
    saveButton:Dock(RIGHT)
    saveButton:SetWide(120)
    saveButton:DockMargin(5, 0, 5, 0)
    saveButton.Paint = function(self, w, h)
        local isHovered = self:IsHovered()
        draw.RoundedBox(4, 0, 0, w, h, isHovered and colors.buttonHover or colors.button)
        surface.SetDrawColor(colors.border)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end
    saveButton.DoClick = function()
        surface.PlaySound("ui/buttonclickrelease.wav")
        thirdPersonFrame:Close()
        notification.AddLegacy("Настройки сохранены", NOTIFY_GENERIC, 3)
    end
    
    local cancelButton = vgui.Create("DButton", buttonPanel)
    cancelButton:SetText("Отмена")
    cancelButton:SetFont("TL X16")
    cancelButton:SetTextColor(colors.text)
    cancelButton:Dock(RIGHT)
    cancelButton:SetWide(120)
    cancelButton:DockMargin(5, 0, 5, 0)
    cancelButton.Paint = function(self, w, h)
        local isHovered = self:IsHovered()
        draw.RoundedBox(4, 0, 0, w, h, isHovered and colors.buttonHover or colors.button)
        surface.SetDrawColor(colors.border)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end
    cancelButton.DoClick = function()
        surface.PlaySound("ui/buttonclickrelease.wav")
        thirdPersonFrame:Close()
    end
    
    -- Создаем ConVars если они не существуют
    if not ConVarExists("thirdperson_etp") then
        CreateClientConVar("thirdperson_etp", "0", true, false)
        CreateClientConVar("thirdperson_etp_vehicles_sync", "1", true, false)
        CreateClientConVar("thirdperson_etp_addons_sync", "1", true, false)
        CreateClientConVar("thirdperson_etp_headpos", "1", true, false)
        CreateClientConVar("thirdperson_etp_bind", "0", true, false)
        CreateClientConVar("thirdperson_etp_offset_x", "0", true, false)
        CreateClientConVar("thirdperson_etp_offset_y", "0", true, false)
        CreateClientConVar("thirdperson_etp_offset_z", "0", true, false)
        CreateClientConVar("thirdperson_etp_aim", "1", true, false)
        CreateClientConVar("thirdperson_etp_angle_x", "0", true, false)
        CreateClientConVar("thirdperson_etp_angle_y", "0", true, false)
        CreateClientConVar("thirdperson_etp_angle_z", "0", true, false)
        CreateClientConVar("thirdperson_etp_fov", "75", true, false)
        CreateClientConVar("thirdperson_etp_smoothing", "1", true, false)
        CreateClientConVar("thirdperson_etp_smoothing_speed", "10", true, false)
    end
end