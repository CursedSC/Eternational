allowed_old =  {
    [ "STEAM_0:1:188105562" ] = true, 
    [ "STEAM_0:1:95796521" ] = true, 
    [ "STEAM_0:1:521065551" ] = true, 
    [ "STEAM_0:1:216502433" ] = true, 
    [ "STEAM_0:0:170628759" ] = true, 
    [ "STEAM_0:0:516436115" ] = true, 
    [ "STEAM_0:0:381811561" ] = true, 
    [ "STEAM_0:0:594178822" ] = true, 
    [ "STEAM_0:0:207956135" ] = true, 
    [ "STEAM_0:1:115171201" ] = true, 
    [ "STEAM_0:0:542396479" ] = true, 
    ["STEAM_0:1:219739348"] = true, 
    ["STEAM_0:1:176216756"] = true, 
    ["STEAM_0:0:90645043"] = true,
    ["STEAM_0:1:108029369"] = true, 
    ["STEAM_1:1:443058603"] = true,
}


allowed = allowed or {}  

hook.Add( "CheckPassword", "access_whitelist", function( steamID64 )
    local converted = util.SteamIDFrom64(steamID64)

    if allowed_old[ util.SteamIDFrom64(steamID64) ] then
        return true
    end

    if not allowed[ util.SteamIDFrom64(steamID64) ] then
        return false, "Доступ на сервер запрещен \n"--"Доступ на сервер только по записи \n"
    end 
    
end)
