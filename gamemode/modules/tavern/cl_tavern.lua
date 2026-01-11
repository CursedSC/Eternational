local pos1 = Vector("2085.264648 -3372.590576 263")
local angle1 = Angle("11.615971 129.775772 -0.000003")

local cameraTables = {
    ["default"] = {
        pos = Vector("2277.468750 -3406.310791 354.915802"),
        angle = Angle("25.519955 -179.887756 0.000000"),
        variations = {--Vector("2114.17578125 -3545.15625 264.03125")
            {
                pos = Vector("2085.264648 -3372.590576 263"),
                angle = Angle("11.615971 129.775772 -0.000003"),
                id = 395,
            },
            {
                pos = Vector("2114.17578125 -3535.15625 284.03125"),
                angle = Angle("0 0 0"),
                id = 2649,
            },       
            {
                pos = Vector("2072.4868164063 -3496.6955566406 264.03125"),
                angle = Angle("0 200 0"),
                id = 1777,
            }
        },
        player = {
                pos = Vector("2072.4868164063 -3496.6955566406 264.03125"),
                angle = Angle("0 200 0"),
                id = 1777,
        }
    },--Vector("2072.4868164063 -3496.6955566406 264.03125")
    ["storage"] = {
        pos = Vector("2104.728760 -3525.629395 337.334869"),
        angle = Angle("27.631947 -243.072769 0.000000"),
        player = {
            pos = Vector("2111.714111 -3452.783936 263"),
            angle = Angle("36.256012 -178.304214 -0.000000"),    
            id = 1978,
        }
    }
}

hook.Add( "PreDrawOpaqueRenderables" , "enterTavernRoom" , function( ply )
	if !IsValid(tavernFrame) then return end
    local ply = LocalPlayer()
	ply:SetPos( cameraTables[CurrentCameraTbl].player.pos )
	ply:SetupBones()
	ply:DrawModel()
end) 

hook.Add("CreateMove", "enterTavernRoom", function( ccmd, x, y, angle )
	if !IsValid(tavernFrame) then return end
	ccmd:SetViewAngles( cameraTables[CurrentCameraTbl].player.angle )
	return true
end)

hook.Add("TranslateActivity", "enterTavernRoom.enterTavernRoom", function(pl,sq)
    if !IsValid(tavernFrame) then return end
    local animSit = pl:LookupSequence("silo_sit")
    return cameraTables[CurrentCameraTbl].player.id
end)
local function clearFrame()
    for k, i in pairs(tavernFrame.ListPanels) do 
        i:Remove()
    end
    tavernFrame.ListPanels = {}
end
 

function buildReturnButton()
    local buttonStorage = vgui.Create("DButton", tavernFrame)
    buttonStorage:SetSize(paintLib.WidthSource(300), paintLib.HightSource(180))
    buttonStorage:SetPos(paintLib.WidthSource(1650), paintLib.HightSource(500))
    buttonStorage:SetText("")
    buttonStorage.DoClick = function()
        CurrentCameraTbl = "default"
        local canvariations = cameraTables[CurrentCameraTbl].variations
        if canvariations and #canvariations > 0 then
            local variation = canvariations[math.random(1, #canvariations)]
            cameraTables[CurrentCameraTbl].player.pos = variation.pos
            cameraTables[CurrentCameraTbl].player.angle = variation.angle
            cameraTables[CurrentCameraTbl].player.id = variation.id
        end
        CameraController.SetTarget(cameraTables[CurrentCameraTbl].pos, cameraTables[CurrentCameraTbl].angle)
        clearFrame()
        buildMainButtons()
    end
    buttonStorage.Paint = function(self, w, h)
        draw.SimpleText("Назад →", "TL X28", w / 2, h / 2, inventoryColors.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    tavernFrame.ListPanels[1] = buttonStorage
end

function buildMainButtons()
    local buttonStorage = vgui.Create("DButton", tavernFrame)
    buttonStorage:SetSize(300,180)
    buttonStorage:SetPos(650, 400)
    buttonStorage:SetText("")
    buttonStorage.DoClick = function()
        CurrentCameraTbl = "storage"
        CameraController.SetTarget(cameraTables[CurrentCameraTbl].pos, cameraTables[CurrentCameraTbl].angle)
        clearFrame()
        buildReturnButton()
        print("Opening storage")
        netstream.Start("openselfstorage")
    end
    buttonStorage.Paint = function(self, w, h)
        draw.SimpleText("Хранилище", "TL X28", w / 2, h / 2, inventoryColors.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    tavernFrame.ListPanels[1] = buttonStorage
 
    
    local buttonExit = vgui.Create("DButton", tavernFrame)
    buttonExit:SetSize(paintLib.WidthSource(300),180)
    buttonExit:SetPos(ScrW() / 2 - 150, ScrH() * 0.8) 
    buttonExit:SetText("")
    buttonExit.DoClick = function()
        exitTavernRoom()
    end
    buttonExit.Paint = function(self, w, h)
        draw.SimpleText("↓Выйти↓", "TL X28", w / 2, h / 2, inventoryColors.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    tavernFrame.ListPanels[2] = buttonExit
end

--silo_sit
function enterTavernRoom()
    
    local thirdperson = GetConVar("simple_thirdperson_enabled")
    thirdperson:SetInt(0)
    if IsValid(tavernFrame) then tavernFrame:Close() end
    HideUI = true
    CurrentCameraTbl = "default"
    tavernFrame = vgui.Create("DFrame")
    tavernFrame:SetSize(ScrW(), ScrH())
    tavernFrame:Center()
    tavernFrame:SetTitle("")
    tavernFrame:SetDraggable(false)
    tavernFrame:ShowCloseButton(false)
    tavernFrame:MakePopup()
    tavernFrame.Paint = function(self, w, h)
        
    end
    tavernFrame.ListPanels = {}
    tavernFrame.OnClose = function()
        exitTavernRoom()
    end
    buildMainButtons()
    local canvariations = cameraTables[CurrentCameraTbl].variations
    if canvariations and #canvariations > 0 then
        local variation = canvariations[math.random(1, #canvariations)]
        cameraTables[CurrentCameraTbl].player.pos = variation.pos
        cameraTables[CurrentCameraTbl].player.angle = variation.angle
        cameraTables[CurrentCameraTbl].player.id = variation.id
    end
    CameraController.SetTarget(cameraTables[CurrentCameraTbl].pos, cameraTables[CurrentCameraTbl].angle)
    for k, i in pairs(player.GetAll()) do 
        if i == LocalPlayer() then continue end
        i:SetNoDraw(true)
    end
end 

function exitTavernRoom()
    local thirdperson = GetConVar("simple_thirdperson_enabled")
    thirdperson:SetInt(1)
    netstream.Start("tavernExit")
    if IsValid(tavernFrame) then tavernFrame:Close() end
    HideUI = false
    CameraController.Stop()
    for k, i in pairs(player.GetAll()) do 
        i:SetNoDraw(false)
    end
end

netstream.Hook("tavernentry", enterTavernRoom)

netstream.Hook("tavernRoomNotRented", function()
    chat.AddText(Color(255, 100, 100), "Комната не арендована! Вам нужно арендовать комнату для доступа к хранилищу.")
    showRentDialog()
end)

netstream.Hook("tavernRentExpired", function()
    chat.AddText(Color(255, 100, 100), "Аренда комнаты истекла! Вы были выселены из таверны.")
    if IsValid(tavernFrame) then
        exitTavernRoom()
    end
end)

netstream.Hook("tavernRentSuccess", function()
    chat.AddText(Color(100, 255, 100), "Комната успешно арендована на 24 часа!")
end)

netstream.Hook("tavernRentFailed", function(message)
    chat.AddText(Color(255, 100, 100), message)
end)


-- Диалог аренды комнаты
function showRentDialog()
    if IsValid(rentDialog) then rentDialog:Remove() end
    
    rentDialog = vgui.Create("DFrame")
    rentDialog:SetSize(400, 300)
    rentDialog:Center()
    rentDialog:SetTitle("Аренда комнаты в таверне")
    rentDialog:SetDraggable(true)
    rentDialog:ShowCloseButton(true)
    rentDialog:MakePopup()
    
    local label = vgui.Create("DLabel", rentDialog)
    label:SetPos(20, 40)
    label:SetSize(360, 100)
    label:SetText("Для доступа к персональному хранилищу\nвам необходимо арендовать комнату.\n\nСтоимость: 50 золота за 24 часа")
    label:SetWrap(true)
    label:SetTextColor(Color(255, 255, 255))
    
    local rentButton = vgui.Create("DButton", rentDialog)
    rentButton:SetPos(50, 180)
    rentButton:SetSize(120, 40)
    rentButton:SetText("Арендовать")
    rentButton.DoClick = function()
        netstream.Start("tavernRentRoom")
        rentDialog:Remove()
    end
    
    local cancelButton = vgui.Create("DButton", rentDialog)
    cancelButton:SetPos(230, 180)
    cancelButton:SetSize(120, 40)
    cancelButton:SetText("Отмена")
    cancelButton.DoClick = function()
        rentDialog:Remove()
    end
end

concommand.Add("exitTavernRoom", exitTavernRoom)

-- Команда для показа диалога аренды
concommand.Add("tavern_rent_dialog", showRentDialog)

netstream.Hook("tavernRentSuccess", function()
    chat.AddText(Color(100, 255, 100), "Комната успешно арендована на 24 часа!")
end)

netstream.Hook("tavernRentFailed", function(msg)
    chat.AddText(Color(255, 100, 100), msg)
end)