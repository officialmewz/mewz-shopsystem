local function GetPlayerBank(source)
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.getAccount('bank').money
    elseif QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player.PlayerData.money.bank
    end
    return 0
end

local function GetPlayerCash(source)
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.getMoney()
    elseif QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player.PlayerData.money.cash
    end
    return 0
end

local function RemovePlayerBank(source, amount)
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.removeAccountMoney('bank', amount)
            return true
        end
    elseif QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            local removed = Player.Functions.RemoveMoney('bank', amount)
            return removed == true
        end
    end
    return false
end

local function RemovePlayerCash(source, amount)
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.removeMoney(amount)
            return true
        end
    elseif QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            local removed = Player.Functions.RemoveMoney('cash', amount)
            return removed == true
        end
    end
    return false
end

local function AddItem(source, item, quantity)
    if GetResourceState('ox_inventory') == 'started' then
        local success = exports.ox_inventory:AddItem(source, item, quantity)
        if success then
            return true
        end
        return false
    elseif ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.addInventoryItem(item, quantity)
            return true
        end
    elseif QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            Player.Functions.AddItem(item, quantity)
            return true
        end
    end
    return false
end

local function GetShopItems(shopType)
    local itemsToUse = Config.Items[shopType] or {}
    local shopItems = {}
    for category, items in pairs(itemsToUse) do
        shopItems[category] = {}
        for _, item in ipairs(items) do
            table.insert(shopItems[category], {
                id = item.id,
                name = item.name,
                label = item.label or item.name,
                item = item.item,
                type = item.type,
                price = item.price,
                description = item.description or ''
            })
        end
    end
    return shopItems
end

local function GetItemById(itemId, shopType)
    local itemsToUse = Config.Items[shopType] or {}
    for category, items in pairs(itemsToUse) do
        for _, item in ipairs(items) do
            if item.id == itemId then
                return item, category
            end
        end
    end
    return nil, nil
end

local function GetPlayerFullName(source)
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.getName() or 'Spiller'
        end
    elseif QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
        end
    end
    return GetPlayerName(source) or 'Spiller'
end

RegisterNetEvent('bamz-shopsystem:openShop', function(shopType)
    local source = source
    local playerBank = GetPlayerBank(source)
    local shopItems = GetShopItems(shopType or 'supermarket')
    local playerFullName = GetPlayerFullName(source)
    
    TriggerClientEvent('bamz-shopsystem:openShop', source, {
        money = playerBank,
        items = shopItems,
        shopType = shopType or 'supermarket',
        playerFullName = playerFullName
    })
end)

RegisterNetEvent('bamz-shopsystem:closeShop', function()
end)

RegisterNetEvent('bamz-shopsystem:purchaseBasket', function(basket, paymentMethod, shopType)
    local source = source
    
    if not basket or #basket == 0 then
        TriggerClientEvent('bamz-shopsystem:purchaseResponse', source, { 
            success = false, 
            message = 'Kurven er tom' 
        })
        return
    end
    
    paymentMethod = paymentMethod or 'bank'
    shopType = shopType or 'supermarket'
    
    local totalPrice = 0
    local itemsToAdd = {}
    
    for _, basketItem in ipairs(basket) do
        local item, category = GetItemById(basketItem.itemId, shopType)
        if not item then
            TriggerClientEvent('bamz-shopsystem:purchaseResponse', source, { 
                success = false, 
                message = 'Item ikke fundet: ' .. tostring(basketItem.itemId) 
            })
            return
        end
        
        local quantity = tonumber(basketItem.quantity) or 1
        local itemTotal = item.price * quantity
        totalPrice = totalPrice + itemTotal
        
        table.insert(itemsToAdd, {
            item = item.item,
            quantity = quantity,
            name = item.name
        })
    end
    
    local hasEnough = false
    if paymentMethod == 'cash' then
        local playerCash = GetPlayerCash(source)
        hasEnough = playerCash >= totalPrice
        if not hasEnough then
            local missing = totalPrice - playerCash
            TriggerClientEvent('bamz-shopsystem:purchaseResponse', source, { 
                success = false, 
                    message = 'Ikke tilstrækkelige kontanter. Du mangler ' .. missing .. ' DKK' 
                })
            exports.ox_lib:notify(source, {
                title = 'Ikke tilstrækkelige kontanter',
                description = 'Du mangler ' .. missing .. ' DKK',
                type = 'error',
                duration = 5000
            })
            return
        end
    else
        local playerBank = GetPlayerBank(source)
        hasEnough = playerBank >= totalPrice
        if not hasEnough then
            local missing = totalPrice - playerBank
            TriggerClientEvent('bamz-shopsystem:purchaseResponse', source, { 
                success = false, 
                    message = 'Ikke tilstrækkelige midler på kontoen. Du mangler ' .. missing .. ' DKK' 
                })
            exports.ox_lib:notify(source, {
                title = 'Ikke tilstrækkelige midler',
                description = 'Du mangler ' .. missing .. ' DKK på din konto',
                type = 'error',
                duration = 5000
            })
            return
        end
    end
    
    local removed = false
    if paymentMethod == 'cash' then
        removed = RemovePlayerCash(source, totalPrice)
    else
        removed = RemovePlayerBank(source, totalPrice)
    end
    
    if not removed then
        TriggerClientEvent('bamz-shopsystem:purchaseResponse', source, { 
            success = false, 
            message = 'Kunne ikke fjerne penge. Tjek om du har tilstrækkelige midler.' 
        })
        return
    end
    
    if paymentMethod == 'cash' then
        TriggerClientEvent('bamz-shopsystem:showMoneyExchange', source, paymentMethod, totalPrice)
    end
    
    for _, itemData in ipairs(itemsToAdd) do
        local success = AddItem(source, itemData.item, itemData.quantity)
        if not success then
            TriggerClientEvent('bamz-shopsystem:purchaseResponse', source, { 
                success = false, 
                message = 'Kunne ikke tilføje item: ' .. itemData.name
            })
            return
        end
    end
    
    exports.ox_lib:notify(source, {
        title = 'Købet er vellykket!',
        type = 'success',
        duration = 5000
    })
    
    TriggerClientEvent('bamz-shopsystem:purchaseResponse', source, { 
        success = true, 
        message = 'Køb gennemført',
        totalPrice = totalPrice
    })
    
    Wait(50)
    TriggerClientEvent('bamz-shopsystem:closeShop', source)
end)


exports('OpenShop', function(source, shopType)
    local playerBank = GetPlayerBank(source)
    local shopItems = GetShopItems(shopType or 'supermarket')
    
    TriggerClientEvent('bamz-shopsystem:openShop', source, {
        money = playerBank,
        items = shopItems,
        shopType = shopType or 'supermarket',
        playerFullName = GetPlayerFullName(source)
    })
end)

