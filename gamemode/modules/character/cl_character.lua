netstream.Hook("fantasy/character/init", function(data)
    print("fantasycharacterinit")
   
    chache_characterData = data
    LocalPlayer().characterData = data
end)

hook.Add("InitPostEntity", "loadCharacterData", function()
    LocalPlayer().characterData = chache_characterData
end)

netstream.Hook("fantasy/testnetstream", function(data)
    print("fantasy/testnetstream")
    print("Received message: " .. data.message)
end)

concommand.Add("typeofme", function(ply)
    print(ply)
    print(type(ply))
end)