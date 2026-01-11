
CreateClientConVar("iv_status", "1", true, true)
CreateClientConVar("iv_viewsmooth", "0.2", true, true)

CreateClientConVar("iv_crosshair", "1", true, true)
CreateClientConVar("iv_in_r", "255", true, true)
CreateClientConVar("iv_in_g", "255", true, true)
CreateClientConVar("iv_in_b", "255", true, true)
CreateClientConVar("iv_in_a", "150", true, true)
CreateClientConVar("iv_out_r", "0", true, true)
CreateClientConVar("iv_out_g", "0", true, true)
CreateClientConVar("iv_out_b", "0", true, true)
CreateClientConVar("iv_out_a", "125", true, true)

CreateClientConVar("iv_znear", "0.4", true, true)
CreateClientConVar("iv_pitchlock", "1", true, true)
CreateClientConVar("iv_pitchlock_max", "65", true, true)

local ViewOffsetUp = 0
local ViewOffsetForward = 3
local ViewOffsetForward2 = 0
local ViewOffsetLeftRight = 0
local RollDependency = 0.1
local CurView = nil
local holdType
local traceHit = false
local eyeAt, forwardVec, FT, EA, wep, ply
local view = {}

local function IFPP_ShouldDrawLocalPlayer()
    if GetConVarNumber("iv_status") > 0 then
        
        if (not traceHit and not LocalPlayer():InVehicle()) or not traceHit then
            return true
        end
    end
end

hook.Add("ShouldDrawLocalPlayer", "IFPP_ShouldDrawLocalPlayer", IFPP_ShouldDrawLocalPlayer)

local mapp, mclamp = math.Approach, math.Clamp
local FVec = Vector(0, 0, 0)

local function FirstPersonPerspective(ply, pos, angles, fov)
    eyeAtt = ply:GetAttachment(ply:LookupAttachment("eyes"))
    forwardVec = ply:GetAimVector()
    FT = FrameTime()
    EA = ply:EyeAngles()
    wep = ply:GetActiveWeapon()
    
    if !isFPVEnable() or not ply:Alive() or (traceHit and not ply:InVehicle()) or not eyeAtt then
        return
    end
    
    if not CurView then
        CurView = angles
    else
        CurView = LerpAngle(mclamp(FT * (35 * (1 - mclamp(GetConVarNumber("iv_viewsmooth"), 0, 0.8))), 0, 1), CurView, angles + Angle(0, 0, eyeAtt.Ang.r * RollDependency))
    end
    
    if IsValid(wep) then
        holdType = wep:GetHoldType()
    else
        holdType = "normal"
    end
    
    if holdType then
        if holdType == "smg" or holdType == "ar2" or holdType == "rpg" then
            ViewOffsetLeftRight = mapp(ViewOffsetLeftRight, -1, 0.5)
        else
            ViewOffsetLeftRight = mapp(ViewOffsetLeftRight, 0, 0.5)
        end
    else
        ViewOffsetLeftRight = mapp(ViewOffsetLeftRight, 0, 0.5)
    end
    
    if ply:WaterLevel() >= 3 then
        ViewOffsetUp = mapp(ViewOffsetUp, 0, 0.5)
        ViewOffsetForward = mapp(ViewOffsetForward, 8, 0.5)
        RollDependency = Lerp(mclamp(FT * 15, 0, 1), RollDependency, 0.15)
    else
        ViewOffsetUp = mapp(ViewOffsetUp, mclamp(EA.p * -0.1, 0, 10), 0.5)
        ViewOffsetForward = mapp(ViewOffsetForward, 2 + mclamp(EA.p * 0.1, 0, 5), 0.5)
        RollDependency = Lerp(mclamp(FT * 15, 0, 1), RollDependency, 0.05)
    end
    
    if ply:InVehicle() then
        ViewOffsetForward2 = 2
    else
        ViewOffsetForward2 = 0
    end
    
    if eyeAtt then
        FVec.x = forwardVec.x * (ViewOffsetForward + ViewOffsetForward2)
        FVec.y = forwardVec.y * (ViewOffsetForward + ViewOffsetForward2)
        FVec.z = ViewOffsetUp
        FVec = FVec + ply:GetRight() * ViewOffsetLeftRight
        
        view.origin = eyeAtt.Pos + FVec
        view.angles = CurView
        view.fov = fov
        view.znear = mclamp(GetConVarNumber("iv_znear"), 0.1, 1)
            
        return GAMEMODE:CalcView(ply, view.origin, view.angles, view.fov, view.znear)
    end
end

hook.Add("CalcView", "FirstPersonPerspective", FirstPersonPerspective)

local IN_R, IN_G, IN_B, IN_A, OUT_R, OUT_G, OUT_B, OUT_A, tr, pos
local td = {}

local function IFPP_DotCrosshair()
    ply = LocalPlayer()

    if isFPVEnable() or not ply:Alive() or traceHit then
        return
    end
    
    IN_R = GetConVarNumber("iv_in_r")
    IN_G = GetConVarNumber("iv_in_g")
    IN_B = GetConVarNumber("iv_in_b")
    IN_A = GetConVarNumber("iv_in_a")
    
    OUT_R = GetConVarNumber("iv_out_r")
    OUT_G = GetConVarNumber("iv_out_g")
    OUT_B = GetConVarNumber("iv_out_b")
    OUT_A = GetConVarNumber("iv_out_a")
    
    td.start = ply:GetShootPos()
    td.endpos = td.start + ply:GetAimVector() * 3000
    td.filter = ply
    
    tr = util.TraceLine(td)
    pos = tr.HitPos:ToScreen()
        
    surface.SetDrawColor(OUT_R, OUT_G, OUT_B, OUT_A)
    surface.DrawRect(pos.x - 2, pos.y - 1, 5, 5)
    
    surface.SetDrawColor(IN_R, IN_G, IN_B, IN_A)
    surface.DrawRect(pos.x - 1, pos.y, 3, 3)
end

hook.Add("HUDPaint", "IFPP_DotCrosshair", IFPP_DotCrosshair)

local function IFPP_PrePlayerDraw(pl)
    ply = LocalPlayer()
    
    if cam_type == 2 or not ply:Alive() then
        return
    end
    
    EA = ply:GetRenderAngles()
    EA.y = ply:EyeAngles().y
    ply:SetRenderAngles(EA)
    ply:SetPoseParameter("aim_yaw", 0.5)
    ply:SetPoseParameter("body_yaw", 0.5)
    ply:SetPoseParameter("head_yaw", 0.5)
end

hook.Add("PrePlayerDraw", "PrePlayerDraw", IFPP_PrePlayerDraw)

local Vec001, Vec1 = Vector(0.001, 0.001, 0.001), Vector(1, 1, 1)

local function IFPP_Think()
    ply = LocalPlayer()
    
    if not ply:Alive() then
        return
    end
    local bone = ply:LookupBone("ValveBiped.Bip01_Head1")
    if not bone then return end
    if isFPVEnable() then
        ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_Head1"), Vec001)
        
        if eyeAtt then
            forwardVec = ply:GetAimVector()
            forwardVec.z = 0 -- by getting only the X and Y values, I can get what's ahead of the player, and not up/down, because other methods seem to fail.
            
            td.start = eyeAtt.Pos
            td.endpos = td.start + forwardVec * 20
            td.filter = ply
            
            tr = util.TraceLine(td)
            
            if tr.Hit then
                traceHit = true
            else
                traceHit = false
            end
        end
    else
        ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_Head1"), Vec1)
    end
end

hook.Add("Think", "IFPP_Think", IFPP_Think)

local function IFPP_SetupMove(ucmd)
    if isFPVEnable() or GetConVarNumber("iv_pitchlock") <= 0 or not LocalPlayer():Alive() then
        return
    end
    
    EA = ucmd:GetViewAngles()
    ucmd:SetViewAngles(Angle(math.min(EA.p, mclamp(GetConVarNumber("iv_pitchlock_max"), 65, 89)), EA.y, EA.r))
end

hook.Add("CreateMove", "IFPP_SetupMove", IFPP_SetupMove)