Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

local usertable = {}
local admins = {}
local pd = {}
local nhs = {}
local admin_tickets = {}
local pd_tickets = {}
local nhs_tickets = {}

local function hasAdmin(source)
    if admins[source] ~= nil then
        return true
    end
    return false
end
local function hasPD(source)
    if pd[source] ~= nil then
        return true
    end
    return false
end
local function hasNHS(source)
    if nhs[source] ~= nil then
        return true
    end
    return false
end

local function getSource(user_id)
    for k,v in pairs(usertable) do
        if v == user_id then
            return k
        end
    end
    return nil
end


RegisterNetEvent('callmanager:createTicket', function(type, message)
    local source = source
    local user_id = usertable[source]
    local playerName = GetPlayerName(source)
    if type == 1 then
        if user_id ~= nil then
            local id = #admin_tickets + 1
            admin_tickets[id] = {name = playerName, id = user_id, message = message}
        end
    elseif type == 2 then
        if user_id ~= nil then
            local id = #nhs_tickets + 1
            nhs_tickets[id] = {name = playerName, id = user_id, message = message}
        end
    elseif type == 3 then
        if user_id ~= nil then
            local id = #pd_tickets + 1
            pd_tickets[id] = {name = playerName, id = user_id, message = message}
        end
    end
end)



RegisterNetEvent('callmanager:getPerms', function()
    local source = source
    local user_id = usertable[source]
    if user_id ~= nil then
        local perms = {}
        if hasAdmin(source) then
            perms.admin = true
        end
        if hasPD(source) then
            perms.pd = true
        end
        if hasNHS(source) then
            perms.nhs = true
        end
        TriggerClientEvent('callmanager:recPerms', source, perms)
    end
end)

RegisterNetEvent('callmanager:getTickets', function()
    local source = source
    local user_id = usertable[source]
    if user_id ~= nil then
        local tickets = {}
        for k,v in pairs(admin_tickets) do
            if v.id == user_id then
                table.insert(tickets, v)
            end
        end
        for k,v in pairs(nhs_tickets) do
            if v.id == user_id then
                table.insert(tickets, v)
            end
        end
        for k,v in pairs(pd_tickets) do
            if v.id == user_id then
                table.insert(tickets, v)
            end
        end
        TriggerClientEvent('callmanager:recTickets', source, admin_tickets, nhs_tickets, pd_tickets)
    end
end)



--ticket options


RegisterNetEvent('callmanager:sendMessage', function(message, id)
    local source = source
    local user_id = usertable[source]
    local target_id = id
    local playerName = GetPlayerName(source)
    local target_source = getSource(target_id)
    if user_id ~= nil and target_id ~= nil then
        if hasAdmin(source) then
            if target_source then
                TriggerClientEvent('callmanager:recMessage', target_source, playerName, message)
            end
        end
    end
end)



RegisterNetEvent('callmanager:admin:takeTicket', function(ticketInfo)
    local source = source
    local user_id = usertable[source]

    local target_id = ticketInfo.id
    local target_source = getSource(target_id)

    local admin_ped = GetPlayerPed(source)
    local target_ped = GetPlayerPed(target_source)
    
    local admin_coords = GetEntityCoords(admin_ped)
    local target_coords = GetEntityCoords(target_ped)

    if user_id ~= nil and target_id ~= nil then
        if hasAdmin(source) then
            table.remove(admin_tickets, ticketInfo.id)
            TriggerClientEvent('callmanager:admin:takeTicket', source, target_coords)
        end
    end
end)

RegisterNetEvent('callmanager:admin:closeTicket', function(ticketInfo)
    local source = source
    local user_id = usertable[source]
    local target_id = ticketInfo.id
    if user_id ~= nil and target_id ~= nil then
        if hasAdmin(source) then
            table.remove(admin_tickets, ticketInfo.id)
        end
    end
end)




RegisterNetEvent('callmanager:police:takeTicket', function(info)
    local source = source
    local user_id = usertable[source]
    local target_id = info.id
    local target_source = getSource(target_id)
    local admin_ped = GetPlayerPed(source)
    local target_ped = GetPlayerPed(target_source)
    local admin_coords = GetEntityCoords(admin_ped)
    local target_coords = GetEntityCoords(target_ped)
    if user_id ~= nil and target_id ~= nil then
        if hasPD(source) then
            table.remove(pd_tickets, info.id)
            TriggerClientEvent('callmanager:police:takeTicket', source, target_coords)
        end
    end
end)

RegisterNetEvent('callmanager:nhs:takeTicket', function(info)
    local source = source
    local user_id = usertable[source]
    local target_id = info.id
    local target_source = getSource(target_id)
    local target_ped = GetPlayerPed(target_source)
    local target_coords = GetEntityCoords(target_ped)
    if user_id ~= nil and target_id ~= nil then
        if hasNHS(source) then
            table.remove(nhs_tickets, info.id)
            TriggerClientEvent('callmanager:nhs:takeTicket', source, target_coords)
        end
    end
end)

-- Handle User Table
AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
    usertable[source] = user_id
    local has_staff = vRP.hasPermission({user_id, "callmanager.staff.permission"})
    local has_pd = vRP.hasPermission({user_id, "callmanager.pd.permission"})
    local has_nhs = vRP.hasPermission({user_id, "callmanager.nhs.permission"})
    if has_staff then
        admins[source] = user_id
    end
    if has_pd then
        pd[source] = user_id
    end
    if has_nhs then
        nhs[source] = user_id
    end
end)

AddEventHandler('playerDropped', function ()
    local source = source
    usertable[source] = nil
    admins[source] = nil
    pd[source] = nil
    nhs[source] = nil
    for k,v in pairs(admin_tickets) do
        if v.id == source then
            table.remove(admin_tickets, k)
        end
    end
    for k,v in pairs(nhs_tickets) do
        if v.id == source then
            table.remove(nhs_tickets, k)
        end
    end
    for k,v in pairs(pd_tickets) do
        if v.id == source then
            table.remove(pd_tickets, k)
        end
    end
end)
 
 

-- functions




print("[CALLMANAGER] Loaded")
