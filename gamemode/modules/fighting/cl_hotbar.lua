hotbar = {}
local cursorEnabled = false
playerSkillsBind = {
    KEY_1,
    KEY_2,
    KEY_3,
    KEY_4,
}

local function getKeyByBind(bind)
    for i, key in pairs(playerSkillsBind) do
        if key == bind then return i end
    end
end

hook.Add("PlayerButtonDown", "ToggleCursorF3", function(ply, button)
    if not IsFirstTimePredicted() then return end
    if button == KEY_F3 then
        cursorEnabled = not cursorEnabled
        gui.EnableScreenClicker(cursorEnabled)
    end
    local bind = getKeyByBind(button)
    if bind and hotbar[bind] then 
        local skillBox = hotbar[bind]
        if skillBox.skill then
            local weapon = ply:GetActiveWeapon()
            if IsValid(weapon) and (weapon.Type == skillBox.skill.WeaponType or not skillBox.skill.WeaponType) then
                netstream.Start("UseSkill", skillBox.skillid)
            end
        end
    end
end)

local function CreateHotbar()
    if IsValid(hotbarFrame) then hotbarFrame:Remove() end
    hotbarFrame = vgui.Create("DPanel")
    hotbarFrame:SetSize(paintLib.WidthSource(400), paintLib.WidthSource(155))
    hotbarFrame:SetPos(paintLib.WidthSource(1598), paintLib.WidthSource(931))
    hotbarFrame.Paint = function(self, w, h)
    end
    local ply = LocalPlayer()
    
    for i = 1, 4 do
        local boxBind = playerSkillsBind[i]

        local skillBox = vgui.Create("DButton", hotbarFrame)
        skillBox:SetSize(paintLib.WidthSource(45), paintLib.WidthSource(90))
        skillBox:SetPos(20 + (i - 1) * 60, 0)
        skillBox:SetText("")
        skillBox.skill = nil
        skillBox.boxBind = boxBind
        skillBox.skillid = nil
        skillBox.Paint = function(self, w, h)
            if IsValid(TestModel) or HideUI then return end
            local weapon = ply.GetActiveWeapon and ply:GetActiveWeapon() or false
            local color = Color(242, 242 ,242, 170  )
            local addY
            local inCd = false
            if self.skill then
                if IsValid(weapon) and weapon.Type ~= self.skill.WeaponType and self.skill.WeaponType then
                    color = Color(255, 0, 0, 200)
                end
                local cd = ply.GetCooldowns and ply:GetCooldowns() or {}
                for name, endTime in pairs(cd) do
                    if name == self.skill.Name then
                        local timeLeft = endTime - CurTime()
                        if timeLeft > 0 then 
                            inCd = string.format("%.1f", timeLeft) .. "с"
                            break 
                        end
                    end
                end
                local addY = inCd and paintLib.HightSource(3) or 0

                ITEMS_TEX.items[self.skill.Icon](0, addY, paintLib.WidthSource(45), paintLib.WidthSource(45))
                if inCd then 
                    draw.RoundedBox(0, 0, addY, paintLib.WidthSource(45), paintLib.WidthSource(45), Color(0, 0, 0, 200))
                    draw.SimpleText(inCd, "TLP X10", w / 2, h * 0.28, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
            
            draw.RoundedBox(8, paintLib.HightSource(12), paintLib.HightSource(49), paintLib.WidthSource(23), paintLib.WidthSource(23), color)
            
            draw.SimpleText(string.upper(input.GetKeyName(self.boxBind)), "TLP X10", w / 2, h * 0.67, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        skillBox.DoClick = function(self)
            Derma_KeyBindRequest("Кнопка", "Кнопка", _G["KEY_"..i], function(key)
                self.boxBind = key
                playerSkillsBind[i] = key
                SavePlayerBinds()
            end)
        end

        hotbar[i] = skillBox
    end
end

hook.Add("InitPostEntity", "CreateHotbar", CreateHotbar)
CreateHotbar()
function SavePlayerBinds()
    local binds = {}
    for i, key in pairs(playerSkillsBind) do
        binds[i] = key
    end
    settings.Set("player_binds", binds)
end

local function LoadPlayerBinds()
    local binds = settings.Get("player_binds", {})
    if binds then
        for i, key in pairs(binds) do 
            playerSkillsBind[i] = key
            hotbar[i].boxBind = key
        end
    end
end

LoadPlayerBinds()
hook.Add("InitPostEntity", "LoadPlayerBindsOnInit", LoadPlayerBinds)

function SaveHotbarConfig()
    local hotbarConfig = {}
    for i, skillBox in pairs(hotbar) do
        if skillBox.skillid then
            hotbarConfig[i] = skillBox.skillid
        end
    end
    settings.Set("hotbar_config", hotbarConfig)
end
 
local function LoadHotbarConfig()
    local hotbarConfig = settings.Get("hotbar_config", {})
    for i, skillid in pairs(hotbarConfig) do
        if skillList[skillid] then
            hotbar[i].skill = skillList[skillid]
            hotbar[i].skillid = skillid
        end
    end
end

LoadHotbarConfig()
hook.Add("InitPostEntity", "LoadHotbarConfigOnInit", function()
    LoadHotbarConfig()
    timer.Simple(1, function()
        LoadHotbarConfig()
    end)
end)