local FACTION = {}
FACTION.Colors = {
    background = Color(40, 35, 30, 200),
    headerBg = Color(50, 45, 40, 200),
    text = Color(255, 255, 255),
    title = Color(240, 225, 162),
    subtitle = Color(220, 210, 180),
    buttonNormal = Color(60, 55, 50, 200),
    buttonHover = Color(80, 75, 70, 200),
    buttonDanger = Color(100, 35, 35, 200),
    buttonDangerHover = Color(120, 40, 40, 200),
    leaderPanel = Color(100, 80, 40, 255),
    memberPanel = Color(60, 55, 50, 255)
}
FACTION.roleData = {}

function FACTION:InitializeNetworkHooks()

    netstream.Hook("fantasy/fraction/membersData", function(members, isLeader)
        if IsValid(self.membersList) then
            self:PopulateMembersList(members, isLeader)
        end
    end)


    netstream.Hook("fantasy/fraction/rolesData", function(roles)
        if IsValid(self.roleEditor) then
            self:PopulateRolesEditor(roles)
        end
    end)

    netstream.Hook("fantasy/fraction/getRoleList", function(roleData)
        print("roleData", roleData)
        PrintTable(roleData)
        self.roleData = roleData
    end)
end


function FACTION:CreateFactionPage()
    local ply = LocalPlayer()
    local fractionName = ply:GetFraction()


    if !fractionName then
        self:ShowNoFactionMessage()
        return
    end


    local fractionPanel = vgui.Create("DScrollPanel", inventorySubPanel)
    fractionPanel:SetSize(paintLib.WidthSource(1400), paintLib.HightSource(900))
    fractionPanel:SetPos(paintLib.WidthSource(56), paintLib.HightSource(120))
    self:StyleScrollbar(fractionPanel:GetVBar())


    self:CreateHeaderPanel(fractionPanel, fractionName)
    self:CreateMembersPanel(fractionPanel, fractionName)
    self:CreateControlsPanel(fractionPanel)


    self.mainPanel = fractionPanel
end


function FACTION:StyleScrollbar(scrollBar)
    scrollBar:SetHideButtons(true)
    scrollBar.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, FACTION.Colors.background)
    end
    scrollBar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(6, 2, 0, w-4, h, FACTION.Colors.buttonHover)
    end
end


function FACTION:ShowNoFactionMessage()
    local noFractionLabel = vgui.Create("DLabel", inventorySubPanel)
    noFractionLabel:SetFont("TL X40")
    noFractionLabel:SetText("ВЫ НЕ СОСТОИТЕ НИ В ОДНОЙ ФРАКЦИИ")
    noFractionLabel:SetTextColor(FACTION.Colors.title)
    noFractionLabel:SizeToContents()
    noFractionLabel:Center()
end


function FACTION:CreateHeaderPanel(parent, fractionName)
    local ply = LocalPlayer()
    local playerRole = ply:GetFractionRole() or "member"

    local headerPanel = vgui.Create("DPanel", parent)
    headerPanel:SetSize(paintLib.WidthSource(1400), paintLib.HightSource(80))
    headerPanel:Dock(TOP)
    headerPanel:DockMargin(0, 0, 0, paintLib.HightSource(20))
    headerPanel.Paint = function(selff, w, h)
        draw.RoundedBox(0, 0, 0, w, h, FACTION.Colors.headerBg)
        draw.SimpleText(string.upper("Фракция: " .. fractionName), "TL X40", w/2, h/2, FACTION.Colors.title, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)


        local roleText = "Ваша роль: " .. ( self.roleData[playerRole].name or playerRole)
        draw.SimpleText(roleText, "TL X20", w - paintLib.WidthSource(20), h/2, FACTION.Colors.subtitle, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    return headerPanel
end


function FACTION:CreateMembersPanel(parent, fractionName)
    local membersPanel = vgui.Create("DPanel", parent)
    membersPanel:SetSize(paintLib.WidthSource(1400), paintLib.HightSource(400))
    membersPanel:Dock(TOP)
    membersPanel:DockMargin(0, 0, 0, paintLib.HightSource(20))
    membersPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, FACTION.Colors.background)
        draw.RoundedBox(0, 0, 0, w, paintLib.HightSource(40), FACTION.Colors.headerBg)
        draw.SimpleText("УЧАСТНИКИ ФРАКЦИИ", "TL X24", paintLib.WidthSource(20), paintLib.HightSource(20), FACTION.Colors.title, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end


    local membersList = vgui.Create("DScrollPanel", membersPanel)
    membersList:SetSize(paintLib.WidthSource(1380), paintLib.HightSource(340))
    membersList:SetPos(paintLib.WidthSource(10), paintLib.HightSource(50))
    self:StyleScrollbar(membersList:GetVBar())


    self.membersList = membersList


    netstream.Start("fantasy/fraction/getMembers", fractionName)

    return membersPanel
end


function FACTION:PopulateMembersList(members, isLeader)
    local ply = LocalPlayer()

    for steamID, memberData in pairs(members) do
        local memberPanel = vgui.Create("DPanel", self.membersList)
        memberPanel:SetSize(paintLib.WidthSource(1360), paintLib.HightSource(50))
        memberPanel:Dock(TOP)
        memberPanel:DockMargin(0, 0, 0, paintLib.HightSource(5))
        memberPanel.Paint = function(selff, w, h)
            local color = memberData.isLeader and FACTION.Colors.leaderPanel or FACTION.Colors.memberPanel
            draw.RoundedBox(0, 0, 0, w, h, color)
            draw.SimpleText(memberData.name, "TL X20", paintLib.WidthSource(20), h/2, FACTION.Colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText( self.roleData[memberData.role].name, "TL X20", paintLib.WidthSource(400), h/2, FACTION.Colors.title, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)


            if memberData.lastSeen then
                local timeString = os.date("%d.%m.%Y %H:%M", memberData.lastSeen)
                draw.SimpleText("Последний вход: " .. timeString, "TL X14", paintLib.WidthSource(600), h/2, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end


        if ply:FractionCan("giveroles") or ply:FractionCan("kick") then
            if memberData.steamID != ply:SteamID() then
                self:AddMemberManagementButtons(memberPanel, memberData, steamID)
            end
        end
    end
end


function FACTION:AddMemberManagementButtons(panel, memberData, steamID)
    local ply = LocalPlayer()


    if ply:FractionCan("giveroles") and ply:CanAboveRole(memberData.role) then
        local roleButton = vgui.Create("DButton", panel)
        roleButton:SetSize(paintLib.WidthSource(120), paintLib.HightSource(30))
        roleButton:SetPos(paintLib.WidthSource(1000), paintLib.HightSource(10))
        roleButton:SetText("")
        roleButton.Paint = function(self, w, h)
            local col = self:IsHovered() and FACTION.Colors.buttonHover or FACTION.Colors.buttonNormal
            draw.RoundedBox(4, 0, 0, w, h, col)
            draw.SimpleText("Изменить роль", "TL X14", w/2, h/2, FACTION.Colors.subtitle, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        roleButton.DoClick = function()
            self:ShowRoleSelectionMenu(steamID)
        end
    end


    if ply:FractionCan("kick") and ply:CanAboveRole(memberData.role) then
        local kickButton = vgui.Create("DButton", panel)
        kickButton:SetSize(paintLib.WidthSource(80), paintLib.HightSource(30))
        kickButton:SetPos(paintLib.WidthSource(1130), paintLib.HightSource(10))
        kickButton:SetText("")
        kickButton.Paint = function(self, w, h)
            local col = self:IsHovered() and FACTION.Colors.buttonDangerHover or FACTION.Colors.buttonDanger
            draw.RoundedBox(4, 0, 0, w, h, col)
            draw.SimpleText("Исключить", "TL X14", w/2, h/2, FACTION.Colors.subtitle, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        kickButton.DoClick = function()
            self:ConfirmKickMember(memberData.name, steamID)
        end
    end
end


function FACTION:ShowRoleSelectionMenu(steamID)
    local ply = LocalPlayer()
    local roleMenu = DermaMenu()

    for roleName, roleData in pairs(self.roleData) do
        if ply:GetFractionRole() == "leader" or
           (self.roleData[ply:GetFractionRole()].imune > roleData.imune) then
            roleMenu:AddOption(roleData.name, function()
                netstream.Start("fantasy/fraction/changeRole", steamID, roleName)
            end)
        end
    end

    roleMenu:Open()
end


function FACTION:ConfirmKickMember(memberName, steamID)
    Derma_Query(
        "Вы уверены, что хотите исключить " .. memberName .. " из фракции?",
        "Исключение из фракции",
        "Да", function() netstream.Start("fantasy/fraction/kickMember", steamID) createInventoryFrame(true) end,
        "Отмена", function() end
    )
end


function FACTION:CreateControlsPanel(parent)
    local ply = LocalPlayer()

    local controlPanel = vgui.Create("DPanel", parent)
    controlPanel:SetSize(paintLib.WidthSource(1400), paintLib.HightSource(100))
    controlPanel:Dock(TOP)
    controlPanel:DockMargin(0, 0, 0, paintLib.HightSource(20))
    controlPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, FACTION.Colors.background)
        draw.RoundedBox(0, 0, 0, w, paintLib.HightSource(40), FACTION.Colors.headerBg)
        draw.SimpleText("УПРАВЛЕНИЕ ФРАКЦИЕЙ", "TL X24", paintLib.WidthSource(20), paintLib.HightSource(20), FACTION.Colors.title, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end


    local buttonX = paintLib.WidthSource(20)
    local buttonWidth = paintLib.WidthSource(200)
    local buttonSpacing = paintLib.WidthSource(20)


    if ply:FractionCan("invite") then
        local inviteButton = self:CreateControlButton(controlPanel, "Пригласить игрока", buttonX, paintLib.HightSource(50))
        inviteButton.DoClick = function() self:ShowPlayerInviteMenu() end
        buttonX = buttonX + buttonWidth + buttonSpacing
    end


    if ply:FractionCan("editroles") then
        local roleButton = self:CreateControlButton(controlPanel, "Настройка ролей", buttonX, paintLib.HightSource(50))
        roleButton.DoClick = function() self:ShowRoleEditor() end
    end

    return controlPanel
end


function FACTION:CreateControlButton(parent, text, x, y)
    local button = vgui.Create("DButton", parent)
    button:SetSize(paintLib.WidthSource(200), paintLib.HightSource(40))
    button:SetPos(x, y)
    button:SetText("")
    button.Paint = function(self, w, h)
        local col = self:IsHovered() and FACTION.Colors.buttonHover or FACTION.Colors.buttonNormal
        draw.RoundedBox(4, 0, 0, w, h, col)
        draw.SimpleText(text, "TL X18", w/2, h/2, FACTION.Colors.subtitle, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    return button
end


function FACTION:ShowPlayerInviteMenu()
    local playerSelector = vgui.Create("DFrame")
    playerSelector:SetTitle("Выберите игрока")
    playerSelector:SetSize(paintLib.WidthSource(400), paintLib.HightSource(500))
    playerSelector:Center()
    playerSelector:MakePopup()

    local playerList = vgui.Create("DScrollPanel", playerSelector)
    playerList:Dock(FILL)
    self:StyleScrollbar(playerList:GetVBar())

    for _, player in pairs(player.GetAll()) do
        if player:GetFraction() then continue end
        if player == LocalPlayer() then continue end

        local playerButton = vgui.Create("DButton", playerList)
        playerButton:SetText(player:Nick())
        playerButton:Dock(TOP)
        playerButton:DockMargin(5, 5, 5, 0)
        playerButton:SetTall(paintLib.HightSource(40))
        playerButton.DoClick = function()
            netstream.Start("fantasy/fraction/invite", player)
            playerSelector:Close()
        end
    end
end

function FACTION:ShowRoleEditor()
    -- Create the main editor frame with improved styling
    local roleEditor = vgui.Create("DFrame")
    roleEditor:SetTitle("")
    roleEditor:SetSize(paintLib.WidthSource(700), paintLib.HightSource(750))
    roleEditor:Center()
    roleEditor:MakePopup()
    roleEditor.Paint = function(self, w, h)
        -- Main background
        draw.RoundedBox(4, 0, 0, w, h, FACTION.Colors.background)

        -- Header bar
        draw.RoundedBox(0, 0, 0, w, paintLib.HightSource(60), FACTION.Colors.headerBg)
        draw.SimpleText("УПРАВЛЕНИЕ РОЛЯМИ", "TL X28", w/2, paintLib.HightSource(30), FACTION.Colors.title, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Close button "X"
        draw.SimpleText("✕", "TL X24", w - paintLib.WidthSource(30), paintLib.HightSource(30),
            self.CloseHovered and FACTION.Colors.buttonDangerHover or FACTION.Colors.subtitle,
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Add hover detection for close button
    roleEditor.OnCursorMoved = function(self, x, y)
        local w, h = self:GetSize()
        self.CloseHovered = (x > w - paintLib.WidthSource(50) and x < w - paintLib.WidthSource(10) and
                            y > paintLib.HightSource(15) and y < paintLib.HightSource(45))
    end

    -- Add click handling for close button
    roleEditor.OnMousePressed = function(self, mouseCode)
        if mouseCode == MOUSE_LEFT and self.CloseHovered then
            self:Close()
        end
    end

    -- Add description/instructions panel
    local descPanel = vgui.Create("DPanel", roleEditor)
    descPanel:SetPos(paintLib.WidthSource(15), paintLib.HightSource(70))
    descPanel:SetSize(paintLib.WidthSource(670), paintLib.HightSource(60))
    descPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, FACTION.Colors.leaderPanel)
        draw.SimpleText("Здесь вы можете настроить права для различных ролей вашей фракции.", "TL X16",
            w/2, h/2, FACTION.Colors.subtitle, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Add "Create New Role" button
    local createRoleButton = vgui.Create("DButton", roleEditor)
    createRoleButton:SetSize(paintLib.WidthSource(200), paintLib.HightSource(40))
    createRoleButton:SetPos(paintLib.WidthSource(485), paintLib.HightSource(80))
    createRoleButton:SetText("")
    createRoleButton.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(70, 120, 70, 200) or Color(60, 100, 60, 200)
        draw.RoundedBox(4, 0, 0, w, h, col)
        draw.SimpleText("+ СОЗДАТЬ НОВУЮ РОЛЬ", "TL X16", w/2, h/2, Color(220, 255, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    createRoleButton.DoClick = function()
        self:ShowCreateRoleDialog()
    end

    self.roleEditor = roleEditor

    -- Request roles data from server
    netstream.Start("fantasy/fraction/getRoles")

    -- Display loading indicator
    local loadingPanel = vgui.Create("DPanel", roleEditor)
    loadingPanel:SetPos(paintLib.WidthSource(15), paintLib.HightSource(140))
    loadingPanel:SetSize(paintLib.WidthSource(670), paintLib.HightSource(580))
    loadingPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, FACTION.Colors.memberPanel)
        draw.SimpleText("Загрузка данных о ролях...", "TL X20", w/2, h/2, FACTION.Colors.subtitle, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    self.loadingPanel = loadingPanel
end

-- Create role dialog
function FACTION:ShowCreateRoleDialog()
    local createDialog = vgui.Create("DFrame")
    createDialog:SetTitle("")
    createDialog:SetSize(paintLib.WidthSource(400), paintLib.HightSource(280))
    createDialog:Center()
    createDialog:MakePopup()
    createDialog.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, FACTION.Colors.background)
        draw.RoundedBox(6, 0, 0, w, paintLib.HightSource(40), FACTION.Colors.headerBg)
        draw.SimpleText("СОЗДАНИЕ РОЛИ", "TL X20", w/2, paintLib.HightSource(20), FACTION.Colors.title, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Role name input
    local nameLabel = vgui.Create("DLabel", createDialog)
    nameLabel:SetPos(paintLib.WidthSource(20), paintLib.HightSource(60))
    nameLabel:SetText("Название роли:")
    nameLabel:SetFont("TL X16")
    nameLabel:SetTextColor(FACTION.Colors.subtitle)
    nameLabel:SizeToContents()

    local nameEntry = vgui.Create("DTextEntry", createDialog)
    nameEntry:SetPos(paintLib.WidthSource(20), paintLib.HightSource(85))
    nameEntry:SetSize(paintLib.WidthSource(360), paintLib.HightSource(30))
    nameEntry:SetFont("TL X16")

    -- Role ID input
    local idLabel = vgui.Create("DLabel", createDialog)
    idLabel:SetPos(paintLib.WidthSource(20), paintLib.HightSource(125))
    idLabel:SetText("ID роли (только латиница, без пробелов):")
    idLabel:SetFont("TL X16")
    idLabel:SetTextColor(FACTION.Colors.subtitle)
    idLabel:SizeToContents()

    local idEntry = vgui.Create("DTextEntry", createDialog)
    idEntry:SetPos(paintLib.WidthSource(20), paintLib.HightSource(150))
    idEntry:SetSize(paintLib.WidthSource(360), paintLib.HightSource(30))
    idEntry:SetFont("TL X16")

    -- Immunity level slider
    local immuneLabel = vgui.Create("DLabel", createDialog)
    immuneLabel:SetPos(paintLib.WidthSource(20), paintLib.HightSource(190))
    immuneLabel:SetText("Уровень иммунитета: 5")
    immuneLabel:SetFont("TL X16")
    immuneLabel:SetTextColor(FACTION.Colors.subtitle)
    immuneLabel:SizeToContents()

    local immuneSlider = vgui.Create("DSlider", createDialog)
    immuneSlider:SetPos(paintLib.WidthSource(20), paintLib.HightSource(215))
    immuneSlider:SetSize(paintLib.WidthSource(360), paintLib.HightSource(20))
    immuneSlider:SetSlideX(0.1)
    immuneSlider:SetNotches(10)
    immuneSlider.TranslateValues = function(self, x, y)
        local immune = math.floor(x * 10) + 1
        immuneLabel:SetText("Уровень иммунитета: " .. immune)
        return immune
    end

    -- Create and cancel buttons
    local createButton = vgui.Create("DButton", createDialog)
    createButton:SetSize(paintLib.WidthSource(150), paintLib.HightSource(35))
    createButton:SetPos(paintLib.WidthSource(230), paintLib.HightSource(235))
    createButton:SetText("")
    createButton.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(70, 120, 70, 200) or Color(60, 100, 60, 200)
        draw.RoundedBox(4, 0, 0, w, h, col)
        draw.SimpleText("СОЗДАТЬ", "TL X16", w/2, h/2, Color(220, 255, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    createButton.DoClick = function()
        local roleName = nameEntry:GetValue()
        local roleId = idEntry:GetValue()
        local immuneLevel = math.floor(immuneSlider:GetSlideX() * 10) + 1

        if roleName == "" or roleId == "" then
            return
        end

        -- Validate role ID (only lowercase letters, numbers and underscores)
        if not string.match(roleId, "^[a-z0-9_]+$") then
            Derma_Message("ID роли может содержать только строчные латинские буквы, цифры и нижнее подчеркивание.", "Ошибка", "OK")
            return
        end

        netstream.Start("fantasy/fraction/createRole", {
            id = roleId,
            name = roleName,
            immune = immuneLevel
        })

        createDialog:Close()
    end

    local cancelButton = vgui.Create("DButton", createDialog)
    cancelButton:SetSize(paintLib.WidthSource(150), paintLib.HightSource(35))
    cancelButton:SetPos(paintLib.WidthSource(20), paintLib.HightSource(235))
    cancelButton:SetText("")
    cancelButton.Paint = function(self, w, h)
        local col = self:IsHovered() and FACTION.Colors.buttonHover or FACTION.Colors.buttonNormal
        draw.RoundedBox(4, 0, 0, w, h, col)
        draw.SimpleText("ОТМЕНА", "TL X16", w/2, h/2, FACTION.Colors.subtitle, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    cancelButton.DoClick = function()
        createDialog:Close()
    end
end

function FACTION:PopulateRolesEditor(roles)
    -- Remove loading indicator
    if IsValid(self.loadingPanel) then
        self.loadingPanel:Remove()
    end

    -- Create the main scroll panel
    local rolesList = vgui.Create("DScrollPanel", self.roleEditor)
    rolesList:SetPos(paintLib.WidthSource(15), paintLib.HightSource(140))
    rolesList:SetSize(paintLib.WidthSource(670), paintLib.HightSource(580))
    self:StyleScrollbar(rolesList:GetVBar())

    -- Track changes to enable save button
    local changesCount = 0

    -- Function to create permission checkbox with improved styling
    local function CreatePermissionCheckbox(parent, x, y, initialValue, onChange)
        local checkSize = paintLib.HightSource(20)

        local checkPanel = vgui.Create("DPanel", parent)
        checkPanel:SetPos(x, y)
        checkPanel:SetSize(checkSize, checkSize)
        checkPanel.Checked = initialValue
        checkPanel.Hovered = false

        checkPanel.Paint = function(self, w, h)
            -- Background and border
            draw.RoundedBox(4, 0, 0, w, h, self.Hovered and Color(60, 60, 60) or Color(40, 40, 40))
            draw.RoundedBoxEx(4, 1, 1, w-2, h-2, Color(30, 30, 30), true, true, true, true)

            -- Checkmark when checked
            if self.Checked then
                surface.SetDrawColor(FACTION.Colors.title)
                local checkW, checkH = w-8, h-8
                local checkX, checkY = 4, 4

                -- Draw checkmark
                surface.DrawLine(checkX, checkY + checkH/2, checkX + checkW/3, checkY + checkH - 4)
                surface.DrawLine(checkX + checkW/3, checkY + checkH - 4, checkX + checkW, checkY)
                surface.DrawLine(checkX, checkY + checkH/2 + 1, checkX + checkW/3, checkY + checkH - 3)
                surface.DrawLine(checkX + checkW/3, checkY + checkH - 3, checkX + checkW, checkY + 1)
            end
        end

        checkPanel.OnCursorEntered = function(self) self.Hovered = true end
        checkPanel.OnCursorExited = function(self) self.Hovered = false end

        checkPanel.OnMousePressed = function(self)
            self.Checked = not self.Checked
            onChange(self.Checked)
        end

        return checkPanel
    end

    -- Create role panels with improved design
    local yOffset = 0
    for roleName, roleData in pairs(roles) do
        -- Skip showing delete button for leader role
        local isLeaderRole = (roleName == "leader")
        local isMemberRole = (roleName == "member")

        -- Role panel with improved design
        local rolePanel = vgui.Create("DPanel", rolesList)
        rolePanel:SetPos(0, yOffset)
        rolePanel:SetSize(paintLib.WidthSource(650), paintLib.HightSource(180))
        rolePanel.Paint = function(self, w, h)
            -- Main background
            draw.RoundedBox(6, 0, 0, w, h, FACTION.Colors.headerBg)

            -- Role name header with gradient
            local headerHeight = paintLib.HightSource(40)
            surface.SetDrawColor(FACTION.Colors.leaderPanel)
            surface.DrawRect(0, 0, w, headerHeight)

            -- Role name and immunity level
            draw.SimpleText(roleData.name, "TL X22", paintLib.WidthSource(20), headerHeight/2,
                FACTION.Colors.title, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            -- Immunity badge
            local immuneBg = Color(40, 40, 40)
            local immuneFg = FACTION.Colors.subtitle
            draw.RoundedBox(12, w - paintLib.WidthSource(180), headerHeight/2 - paintLib.HightSource(15),
                paintLib.WidthSource(160), paintLib.HightSource(30), immuneBg)

            draw.SimpleText("Иммунитет: "..roleData.imune, "TL X16",
                w - paintLib.WidthSource(100), headerHeight/2,
                immuneFg, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            -- Permissions section header
            draw.SimpleText("РАЗРЕШЕНИЯ", "TL X18", paintLib.WidthSource(20),
                headerHeight + paintLib.HightSource(20), FACTION.Colors.subtitle, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        -- Add delete button for non-default roles
        if not isLeaderRole and not isMemberRole then
            local deleteButton = vgui.Create("DButton", rolePanel)
            deleteButton:SetSize(paintLib.WidthSource(24), paintLib.HightSource(24))
            deleteButton:SetPos(paintLib.WidthSource(620), paintLib.HightSource(8))
            deleteButton:SetText("")
            deleteButton.Paint = function(self, w, h)
                local col = self:IsHovered() and FACTION.Colors.buttonDangerHover or FACTION.Colors.buttonDanger
                draw.RoundedBox(12, 0, 0, w, h, col)
                draw.SimpleText("✕", "TL X16", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            deleteButton.DoClick = function()
                Derma_Query(
                    "Вы действительно хотите удалить роль '"..roleData.name.."'?\nВсе участники с этой ролью получат роль 'Житель'.",
                    "Удаление роли",
                    "Удалить", function()
                        netstream.Start("fantasy/fraction/removeRole", roleName)
                    end,
                    "Отмена", function() end
                )
            end
        end

        -- Add permissions with improved visual design
        local permissions = {
            {"invite", "Приглашать игроков", "Позволяет приглашать новых участников в фракцию"},
            {"storage", "Доступ к хранилищу", "Предоставляет доступ к хранилищу фракции"},
            {"kick", "Исключать участников", "Разрешает исключать участников с более низким иммунитетом"},
            {"giveroles", "Назначать роли", "Позволяет изменять роли участников фракции"}
        }

        local headerHeight = paintLib.HightSource(40)
        local permY = headerHeight + paintLib.HightSource(50)

        for idx, permData in ipairs(permissions) do
            local permKey = permData[1]
            local permName = permData[2]
            local permDesc = permData[3]

            -- Permission row background
            local permRow = vgui.Create("DPanel", rolePanel)
            permRow:SetPos(paintLib.WidthSource(20), permY)
            permRow:SetSize(paintLib.WidthSource(610), paintLib.HightSource(30))
            permRow.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(50, 45, 40, 100))
            end

            -- Create checkbox with improved styling (disable for leader role)
            local checkboxEnabled = not isLeaderRole
            local checkbox = CreatePermissionCheckbox(
                permRow,
                paintLib.WidthSource(10),
                paintLib.HightSource(5),
                roleData.acces[permKey] or false,
                function(val)
                    if not checkboxEnabled then return end

                    -- Animation feedback
                    changesCount = changesCount + 1
                    local saveLabel = vgui.Create("DLabel", permRow)
                    saveLabel:SetText("Сохранение...")
                    saveLabel:SetFont("TL X12")
                    saveLabel:SetTextColor(Color(150, 255, 150))
                    saveLabel:SizeToContents()
                    saveLabel:SetPos(paintLib.WidthSource(460), paintLib.HightSource(8))
                    saveLabel:AlphaTo(0, 1.5, 0, function()
                        saveLabel:Remove()
                        changesCount = changesCount - 1
                    end)

                    -- Send change to server
                    netstream.Start("fantasy/fraction/updateRolePermission", roleName, permKey, val)
                end
            )

            -- Disable checkbox visually for leader role
            if not checkboxEnabled then
                checkbox.OnMousePressed = function() end
                checkbox.Checked = true
            end

            -- Permission name
            local label = vgui.Create("DLabel", permRow)
            label:SetPos(paintLib.WidthSource(40), paintLib.HightSource(5))
            label:SetText(permName)
            label:SetFont("TL X16")
            label:SetTextColor(FACTION.Colors.text)
            label:SizeToContents()

            -- Add help icon with tooltip
            local helpIcon = vgui.Create("DButton", permRow)
            helpIcon:SetSize(paintLib.HightSource(20), paintLib.HightSource(20))
            helpIcon:SetPos(paintLib.WidthSource(240), paintLib.HightSource(5))
            helpIcon:SetText("")
            helpIcon.Paint = function(self, w, h)
                draw.RoundedBox(10, 0, 0, w, h, self:IsHovered() and Color(80, 80, 90) or Color(60, 60, 70))
                draw.SimpleText("?", "TL X14", w/2, h/2, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            -- Show tooltip on hover
            helpIcon.OnCursorEntered = function(self)
                self.Tooltip = vgui.Create("DPanel")
                self.Tooltip:SetSize(paintLib.WidthSource(250), paintLib.HightSource(50))
                self.Tooltip:SetPos(gui.MouseX() + 10, gui.MouseY() + 10)
                self.Tooltip.Paint = function(panel, w, h)
                    draw.RoundedBox(6, 0, 0, w, h, Color(50, 50, 60, 230))
                    draw.DrawText(permDesc, "TL X14", paintLib.WidthSource(10), paintLib.HightSource(8),
                        Color(220, 220, 220), TEXT_ALIGN_LEFT)
                end
            end

            helpIcon.OnCursorExited = function(self)
                if IsValid(self.Tooltip) then
                    self.Tooltip:Remove()
                end
            end

            helpIcon.Think = function(self)
                if IsValid(self.Tooltip) then
                    self.Tooltip:SetPos(gui.MouseX() + 10, gui.MouseY() + 10)
                end
            end

            permY = permY + paintLib.HightSource(32)
        end

        yOffset = yOffset + paintLib.HightSource(190)
    end

    -- Add network hook for role creation/deletion response
    if not self.roleUpdateHooksInitialized then
        netstream.Hook("fantasy/fraction/roleUpdateSuccess", function()
            -- Refresh the role editor after update
            if IsValid(self.roleEditor) then
                netstream.Start("fantasy/fraction/getRoles")
                -- Rebuild the editor content
                if IsValid(rolesList) then rolesList:Remove() end

                -- Show loading indicator again
                local loadingPanel = vgui.Create("DPanel", self.roleEditor)
                loadingPanel:SetPos(paintLib.WidthSource(15), paintLib.HightSource(140))
                loadingPanel:SetSize(paintLib.WidthSource(670), paintLib.HightSource(580))
                loadingPanel.Paint = function(self, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, FACTION.Colors.memberPanel)
                    draw.SimpleText("Обновление данных...", "TL X20", w/2, h/2, FACTION.Colors.subtitle, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                self.loadingPanel = loadingPanel
            end
        end)

        netstream.Hook("fantasy/fraction/roleUpdateError", function(errorMsg)
            Derma_Message(errorMsg or "Произошла ошибка при обновлении роли.", "Ошибка", "OK")
        end)

        self.roleUpdateHooksInitialized = true
    end
end


FACTION:InitializeNetworkHooks()


function fractionPage()
    netstream.Start("fantasy/fraction/getRoleList")
    FACTION:CreateFactionPage()
end

netstream.Start("fantasy/fraction/getRoleList")
