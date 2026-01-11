local standartRunSpeed = 270
local standartWalkSpeed = 180

local function movementControll(ply)
    local speedBuff = ply:GetPerStatus("speed")
    local speed = standartRunSpeed + ((standartRunSpeed / 100) * speedBuff)

    local playerSpeedbuff = ply:GetArmorStat("speed")
    local speed = speed + ((standartRunSpeed / 100) * playerSpeedbuff)

    local speedDebuff = ply:GetPerStatus("debuffspeed")
    local speed = speed - ((speed / 100) * speedDebuff)

    local playerInventory = ply.inventory
    local hasWeapon = playerInventory:GetEquippedItem("weapon")

    if hasWeapon then 
        local bonus = hasWeapon:getMeta("sharpBonus") or nil
        if bonus and bonus["speed"] then 
            speed = speed + sharpBonus["speed"]
        end 
    end

    local weaight = ply.inventory.weight
    local maxWeight = ply:GetWeight()
    if weaight > maxWeight then
        local weaightDebuff = (weaight - maxWeight) * 5
        speed = speed - ((speed / 100) * weaightDebuff)

        local speed2 = standartWalkSpeed - ((standartWalkSpeed / 100) * weaightDebuff)
        ply:SetWalkSpeed(speed2)
    else 
        ply:SetWalkSpeed(standartWalkSpeed)
    end
    if speed < standartRunSpeed then
        local walkSpeed = speed / standartRunSpeed * standartWalkSpeed
        ply:SetWalkSpeed(walkSpeed)
    end 
    if speed <= 0 then
        speed = 1
    end
    ply:SetRunSpeed(speed)
end

timer.Create("dbt/stamina/tick", 0, 0, function() 
    for _, ply in ipairs(player.GetHumans()) do
        if not IsValid(ply) then
            continue
        end
        movementControll(ply)
    end
end)