AddCSLuaFile()
local meta = FindMetaTable("Player")
meta.Quests = meta.Quests or {
	["Main"] = {},
	["Side"] = {},
	["Pick"] = {},
	["Complete"] = {},
}

netstream.Hook("quests/clientdataupdate", function(data, navigatetype, navigatekey)
	for k, questtype in pairs(meta.Quests) do
		if questtype == "Pick" then continue end
		for key, quest in pairs(questtype) do
			if data[k][key] and navigatetype and meta.Quests[navigatetype][navigatekey] == quest then
				data[k][key].navigate = quest.navigate or false
			end
		end
	end
	meta.Quests = data
end)

concommand.Add('checkdata',function ()
	PrintTable(meta.Quests)
end)

local materials = {
    bg = Material("materials/fantasy/bg.png"),
	tasks = Material("materials/fantasy/questsystem/icon_tasks.png", "smooth"),
	location = Material("materials/fantasy/questsystem/icon_location.png", "smooth"),
	description = Material("materials/fantasy/questsystem/icon_description.png", "smooth"),
	completed = Material("materials/fantasy/questsystem/icon_completed.png", "smooth"),
	navigate = Material("materials/fantasy/questsystem/icon_navigate.png", "smooth"),
}

local questsColors = {
	white = color_white,
	WhiteLowAlpha = Color(255, 255, 255, 255 * 0.6),
	black = color_black,
	BlackLowAlpha = Color(0, 0, 0, 255 * 0.3),
	semiTransparentBlack = Color(0, 0, 0, 255 * 0.5),
	YellowLight = Color(240, 225, 161, 255),
	YellowNotLight = Color(146, 137, 101, 255),
	YellowNotLightLowAlpha = Color(146, 137, 101, 255 * 0.6),
	gray = Color(128, 128, 128, 255),
	GrayLowAlpha = Color(128, 128, 128, 255 * 0.6),
	ButtonMain = Color(0, 0, 0, 255 * 0.33),
	QuestMain = Color(160, 32, 83, 255),
	QuestSide = Color(75, 103, 9, 255),
}

function CreateQuestTypeButtons(panel)
	if IsValid(allquestsbutton) then
		allquestsbutton:Remove()
		mainquestsbutton:Remove()
		sidequestsbutton:Remove()
		completedquestsbutton:Remove()
	end
	surface.SetFont("TL X21")
	local textw, texth = surface.GetTextSize("ВСЕ")
	allquestsbutton = vgui.Create("DButton", panel, "AllQuests")
	allquestsbutton:SetSize(paintLib.WidthSource(39), paintLib.HightSource(texth))
	allquestsbutton:SetPos(paintLib.WidthSource(37), paintLib.HightSource(176) - texth * 0.12)
	allquestsbutton:SetText("")

	local textw, texth = surface.GetTextSize("ОСНОВНЫЕ")
	mainquestsbutton = vgui.Create("DButton", panel, "MainQuests")
	mainquestsbutton:SetSize(paintLib.WidthSource(119), paintLib.HightSource(texth))
	mainquestsbutton:SetPos(paintLib.WidthSource(117), paintLib.HightSource(176) - texth * 0.12)
	mainquestsbutton:SetText("")

	local textw, texth = surface.GetTextSize("ПОБОЧНЫЕ")
	sidequestsbutton = vgui.Create("DButton", panel, "SideQuests")
	sidequestsbutton:SetSize(paintLib.WidthSource(118), paintLib.HightSource(texth))
	sidequestsbutton:SetPos(paintLib.WidthSource(266), paintLib.HightSource(176) - texth * 0.12)
	sidequestsbutton:SetText("")

	local textw, texth = surface.GetTextSize("ВЫПОЛНЕННЫЕ")
	completedquestsbutton = vgui.Create("DButton", panel, "CompletedQuests")
	completedquestsbutton:SetSize(paintLib.WidthSource(164), paintLib.HightSource(texth))
	completedquestsbutton:SetPos(paintLib.WidthSource(415), paintLib.HightSource(176) - texth * 0.12)
	completedquestsbutton:SetText("")
	panel.pickedbtn = allquestsbutton

	allquestsbutton.Paint = function(self, w, h)
		if currentPage != 4 then self:Remove() panel.pickedquest = nil return end
		local color = questsColors.YellowNotLightLowAlpha
		if self:IsHovered() then color = questsColors.YellowNotLight end
		if panel.pickedbtn == self then color = questsColors.YellowLight end
		surface.DrawMulticolorText(paintLib.WidthSource(0), paintLib.HightSource(0), "TL X21", {color, "ВСЕ"})
	end
	mainquestsbutton.Paint = function(self, w, h)
		if currentPage != 4 then self:Remove() panel.pickedquest = nil return end
		local color = questsColors.YellowNotLightLowAlpha
		if self:IsHovered() then color = questsColors.YellowNotLight end
		if panel.pickedbtn == self then color = questsColors.YellowLight end
		surface.DrawMulticolorText(paintLib.WidthSource(0), paintLib.HightSource(0), "TL X21", {color, "ОСНОВНЫЕ"})
	end
	sidequestsbutton.Paint = function(self, w, h)
		if currentPage != 4 then self:Remove() panel.pickedquest = nil return end
		local color = questsColors.YellowNotLightLowAlpha
		if self:IsHovered() then color = questsColors.YellowNotLight end
		if panel.pickedbtn == self then color = questsColors.YellowLight end
		surface.DrawMulticolorText(paintLib.WidthSource(0), paintLib.HightSource(0), "TL X21", {color, "ПОБОЧНЫЕ"})
	end
	completedquestsbutton.Paint = function(self, w, h)
		if currentPage != 4 then self:Remove() panel.pickedquest = nil return end
		local color = questsColors.YellowNotLightLowAlpha
		if self:IsHovered() then color = questsColors.YellowNotLight end
		if panel.pickedbtn == self then color = questsColors.YellowLight end
		surface.DrawMulticolorText(paintLib.WidthSource(0), paintLib.HightSource(0), "TL X21", {color, "ВЫПОЛНЕННЫЕ"})
	end

	allquestsbutton.DoClick = function(self)
		panel.pickedbtn = self
		DrawQuestsFromType(panel, "AllQuests")
	end
	mainquestsbutton.DoClick = function(self)
		panel.pickedbtn = self
		DrawQuestsFromType(panel, "MainQuests")
	end
	sidequestsbutton.DoClick = function(self)
		panel.pickedbtn = self
		DrawQuestsFromType(panel, "SideQuests")
	end
	completedquestsbutton.DoClick = function(self)
		panel.pickedbtn = self
		DrawQuestsFromType(panel, "Complete")
	end
end

local function is_equal(tbl1, tbl2)
	if #tbl1 ~= #tbl2 then return false end

	for i = 1, #tbl1 do
		if tbl1[i] ~= tbl2[i] then return false end
	end

	return true
end
function DrawQuestsFromType(panel, type)
	if IsValid(QuestScrollMainPanel) then QuestScrollMainPanel:Remove() end
	panel.pickedquest = nil
	QuestScrollMainPanel = vgui.Create("DScrollPanel", panel)
	QuestScrollMainPanel:SetSize(paintLib.WidthSource(568), paintLib.HightSource(830))
	QuestScrollMainPanel:SetPos(paintLib.WidthSource(25), paintLib.HightSource(225))
	local List = vgui.Create("DIconLayout", QuestScrollMainPanel)
	local sbar = QuestScrollMainPanel:GetVBar()
	List:Dock(FILL)
	List:SetSpaceY(paintLib.HightSource(13))
	sbar.Paint = function() end
	sbar.btnUp.Paint = function() end
	sbar.btnDown.Paint = function() end
	sbar.btnGrip.Paint = function() end

	local queststodrawmain = meta.Quests["Main"]
	local queststodrawside = meta.Quests["Side"]
	local queststodrawcomplete = meta.Quests["Complete"]
	if type == "AllQuests" then
		DrawQuestButtons(queststodrawmain, List, panel, queststodrawmain, queststodrawside)
		DrawQuestButtons(queststodrawside, List, panel, queststodrawmain, queststodrawside)
	elseif type == "MainQuests" then
		DrawQuestButtons(queststodrawmain, List, panel, queststodrawmain, queststodrawside)
	elseif type == "SideQuests" then
		DrawQuestButtons(queststodrawside, List, panel, queststodrawmain, queststodrawside)
	elseif type == "Complete" then
		DrawQuestButtons(queststodrawcomplete, List, panel, queststodrawmain, queststodrawside, true)
	end
end

function DrawQuestButtons(table, List, panel, queststodrawmain, queststodrawside, iscomplete)
	for k, v in pairs(table) do
		local DButton = List:Add("DButton")
		DButton.IsMain = v.type == "Main"
		DButton:SetText('')
		print('test')
		DButton:SetSize(paintLib.WidthSource(548), paintLib.HightSource(84))
		DButton.data = v
		DButton.num = k

		DButton.Paint = function(self, w, h)
			if currentPage != 4 then self:Remove() return end
			surface.SetDrawColor(questsColors.ButtonMain)
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(self.IsMain and questsColors.QuestMain or questsColors.QuestSide)
			surface.DrawRect(0, 0, paintLib.WidthSource(15), paintLib.HightSource(84))

			surface.DrawMulticolorText(paintLib.WidthSource(33), paintLib.HightSource(16), "TL X21", {questsColors.WhiteLowAlpha, self.data.name})
			surface.DrawMulticolorText(paintLib.WidthSource(31), paintLib.HightSource(50), "TL X21", {questsColors.GrayLowAlpha, 'Локация: '..self.data.location})

			if panel.pickedquest == self then
				surface.DrawOutlinedRect(0, 0, w, h, 2)
			end

			if self.data.navigate then
				surface.SetDrawColor(questsColors.white)
				surface.SetMaterial(materials.navigate)
				surface.DrawTexturedRect(paintLib.WidthSource(490), paintLib.HightSource(19), paintLib.WidthSource(38), paintLib.WidthSource(38))
			end
		end

		DButton.DoClick = function(self)
			if IsValid(ButtonNavigate) then ButtonNavigate:Remove() end
			panel.pickedquest = self
			if iscomplete then return end
			ButtonNavigate = vgui.Create("DButton", panel)
			ButtonNavigate:SetSize(paintLib.WidthSource(356), paintLib.HightSource(55))
			ButtonNavigate:SetPos(paintLib.WidthSource(1547), paintLib.HightSource(1009))
			ButtonNavigate:SetFont('TL X24')
			ButtonNavigate:SetText(self.data.navigate and "ПРЕКРАТИТЬ ОТСЛЕЖИВАТЬ" or "ОТСЛЕЖИВАТЬ")
			ButtonNavigate:SetTextColor(questsColors.white)
			ButtonNavigate.Paint = function(selfnavig, w, h)
				surface.SetDrawColor(questsColors.BlackLowAlpha)
				surface.DrawRect(0, 0, w, h)
			end
			ButtonNavigate.DoClick = function(selfnavig, w, h)
				for a, b in pairs(queststodrawmain) do
					if b.navigate and b != self.data then
						b.navigate = false
					end
				end
				for a, b in pairs(queststodrawside) do
					if b.navigate and b != self.data then
						b.navigate = false
					end
				end
				self.data.navigate = not self.data.navigate
				netstream.Start("questsystem/setnavigate", self.data.type, self.num)
				ButtonNavigate:SetText(self.data.navigate and "ПРЕКРАТИТЬ ОТСЛЕЖИВАТЬ" or "ОТСЛЕЖИВАТЬ")
			end

			ButtonNavigate.Think = function(selfnavig)
				if not panel.pickedquest then selfnavig:Remove() return end
			end
		end
	end
end
