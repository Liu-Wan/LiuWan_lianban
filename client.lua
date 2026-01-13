RegisterNetEvent('liuwan_lianban:openPanel')
AddEventHandler('liuwan_lianban:openPanel', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "OPEN_PANEL"
    })
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('performAction', function(recv, cb)
    local action = recv.action
    local data = recv.data or {}

    if action == "searchBan" then
        TriggerServerEvent('liuwan_lianban:searchBan', data.identifier)

    elseif action == "myBans" then
        TriggerServerEvent('liuwan_lianban:myBans')

    elseif action == "submitBan" then
        TriggerServerEvent('liuwan_lianban:submitBan', data)

    elseif action == "removeBan" then
        TriggerServerEvent('liuwan_lianban:removeBan', data)

    elseif action == "requestUnban" then
        TriggerServerEvent('liuwan_lianban:requestUnban', data)
    end

    cb('ok')
end)

RegisterNetEvent('liuwan_lianban:apiResponse')
AddEventHandler('liuwan_lianban:apiResponse', function(action, code, response)
    SendNUIMessage({
        type = "API_RESPONSE",
        action = action,
        code = code,
        response = response
    })
end)
