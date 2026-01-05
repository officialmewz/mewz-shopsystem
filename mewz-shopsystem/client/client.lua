local isShopOpen = false
local currentShopType = 'supermarket'

local function OpenShop(shopType)
    currentShopType = shopType or 'supermarket'
    TriggerServerEvent('bamz-shopsystem:openShop', currentShopType)
end

local function CloseShop()
    if not isShopOpen then
        return
    end
    
    isShopOpen = false
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        action = 'closeShop'
    })
    
    TriggerServerEvent('bamz-shopsystem:closeShop')
end

local currentShopLocation = nil
local shopNPCs = {}
local shopBlips = {}
local shopLocationsData = {}
local targetZones = {}

local function CreateShopNPC(coords, locationName, npcModel, npcOffset)
    local model = npcModel or `mp_m_shopkeep_01`
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end
    
    local offset = npcOffset or vector3(0.0, 0.0, 0.0)
    local heading = math.rad(coords.w)
    local offsetX = coords.x + (offset.x * math.cos(heading) - offset.y * math.sin(heading))
    local offsetY = coords.y + (offset.x * math.sin(heading) + offset.y * math.cos(heading))
    
    local npc = CreatePed(4, model, offsetX, offsetY, coords.z - 1.0, coords.w, false, true)
    
    SetEntityAsMissionEntity(npc, true, true)
    SetPedFleeAttributes(npc, 0, false)
    SetPedCombatAttributes(npc, 17, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    
    TaskStandStill(npc, -1)
    SetEntityHeading(npc, coords.w)
    SetModelAsNoLongerNeeded(model)
    
    return npc
end

local function CreateShopBlip(coords, blipConfig, locationName)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, blipConfig.id or 59)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, blipConfig.scale or 0.8)
    SetBlipColour(blip, blipConfig.colour or 69)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(locationName or "Butik")
    EndTextCommandSetBlipName(blip)
    
    return blip
end

CreateThread(function()
    Wait(500)
    
    for shopIndex, shopData in ipairs(Config.Shops) do
        if shopData and shopData.locations then
            local shopName = shopData.name
            local shopType = shopData.shopType
            local blipConfig = shopData.blip or {}
            local npcConfig = shopData.npc or {}
            
            for locationIndex, locationData in ipairs(shopData.locations) do
                if locationData and locationData.coords then
                    local location = locationData.coords
                    local uniqueId = shopData.id .. '_' .. locationIndex
                    
                    Wait(100 * (shopIndex + locationIndex))
                    
                    if npcConfig.model then
                        local npcOffset = locationData.npcOffset or npcConfig.offset or vector3(0.0, 0.0, 0.0)
                        local npc = CreateShopNPC(location, shopName, npcConfig.model, npcOffset)
                        if npc then
                            shopNPCs[uniqueId] = npc
                            shopLocationsData[uniqueId] = {
                                npc = npc,
                                coords = location
                            }
                        end
                    end
                    
                    local blip = CreateShopBlip(location, blipConfig, shopName)
                    if blip then
                        shopBlips[uniqueId] = blip
                    end
                    
                    local coords = vector3(location.x, location.y, location.z)
                    local zoneId = 'bamz-shopsystem_' .. uniqueId
                    
                    exports.ox_target:addSphereZone({
                        coords = coords,
                        radius = 2.0,
                        debug = false,
                        options = {
                            {
                                name = zoneId,
                                icon = 'fas fa-shopping-cart',
                                label = 'Åben ' .. shopName,
                                onSelect = function()
                                    currentShopLocation = shopName
                                    OpenShop(shopType)
                                end
                            }
                        }
                    })
                    
                    table.insert(targetZones, zoneId)
                end
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, zoneId in ipairs(targetZones) do
            exports.ox_target:removeZone(zoneId)
        end
        
        for _, npc in pairs(shopNPCs) do
            if DoesEntityExist(npc) then
                DeleteEntity(npc)
            end
        end
        
        for _, blip in pairs(shopBlips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
    end
end)

RegisterNUICallback('openShop', function(data, cb)
    TriggerServerEvent('bamz-shopsystem:openShop')
    cb({ success = true })
end)

RegisterNUICallback('closeShop', function(data, cb)
    CloseShop()
    cb({ success = true })
end)

RegisterNUICallback('purchaseBasket', function(data, cb)
    local basket = data.basket or {}
    if #basket == 0 then
        cb({ success = false })
        return
    end
    
    SetNuiFocus(false, false)
    
    local input = lib.inputDialog('Vælg Betalingsmetode', {
        {
            type = 'select',
            label = 'Betalingsmetode',
            options = {
                { value = 'cash', label = 'Kontant' },
                { value = 'bank', label = 'Bank' }
            },
            required = true
        }
    })
    
    SetNuiFocus(true, true)
    
    if not input or not input[1] then
        SendNUIMessage({
            action = 'purchaseResponse',
            success = false,
            message = 'Betaling annulleret'
        })
        cb({ success = false })
        return
    end
    
    local paymentMethod = input[1]
    
    TriggerServerEvent('bamz-shopsystem:purchaseBasket', basket, paymentMethod, currentShopType)
    
    cb({ success = true })
end)

RegisterNetEvent('bamz-shopsystem:openShop', function(data)
    isShopOpen = true
    currentShopType = data.shopType or 'supermarket'
    SetNuiFocus(true, true)
    
    local locationName = currentShopLocation
    if not locationName then
        for _, shopData in ipairs(Config.Shops) do
            if shopData.shopType == currentShopType then
                locationName = shopData.name
                break
            end
        end
    end
    
    SendNUIMessage({
        action = 'openShop',
        money = data.money,
        items = data.items,
        locationName = locationName or 'Butik',
        shopType = currentShopType,
        playerFullName = data.playerFullName
    })
end)

RegisterNetEvent('bamz-shopsystem:closeShop', function()
    if isShopOpen then
        isShopOpen = false
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = 'closeShop'
        })
    else
        SetNuiFocus(false, false)
    end
end)

RegisterNetEvent('bamz-shopsystem:purchaseResponse', function(response)
    SendNUIMessage({
        action = 'purchaseResponse',
        success = response.success,
        message = response.message,
        totalPrice = response.totalPrice
    })
end)

local function ShowMoneyExchangeAnimation(paymentMethod, totalPrice)
    if paymentMethod ~= 'cash' then
        return
    end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local nearestNPC = nil
    local nearestDistance = 999.0
    
    for _, npc in pairs(shopNPCs) do
        if DoesEntityExist(npc) then
            local npcCoords = GetEntityCoords(npc)
            local distance = #(playerCoords - npcCoords)
            if distance < nearestDistance and distance < 5.0 then
                nearestDistance = distance
                nearestNPC = npc
            end
        end
    end
    
    if nearestNPC then
        local moneyProp = `prop_cash_pile_01`
        RequestModel(moneyProp)
        while not HasModelLoaded(moneyProp) do
            Wait(10)
        end
        
        RequestAnimDict("mp_common")
        while not HasAnimDictLoaded("mp_common") do
            Wait(10)
        end
        
        local moneyObject = CreateObject(moneyProp, 0.0, 0.0, 0.0, true, true, true)
        AttachEntityToEntity(moneyObject, playerPed, GetPedBoneIndex(playerPed, 57005), 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)
        
        TaskPlayAnim(playerPed, "mp_common", "givetake2_a", 8.0, -8.0, 2000, 0, 0, false, false, false)
        
        RequestAnimDict("mp_common")
        while not HasAnimDictLoaded("mp_common") do
            Wait(10)
        end
        
        TaskPlayAnim(nearestNPC, "mp_common", "givetake2_a", 8.0, -8.0, 2000, 0, 0, false, false, false)
        
        CreateThread(function()
            Wait(2000)
            if DoesEntityExist(moneyObject) then
                DeleteObject(moneyObject)
            end
            SetModelAsNoLongerNeeded(moneyProp)
        end)
    end
end

RegisterNetEvent('bamz-shopsystem:showMoneyExchange', function(paymentMethod, totalPrice)
    ShowMoneyExchangeAnimation(paymentMethod, totalPrice)
end)

local escPressed = false
CreateThread(function()
    while true do
        Wait(0)
        if isShopOpen then
            if IsControlJustReleased(0, 322) then
                if not escPressed then
                    escPressed = true
                    CloseShop()
                    Wait(500)
                    escPressed = false
                end
            end
        else
            Wait(500)
        end
    end
end)
