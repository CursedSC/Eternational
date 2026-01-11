netstream.Hook("fnt/hello", function(ply)
	ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_WAVE, true)
end)
 
UsePlayerOptions = {
	[1] = {
		name = "Толкнуть",
		mat = http.Material("https://imgur.com/oRAepPx.png"),
		func = function()
			netstream.Start("PushPlayer", TargetPlayer)
		end,
	},
	[2] = {
		name = "Пожать руку",
		mat = http.Material("https://imgur.com/lbhKRs1.png"),
		func = function() 
			netstream.Start("fnt/acquaintance", TargetPlayer)
		end,
	},
}

netstream.Hook("OpenActionMenu", function(pl, addTable)
	TargetPlayer = pl
	local tablesend = table.Copy(UsePlayerOptions)
	if addTable.inviteOption then
		table.insert(tablesend, {
			name = "Инвайт",
			--mat = http.Material("https://imgur.com/1Z2Z2Zz.png"),
			func = function()
				netstream.Start("fantasy/fraction/invite", TargetPlayer)
			end,
		})
	end

	NewWheel(tablesend)
end)

