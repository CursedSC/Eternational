paintLib = paintLib or {}
local standartColor = Color(255,255,255)

// Fonts

paintLib.DrawRect = function(mat, x, y, w, h, col)
    local col = col or standartColor
    surface.SetDrawColor( col )
    surface.SetMaterial( mat )
    surface.DrawTexturedRect(x, y, w, h)
end

paintLib.DrawRectR = function(mat, x, y, w, h, r, col)
    local col = col or standartColor
    surface.SetDrawColor( col )
    surface.SetMaterial( mat )
    surface.DrawTexturedRectRotated(x, y, w, h, r)
end

function paintLib.WidthSource(x, custom)
    local a = custom or 1920
    return ScrW() / a  * x
end

function paintLib.HightSource(x, custom)
    local a = custom or 1080
    return ScrH() / a  * x
end

function paintLib.Color(r, g, b, a)
    r = r < 90 and (0.916 * r + 7.8252) or r
    g = g < 90 and (0.916 * g + 7.8252) or g
    b = b < 90 and (0.916 * b + 7.8252) or b
    return Color(r, g, b, a)
end

-- WORKER 0.625

for k = 1, 128 do
	surface.CreateFont( "ClassRoomCursiveSwash X"..k, {
		font = "ClassRoomCursiveSwash",
		extended = true,
		size =  math.floor(paintLib.WidthSource(k) * 1.625),
		weight = paintLib.WidthSource(400),
	} )
end


local lerpCounter = 0
local timerList = {}
paintLib.CreateLerp = function(time, callback)
    lerpCounter = lerpCounter + 1
    timerList[lerpCounter] = {
        timeEnd = time + CurTime(),
        time = time,
        callback = callback
    }
    return lerpCounter
end

paintLib.GetLerp = function(id)
    if !timerList[id] then return 1 end
    local info = timerList[id]
    local timeLeft = info.timeEnd - CurTime()
    local x = timeLeft / info.time
    return 1 - x
end

paintLib.LerpExist = function(id)
    return timerList[id]
end

paintLib.StartStencil = function()
	render.SetStencilWriteMask( 0xFF )
	render.SetStencilTestMask( 0xFF )
	render.SetStencilReferenceValue( 0 )
	render.SetStencilPassOperation( STENCIL_KEEP )
	render.SetStencilZFailOperation( STENCIL_KEEP )
	render.ClearStencil()


	render.SetStencilEnable( true )
	render.SetStencilReferenceValue( 1 )
	render.SetStencilCompareFunction( STENCIL_NEVER )
	render.SetStencilFailOperation( STENCIL_REPLACE )
end

paintLib.ApllyStencil = function()
	render.SetStencilCompareFunction( STENCIL_EQUAL )
	render.SetStencilFailOperation( STENCIL_KEEP )
end


local listOfCircles = {}
function paintLib.Circle( x, y, radius, seg, bNotUseList )
    local uid = x.."_"..y.."_"..radius.."_"..seg
    local cir = {}
    if listOfCircles[uid] and !bNotUseList then 
        cir = listOfCircles[uid]
    else
	    table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	    for i = 0, seg do
	    	local a = math.rad( ( i / seg ) * -360 )
	    	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	    end

	    local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	    table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

        listOfCircles[uid] = cir
    end
	surface.DrawPoly( cir )
end

hook.Add("HUDPaint", "paintLib.lerp", function()
    for k, i in pairs(timerList) do
        if CurTime() > i.timeEnd then  if i.callback then i.callback() end timerList[k] = nil end
    end
end)
--[[
local old_Material = Material
local chacheMats = {}
function Material(path, pngParameters)
	pngParameters = pngParameters or ""
	if chacheMats[path.."_"..pngParameters] then return chacheMats[path.."_"..pngParameters] end 
	chacheMats[path.."_"..pngParameters] = old_Material(path, pngParameters)
	return chacheMats[path.."_"..pngParameters]
end]]

--https://imgur.com/5RvzzJp.png
file.CreateDir("dbt-material")

local httpMaterial = {}
httpMaterial.__index = httpMaterial

function httpMaterial:Init(url, flags, ttl)
	ttl = ttl or 86400
	url = url:gsub("cdn.discordapp.com", "media.discordapp.net")
	local fname = url:match("([^/]+)$"):gsub("[&?]([^/%s]+)=([^/%s]+)", "")
	if fname:match("^.+(%..+)$") == nil then
		fname = fname ..".png"
	end

	local uid = util.CRC(url)  .."_".. fname
	local path = "dbt-material/".. uid

	if file.Exists(path, "DATA") and file.Time(path, "DATA") + ttl > os.time() then
		self.material = Material("data/".. path, flags)
	else
		self:Download(url, function(succ, result)
			if succ then
				file.Write(path, result)
				self.material = Material("data/".. path, flags)
			else
				--ErrorNoHalt(string.format("Cant download http-material! Url: %s, reason: %s\n", url, reason))

				url = "https://proxy.duckduckgo.com/iu/?u=".. url
				self:Download(url, function(succ, result)
					if succ then
						file.Write(path, result)
						self.material = Material("data/".. path, flags)
					else
						--ErrorNoHalt(string.format("Cant download http-material! Url: %s, reason: %s\n", url, reason))
						self.material = Material("error")
					end
				end)
			end
		end)
	end
end

function httpMaterial:Download(url, cback, retry)
	retry = retry or 3
	if retry <= 0 then return cback(false, "retry") end

	http.Fetch(url, function(raw, _, _, code)
		if not raw or raw == "" or code ~= 200 or raw:find("<!DOCTYPE HTML>", 1, true) then
			--self:Download(url, cback, retry - 1)
			return
		end

		cback(true, raw)
	end, function(err)
		cback(false, err)
	end)
end

function httpMaterial:GetMaterial()
	return self.material
end

function httpMaterial:Draw(x, y, w, h)
	if self.material == nil then return end
	surface.SetMaterial(self.material)
	surface.DrawTexturedRect(x, y, w, h)
end

function httpMaterial:DrawR(x, y, w, h, r)
	if self.material == nil then return end
	surface.SetMaterial(self.material)
	surface.DrawTexturedRectRotated(x, y, w, h, r)
end

setmetatable(httpMaterial, {
	__call = httpMaterial.Draw
})

function HTTP_IMG(url, flags)
	local instance = setmetatable({}, httpMaterial)
	instance:Init(url, flags)
	return instance
end


function surface.DrawMulticolorText2(x, y, font, text, maxW)
	surface.SetTextColor(255, 255, 255)
	surface.SetFont(font)
	surface.SetTextPos(x, y)
	local baseX = x
	local w, h = surface.GetTextSize("W")
	local lineHeight = h * 0.8

	if maxW and x > 0 then
		maxW = maxW + x
	end

	for _, v in ipairs(text) do
		if isstring(v) then
			w, h = surface.GetTextSize(v)

			if maxW and x + w > maxW then
				v:gsub("(%s?[%S]+)", function(word)
					w, h = surface.GetTextSize(word)

					if x + w >= maxW then
						x, y = baseX, y + (lineHeight)
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
		else
			surface.SetTextColor(v.r, v.g, v.b, v.a)
		end
	end

	return x, y
end



http.Material = HTTP_IMG