AddCSLuaFile()
include('sh_dialogue.lua')
listquests = {}

netstream.Hook("questboard_use_daily", function(quest)
	DrawQuestBoard(quest)
end)

netstream.Hook("dialoguesystem/npcstart", function(npcname, npcdialogue, table, ent)
	dialoguesystem.MainPanel(npcdialogue, "Старт", table, ent)
end)

function cl_RefreshQuests()
	netstream.Start("questsystem/getquestsfromserver", LocalPlayer())
end

function dialoguesystem.MainPanel(dialoguename, stage, tbl, ent)
    local thirdperson = GetConVar("simple_thirdperson_enabled")
    thirdperson:SetInt(0)
    HideUI = true
    dialogEntity = ent
    stage = stage or "Старт"
    local DFrame = vgui.Create("DFrame")
    local i = 0
    DFrame:SetSize(paintLib.WidthSource(800), paintLib.HightSource(400))
    DFrame:SetPos(paintLib.WidthSource(900), paintLib.HightSource(500))
    DFrame:SetTitle('')
    DFrame:ShowCloseButton(false)
    DFrame:SetDraggable(false)
    DFrame:MakePopup()

    local npcText = dialoguesystem.list[dialoguename][stage]["text"]
    if type(npcText) == "function" then
        npcText = npcText()
    end
    local displayedText = ""
    local currentChar = 1
    local typewriterTimer = "typewriter_" .. tostring(math.random(1000, 9999))

    local cx2, cy2 = surface.DrawMulticolorText(paintLib.WidthSource(20), paintLib.HightSource(30), 'TL X32', {Color(240, 220, 180), npcText}, paintLib.WidthSource(760))
    DFrame.Paint = function(self, w, h)
        if currentChar <= string.len(npcText) then
            displayedText = string.sub(npcText, 1, currentChar)
            currentChar = currentChar + 1
        end
        draw.RoundedBox(8, 0, 0, w, h, Color(25, 20, 15, 240))

        for i = 0, h, 25 do
            surface.SetDrawColor(15, 10, 5, 80)
            surface.DrawLine(0, i, w, i)
        end

        surface.SetDrawColor(80, 60, 40, 200)
        surface.DrawOutlinedRect(0, 0, w, h, 3)

        draw.RoundedBox(0, 20, 15, w-40, 8, Color(150, 120, 80, 255))
        draw.RoundedBox(0, 20, h-23, w-40, 8, Color(150, 120, 80, 255))

        local cornerDecorations = {
            {15, 15}, {w-15, 15}, {15, h-15}, {w-15, h-15}
        }

        for _, pos in pairs(cornerDecorations) do
            draw.RoundedBox(12, pos[1]-8, pos[2]-8, 16, 16, Color(60, 45, 30))
            draw.RoundedBox(6, pos[1]-4, pos[2]-4, 8, 8, Color(100, 85, 70))
        end

        local x2, y2 = surface.DrawMulticolorText(paintLib.WidthSource(20), paintLib.HightSource(30), 'TL X32', {Color(240, 220, 180), displayedText}, paintLib.WidthSource(760))

        draw.RoundedBox(0, paintLib.WidthSource(15), paintLib.HightSource(40) + cy2, w - paintLib.WidthSource(30), paintLib.HightSource(2), Color(150, 120, 80, 200))
    end

    local x1, y1 = surface.DrawMulticolorText(0, 0, 'TL X32', {color_white, npcText}, paintLib.WidthSource(760))

    for k, v in pairs(dialoguesystem.list[dialoguename][stage]["variations"]) do
        local DButton = vgui.Create("DButton", DFrame)
        local x, y = surface.DrawMulticolorText(0, 0, 'TL X24', {color_white, v["name"]}, paintLib.WidthSource(720))
        DButton:SetSize(paintLib.WidthSource(40) + x, paintLib.HightSource(30) + y)
        DButton:SetPos(paintLib.WidthSource(40), paintLib.HightSource(80 + 35*i) + y1)
        DButton:SetText('')

        DButton.Paint = function(self, w, h)
            local bgColor = self:IsHovered() and Color(40, 30, 20, 220) or Color(30, 22, 15, 180)
            local borderColor = self:IsHovered() and Color(150, 120, 80, 255) or Color(100, 80, 60, 200)
            local textColor = self:IsHovered() and Color(240, 200, 120, 255) or Color(220, 200, 160, 255)

            draw.RoundedBox(4, 0, 0, w, h, bgColor)
            surface.SetDrawColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
            surface.DrawOutlinedRect(0, 0, w, h, 2)

            if self:IsHovered() then
                draw.RoundedBox(4, 2, 2, w-4, h-4, Color(50, 35, 25, 100))
            end

            draw.SimpleText(tostring(k) .. ". ", 'TL X24', paintLib.WidthSource(8), paintLib.HightSource(h/2), textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            surface.DrawMulticolorText(paintLib.WidthSource(28), paintLib.HightSource(0), 'TL X24', {textColor, v["name"]}, paintLib.WidthSource(720))
        end

        DButton.DoClick = function(self)
            surface.PlaySound("buttons/button14.wav")
            timer.Remove(typewriterTimer)
            DFrame:Remove()
            local result = v["continue"]
            if v["func"] then
                v["func"]()
            end
            if v["questcomplete"] or v["setquest"] then
                netstream.Start("dialoguesystem/setquest", v["questcomplete"] and true or false, v["questcomplete"] and v["questcomplete"] or v["setquest"], tbl)
            end
            if result == "end" then
                dialogEntity = nil
                HideUI = false
                local thirdperson = GetConVar("simple_thirdperson_enabled")
                thirdperson:SetInt(1)
                return
            end
            dialoguesystem.MainPanel(dialoguename, result, tbl, ent)
        end
        i = i + 1
    end
end
