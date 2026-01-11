local COMMISSION_RATE = 0.15 
local AUCTION_DIR = "fantasy"
local AUCTION_FILE = AUCTION_DIR .. "/listings.json"
local HISTORY_FILE = AUCTION_DIR .. "/history.json"

if not file.Exists(AUCTION_DIR, "DATA") then
    file.CreateDir(AUCTION_DIR)
end

local function LoadJSONData(filePath)
    if not file.Exists(filePath, "DATA") then
        return {}
    end

    local jsonData = file.Read(filePath, "DATA")
    return util.JSONToTable(jsonData) or {}
end

local function SaveJSONData(filePath, data)
    local jsonData = util.TableToJSON(data, true)
    file.Write(filePath, jsonData)
end


local function InitializeAuctionData()
    if not file.Exists(AUCTION_FILE, "DATA") then
        SaveJSONData(AUCTION_FILE, {})
    end

    if not file.Exists(HISTORY_FILE, "DATA") then
        SaveJSONData(HISTORY_FILE, {})
    end
end

hook.Add("Initialize", "AuctionInitData", InitializeAuctionData)

local function GetActiveListings()
    local currentTime = os.time()
    local listings = LoadJSONData(AUCTION_FILE)
    local activeListings = {}

    for _, listing in ipairs(listings) do
        local timeLeft = (listing.time_created + listing.duration) - currentTime
        if timeLeft <= 0 then
            ProcessExpiredListing(listing.id)
        else
            table.insert(activeListings, {
                id = listing.id,
                seller = listing.seller_name,
                sellerSteamID = listing.seller_steamid,
                item = listing.item,
                price = listing.price,
                quantity = listing.quantity,
                timeLeft = timeLeft,
                commission = listing.commission
            })
        end
    end

    return activeListings
end

local function GetPlayerListings(ply)
    local steamID = ply:SteamID()
    local currentTime = os.time()
    local listings = LoadJSONData(AUCTION_FILE)
    local history = LoadJSONData(HISTORY_FILE)
    local active = {}
    local completed = {}

    for _, listing in ipairs(listings) do
        if listing.seller_steamid == steamID then
            local timeLeft = (listing.time_created + listing.duration) - currentTime
            table.insert(active, {
                id = listing.id,
                item = listing.item,
                price = listing.price,
                quantity = listing.quantity,
                timeLeft = timeLeft,
                commission = listing.commission
            })
        end 
    end

    for _, entry in ipairs(history) do
        if entry.seller_steamid == steamID then
            local soldTime = os.date("%Y-%m-%d", entry.time_sold)
            table.insert(completed, {
                id = entry.id,
                item = entry.item,
                price = entry.price,
                quantity = entry.quantity,
                sold = entry.sold,
                profit = math.floor(entry.price * entry.quantity * (1 - COMMISSION_RATE)),
                date = soldTime
            })
        end
    end

    return {active = active, completed = completed}
end

local function ProcessExpiredListing(listingId)
    local listings = LoadJSONData(AUCTION_FILE)
    local history = LoadJSONData(HISTORY_FILE)
    local listingIndex = nil
    local listing = nil

    for i, l in ipairs(listings) do
        if l.id == listingId then
            listingIndex = i
            listing = l
            break
        end
    end

    if not listing then return end

    local seller = player.GetBySteamID(listing.seller_steamid)
    local itemData = listing.item

    table.insert(history, {
        id = #history + 1,
        auction_id = listing.id,
        seller_steamid = listing.seller_steamid,
        seller_name = listing.seller_name,
        item = listing.item,
        price = listing.price,
        quantity = listing.quantity,
        sold = false,
        time_sold = os.time()
    })

    table.remove(listings, listingIndex)
    SaveJSONData(AUCTION_FILE, listings)
    SaveJSONData(HISTORY_FILE, history)

    if IsValid(seller) then
        seller:SetCharacterData("money", seller:GetCharacterData("money") + listing.commission)
        netstream.Start(seller, "auk_commission_return", listing.commission)
        netstream.Start(seller, "auk_notification", "Ваш лот '" .. itemData.name .. "' не был продан. Предмет " .. listing.commission .. " м. возвращены вам.", "info")

        seller.inventory:addItem(Item:fromTable(itemData), listing.quantity)
        netstream.Start(seller, "auk_refresh_inventory")
    else
        StoreOfflinePlayerReturn(listing.seller_steamid, listing.commission, itemData, listing.quantity)
    end
end

function StoreOfflinePlayerReturn(steamID, commission, itemData, quantity)

    print("[Auction] Storing return for offline player: " .. steamID)
end



netstream.Hook("auk_request_listings", function(ply)
    local listings = GetActiveListings()
    netstream.Start(ply, "auk_listings", listings)
end)

netstream.Hook("auk_request_my_listings", function(ply)
    local myListings = GetPlayerListings(ply)
    netstream.Start(ply, "auk_my_listings", myListings)
end)

netstream.Hook("auk_buy_item", function(ply, listingId, quantity)
    local listings = LoadJSONData(AUCTION_FILE)
    local listing = nil
    local listingIndex = nil

    for i, l in ipairs(listings) do
        if l.id == listingId and l.active == 1 then
            listing = l
            listingIndex = i
            break
        end
    end

    if not listing then
        netstream.Start(ply, "auk_notification", "Этот лот больше не доступен.", "error")
        return
    end

    local requestedQuantity = listing.quantity

    local totalPrice = listing.price * requestedQuantity
    local playerMoney = ply:GetCharacterData("money") or 0

    if playerMoney < totalPrice then
        netstream.Start(ply, "auk_notification", "Недостаточно денег для покупки.", "error")
        return
    end

    if listing.seller_steamid == ply:SteamID() then
        netstream.Start(ply, "auk_notification", "Вы не можете купить свой собственный лот.", "error")
        return
    end

    ply:SetCharacterData("money", playerMoney - totalPrice)

    local itemData = listing.item
    ply.inventory:addItem(Item:fromTable(itemData), requestedQuantity)
    netstream.Start(ply, "auk_refresh_inventory")

    local seller = player.GetBySteamID(listing.seller_steamid)
    local sellerProfit = math.floor(totalPrice * (1 - COMMISSION_RATE))

    if IsValid(seller) then
        seller:SetCharacterData("money", seller:GetCharacterData("money") + sellerProfit)
        netstream.Start(seller, "auk_notification", "Ваш предмет '" .. itemData.name .. "' был продан за " .. totalPrice .. " м.", "success")
        netstream.Start(seller, "auk_sold_notification", itemData.name, sellerProfit)
    else
        StoreOfflinePlayerSale(listing.seller_steamid, sellerProfit)
    end

    if requestedQuantity >= listing.quantity then
        local history = LoadJSONData(HISTORY_FILE)
        table.insert(history, {
            id = #history + 1,
            auction_id = listing.id,
            seller_steamid = listing.seller_steamid,
            buyer_steamid = ply:SteamID(),
            seller_name = listing.seller_name,
            buyer_name = ply:Nick(),
            item = listing.item,
            price = listing.price,
            quantity = requestedQuantity,
            sold = true,
            time_sold = os.time()
        })
        table.remove(listings, listingIndex)
        SaveJSONData(AUCTION_FILE, listings)
        SaveJSONData(HISTORY_FILE, history)
    else
        listing.quantity = listing.quantity - requestedQuantity
        listings[listingIndex] = listing
        SaveJSONData(AUCTION_FILE, listings)

        local history = LoadJSONData(HISTORY_FILE)
        table.insert(history, {
            id = #history + 1,
            auction_id = listing.id,
            seller_steamid = listing.seller_steamid,
            buyer_steamid = ply:SteamID(),
            seller_name = listing.seller_name,
            buyer_name = ply:Nick(),
            item = listing.item,
            price = listing.price,
            quantity = requestedQuantity,
            sold = true,
            time_sold = os.time()
        })
        SaveJSONData(HISTORY_FILE, history)
    end

    netstream.Start(ply, "auk_notification", "Вы успешно купили '" .. itemData.name .. "' x" .. requestedQuantity .. " за " .. totalPrice .. " м.", "success")

    netstream.Start(ply, "auk_request_listings")
end)

function StoreOfflinePlayerSale(steamID, amount)
    local steamID = util.SteamIDTo64( steamID )
    local filePath = "fantasy/character/" .. steamID .. ".txt"
    if file.Exists(filePath, "DATA") then
        local data = file.Read(filePath, "DATA")
        characterData = util.JSONToTable(data)
        characterData.money = characterData.money + amount
        local newData = util.TableToJSON(characterData, true)
        file.Write(filePath, newData)
    end
    print("[Auction] Storing sale for offline player: " .. steamID .. ", Amount: " .. amount)
end

netstream.Hook("auk_list_item", function(ply, data)
    if not data.itemSource or not data.price or not data.quantity or not data.duration then
        netstream.Start(ply, "auk_notification", "Неверные данные для выставления лота.", "error")
        return
    end
    local itemData = data.item
    if not ply.inventory:hasItem(itemData.x, itemData.y, data.quantity) then
        netstream.Start(ply, "auk_notification", "У вас нет этого предмета или не хватает количества.", "error")
        return
    end

    local totalPrice = data.price * data.quantity
    local commission = math.floor(totalPrice * COMMISSION_RATE)

    local playerMoney = ply:GetCharacterData("money") or 0
    if playerMoney < commission then
        netstream.Start(ply, "auk_notification", "Недостаточно денег для оплаты комиссии (" .. commission .. " м.).", "error")
        return
    end

    ply:SetCharacterData("money", playerMoney - commission)

    ply.inventory:removeItem(itemData.x, itemData.y, data.quantity)
    netstream.Start(ply, "auk_refresh_inventory")

    
    local durationSeconds = data.duration * 3600

    local listings = LoadJSONData(AUCTION_FILE)
    table.insert(listings, {
        id = #listings + 1,
        seller_steamid = ply:SteamID(),
        seller_name = ply:GetName(true),
        item = itemData,
        price = data.price,
        quantity = data.quantity,
        duration = durationSeconds,
        time_created = os.time(),
        commission = commission,
        active = 1
    })
    SaveJSONData(AUCTION_FILE, listings)

    netstream.Start(ply, "auk_notification", "Вы выставили '" .. itemData.name .. "' x" .. data.quantity .. " на аукцион за " .. data.price .. " м. Комиссия: " .. commission .. " м.", "success")

    netstream.Start(ply, "auk_request_my_listings")
end)

netstream.Hook("auk_cancel_listing", function(ply, listingId)
    local listings = LoadJSONData(AUCTION_FILE)
    local listing = nil
    local listingIndex = nil

    for i, l in ipairs(listings) do
        if l.id == listingId and l.seller_steamid == ply:SteamID() then
            listing = l
            listingIndex = i
            break
        end
    end

    if not listing then
        netstream.Start(ply, "auk_notification", "Лот не найден или не принадлежит вам.", "error")
        return
    end

    local itemData = listing.item
    ply.inventory:addItem(Item:fromTable(itemData), listing.quantity)

    local history = LoadJSONData(HISTORY_FILE)
    table.insert(history, {
        id = #history + 1,
        auction_id = listing.id,
        seller_steamid = listing.seller_steamid,
        seller_name = listing.seller_name,
        item = listing.item,
        price = listing.price,
        quantity = listing.quantity,
        sold = false,
        time_sold = os.time()
    })
    table.remove(listings, listingIndex)
    SaveJSONData(AUCTION_FILE, listings)
    SaveJSONData(HISTORY_FILE, history)

    netstream.Start(ply, "auk_notification", "Лот '" .. itemData.name .. "' был отменен. Предмет " .. listing.commission .. " м. возвращены вам.", "info")
    netstream.Start(ply, "auk_commission_return", listing.commission)
    netstream.Start(ply, "auk_refresh_inventory")

    netstream.Start(ply, "auk_request_my_listings")
end)

timer.Create("AuctionCheckExpired", 60, 0, function()
    local currentTime = os.time()
    local listings = LoadJSONData(AUCTION_FILE)
    local expiredListings = {}

    for _, listing in ipairs(listings) do
        if listing.active == 1 and (listing.time_created + listing.duration) <= currentTime then
            table.insert(expiredListings, listing.id)
        end
    end

    for _, listingId in ipairs(expiredListings) do
        ProcessExpiredListing(listingId)
    end
end)


concommand.Add("auk_open", function(ply)
    if not IsValid(ply) then return end
    netstream.Start(ply, "auk_open")
end)

concommand.Add("auk_cleanup", function(ply)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end

    local thirtyDaysAgo = os.time() - (30 * 24 * 60 * 60)
    local history = LoadJSONData(HISTORY_FILE)
    local newHistory = {}

    for _, entry in ipairs(history) do
        if entry.time_sold >= thirtyDaysAgo then
            table.insert(newHistory, entry)
        end
    end

    SaveJSONData(HISTORY_FILE, newHistory)

    if IsValid(ply) then
        ply:PrintMessage(HUD_PRINTCONSOLE, "[Auction] Cleaned up old records.")
    else
        print("[Auction] Cleaned up old records.")
    end
end)
