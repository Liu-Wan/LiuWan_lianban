local function PrintLogo()
    print("^4   __    _           ______              ")
    print("^4  / /   (_)___ _____/ / __ )____ _____   ")
    print("^4 / /   / / __ `/ __  / __  / __ `/ __ /  ")
    print("^4/ /___/ / /_/ / / / / /_/ / /_/ / / / /  ")
    print("^4/_____/_//__,_/_/ /_/_____//__,_/_/ /_/   ")
    print("^0")
end

local ESX = nil
local QBCore = nil

if Config.Framework == "esx" then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == "qbcore" then
    QBCore = exports['qb-core']:GetCoreObject()
end

local function IsPlayerAdmin(src)
    if not Config.AdminGroups then return false end
    
    if Config.Framework == "esx" and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            local myGroup = xPlayer.getGroup()
            for _, group in ipairs(Config.AdminGroups) do
                if myGroup == group then return true end
            end
        end
        return false
        
    elseif Config.Framework == "qbcore" and QBCore then
        for _, group in ipairs(Config.AdminGroups) do
            if QBCore.Functions.HasPermission(src, group) then
                return true
            end
        end
        return false
        
    else
        for _, group in ipairs(Config.AdminGroups) do
            if IsPlayerAceAllowed(src, "group." .. group) then
                return true
            end
        end
    end
    
    return false
end

local function MakeAllianceRequest(endpoint, method, data, cb)
    local baseUrl = "https://lianban.fivemzh.cn/api"
    if string.sub(endpoint, 1, 1) ~= "/" then endpoint = "/" .. endpoint end
    
    local url = string.format("%s%s?api_key=%s", baseUrl, endpoint, ServerConfig.ApiKey)
    local headers = { ["Content-Type"] = "application/json" }
    local postData = ""

    local function urlEncode(str)
        if str then
            str = string.gsub(str, "\n", "\r\n")
            str = string.gsub(str, "([^%w %-%_%.%~])",
                function(c) return string.format("%%%02X", string.byte(c)) end)
            str = string.gsub(str, " ", "+")
        end
        return str
    end

    if method == "POST" or method == "PUT" then
        if data then
            postData = json.encode(data)
        end
    elseif method == "GET" and data then

        for k, v in pairs(data) do
            url = url .. "&" .. k .. "=" .. urlEncode(tostring(v))
        end
    end

    PerformHttpRequest(url, function(errorCode, resultData, resultHeaders)
        if errorCode == 0 then
            print("^1[LianBan] Api端点请求超时或连接失败 " .. endpoint .. "^0")
            if cb then cb(500, nil) end
            return
        end

        local decoded = nil
        if resultData then
            local status, result = pcall(json.decode, resultData)
            if status then
                decoded = result
            else
                print("^1[LianBan] 无法解码 Api端点JSON " .. endpoint .. "^0")
            end
        end

        if cb then cb(errorCode, decoded) end
    end, method, postData, headers)
end

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    
    PrintLogo()
    print("^3[LianBan] 正在初始化插件...^0")
    
    MakeAllianceRequest("/stats", "GET", nil, function(code, data)
        if code == 200 and data then
            print("^2[LianBan] 加载成功！已连接到联盟封禁数据库。^0")
            print("^2[LianBan] 当前全网封禁数据: " .. (data.total_bans or 0) .. " 条。^0")
        else
            print("^1[LianBan] 加载失败: API不可用 (Code: " .. tostring(code) .. ")^0")
        end
    end)
end)

RegisterNetEvent('liuwan_lianban:searchBan')
AddEventHandler('liuwan_lianban:searchBan', function(identifier)
    local src = source
    if not IsPlayerAdmin(src) then return end
    
    if not identifier or identifier == "" then
        TriggerClientEvent('liuwan_lianban:apiResponse', src, 'searchBan', 400, { error = "需要标识符" })
        return
    end

    MakeAllianceRequest("/check_ban", "GET", { identifier = identifier }, function(code, res)
        TriggerClientEvent('liuwan_lianban:apiResponse', src, 'searchBan', code, res)
    end)
end)

RegisterNetEvent('liuwan_lianban:myBans')
AddEventHandler('liuwan_lianban:myBans', function()
    local src = source
    if not IsPlayerAdmin(src) then return end
    
    MakeAllianceRequest("/my_bans", "GET", nil, function(code, res)
        TriggerClientEvent('liuwan_lianban:apiResponse', src, 'myBans', code, res)
    end)
end)

RegisterNetEvent('liuwan_lianban:submitBan')
AddEventHandler('liuwan_lianban:submitBan', function(data)
    local src = source
    if not IsPlayerAdmin(src) then return end
    
    if not data or not data.identifier or not data.reason then
        TriggerClientEvent('liuwan_lianban:apiResponse', src, 'submitBan', 400, { error = "缺少字段" })
        return
    end
    
    MakeAllianceRequest("/submit_ban", "POST", data, function(code, res)
        TriggerClientEvent('liuwan_lianban:apiResponse', src, 'submitBan', code, res)
    end)
end)

RegisterNetEvent('liuwan_lianban:removeBan')
AddEventHandler('liuwan_lianban:removeBan', function(data)
    local src = source
    if not IsPlayerAdmin(src) then return end

    if not data or not data.id then
        TriggerClientEvent('liuwan_lianban:apiResponse', src, 'removeBan', 400, { error = "需要封禁ID" })
        return
    end

    MakeAllianceRequest("/remove_ban", "POST", data, function(code, res)
        TriggerClientEvent('liuwan_lianban:apiResponse', src, 'removeBan', code, res)
    end)
end)

RegisterNetEvent('liuwan_lianban:requestUnban')
AddEventHandler('liuwan_lianban:requestUnban', function(data)
    local src = source
    if not IsPlayerAdmin(src) then return end

    if not data or not data.ban_id or not data.reason then
        TriggerClientEvent('liuwan_lianban:apiResponse', src, 'requestUnban', 400, { error = "封禁ID和封禁理由" })
        return
    end

    MakeAllianceRequest("/request_unban", "POST", data, function(code, res)
        TriggerClientEvent('liuwan_lianban:apiResponse', src, 'requestUnban', code, res)
    end)
end)

local function PresentBanCard(deferrals, banData)
    local card = {
        type = "AdaptiveCard",
        ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
        version = "1.3",
        body = {
            {
                type = "Container",
                items = {
                    {
                        type = "TextBlock",
                        text = "🚫 联盟封禁通知 / ALLIANCE BAN",
                        weight = "Bolder",
                        size = "Medium",
                        color = "Attention",
                        horizontalAlignment = "Center"
                    },
                    {
                        type = "TextBlock",
                        text = "您已被列入联盟封禁黑名单，无法进入此服务器。",
                        wrap = true,
                        horizontalAlignment = "Center",
                        spacing = "Medium"
                    },
                    {
                        type = "FactSet",
                        facts = {
                            { title = "封禁原因:", value = banData.reason or "无" },
                            { title = "触发标识:", value = banData.identifier or "未知" }
                        },
                        spacing = "Large"
                    }
                }
            }
        }
    }

    if banData.evidence and banData.evidence ~= "" then
        table.insert(card.body[1].items, {
            type = "Image",
            url = banData.evidence,
            size = "Large",
            horizontalAlignment = "Center",
            spacing = "Medium"
        })
    end

    table.insert(card.body[1].items, {
        type = "TextBlock",
        text = "如有异议，请联系服务器管理员或访问Lianban.fivemzh.cn进行申诉。",
        isSubtle = true,
        wrap = true,
        horizontalAlignment = "Center",
        spacing = "ExtraLarge",
        size = "Small"
    })

    deferrals.presentCard(card, function(data, rawData)

    end)
end

if Config.CheckBanOnJoin then
    AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
        local src = source
        local identifiers = GetPlayerIdentifiers(src)
        
        deferrals.defer()
        Wait(0)
        deferrals.update("🛡️ [LianBan] 正在核查联盟信用记录...")

        MakeAllianceRequest("/check_ban", "POST", { identifiers = identifiers }, function(errorCode, data)
            if errorCode == 200 and data and data.banned then
                PresentBanCard(deferrals, data)
            else
                if errorCode ~= 200 then
                    print("^3[LianBan] 由于 API 错误，已跳过检查： " .. tostring(errorCode) .. "^0")
                end
                deferrals.done()
            end
        end)
    end)
end

RegisterCommand("lbpanel", function(source, args, rawCommand)
    if source == 0 then return end
    
    if not IsPlayerAdmin(source) then
        TriggerClientEvent('chat:addMessage', source, { args = { "^1SYSTEM", "无权限访问。" } })
        return
    end

    TriggerClientEvent('liuwan_lianban:openPanel', source)

end, false)
