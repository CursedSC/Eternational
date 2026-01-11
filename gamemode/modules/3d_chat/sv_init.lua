util.AddNetworkString("rp.Chat.Command")
util.AddNetworkString("Chat_say")
util.AddNetworkString("advert.Start")

hook.Add( "PlayerCanHearPlayersVoice", "rp.Voice", function( listener, talker )
    if listener:GetPos():Distance( talker:GetPos() ) < 45 and talker:KeyDown(IN_WALK) then
        return true,true 
    elseif talker:KeyDown(IN_WALK) then 
        return false 
    end
    if listener:GetPos():Distance( talker:GetPos() ) < 700 and talker:KeyDown(IN_SPEED) then
        return true,true
    elseif listener:GetPos():Distance( talker:GetPos() ) < 300 then 
        return true,true 
    else 
        return false
    end

    return false 
end )

function chat_say(ply,text)
    for k, v in ipairs( ents.FindInSphere(ply:GetPos(), 300) ) do
        if v:IsPlayer() then
            net.Start("Chat_say")
                net.WriteString(text)
                net.WriteEntity(ply)
            net.Send(v)
        end
    end
end


function util.FindPlayer(identifier, user, bNoMessage)
	if (!identifier) then 
		return;
	end;
	
	local output = {};

	for k, v in ipairs(player.GetAll()) do
		local playerNick = string.lower(v:Nick());
		local playerName = string.lower(v:Name());

		if (v:SteamID() == identifier or v:UniqueID() == identifier
		or v:SteamID64() == identifier or (v:IPAddress():gsub(":%d+", "")) == identifier
		or playerNick == string.lower(identifier) or playerName == string.lower(identifier)) then
			return v;
		end;
		
		if (string.find(playerNick, string.lower(identifier), 0, true) 
		or string.find(playerName, string.lower(identifier), 0, true)) then
			table.insert(output, v);
		end;
	end;

	if (#output == 1) then
		return output[1];
	elseif (#output > 1) then
		if (!bNoMessage) then
			if (IsValid(user)) then
				if (serverguard and serverguard.Notify) then
					serverguard.Notify(user, SERVERGUARD.NOTIFY.RED, "Found more than one player with that identifier.");
				else
					user:ChatPrint("Found more than one player with that identifier.");
				end;
			else
				if (SERVER) then
					Msg("Found more than one player with that identifier.\n");
				end;
			end;
		end;
	else
		if (!bNoMessage) then
			if (IsValid(user)) then
				if (serverguard and serverguard.Notify) then
					serverguard.Notify(user, SERVERGUARD.NOTIFY.RED, "Can't find any player with that identifier.");
				else
					user:ChatPrint("Can't find any player with that identifier.");
				end;
			else
				if (SERVER) then
					Msg("Can't find any player with that identifier.\n");
				end;
			end;
		end;
	end;
end;

function util.ExplodeByTags(text, seperator, open, close, bRemoveTag)
	local results = {};
	local current = "";
	local tag = nil;

	text = string.gsub(text, "%s+", " ");
	
	for i = 1, #text do
		local character = string.sub(text, i, i);
		
		if (!tag) then
			if (character == open) then
				if (!bRemoveTag) then
					current = current..character;
				end;
				
				tag = true;
			elseif (character == seperator) then
				results[#results + 1] = current; current = "";
			else
				current = current..character;
			end;
		else
			if (character == close) then
				if (!bRemoveTag) then
					current = current..character;
				end;
				
				tag = nil;
			else
				current = current..character;
			end;
		end;
	end;
	
	if (current != "") then
		results[#results + 1] = current;
	end;
	
	return results;
end;
local function PlayerSay(ply, text)
    local text_s = string.Split( text, " " )
    for command, func in pairs(RP.chat.commands) do 
        if text_s[1] == command then 
            func.server(ply, text)
            return ""
        end
    end
	logger.ChatLog(ply, text)
    chat_say(ply,text)
    return ""
end

hook.Add("PlayerSay", "dbt.Chat.Say", function( ply, text )
    return PlayerSay(ply, text)
end)

