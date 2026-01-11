if 1 then return  end
if pcall(require, "chttp") and CHTTP ~= nil then
    HTTP = CHTTP
else
    return MsgC(Color(255, 0, 0), "Discord Chat Relay ERROR!", Color(255, 255, 255), "Please install https://github.com/timschumi/gmod-chttp!")
end

function DoLog(title, text)
    print("SDP")
    local title = title or "Отслеживание"
          local table_s = {
               content = " ",
               username = "Cordinal",
               embeds = {
                   [1] = {
                       title = title,
                       color = 16750899,
                       description = text,
                       timestamp = "",
                       fields = {},
                       thumbnail = {},
                       author = {
                           name = "",
                           icon_url = "", 
                       },
                   }
               }

           }
            
        HTTP({
            method = "post",
            type = "application/json; charset=utf-8",
            headers = {
                ["User-Agent"] = "Discord Chat Relay",
            },
            url = "https://discord.com/api/webhooks/1201286120529461308/38yGGf4-_KK82CunMsq4xrwlAQOiNtwpktglOcqN8RjhNOny4fxoywnQcNO1d-L6ph05",
            body  = util.TableToJSON(table_s),
            failed = function(error)
                MsgC(Red, "Discord API HTTP Error:", White, error, "\n")
            end,
            success = function(code, response)
                if code ~= 204 then
                    MsgC(Red, "Discord API HTTP Error:", White, code, response, "\n")
                end
            end
        })
end