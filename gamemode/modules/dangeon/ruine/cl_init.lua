RUIN_DUNGEON_ENTRY_BOX = {
    Vector("-10333.899414063 -8508.2255859375 -954.31567382813"),
    Vector("-9232.2353515625 -7286.712890625 -282.54217529297"),
}

RUIN_DUNGEON_DOOR_ID = 68604

-- Fog variables
local fogDensity = 0
local targetDensity = 0
local fogColor = Color(77, 77, 77) -- Black fog
local fogLerpSpeed = 2 -- Speed of transition

-- Function to check if a point is inside a box defined by two corners
local function IsInBox(pos, corner1, corner2)
    local minX = math.min(corner1.x, corner2.x)
    local minY = math.min(corner1.y, corner2.y)
    local minZ = math.min(corner1.z, corner2.z)
    
    local maxX = math.max(corner1.x, corner2.x)
    local maxY = math.max(corner1.y, corner2.y)
    local maxZ = math.max(corner1.z, corner2.z)
    
    return pos.x >= minX and pos.x <= maxX and
           pos.y >= minY and pos.y <= maxY and
           pos.z >= minZ and pos.z <= maxZ
end
--[[
-- Check if player is in the dungeon box and update fog
hook.Add("Think", "RuinDungeonFogCheck", function()
    local ply = LocalPlayer()
    if !IsValid(ply) then return end
    
    local pos = ply:GetPos()
    
    -- Check if player is in the dungeon entry box
    local inBox = IsInBox(pos, RUIN_DUNGEON_ENTRY_BOX[1], RUIN_DUNGEON_ENTRY_BOX[2])
    local inDungeon = ply:GetNWBool("InDangeon", false)
    local checked = inBox and !inDungeon
    
    -- Set target density based on position
    targetDensity = checked and 1 or 0
    
    -- Lerp current density to target
    fogDensity = Lerp(FrameTime() * fogLerpSpeed, fogDensity, targetDensity)
end)

-- Apply the fog effect
hook.Add("SetupWorldFog", "RuinDungeonFog", function()
    if fogDensity > 0.01 then
        render.FogMode(MATERIAL_FOG_LINEAR)
        render.FogStart(0)
        render.FogEnd(200 * fogDensity)
        render.FogMaxDensity(fogDensity)
        
        render.FogColor(fogColor.r, fogColor.g, fogColor.b)
        
        return true
    end
    return false
end) 

-- Apply fog to skybox for consistency
hook.Add("SetupSkyboxFog", "RuinDungeonSkyboxFog", function(scale)
    if fogDensity > 0.01 then
        render.FogMode(MATERIAL_FOG_LINEAR)
        render.FogStart(0)
        render.FogEnd(200 * fogDensity)

        
        render.FogColor(fogColor.r, fogColor.g, fogColor.b)
        
        return true
    end
    return false
end)]]