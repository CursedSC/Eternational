local tables_dos = {}
local function weight_source(x)
    return ScrW() / 1920  * x
end

local function hight_source(x)
    return ScrH() / 1080  * x 
end

local function Alpha(pr)
    return (255 / 100) * pr
end

local MetaWords = {
    ["strength"] = "Прочность",
    ["creator"] = "Создатель",
    ["BlockPoints"] = "Очки блокирования",
    ["BlockMulty"] = "Множитель блокирования"
}

local typesName = {
    ["sword"] = "Одноручный Меч",
    ["spike"] = "Копье",
    ["bigsword"] = "Двуручный меч",
    ["axe"] = "Топор",
    ["bow"] = "Лук",
    ["knife"] = "Кинжал",
    ["rapier"] = "Рапира",
}

local function GetSkillName(codename)
    for k, i in pairs(stats_m[1]) do 
        if i.name_code == codename then return i.name end
    end
    return "???"
end

DOS = DOS or {}
local up_mat = Material("dos/ui/Tex_0009.png", "smooth")
local wood_mat = Material("dos/ui/Tex_0008.png", "smooth")
local line_mat = Material("dos/ui/Tex_0010.png", "smooth")
local down_mat = Material("dos/ui/Tex_0017.png", "smooth")
local line2_mat = Material("dos/ui/Tex_0011.png", "smooth")
function DOS.ShowRight(panel_v, TableInfo)
    if panel_v.dos_show then tables_dos[panel_v.dos_show] = CurTime() return panel_v.dos_show end
    if panel_v.dos_show then tables_dos[panel_v.dos_show] = CurTime() return panel_v.dos_show end
    local item_panel = items.it[TableInfo.id_item]
    local descriprion = item_panel and item_panel.desc or TableInfo.description
    local w,h = ScrW(),ScrH()
    local g_h = h

    local pos_x, pos_y = panel_v:LocalToScreen( pos_x, pos_y )


    local hight_tab = weight_source(65)
    local rare = item_panel and item_panel.rare or "Обычный"
    local weight = TableInfo.weight and TableInfo.weight or ""
    if descriprion then 
        local x, y = surface.DrawMulticolorText(10, weight_source(55), "Barkentina X20", descriprion, weight_source(350))
        hight_tab = hight_tab + y
    end
    local skill = false
    if item_panel and item_panel.skill then 
        skill = item_panel.skill
        local MetaSkill = WeaponSkills[skill]
        SKILLDRAWY = hight_tab - weight_source(50)

        local x, y = surface.DrawMulticolorText(0, 0, "Barkentina X19", MetaSkill.description, weight_source(250))
        hight_tab = hight_tab + y + weight_source(70)
    end


    local RequestInfo = false
    if item_panel and item_panel.req then 
        RequestInfoPos = hight_tab
        if not RequestInfo then RequestInfo = {} end
        local Config = item_panel.req
        RequestInfo[#RequestInfo+1] = Color(200,200,200,200)
        RequestInfo[#RequestInfo+1] = "Требуемый уровень: "..Config.lvl
        RequestInfo[#RequestInfo+1] = true  

        if Config.abil[1] then 
            for k, i in pairs(Config.abil) do 
                RequestInfo[#RequestInfo+1] = Color(200,200,200,200)
                RequestInfo[#RequestInfo+1] = "Требуеться "..i.abil_name..": "..i.abil_lvl
                RequestInfo[#RequestInfo+1] = true  
            end
        else 
            RequestInfo[#RequestInfo+1] = Color(200,200,200,200)
            RequestInfo[#RequestInfo+1] = "Требования предмета указаны неверно"
            RequestInfo[#RequestInfo+1] = true  
        end

        local x, y = surface.DrawMulticolorText(0, 0, "Barkentina X20", RequestInfo, weight_source(350))
        hight_tab = hight_tab + y + weight_source(20)
    end


    local WeaponInfo = false
    if item_panel and TableInfo.meta and TableInfo.meta.Type then 
        local weaponType = TableInfo.meta
        WeaponInfoPos = hight_tab
        if not WeaponInfo then WeaponInfo = {} end
        WeaponInfo[#WeaponInfo+1] = Color(200,200,200,200)
        WeaponInfo[#WeaponInfo+1] = "Урон: "..weaponType.damage.min.."-"..weaponType.damage.max
        WeaponInfo[#WeaponInfo+1] = true  
        WeaponInfo[#WeaponInfo+1] = Color(200,200,200,200)
        WeaponInfo[#WeaponInfo+1] = "Атрибут: "..GetSkillName(weaponType.MainAttribute)
        WeaponInfo[#WeaponInfo+1] = true  
        WeaponInfo[#WeaponInfo+1] = Color(200,200,200,200)
        WeaponInfo[#WeaponInfo+1] = "Тип: "..typesName[weaponType.Type]
        WeaponInfo[#WeaponInfo+1] = true  
        local x, y = surface.DrawMulticolorText(0, 0, "Barkentina X20", WeaponInfo, weight_source(350))
        hight_tab = hight_tab + y + weight_source(20)
    end


    local MetaDesc = false
    if TableInfo.meta then 
        MetaPos = hight_tab
        for k, i in pairs(TableInfo.meta) do 
            if MetaWords[k] then 
                if not MetaDesc then MetaDesc = {} end
                MetaDesc[#MetaDesc+1] = Color(200,200,200,200)
                MetaDesc[#MetaDesc+1] = MetaWords[k]..": "..i
                MetaDesc[#MetaDesc+1] = true
            end
        end
        if MetaDesc then 
            local x, y = surface.DrawMulticolorText(0, 0, "Barkentina X20", MetaDesc, weight_source(350))
            hight_tab = hight_tab + y + weight_source(20)
        end
    end
    local info = vgui.Create("DPanel")
    info:SetPos(pos_x + panel_v:GetWide() + 5, pos_y - (hight_tab / 2))
    info:SetSize(w * 0.2, hight_tab)
    info:SetZPos( 999 )

    info.Paint = function( self, w, h ) 
        surface.SetDrawColor(0,0,0,240)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(0,86,199,200)
        surface.DrawRect(0, 0, w * 0.1, weight_source(5))
        surface.SetDrawColor(0,86,199,200)
        surface.DrawRect(0, 0, w * 0.2, weight_source(3))

        surface.SetDrawColor(0,86,199,200)
        surface.DrawRect(0, 0, weight_source(5), h * 0.1)
        surface.SetDrawColor(0,86,199,200)
        surface.DrawRect(0, 0, weight_source(3), h * 0.2)


        surface.SetDrawColor(0,86,199,200)
        surface.DrawRect(w * 0.9, h - weight_source(5), w * 0.1, weight_source(5))
        surface.SetDrawColor(0,86,199,200)
        surface.DrawRect(w * 0.8, h - weight_source(3), w * 0.2, weight_source(3))

        surface.SetDrawColor(0,86,199,200)
        surface.DrawRect(w - weight_source(5), h * 0.9, weight_source(5), h * 0.1)
        surface.SetDrawColor(0,86,199,200)
        surface.DrawRect(w - weight_source(2), h * 0.8, weight_source(3), h * 0.2)



        if descriprion then local x, y = surface.DrawMulticolorText(weight_source(25), weight_source(55), "Barkentina X20", descriprion, weight_source(350)) end
        draw.DrawText( "["..TableInfo.name.."]", "Barkentina X24", w * 0.5, weight_source(15), color_white, TEXT_ALIGN_CENTER )
        draw.DrawText( rare, "Barkentina X17", weight_source(25), h - weight_source(26), RP.rare[rare].color, TEXT_ALIGN_LEFT )
        draw.DrawText( weight.." кг.", "Barkentina X17", w - weight_source(25), h - weight_source(26), color_white, TEXT_ALIGN_RIGHT )

        if item_panel and item_panel.skill then 
            skill = item_panel.skill
            local MetaSkill = WeaponSkills[skill]


            draw.DrawText( MetaSkill.name, "Barkentina X24", weight_source(100), SKILLDRAWY + weight_source(30), color_white, TEXT_ALIGN_LEFT )
            ITEMS_TEX.items[MetaSkill.icon](weight_source(30), SKILLDRAWY + weight_source(30), weight_source(64),weight_source(64))

            local x, y = surface.DrawMulticolorText(weight_source(100), SKILLDRAWY + weight_source(60), "Barkentina X19", MetaSkill.description, weight_source(250))
        end

        if MetaDesc then 

            surface.SetDrawColor(0,86,199,200)
            surface.DrawRect(0, MetaPos - weight_source(35), w, weight_source(2))

            local x, y = surface.DrawMulticolorText(weight_source(25), MetaPos - weight_source(25), "Barkentina X20", MetaDesc, weight_source(350))
        end


        if WeaponInfo then 

            surface.SetDrawColor(0,86,199,200)
            surface.DrawRect(0, WeaponInfoPos - weight_source(35), w, weight_source(2))

            local x, y = surface.DrawMulticolorText(weight_source(25), WeaponInfoPos - weight_source(25), "Barkentina X20", WeaponInfo, weight_source(350))
        end


        if RequestInfo then 

            surface.SetDrawColor(0,86,199,200)
            surface.DrawRect(0, RequestInfoPos - weight_source(35), w, weight_source(2))

            local x, y = surface.DrawMulticolorText(weight_source(25), RequestInfoPos - weight_source(25), "Barkentina X20", RequestInfo, weight_source(350))
        end

    end 

    if (pos_y - (hight_tab / 2) + hight_tab) > ScrH() then 
        info:SetPos(pos_x - w * 0.2, ScrH() - hight_tab)
    end
    panel_v.dos_show = info
    tables_dos[panel_v.dos_show] = CurTime()
end

function DOS.ShowLeft(panel_v, TableInfo)
    if panel_v.dos_show then tables_dos[panel_v.dos_show] = CurTime() return panel_v.dos_show end
    local item_panel = items.it[TableInfo.id_item]
    local descriprion = item_panel and item_panel.desc or TableInfo.description
    local w,h = ScrW(),ScrH()
    local g_h = h
    local pos_x, pos_y = panel_v:LocalToScreen( pos_x, pos_y )
    if ((pos_x - w * 0.2) - w * 0.2) < 0 then
        DOS.ShowRight(panel_v, TableInfo)
        return nil
    end

    local hight_tab = weight_source(65)
    local rare = item_panel and item_panel.rare or "Обычный"
    local weight = TableInfo.weight and TableInfo.weight or ""
    if descriprion then 
        local x, y = surface.DrawMulticolorText(10, weight_source(55), "Barkentina X20", descriprion, weight_source(350))
        hight_tab = hight_tab + y
    end
    local skill = false
    if item_panel and item_panel.skill then 
        skill = item_panel.skill
        local MetaSkill = WeaponSkills[skill]
        SKILLDRAWY = hight_tab - weight_source(50)

        local x, y = surface.DrawMulticolorText(0, 0, "Barkentina X19", MetaSkill.description, weight_source(250))
        hight_tab = hight_tab + y + weight_source(70)
    end


    local RequestInfo = false
    if item_panel and  item_panel.req then 
        RequestInfoPos = hight_tab
        if not RequestInfo then RequestInfo = {} end
        local Config = item_panel.req
        RequestInfo[#RequestInfo+1] = Color(200,200,200,200)
        RequestInfo[#RequestInfo+1] = "Требуемый уровень: "..Config.lvl
        RequestInfo[#RequestInfo+1] = true  

        if Config.abil[1] then 
            for k, i in pairs(Config.abil) do 
                RequestInfo[#RequestInfo+1] = Color(200,200,200,200)
                RequestInfo[#RequestInfo+1] = "Требуеться "..i.abil_name..": "..i.abil_lvl
                RequestInfo[#RequestInfo+1] = true  
            end
        else 
            RequestInfo[#RequestInfo+1] = Color(200,200,200,200)
            RequestInfo[#RequestInfo+1] = "Требования предмета указаны неверно"
            RequestInfo[#RequestInfo+1] = true  
        end

        local x, y = surface.DrawMulticolorText(0, 0, "Barkentina X20", RequestInfo, weight_source(350))
        hight_tab = hight_tab + y + weight_source(20)
    end


    local WeaponInfo = false
    if item_panel and TableInfo.meta and TableInfo.meta.Type then 
        local weaponType = TableInfo.meta
        WeaponInfoPos = hight_tab
        if not WeaponInfo then WeaponInfo = {} end
        WeaponInfo[#WeaponInfo+1] = Color(200,200,200,200)
        WeaponInfo[#WeaponInfo+1] = "Урон: "..weaponType.damage.min.."-"..weaponType.damage.max
        WeaponInfo[#WeaponInfo+1] = true  
        WeaponInfo[#WeaponInfo+1] = Color(200,200,200,200)
        WeaponInfo[#WeaponInfo+1] = "Атрибут: "..GetSkillName(weaponType.MainAttribute)
        WeaponInfo[#WeaponInfo+1] = true  
        WeaponInfo[#WeaponInfo+1] = Color(200,200,200,200)
        WeaponInfo[#WeaponInfo+1] = "Тип: "..typesName[weaponType.Type]
        WeaponInfo[#WeaponInfo+1] = true  
        local x, y = surface.DrawMulticolorText(0, 0, "Barkentina X20", WeaponInfo, weight_source(350))
        hight_tab = hight_tab + y + weight_source(20)
    end


    local MetaDesc = false
    if TableInfo.meta then 
        MetaPos = hight_tab
        for k, i in pairs(TableInfo.meta) do 
            if MetaWords[k] then 
                if not MetaDesc then MetaDesc = {} end
                MetaDesc[#MetaDesc+1] = Color(200,200,200,200)
                MetaDesc[#MetaDesc+1] = MetaWords[k]..": "..i
                MetaDesc[#MetaDesc+1] = true
            end
        end
        if MetaDesc then 
            local x, y = surface.DrawMulticolorText(0, 0, "Barkentina X20", MetaDesc, weight_source(350))
            hight_tab = hight_tab + y + weight_source(20)
        end
    end

    local info = vgui.Create("DPanel")
    info:SetPos(pos_x - w * 0.2, pos_y - (hight_tab / 2))
    info:SetSize(w * 0.2, hight_tab)
    info:SetZPos( 999 )

    if (pos_y - (hight_tab / 2) + hight_tab) > ScrH() then 
        info:SetPos(pos_x - w * 0.2, ScrH() - hight_tab)
    end
    info.Paint = function( self, w, h ) 
        surface.SetDrawColor(0,0,0,240)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(0,86,199,200)
        surface.DrawRect(0, 0, w * 0.1, weight_source(5))
        surface.SetDrawColor(0,86,199,200)
        surface.DrawRect(0, 0, w * 0.2, weight_source(3))

        surface.SetDrawColor(0,86,199,200)
        surface.DrawRect(0, 0, weight_source(5), h * 0.1)
        surface.SetDrawColor(0,86,199,200)
        surface.DrawRect(0, 0, weight_source(3), h * 0.2)


        surface.SetDrawColor(0,86,199,200)
        surface.DrawRect(w * 0.9, h - weight_source(5), w * 0.1, weight_source(5))
        surface.SetDrawColor(0,86,199,200)
        surface.DrawRect(w * 0.8, h - weight_source(3), w * 0.2, weight_source(3))

        surface.SetDrawColor(0,86,199,200)
        surface.DrawRect(w - weight_source(5), h * 0.9, weight_source(5), h * 0.1)
        surface.SetDrawColor(0,86,199,200)
        surface.DrawRect(w - weight_source(2), h * 0.8, weight_source(3), h * 0.2)


        if descriprion then local x, y = surface.DrawMulticolorText(weight_source(25), weight_source(55), "Barkentina X20", descriprion, weight_source(350)) end
        draw.DrawText( "["..TableInfo.name.."]", "Barkentina X24", w * 0.5, weight_source(15), color_white, TEXT_ALIGN_CENTER )
        draw.DrawText( rare, "Barkentina X17", weight_source(25), h - weight_source(26), RP.rare[rare].color, TEXT_ALIGN_LEFT )
        draw.DrawText( weight.." кг.", "Barkentina X17", w - weight_source(25), h - weight_source(26), color_white, TEXT_ALIGN_RIGHT )

        if item_panel and item_panel.skill then 
            skill = item_panel.skill
            local MetaSkill = WeaponSkills[skill]

            draw.DrawText( MetaSkill.name, "Barkentina X24", weight_source(100), SKILLDRAWY + weight_source(30), color_white, TEXT_ALIGN_LEFT )
            ITEMS_TEX.items[MetaSkill.icon](weight_source(30), SKILLDRAWY + weight_source(30), weight_source(64),weight_source(64))

            local x, y = surface.DrawMulticolorText(weight_source(100), SKILLDRAWY + weight_source(60), "Barkentina X19", MetaSkill.description, weight_source(250))
        end

        if MetaDesc then 

            surface.SetDrawColor(0,86,199,200)
            surface.DrawRect(0, MetaPos - weight_source(35), w, weight_source(2))

            local x, y = surface.DrawMulticolorText(weight_source(25), MetaPos - weight_source(25), "Barkentina X20", MetaDesc, weight_source(350))
        end


        if WeaponInfo then 

            surface.SetDrawColor(0,86,199,200)
            surface.DrawRect(0, WeaponInfoPos - weight_source(35), w, weight_source(2))

            local x, y = surface.DrawMulticolorText(weight_source(25), WeaponInfoPos - weight_source(25), "Barkentina X20", WeaponInfo, weight_source(350))
        end


        if RequestInfo then 

            surface.SetDrawColor(0,86,199,200)
            surface.DrawRect(0, RequestInfoPos - weight_source(35), w, weight_source(2))

            local x, y = surface.DrawMulticolorText(weight_source(25), RequestInfoPos - weight_source(25), "Barkentina X20", RequestInfo, weight_source(350))
        end


    end 

    panel_v.dos_show = info
    tables_dos[panel_v.dos_show] = CurTime()
end

function DOS.ShowRemove(panel_v)
    if panel_v.dos_show then 
        panel_v.dos_show:Remove() 
        panel_v.dos_show = nil 
    end
end

hook.Add("HUDPaint", "dos.check", function()
    for k,i in pairs(tables_dos) do 
        if i + 0.1 < CurTime() then 
            k:Remove()
            k = nil 
        end
    end
end)

function surface.DrawMulticolorText(x, y, font, text, maxW)
    surface.SetTextColor(255, 255, 255)
    surface.SetFont(font)
    surface.SetTextPos(x, y)

    local baseX = x
    local w, h = surface.GetTextSize("W")
    local lineHeight = h

    if maxW and x > 0 then
        maxW = maxW + x
    end

    for _, v in ipairs(text) do
        if isstring(v) or isnumber(v)  then
            w, h = surface.GetTextSize(v)

            if maxW and x + w > maxW then
                v:gsub("(%s?[%S]+)", function(word)
                    w, h = surface.GetTextSize(word)

                    if x + w >= maxW then
                        x, y = baseX, y + lineHeight
                        word = word:gsub("^%s+", "")
                        w, h = surface.GetTextSize(word)

                        if x + w >= maxW then
                            word:gsub("[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]*", function(char)
                                w, h = surface.GetTextSize(char)

                                if x + w >= maxW then
                                    x, y = baseX, y + lineHeight
                                end

                                surface.SetTextPos(x, y)
                                surface.DrawText(char)

                                x = x + w
                            end)

                            return
                        end
                    end

                    surface.SetTextPos(x, y)
                    surface.DrawText(word)

                    x = x + w
                end)
            else
                surface.SetTextPos(x, y)
                surface.DrawText(v)

                x = x + w
            end
        elseif isbool(v) then 
            x, y = baseX, y + lineHeight
        elseif IsColor(v) then 
            surface.SetTextColor(v.r, v.g, v.b, v.a)
        end
    end

    return x, y
end