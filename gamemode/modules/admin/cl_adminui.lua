ADMIN = {}
ADMIN.Functions = {}
ADMIN.Categories = {}

function ADMIN:RegisterCategory(id, name, icon, order)
    self.Categories[id] = {
        name = name,
        icon = icon,
        order = order or 100,
        functions = {}
    }
end

function ADMIN:RegisterFunction(category, id, name, icon, callback)
    if not self.Categories[category] then
        self:RegisterCategory(category, category, "icon16/folder.png")
    end
    print("Registering function: " .. name)
    self.Categories[category].functions[id] = {
        name = name,
        icon = icon,
        callback = callback
    }
end

function ADMIN:GetSortedCategories()
    local categories = {}
    
    for id, data in pairs(self.Categories) do
        table.insert(categories, {id = id, data = data})
    end
    
    table.sort(categories, function(a, b)
        return a.data.order < b.data.order
    end)
    
    return categories
end

local function CreatePlayerList(parent)
    local playerPanel = vgui.Create("DPanel", parent)
    playerPanel:SetSize(paintLib.WidthSource(300), paintLib.HightSource(250))
    playerPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 50, 180))
        draw.SimpleText("ВЫБОР ИГРОКА", "TL X22", w/2, paintLib.HightSource(20), Color(220, 170, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(220, 170, 60, 150)
        surface.DrawRect(w * 0.1, paintLib.HightSource(35), w * 0.8, 2)
    end
    
    local playerScroll = vgui.Create("DScrollPanel", playerPanel)
    playerScroll:SetSize(paintLib.WidthSource(280), paintLib.HightSource(190))
    playerScroll:SetPos(paintLib.WidthSource(10), paintLib.HightSource(50))
    
    local playerList = {}
    local players = player.GetAll()
    
    for _, ply in ipairs(players) do
        local playerButton = vgui.Create("DButton", playerScroll)
        playerButton:SetSize(paintLib.WidthSource(270), paintLib.HightSource(40))
        playerButton:Dock(TOP)
        playerButton:DockMargin(0, 0, 0, paintLib.HightSource(5))
        playerButton:SetText("")
        
        playerButton.Paint = function(self, w, h)
            local color = self:IsHovered() and Color(60, 60, 80, 200) or Color(50, 50, 70, 180)
            if self.Selected then
                color = Color(70, 90, 120, 200)
            end
            
            draw.RoundedBox(4, 0, 0, w, h, color)
            
            local cornerSize = 8
            local cornerColor = Color(220, 170, 60, 150)
            
            if self.Selected then
                cornerColor = Color(220, 170, 60, 255)
                
                surface.SetDrawColor(cornerColor)
                surface.DrawRect(0, 0, cornerSize, 2)
                surface.DrawRect(0, 0, 2, cornerSize)
                
                surface.DrawRect(w - cornerSize, 0, cornerSize, 2)
                surface.DrawRect(w - 2, 0, 2, cornerSize)
                
                surface.DrawRect(0, h - 2, cornerSize, 2)
                surface.DrawRect(0, h - cornerSize, 2, cornerSize)
                
                surface.DrawRect(w - cornerSize, h - 2, cornerSize, 2)
                surface.DrawRect(w - 2, h - cornerSize, 2, cornerSize)
            end
            
            draw.SimpleText(ply:Nick(), "TL X18", paintLib.WidthSource(10), h/2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            local status = ""
            if ply:IsAdmin() then status = "Админ" end
            if ply:IsSuperAdmin() then status = "СуперАдмин" end
            
            if status ~= "" then
                draw.SimpleText(status, "TL X14", w - paintLib.WidthSource(10), h/2, Color(220, 170, 60), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end
        
        playerButton.DoClick = function(self)
            for _, btn in ipairs(playerList) do
                btn.Selected = false
            end
            self.Selected = true
            parent.SelectedPlayer = ply
            
            if parent.OnPlayerSelected then
                parent.OnPlayerSelected(ply)
            end
        end
        
        table.insert(playerList, playerButton)
    end
    
    return playerPanel
end

function ADMIN:OpenMenu()
    if IsValid(self.Frame) then
        self.Frame:Remove()
    end
    
    local frame = vgui.Create("DFrame")
    self.Frame = frame
    frame:SetSize(paintLib.WidthSource(1100), paintLib.HightSource(700))
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:MakePopup()
    frame:ShowCloseButton(false)
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 40, 240))
        
        local corner_size = 50
        local corner_width = 3
        local glow = math.abs(math.sin(CurTime() * 1.5)) * 50
        local cornerColor = Color(220, 170, 60, 255 - glow)
        
        surface.SetDrawColor(cornerColor)
        
        surface.DrawRect(0, 0, corner_size, corner_width)
        surface.DrawRect(0, 0, corner_width, corner_size)
        
        surface.DrawRect(w - corner_size, 0, corner_size, corner_width)
        surface.DrawRect(w - corner_width, 0, corner_width, corner_size)
        
        surface.DrawRect(0, h - corner_width, corner_size, corner_width)
        surface.DrawRect(0, h - corner_size, corner_width, corner_size)
        
        surface.DrawRect(w - corner_size, h - corner_width, corner_size, corner_width)
        surface.DrawRect(w - corner_width, h - corner_size, corner_width, corner_size)
        
        local titleText = "ПАНЕЛЬ АДМИНИСТРАТОРА"
        local titleColor = Color(255, 215, 100)
        local glowAmount = math.abs(math.sin(CurTime() * 2)) * 55
        
        draw.SimpleText(titleText, "TL X28", w / 2, 40, Color(255, 215, 100, glowAmount), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(titleText, "TL X28", w / 2, 40, titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
         
        surface.SetDrawColor(220, 170, 60, 150 + glowAmount)
        surface.DrawRect(w * 0.1, paintLib.HightSource(70), w * 0.8, 2)
    end
    
    local contentPanel = vgui.Create("DPanel", frame)
    contentPanel:SetPos(paintLib.WidthSource(50), paintLib.HightSource(90))
    contentPanel:SetSize(paintLib.WidthSource(1000), paintLib.HightSource(550))
    contentPanel.Paint = function() end
    
    local playerPanel = CreatePlayerList(contentPanel)
    playerPanel:SetPos(0, 0)
    
    local categoryPanel = vgui.Create("DPanel", contentPanel)
    categoryPanel:SetPos(0, paintLib.HightSource(260))
    categoryPanel:SetSize(paintLib.WidthSource(300), paintLib.HightSource(290))
    categoryPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 50, 180))
        draw.SimpleText("КАТЕГОРИИ", "TL X22", w/2, paintLib.HightSource(20), Color(220, 170, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(220, 170, 60, 150)
        surface.DrawRect(w * 0.1, paintLib.HightSource(35), w * 0.8, 2)
    end
    
    local categoryScroll = vgui.Create("DScrollPanel", categoryPanel)
    categoryScroll:SetSize(paintLib.WidthSource(280), paintLib.HightSource(230))
    categoryScroll:SetPos(paintLib.WidthSource(10), paintLib.HightSource(50))
    
    local categoryButtons = {}
    
    for _, categoryData in ipairs(self:GetSortedCategories()) do
        local categoryId = categoryData.id
        local data = categoryData.data
        
        local categoryButton = vgui.Create("DButton", categoryScroll)
        categoryButton:SetSize(paintLib.WidthSource(270), paintLib.HightSource(40))
        categoryButton:Dock(TOP)
        categoryButton:DockMargin(0, 0, 0, paintLib.HightSource(5))
        categoryButton:SetText("")
        
        categoryButton.Paint = function(self, w, h)
            local color = self:IsHovered() and Color(60, 60, 80, 200) or Color(50, 50, 70, 180)
            if self.Selected then
                color = Color(70, 90, 120, 200)
            end
            
            draw.RoundedBox(4, 0, 0, w, h, color)
            
            if self.Selected then
                surface.SetDrawColor(220, 170, 60, 255)
                surface.DrawRect(0, 0, 3, h)
            end
            
            if data.icon then
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(Material(data.icon))
                surface.DrawTexturedRect(paintLib.WidthSource(10), h/2 - 8, 16, 16)
            end
            
            draw.SimpleText(data.name, "TL X18", paintLib.WidthSource(40), h/2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        categoryButton.DoClick = function(self)
            for _, btn in ipairs(categoryButtons) do
                btn.Selected = false
            end
            self.Selected = true
            
            frame:PopulateFunctions(categoryId)
        end
        
        table.insert(categoryButtons, categoryButton)
    end
    
    local functionsPanel = vgui.Create("DPanel", contentPanel)
    functionsPanel:SetPos(paintLib.WidthSource(310), 0)
    functionsPanel:SetSize(paintLib.WidthSource(690), paintLib.HightSource(550))
    functionsPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 50, 180))
        
        local title = "ДЕЙСТВИЯ"
        if frame.CurrentCategory and ADMIN.Categories[frame.CurrentCategory] then
            title = ADMIN.Categories[frame.CurrentCategory].name
        end
        
        draw.SimpleText(title, "TL X22", w/2, paintLib.HightSource(20), Color(220, 170, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(220, 170, 60, 150)
        surface.DrawRect(w * 0.1, paintLib.HightSource(35), w * 0.8, 2)
        
        if not frame.CurrentCategory or not contentPanel.SelectedPlayer then
            draw.SimpleText("Выберите игрока и категорию", "TL X20", w/2, h/2, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    local functionsScroll = vgui.Create("DScrollPanel", functionsPanel)
    functionsScroll:SetSize(paintLib.WidthSource(670), paintLib.HightSource(490))
    functionsScroll:SetPos(paintLib.WidthSource(10), paintLib.HightSource(50))
    
    frame.PopulateFunctions = function(self, categoryId)
        functionsScroll:Clear()
        self.CurrentCategory = categoryId
        
        if not ADMIN.Categories[categoryId] then return end
        
        local functions = ADMIN.Categories[categoryId].functions
        local pos = 0
        
        for id, funcData in pairs(functions) do
            local funcButton = vgui.Create("DButton", functionsScroll)
            funcButton:SetSize(paintLib.WidthSource(650), paintLib.HightSource(60))
            funcButton:SetPos(0, pos)
            pos = pos + paintLib.HightSource(65)
            funcButton:SetText("")
            
            funcButton.Paint = function(self, w, h)
                local color = self:IsHovered() and Color(60, 70, 90, 200) or Color(50, 50, 70, 180)
                draw.RoundedBox(4, 0, 0, w, h, color)
                
                if funcData.icon then
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(Material(funcData.icon))
                    surface.DrawTexturedRect(paintLib.WidthSource(15), h/2 - 16, 32, 32)
                end
                
                draw.SimpleText(funcData.name, "TL X20", paintLib.WidthSource(60), h/2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                
                if self:IsHovered() then
                    surface.SetDrawColor(220, 170, 60, 100)
                    surface.DrawRect(0, h - 2, w, 2)
                end
            end
            
            funcButton.DoClick = function()
                if not contentPanel.SelectedPlayer then
                    surface.PlaySound("buttons/button10.wav")
                    return
                end
                
                surface.PlaySound("buttons/button14.wav")
                funcData.callback(contentPanel.SelectedPlayer)
            end
        end
    end
    
    if #categoryButtons > 0 then
        categoryButtons[1].Selected = true
        frame:PopulateFunctions(self:GetSortedCategories()[1].id)
    end
    
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetSize(paintLib.WidthSource(120), paintLib.HightSource(40))
    closeBtn:SetPos(frame:GetWide() - paintLib.WidthSource(170), paintLib.HightSource(650))
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Color(70, 30, 30, 180) or Color(50, 20, 20, 180))
        draw.SimpleText("Закрыть", "TL X20", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        frame:Remove()
    end
end

concommand.Add("fantasy_admin", function(ply)
    if IsValid(ply) and (ply:IsAdmin() or ply:IsSuperAdmin()) then
        ADMIN:OpenMenu()
    end
end)

function InitializeAdminFunctions()
    ADMIN:RegisterCategory("player", "Управление игроками", "icon16/user.png", 10)
    ADMIN:RegisterCategory("server", "Управление сервером", "icon16/server.png", 20)
    ADMIN:RegisterCategory("utilities", "Утилиты", "icon16/wrench.png", 30)
    ADMIN:RegisterCategory("roleplay", "Ролевая игра", "icon16/script.png", 40)
    ADMIN:RegisterFunction("roleplay", "managestatus", "Управление статусами игрока", "icons_/2/1.png", function(target)
        netstream.Start("fantasy/rpdata/admin/request", target:SteamID())
        OpenStatusAdminMenu()
    end) 
    ADMIN:RegisterFunction("server", "shopedit", "Редактор магазинов", "icon16/cart_edit.png", function(target)
        OpenShopEditMenu()
    end)
    ADMIN:RegisterFunction("roleplay", "editcharacter", "Редактор персонажей", "icon16/user_edit.png", function(target)
        OpenCharacterEditMenu()
    end)
    ADMIN:RegisterFunction("utilities", "itemcreator", "Редактор предметов", "icon16/package_add.png", function(target)
        OpenItemCreationMenu()
    end)
end
InitializeAdminFunctions() 
hook.Add("Initialize", "FantasyAdmin_Setup", InitializeAdminFunctions)

concommand.Add("AdminOpenMenu", function(ply)
    ADMIN:OpenMenu()
end)