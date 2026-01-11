local function lumberFrame(ent) 
    frameMining = vgui.Create("DFrame")
    frameMining:SetSize(ScrW() * 0.2, ScrH() * 0.2)
    frameMining:Center()
    frameMining:SetTitle("")
    frameMining:SetDraggable(false)
    frameMining:MakePopup()
    frameMining:ShowCloseButton(false)
    frameMining.Lerp = 0
    frameMining.Combo = 0
    frameMining.Trys = 5
    frameMining.NeedRetry = true
    local needXmin, needXmax = 0.7, 0.25
    frameMining.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
        local isLMB = input.IsMouseDown(MOUSE_LEFT)
        if isLMB then
            self.Lerp = math.Clamp(self.Lerp + 0.005, 0, 1)
        elseif self.Lerp > 0 then
            self.NeedRetry = true
            if self.Lerp >= needXmin and self.Lerp <= (needXmin + needXmax) then
                self.Combo = self.Combo + 1
            end
            self.Trys = self.Trys - 1
            if self.Trys <= 0 then
                self:Close()
                netstream.Start("lumber", self.Combo, ent)
            end
        end
            
        if self.NeedRetry then
            self.NeedRetry = false
            needXmin = math.Round(math.Rand(0.3, 0.7), 1)
            needXmax = needXmax - 0.03
            print(needXmin, needXmax)
            self.Lerp = 0
        end
        local wed = (w - 50)
        draw.RoundedBox(0, 25, h * 0.5, (w - 50), 10, Color(71, 65, 50, 200))
        draw.RoundedBox(0, 25 + wed * needXmin, h * 0.5, wed * (needXmax), 10, Color(21, 211, 62, 99, 200))
        draw.RoundedBox(0, 25, h * 0.5, (w - 50) * self.Lerp, 10, Color(247, 177, 25, 200))

        draw.SimpleText("Combo X"..self.Combo, "TLP X9", w * 0.5, h * 0.5 - 20, color_white, TEXT_ALIGN_CENTER)
    end
end
netstream.Hook("lumber", function(ent)
	lumberFrame(ent)
end)

local keyTable = {
    ["w"] = KEY_W,
    ["a"] = KEY_A,
    ["s"] = KEY_S,
    ["d"] = KEY_D,
}

local function stoneFrame(ent) 
    frameMining = vgui.Create("DFrame")
    frameMining:SetSize(ScrW() * 0.4, ScrH() * 0.4)
    frameMining:Center()
    frameMining:SetTitle("")
    frameMining:SetDraggable(false)
    frameMining:MakePopup()
    frameMining:ShowCloseButton(true)
    frameMining.CurrentCircle = 1

    
    local crTable = {}
    for i = 1, 5 do
        crTable[i] = {math.Rand(0.1, 0.9), math.Rand(0.1, 0.9), btn = table.Random(keyTable), size = 1, color = Color(255, 255, 255)}
    end
    frameMining.DrawTable = {}
    local iIter = 1
    timer.Create("stoneFrame", 0.15, 5, function()
        frameMining.DrawTable[iIter] = crTable[iIter]
        iIter = iIter + 1
    end)
    frameMining.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))

        for k, i in pairs(self.DrawTable) do
            surface.DrawCircle( w * i[1], h * i[2], 30 * i.size, i.color )
            draw.SimpleText(input.GetKeyName(i.btn):upper(), "TLP X9", w * i[1], h * i[2], color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local cur = self.DrawTable[frameMining.CurrentCircle]
        cur.size = cur.size - 0.002
        if cur.size >= 0.3 and cur.size <= 0.5 then
            cur.color = Color(0, 255, 0)    
            local isTrueButton = input.IsButtonDown(cur.btn)
            if isTrueButton then
                self.CurrentCircle = self.CurrentCircle + 1
                if self.CurrentCircle > 5 then
                    self:Close()
                end
            end
        end
        if cur.size <= 0.3 then
            self.DrawTable[frameMining.CurrentCircle] = nil
            self.CurrentCircle = self.CurrentCircle + 1
            if self.CurrentCircle > 5 then
                self:Close()
            end
        end
    end
end

concommand.Add("stone", function()
    stoneFrame()
end)
