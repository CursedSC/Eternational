CameraController = {
    targetPos = nil,
    targetAng = nil,
    currentPos = nil,
    currentAng = nil,
    fadeAlpha = 0,
    fadeSpeed = 1,
    lerpSpeed = 5, 
    active = false
}

hook.Add("CalcView", "CustomCameraView", function(ply, pos, ang, fov, znear, zfar)
    if not CameraController.active then return end
    
    if not CameraController.currentPos or not CameraController.currentAng then
        CameraController.currentPos = pos
        CameraController.currentAng = ang
    end

    CameraController.currentPos = LerpVector(FrameTime() * CameraController.lerpSpeed, CameraController.currentPos, CameraController.targetPos)
    CameraController.currentAng = LerpAngle(FrameTime() * CameraController.lerpSpeed, CameraController.currentAng, CameraController.targetAng)

    if CameraController.fadeAlpha > 1 then
        CameraController.fadeAlpha = math.min(255, CameraController.fadeAlpha - FrameTime() * CameraController.fadeSpeed * 255)
    end
    
    return {
        origin = CameraController.currentPos,
        angles = CameraController.currentAng  + Angle(math.sin(CurTime()) * 0.3, math.sin(CurTime()) * 0.3, 0),
        fov = fov,
        znear = znear,
        zfar = zfar,
        drawviewer = true
    }
end)

hook.Add("HUDPaint", "CameraFadeEffect", function()
    if not CameraController.active or !CameraController.fade then return end
    
    surface.SetDrawColor(0, 0, 0, CameraController.fadeAlpha)
    surface.DrawRect(0, 0, ScrW(), ScrH())
    
    if CameraController.fadeAlpha <= 1 then
        CameraController.fadeAlpha = 0 
        CameraController.fade = false
    end
end)

function CameraController.SetTarget(pos, ang)
    CameraController.targetPos = pos
    CameraController.targetAng = ang
    CameraController.fadeAlpha = 255
    CameraController.fade = true
    CameraController.active = true
end

function CameraController.Stop()
    CameraController.active = false
end