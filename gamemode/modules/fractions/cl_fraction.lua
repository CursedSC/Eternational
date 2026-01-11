-- Add this at the top of your file
fractions = fractions or {}
fractions.List = fractions.List or {}

-- Add the hook to receive fraction data from server
netstream.Hook("fantasy/fraction/syncData", function(fractionData)
    fractions.List = fractionData
    hook.Run("FactionsUpdated") -- Run a hook so other scripts can respond
end)

-- Function to get fraction data by ID
function fractions.Get(fractionID)
    return fractions.List[fractionID]
end

-- Function to get all fractions
function fractions.GetAll()
    return fractions.List
end

-- Function to request a refresh from the server
function fractions.RequestSync()
    netstream.Start("fantasy/fraction/requestSync")
end

-- Add a hook on the server side to handle sync requests
netstream.Hook("fantasy/fraction/requestSync", function(ply)
    fractions.SyncToPlayer(ply)
end)

-- Add hook for fraction invites
netstream.Hook("fantasy/fraction/ask/invite", function(fract)
    Derma_YesNoRequest("Приглашение", "Вы хотите вступить в "..fract, function()
        netstream.Start("fantasy/fraction/accept/invite", fract)
    end)
end)

netstream.Hook("fantasy/fraction/ask/invite", function(fract)
    Derma_YesNoRequest("Приглошение", "Вы хотите вступить в "..fract, function()
        netstream.Start("fantasy/fraction/accept/invite", fract)
    end)
end)