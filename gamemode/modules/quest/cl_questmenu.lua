AddCSLuaFile()
/*
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
	local allbutton = vgui.Create("DButton", panel, "AllQuests")
	allbutton:SetSize(paintLib.WidthSource(39), paintLib.HightSource(20))
	allbutton:SetPos(paintLib.WidthSource(37), paintLib.HightSource(176))
	allbutton:SetText("")
	local mainbutton = vgui.Create("DButton", panel, "MainQuests")
	mainbutton:SetSize(paintLib.WidthSource(119), paintLib.HightSource(20))
	mainbutton:SetPos(paintLib.WidthSource(117), paintLib.HightSource(176))
	mainbutton:SetText("")
	local sidequestsbutton = vgui.Create("DButton", panel, "SideQuests")
	sidequestsbutton:SetSize(paintLib.WidthSource(118), paintLib.HightSource(20))
	sidequestsbutton:SetPos(paintLib.WidthSource(266), paintLib.HightSource(176))
	sidequestsbutton:SetText("")
	local completedquestsbutton = vgui.Create("DButton", panel, "CompletedQuests")
	completedquestsbutton:SetSize(paintLib.WidthSource(164), paintLib.HightSource(20))
	completedquestsbutton:SetPos(paintLib.WidthSource(415), paintLib.HightSource(176))
	completedquestsbutton:SetText("")
	panel.pickedbtn = allbutton

	allbutton.Paint = function(self, w, h)
		if currentPage != 4 then self:Remove() return end
		local color = questsColors.YellowNotLightLowAlpha
		if self:IsHovered() then color = questsColors.YellowNotLight end
		if panel.pickedbtn == self then color = questsColors.YellowLight end
		surface.DrawMulticolorText(paintLib.WidthSource(0), paintLib.HightSource(0), "TL X21", {color, "ВСЕ"})
	end
	mainbutton.Paint = function(self, w, h)
		if currentPage != 4 then self:Remove() return end
		local color = questsColors.YellowNotLightLowAlpha
		if self:IsHovered() then color = questsColors.YellowNotLight end
		if panel.pickedbtn == self then color = questsColors.YellowLight end
		surface.DrawMulticolorText(paintLib.WidthSource(0), paintLib.HightSource(0), "TL X21", {color, "ОСНОВНЫЕ"})
	end
	sidequestsbutton.Paint = function(self, w, h)
		if currentPage != 4 then self:Remove() return end
		local color = questsColors.YellowNotLightLowAlpha
		if self:IsHovered() then color = questsColors.YellowNotLight end
		if panel.pickedbtn == self then color = questsColors.YellowLight end
		surface.DrawMulticolorText(paintLib.WidthSource(0), paintLib.HightSource(0), "TL X21", {color, "ПОБОЧНЫЕ"})
	end
	completedquestsbutton.Paint = function(self, w, h)
		if currentPage != 4 then self:Remove() return end
		local color = questsColors.YellowNotLightLowAlpha
		if self:IsHovered() then color = questsColors.YellowNotLight end
		if panel.pickedbtn == self then color = questsColors.YellowLight end
		surface.DrawMulticolorText(paintLib.WidthSource(0), paintLib.HightSource(0), "TL X21", {color, "ВЫПОЛНЕННЫЕ"})
	end

	allbutton.DoClick = function(self)
		panel.pickedbtn = self
		DrawQuestsFromType(panel, "AllQuests")
	end
	mainbutton.DoClick = function(self)
		panel.pickedbtn = self
		DrawQuestsFromType(panel, "MainQuests")
	end
	sidequestsbutton.DoClick = function(self)
		panel.pickedbtn = self
		DrawQuestsFromType(panel, "SideQuests")
	end
	completedquestsbutton.DoClick = function(self)
		panel.pickedbtn = self
		DrawQuestsFromType(panel, "CompletedQuests")
	end
end

function DrawQuestsFromType(panel, type)
	if IsValid(QuestScrollMainPanel) then QuestScrollMainPanel:Remove() end
	panel.pickedquest = nil
	cl_RefreshQuests()
	QuestScrollMainPanel = vgui.Create("DScrollPanel", panel)
	QuestScrollMainPanel:SetSize(paintLib.WidthSource(568), paintLib.HightSource(830))
	QuestScrollMainPanel:SetPos(paintLib.WidthSource(25), paintLib.HightSource(225))
	local List = vgui.Create("DIconLayout", QuestScrollMainPanel)
	List:Dock(FILL)
	List:SetSpaceY(paintLib.HightSource(13))

	local queststodraw = {}
	if type == "AllQuests" then
		for k, v in pairs(listquests) do
			if v.iscompleted then continue end
			queststodraw[#queststodraw + 1] = v
		end
	elseif type == "MainQuests" then
		for k, v in pairs(listquests) do
			if not v.main or v.iscompleted then continue end
			queststodraw[#queststodraw + 1] = v
		end
	elseif type == "SideQuests" then
		for k, v in pairs(listquests) do
			if v.main or v.iscompleted then continue end
			queststodraw[#queststodraw + 1] = v
		end
	elseif type == "CompletedQuests" then
		for k, v in pairs(listquests) do
			if not v.iscompleted then continue end
			queststodraw[#queststodraw + 1] = v
		end
	end

	if not queststodraw then return end

	for k, v in pairs(queststodraw) do
		local DButton = List:Add("DButton")
		DButton.IsMain = v.main
		DButton:SetText('')
		DButton:SetSize(paintLib.WidthSource(548), paintLib.HightSource(84))
		DButton.data = v

		DButton.Paint = function(self, w, h)
			if currentPage != 4 then self:Remove() return end
			if self.IsMain then
				surface.SetDrawColor(questsColors.ButtonMain)
				surface.DrawRect(0, 0, w, h)
				surface.SetDrawColor(questsColors.QuestMain)
				surface.DrawRect(0, 0, paintLib.WidthSource(15), paintLib.HightSource(84))

				surface.DrawMulticolorText(paintLib.WidthSource(33), paintLib.HightSource(16), "TL X21", {questsColors.WhiteLowAlpha, self.data.questname})
				surface.DrawMulticolorText(paintLib.WidthSource(31), paintLib.HightSource(50), "TL X21", {questsColors.GrayLowAlpha, 'Локация: '..self.data.location})

				if panel.pickedquest == self then
					surface.DrawOutlinedRect(0, 0, w, h, 2)
				end

				if listquests[k].navigate then
					surface.SetDrawColor(questsColors.white)
					surface.SetMaterial(materials.navigate)
					surface.DrawTexturedRect(paintLib.WidthSource(490), paintLib.HightSource(23), paintLib.WidthSource(38), paintLib.HightSource(38))
				end
			else
				surface.SetDrawColor(questsColors.ButtonMain)
				surface.DrawRect(0, 0, w, h)
				surface.SetDrawColor(questsColors.QuestSide)
				surface.DrawRect(0, 0, paintLib.WidthSource(15), paintLib.HightSource(84))

				surface.DrawMulticolorText(paintLib.WidthSource(33), paintLib.HightSource(16), "TL X21", {questsColors.WhiteLowAlpha, self.data.questname})
				surface.DrawMulticolorText(paintLib.WidthSource(31), paintLib.HightSource(50), "TL X21", {questsColors.GrayLowAlpha, 'Локация: '..self.data.location})
				if panel.pickedquest == self then
					surface.DrawOutlinedRect(0, 0, w, h, 2)
				end
				if listquests[k].navigate then
					surface.SetDrawColor(questsColors.white)
					surface.SetMaterial(materials.navigate)
					surface.DrawTexturedRect(paintLib.WidthSource(490), paintLib.HightSource(23), paintLib.WidthSource(38), paintLib.HightSource(38))
				end
			end
		end

		DButton.DoClick = function(self)
			if IsValid(ButtonNavigate) then ButtonNavigate:Remove() end
			panel.pickedquest = self
			ButtonNavigate = vgui.Create("DButton", panel)
			ButtonNavigate:SetSize(paintLib.WidthSource(356), paintLib.HightSource(55))
			ButtonNavigate:SetPos(paintLib.WidthSource(1547), paintLib.HightSource(1009))
			ButtonNavigate:SetFont('TL X24')
			ButtonNavigate:SetText(listquests[k].navigate and "ПРЕКРАТИТЬ ОТСЛЕЖИВАТЬ" or "ОТСЛЕЖИВАТЬ")
			ButtonNavigate:SetTextColor(questsColors.white)
			ButtonNavigate.Paint = function(selfnavig, w, h)
				surface.SetDrawColor(questsColors.BlackLowAlpha)
				surface.DrawRect(0, 0, w, h)
			end
			ButtonNavigate.DoClick = function(selfnavig, w, h)
				for a, b in pairs(listquests) do
					if b.navigate and b != listquests[k] then
						b.navigate = false
					end
				end
				listquests[k].navigate = not listquests[k].navigate
				ButtonNavigate:SetText(listquests[k].navigate and "ПРЕКРАТИТЬ ОТСЛЕЖИВАТЬ" or "ОТСЛЕЖИВАТЬ")
			end

			ButtonNavigate.Think = function(selfnavig)
				if not panel.pickedquest then selfnavig:Remove() return end
			end
		end
	end
end

function DrawQuestMenu()
	local DFrame = vgui.Create("DFrame")
	DFrame:SetSize(paintLib.WidthSource(1920), paintLib.HightSource(1080))
	DFrame:MakePopup()
	DFrame.Paint = function(self, w, h)
		paintLib.DrawRect(materials.bg, 0, 0, w, h, questsColors.white)
		draw.RoundedBox(0, 0, 0, w, paintLib.HightSource(93), questsColors.semiTransparentBlack)

		-- main menu start --
		surface.SetDrawColor(questsColors.BlackLowAlpha)
		surface.DrawRect(paintLib.WidthSource(16), paintLib.HightSource(106), paintLib.WidthSource(586), paintLib.HightSource(957))
		surface.DrawRect(paintLib.WidthSource(16), paintLib.HightSource(163), paintLib.WidthSource(586), paintLib.HightSource(44))
		surface.DrawMulticolorText(paintLib.WidthSource(165), paintLib.HightSource(124), "TL X28", {questsColors.WhiteLowAlpha, "СПИСОК КВЕСТОВ"})
		-- main menu end --

		-- number quests start --
		surface.DrawMulticolorText(paintLib.WidthSource(79), paintLib.HightSource(169), "TL X14", {questsColors.YellowNotLight, tostring(table.Count(listquests))})
		local mainquests = 0
		local sidequests = 0
		local completedquests = 0
		for k, v in pairs(listquests) do
			if v.main and not v.iscompleted then mainquests = mainquests + 1 end
			if not v.main and not v.iscompleted then sidequests = sidequests + 1 end
			if v.iscompleted then completedquests = completedquests + 1 end
		end
		surface.DrawMulticolorText(paintLib.WidthSource(235), paintLib.HightSource(169), "TL X14", {questsColors.YellowNotLight, tostring(mainquests)})
		surface.DrawMulticolorText(paintLib.WidthSource(381), paintLib.HightSource(169), "TL X14", {questsColors.YellowNotLight, tostring(sidequests)})
		surface.DrawMulticolorText(paintLib.WidthSource(577), paintLib.HightSource(169), "TL X14", {questsColors.YellowNotLight, tostring(completedquests)})
		-- number quests end --

		-- quest description start --
		if self.pickedquest then
			local width, height = surface.DrawMulticolorText(0, 0, "TL X18", {Color(0, 0, 0, 0), self.pickedquest.data.description}, paintLib.WidthSource(1200))
			surface.DrawRect(paintLib.WidthSource(622), paintLib.HightSource(106), paintLib.WidthSource(1284), paintLib.HightSource(887))
			surface.SetFont("TL X30")
			local x, y = surface.GetTextSize(self.pickedquest.data.questname)
			surface.DrawMulticolorText(paintLib.WidthSource(1261) - x*0.5, paintLib.HightSource(132), "TL X30", {questsColors.WhiteLowAlpha, self.pickedquest.data.questname})
			surface.SetFont("TL X18")
			local x, y = self.pickedquest.data.main and surface.GetTextSize('ОСНОВНОЙ КВЕСТ') or surface.GetTextSize('ПОБОЧНЫЙ КВЕСТ')
			surface.DrawMulticolorText(paintLib.WidthSource(1261) - x*0.5, paintLib.HightSource(169), "TL X18", {self.pickedquest.data.main and questsColors.QuestMain or questsColors.QuestSide, self.pickedquest.data.main and "ОСНОВНОЙ КВЕСТ" or "ПОБОЧНЫЙ КВЕСТ"})

			surface.SetDrawColor(questsColors.white)
			surface.SetMaterial(materials.tasks)
			surface.DrawTexturedRect(paintLib.WidthSource(665), paintLib.HightSource(217), paintLib.WidthSource(25), paintLib.HightSource(25))
			surface.DrawMulticolorText(paintLib.WidthSource(705), paintLib.HightSource(219), "TL X18", {questsColors.WhiteLowAlpha, "ЗАДАНИЯ"})
			surface.SetDrawColor(questsColors.ButtonMain)
			local i = 0
			for k, v in pairs(self.pickedquest.data.tasks) do
				local posy = paintLib.HightSource(250) + paintLib.HightSource(55)*i
				surface.DrawRect(paintLib.WidthSource(651), posy, paintLib.WidthSource(586), paintLib.HightSource(44))
				surface.DrawRect(paintLib.WidthSource(1244), posy, paintLib.WidthSource(67), paintLib.HightSource(44))
				local x, y = surface.GetTextSize(v.name)
				surface.DrawMulticolorText(paintLib.WidthSource(672), posy + y*0.8, "TL X18", {v.amount == v.need and questsColors.YellowLight or questsColors.gray, v.name})
				local x, y = surface.GetTextSize(''..v.amount..'/'..v.need)
				surface.DrawMulticolorText(paintLib.WidthSource(1265), posy + y*0.8, "TL X18", {v.amount == v.need and questsColors.YellowLight or questsColors.gray, ''..v.amount..'/'..v.need})

				i = i + 1
			end

			surface.SetDrawColor(questsColors.white)
			surface.SetMaterial(materials.location)
			surface.DrawTexturedRect(paintLib.WidthSource(665), paintLib.HightSource(255) + paintLib.HightSource(55)*i, paintLib.WidthSource(25), paintLib.HightSource(25))
			surface.DrawMulticolorText(paintLib.WidthSource(705), paintLib.HightSource(260) + paintLib.HightSource(55)*i, "TL X18", {questsColors.WhiteLowAlpha, "ЛОКАЦИЯ"})
			surface.SetDrawColor(questsColors.ButtonMain)
			surface.DrawRect(paintLib.WidthSource(651), paintLib.HightSource(293) + paintLib.HightSource(55)*i, paintLib.WidthSource(1227), paintLib.HightSource(45))
			local x, y = surface.GetTextSize(self.pickedquest.data.location)
			surface.DrawMulticolorText(paintLib.WidthSource(672), paintLib.HightSource(293) + paintLib.HightSource(55)*i + y*0.8, "TL X18", {questsColors.GrayLowAlpha, self.pickedquest.data.location})

			surface.SetDrawColor(questsColors.white)
			surface.SetMaterial(materials.description)
			surface.DrawTexturedRect(paintLib.WidthSource(665), paintLib.HightSource(364) + paintLib.HightSource(55)*i, paintLib.WidthSource(22), paintLib.HightSource(27))
			surface.DrawMulticolorText(paintLib.WidthSource(705), paintLib.HightSource(369) + paintLib.HightSource(55)*i, "TL X18", {questsColors.WhiteLowAlpha, "ПОДРОБНОСТИ"})
			surface.SetDrawColor(questsColors.ButtonMain)
			surface.DrawRect(paintLib.WidthSource(651), paintLib.HightSource(400) + paintLib.HightSource(55)*i, paintLib.WidthSource(1227), paintLib.HightSource(40) + height)
			local width, height = surface.DrawMulticolorText(paintLib.WidthSource(661), paintLib.HightSource(410) + paintLib.HightSource(55)*i, "TL X18", {questsColors.GrayLowAlpha, self.pickedquest.data.description}, paintLib.WidthSource(1200))
		end
		-- quest description end --
	end

	CreateQuestTypeButtons(DFrame)
	DrawQuestsFromType(DFrame, "AllQuests")
end*/
