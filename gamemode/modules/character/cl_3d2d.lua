local doing = true
local distance_draw = 300

hook.Add("PostPlayerDraw", "dbt.drawNicks", function(player)
    local localPlayer = LocalPlayer()
    local distance = player:GetPos():Distance(localPlayer:GetPos())

    if player == LocalPlayer() or
       not player:Alive() or
       distance >= distance_draw
    then
        return
    end

    local alpha = math.max((distance_draw - distance) / 100, 0) * 255
    local alpha2 = math.max((distance_draw - distance) / 100, 0) * 100
    local drawColor = Color(255, 255, 255, alpha)
    local drawColor2 = Color(211, 211, 211, alpha2)
    local boneNumber = player:LookupBone("ValveBiped.Bip01_Head1")

    if not boneNumber then
        return
    end

    cam.Start3D2D(player:GetBonePosition(boneNumber) + Vector(0, 0, 15), Angle(0, RenderAngles().y - 90, 90), 0.1)

        draw.SimpleText((player:GetName()), "TLP X20", 0, 0, drawColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("#0", "TLP X15", 0, 30, drawColor2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        if player:IsSpeaking() then
            draw.SimpleText("Говорит...", "TLP X20", 0, -30 * 1.25, drawColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    cam.End3D2D()
end)
