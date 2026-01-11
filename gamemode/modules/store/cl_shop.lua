local curpos = {x = 0, y = 0, z = 0}
local isondialogue = false
netstream.Hook("fantasy/store/updateShops", function(data)
    Shops = data
end)

hook.Add("RenderScreenspaceEffects", "BlurScreenExceptEntity", function()
    if not IsValid(dialogEntity) then return end
    BlurScreen(24)
    cam.Start3D()
        dialogEntity:SetRenderMode(RENDERMODE_TRANSCOLOR)
        dialogEntity:DrawModel()
    cam.End3D()
end)

hook.Add("CalcView", "CalcView.Dialog", function(ply, pos, angles, fov)
    if not IsValid(dialogEntity) then isondialogue = false return end
    local view = {}
    local entEye = dialogEntity:EyePos() + Vector(0,0,60)
    local entEyeAngles = dialogEntity:EyeAngles()
    local anglesNeed = Angle(0, entEyeAngles.y - 210, 0)
	local endpos = entEye - dialogEntity:GetForward() * -35 - dialogEntity:GetRight()
	if not isondialogue then
		local eyepos = ply:GetAttachment(ply:LookupAttachment("eyes"))
		curpos = {x = eyepos.Pos.x, y = eyepos.Pos.y, z = eyepos.Pos.z}
		isondialogue = true
	end
	curpos.x = Lerp(RealFrameTime()*5, curpos.x, endpos.x)
	curpos.y = Lerp(RealFrameTime()*5, curpos.y, endpos.y)
	curpos.z = Lerp(RealFrameTime()*5, curpos.z, endpos.z)
    view.origin = Vector(curpos.x, curpos.y, curpos.z)
    view.angles = anglesNeed
    view.fov = fov
    view.drawviewer = true
    return view
end)

function shopNPCDialog(ent, idShop)
    dialogEntity = ent
    OpenShop(idShop)
end

local ListButtons = {}


local function buildItemsMode(tbl)
    for k, i in pairs(ListButtons) do
        if IsValid(i) then i:Remove() end
    end
    ListButtons = {}
    local yPos = 0
    for k, i in pairs(tbl) do

        local itemButton = vgui.Create("DButton", itemsShopScroll)
        itemButton:SetSize(paintLib.WidthSource(500), paintLib.HightSource(40))
        itemButton:SetPos(0,yPos)
        itemButton:SetText("")
        local item = itemList[i.id]
        local newItem = Item:new(i.id)
        itemButton.OnCursorEntered = function()
            showItemInfo(itemButton, newItem)
        end

        itemButton.OnCursorExited = function()
            if IsValid(infoPanel) then
                infoPanel:Remove()
            end
        end

        itemButton.Paint = function(self, w, h)
            local color = Color(0, 0, 0, 200)
            if self:IsHovered() then
                color = Color(0, 0, 0, 150)
            end
            draw.RoundedBox(0, 0, 0, w, h, color)
            local hasItem, num = playerInventory:hasItems(i.id)
            local name = hasItem and item.Name.." ("..num.."x)" or item.Name
            draw.SimpleText(name, "Trebuchet24", paintLib.HightSource(50), h * 0.5, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(i.cost.." м.", "Trebuchet24", w - paintLib.HightSource(10), h * 0.5, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            ITEMS_TEX.items[item.Icon](0, 0, paintLib.HightSource(40), paintLib.HightSource(40))
        end
        itemButton.DoClick = function(self)
            local hasItem, num = playerInventory:hasItems(i.id)
            local money = LocalPlayer():GetCharacterData("money") or 0
            if !hasItem and (frameShop.CurrentMode == "Sell") then return end
            local maxnum = (frameShop.CurrentMode == "Sell") and num or (math.floor(money / i.cost))
            if money < i.cost then
                return
            end
            Derma_NumRequest(
                "Количество",          -- Title
                "Выберите число предмета:",  -- Instruction text
                1,                         -- Default value
                1,                          -- Minimum value
                maxnum,                        -- Maximum value
                0,                          -- Decimals (0 means integer)
                function(value)
                    netstream.Start("shopAction/"..frameShop.CurrentMode, {shopId = CurrentShopId, itemId = k, itemCount = math.floor(value)})
                end,
                function()
                    print("User canceled the request.")
                end
            )
            --netstream.Start("shopAction/"..frameShop.CurrentMode, {shopId = CurrentShopId, itemId = k})
        end
        ListButtons[#ListButtons + 1] = itemButton
        yPos = yPos + paintLib.HightSource(40)
    end
end

function OpenShop(idShop)
    idShop = idShop or 1
    CurrentShopId = idShop
    frameShop = vgui.Create("DFrame")
    frameShop:SetSize(paintLib.WidthSource(500), paintLib.HightSource(700))
    frameShop:SetPos(ScrW() * 0.6, paintLib.HightSource(200))
    frameShop:MakePopup()
    frameShop:SetTitle("")
    frameShop:ShowCloseButton(false)
    frameShop.CurrentMode = "Sell"
    frameShop.Paint = function(self, w, h)
        local escDown = input.IsKeyDown(KEY_ESCAPE)
        if escDown then
            self:Close()
            gui.HideGameUI()
        end

        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
    end
    local thirdperson = GetConVar("simple_thirdperson_enabled")
    thirdperson:SetInt(0)
    HideUI = true
    frameShop.OnClose = function()
        dialogEntity = nil
        local thirdperson = GetConVar("simple_thirdperson_enabled")
        thirdperson:SetInt(1)
        HideUI = false
    end

    local buttonModeSell = vgui.Create("DButton", frameShop)
    buttonModeSell:SetSize(paintLib.WidthSource(250), paintLib.HightSource(40))
    buttonModeSell:SetPos(0, 0)
    buttonModeSell:SetText("")
    buttonModeSell.Paint = function(self, w, h)
        local color = Color(0, 0, 0, 200)
        if self:IsHovered() then
            color = Color(0, 0, 0, 150)
        end
        draw.RoundedBox(0, 0, 0, w, h, color)
        draw.SimpleText("ПРОДАЖА", "Trebuchet24", w * 0.5, h * 0.5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    buttonModeSell.DoClick = function()
        frameShop.CurrentMode = "Sell"
        buildItemsMode(Shops[idShop][frameShop.CurrentMode])
    end

    local buttonModeBuy = vgui.Create("DButton", frameShop)
    buttonModeBuy:SetSize(paintLib.WidthSource(250), paintLib.HightSource(40))
    buttonModeBuy:SetPos(paintLib.WidthSource(250), 0)
    buttonModeBuy:SetText("")
    buttonModeBuy.Paint = function(self, w, h)
        local color = Color(0, 0, 0, 200)
        if self:IsHovered() then
            color = Color(0, 0, 0, 150)
        end
        draw.RoundedBox(0, 0, 0, w, h, color)
        draw.SimpleText("ПОКУПКА", "Trebuchet24", w * 0.5, h * 0.5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    buttonModeBuy.DoClick = function()
        frameShop.CurrentMode = "Buy"
        buildItemsMode(Shops[idShop][frameShop.CurrentMode])
    end


    itemsShopScroll = vgui.Create("DScrollPanel", frameShop)
    itemsShopScroll:SetPos(0, paintLib.HightSource(40))
    itemsShopScroll:SetSize(paintLib.WidthSource(500), paintLib.HightSource(660))
    local vbar = itemsShopScroll:GetVBar()
    vbar.Paint = function(self, w, h)
    end
    vbar.btnUp.Paint = function(self, w, h)
    end
    vbar.btnDown.Paint = function(self, w, h)
    end
    vbar.btnGrip.Paint = function(self, w, h)
    end
    buildItemsMode(Shops[idShop][frameShop.CurrentMode])
end
