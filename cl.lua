local admin_tickets = {}
local nhs_tickets = {}
local pd_tickets = {}
local isAdmin = false
local isPD = false
local isNHS = false
local selected_ticket = nil
local cooldownTimer = 0
local pd_cooldownTimer = 0
local nhs_cooldownTimer = 0
local mycoords = {}


local function getMessage()
	AddTextEntry('FMMC_MPM_NA', "Enter Message (MAX 120 characters):")
	DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "Enter Message", "", "", "", "", 120)
    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0);
        Wait(0);
    end
    if (GetOnscreenKeyboardResult()) then
        local result = GetOnscreenKeyboardResult()
		if result then
			return result
		end
    end
	return ""
end
local function notifyPlayer(msg)
    Citizen.CreateThread(function()
        local scaleform = RequestScaleformMovie("mp_big_message_freemode")
        while not HasScaleformMovieLoaded(scaleform) do Citizen.Wait(0) end
        BeginScaleformMovieMethod(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
        PushScaleformMovieMethodParameterString("~y~Admin Message")
        PushScaleformMovieMethodParameterString(msg)
        PushScaleformMovieMethodParameterInt(3)
        EndScaleformMovieMethod()
        PlaySoundFrontend(-1, "LOSER", "HUD_AWARDS")
        local drawing = true
        Citizen.SetTimeout((10 * 1000),function() drawing = false end)
        while drawing do
            Citizen.Wait(0)
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
        end
        SetScaleformMovieAsNoLongerNeeded(scaleform)
    end)
end
local function notifyCooldown()
    Citizen.CreateThread(function()
        local scaleform = RequestScaleformMovie("mp_big_message_freemode")
        while not HasScaleformMovieLoaded(scaleform) do Citizen.Wait(0) end
        BeginScaleformMovieMethod(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
        PushScaleformMovieMethodParameterString("~y~Warning")
        PushScaleformMovieMethodParameterString("You can only make a ticket every 3 Minutes.")
        PushScaleformMovieMethodParameterInt(3)
        EndScaleformMovieMethod()
        PlaySoundFrontend(-1, "LOSER", "HUD_AWARDS")
        local drawing = true
        Citizen.SetTimeout((2 * 1000),function() drawing = false end)
        while drawing do
            Citizen.Wait(0)
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
        end
        SetScaleformMovieAsNoLongerNeeded(scaleform)
    end)
end




-- Main Parts
RMenu.Add('CallManager', 'main', RageUI.CreateMenu("Callum's Callmanager", "~g~Call System",1250,100))
RMenu.Add('CallManager', 'admin_tickets',  RageUI.CreateSubMenu(RMenu:Get("CallManager", "main")))
RMenu.Add('CallManager', 'police_tickets',  RageUI.CreateSubMenu(RMenu:Get("CallManager", "main")))
RMenu.Add('CallManager', 'nhs_tickets',  RageUI.CreateSubMenu(RMenu:Get("CallManager", "main")))
RMenu.Add('CallManager', 'make_tickets',  RageUI.CreateSubMenu(RMenu:Get("CallManager", "main")))
-- Sub Parts
RMenu.Add('CallManager', 'admin_tickets_sub',  RageUI.CreateSubMenu(RMenu:Get("CallManager", "admin_tickets")))
RMenu.Add('CallManager', 'police_tickets_sub',  RageUI.CreateSubMenu(RMenu:Get("CallManager", "police_tickets")))
RMenu.Add('CallManager', 'nhs_tickets_sub',  RageUI.CreateSubMenu(RMenu:Get("CallManager", "nhs_tickets")))


RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('CallManager', 'main')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Button("Make Tickets", "", {}, true, function(Hovered, Active, Selected)
                if Selected then end
            end, RMenu:Get('CallManager', 'make_tickets'))
            if isAdmin then
                RageUI.Button("Admin Tickets", "", {}, true, function(Hovered, Active, Selected) 
                    if Selected then end
                end, RMenu:Get("CallManager", "admin_tickets"))
            end
            if isPD then
                RageUI.Button("Police Calls", "", {}, true, function(Hovered, Active, Selected) 
                    if Selected then end
                end, RMenu:Get("CallManager", "police_tickets"))
            end
            if isNHS then
                RageUI.Button("NHS Calls", "", {}, true, function(Hovered, Active, Selected) 
                    if Selected then end
                end, RMenu:Get("CallManager", "nhs_tickets"))
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('CallManager', 'admin_tickets')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            for k, v in pairs(admin_tickets) do
                RageUI.Button(v.name, v.message, {}, true, function(Hovered, Active, Selected) 
                    if Selected then 
                        selected_ticket = v
                    end
                end, RMenu:Get("CallManager", "admin_tickets_sub"))
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('CallManager', 'police_tickets')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            for k, v in pairs(pd_tickets) do
                RageUI.Button(v.name, v.message, {}, true, function(Hovered, Active, Selected) 
                    if Selected then 
                        selected_ticket = v
                    end
                end, RMenu:Get("CallManager", "police_tickets_sub"))
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('CallManager', 'nhs_tickets')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            for k, v in pairs(nhs_tickets) do
                RageUI.Button(v.name, v.message, {}, true, function(Hovered, Active, Selected) 
                    if Selected then 
                        selected_ticket = v
                    end
                end, RMenu:Get("CallManager", "nhs_tickets_sub"))
            end
        end)
    end

    -- SUB MENUS

    if RageUI.Visible(RMenu:Get('CallManager', 'admin_tickets_sub')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Separator(selected_ticket.name .. "'s ticket", function() end)
            RageUI.Separator(selected_ticket.message, function() end)
            RageUI.Button("Take Ticket", "", {}, true, function(Hovered, Active, Selected) 
                if Selected then 
                    TriggerServerEvent('callmanager:admin:takeTicket', selected_ticket)
                    selected_ticket = nil
                end
            end)
            RageUI.Button("Send Message To User", "", {}, true, function(Hovered, Active, Selected) 
                if Selected then 
                    local messagetosend = getMessage()
                    local perm_id = selected_ticket.id
                    TriggerServerEvent('callmanager:sendMessage', messagetosend, perm_id)
                    RageUI.ActuallyCloseAll()
                    selected_ticket = nil
                end
            end)
            RageUI.Button("Close Ticket", "", {}, true, function(Hovered, Active, Selected) 
                if Selected then 
                    TriggerServerEvent('callmanager:admin:closeTicket', selected_ticket)
                    RageUI.ActuallyCloseAll()
                    selected_ticket = nil
                end
            end)
        end)
    end
    if RageUI.Visible(RMenu:Get('CallManager', 'police_tickets_sub')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Separator(selected_ticket.name .. "'s ticket", function() end)
            RageUI.Separator(selected_ticket.message, function() end)
            RageUI.Button("Set Waypoint", "", {}, true, function(Hovered, Active, Selected) 
                if Selected then 
                    TriggerServerEvent('callmanager:police:takeTicket', selected_ticket)
                    RageUI.ActuallyCloseAll()
                    selected_ticket = nil
                end
            end)
        end)
    end
    if RageUI.Visible(RMenu:Get('CallManager', 'nhs_tickets_sub')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Separator(selected_ticket.name .. "'s ticket", function() end)
            RageUI.Separator(selected_ticket.message, function() end)
            RageUI.Button("Set Waypoint", "", {}, true, function(Hovered, Active, Selected) 
                if Selected then 
                    TriggerServerEvent('callmanager:nhs:takeTicket', selected_ticket)
                    RageUI.ActuallyCloseAll()
                    selected_ticket = nil
                end
            end)
        end)
    end
    if RageUI.Visible(RMenu:Get('CallManager', 'make_tickets')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Button("Make Admin Ticket", "", {}, true, function(Hovered, Active, Selected) 
                if Selected then 
                    if cooldownTimer > 0 then notifyCooldown() return end
                    message = getMessage()
                    TriggerServerEvent('callmanager:createTicket', 1, message)
                    cooldownTimer = 180
                end
            end)
            RageUI.Button("Make NHS Ticket", "", {}, true, function(Hovered, Active, Selected) 
                if Selected then 
                    if nhs_cooldownTimer > 0 then notifyCooldown() return end
                    message = getMessage()
                    TriggerServerEvent('callmanager:createTicket', 2, message)
                    nhs_cooldownTimer = 180
                end
            end)
            RageUI.Button("Make Police Ticket", "", {}, true, function(Hovered, Active, Selected) 
                if Selected then 
                    if pd_cooldownTimer > 0 then notifyCooldown() return end
                    message = getMessage()
                    TriggerServerEvent('callmanager:createTicket', 3, message)
                    pd_cooldownTimer = 180
                end
            end)
        end)
    end
end)



RegisterCommand('callmanager', function(source, args, raw)
    admin_tickets = {}
    nhs_tickets = {}
    pd_tickets = {}
    TriggerServerEvent('callmanager:getPerms')
    TriggerServerEvent('callmanager:getTickets')
    RageUI.Visible(RMenu:Get("CallManager", "main"), true)
end)
RegisterKeyMapping('callmanager', 'Opens Callmanager', 'keyboard', 'DELETE')

RegisterCommand('return', function(source, args, raw)
    TriggerServerEvent('callmanager:getPerms')
    if isAdmin then
        local player = PlayerPedId()
        SetEntityCoords(player, mycoords.x, mycoords.y, mycoords.z)
        ExecuteCommand('staffoff')
        mycoords = {}
    end
end)



RegisterNetEvent('callmanager:recPerms', function(perms)
    isAdmin = perms.admin
    isPD = perms.pd
    isNHS = perms.nhs
end)

RegisterNetEvent('callmanager:recTickets', function(q, w, r)
    admin_tickets = q
    nhs_tickets = w
    pd_tickets = r
end)

RegisterNetEvent('callmanager:recMessage', function(name, message)
    local message = '~r~' .. message .. 'from ' .. name
    notifyPlayer(message)
end)

RegisterNetEvent('callmanager:admin:takeTicket', function(coords)
    if isAdmin then
        local player = PlayerPedId()
        local playerloc = GetEntityCoords(player)
        mycoords = playerloc
        ExecuteCommand('staffon')
        SetEntityCoords(player, coords)
    end
end)

RegisterNetEvent('callmanager:police:takeTicket', function(coords)
    if isPD then
        SetNewWaypoint(coords.x, coords.y)
    end
end)

RegisterNetEvent('callmanager:nhs:takeTicket', function(coords)
    if isNHS then
        SetNewWaypoint(coords.x, coords.y)
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if cooldownTimer > 0 then
            cooldownTimer = cooldownTimer - 1
        end
        if pd_cooldownTimer > 0 then
            pd_cooldownTimer = pd_cooldownTimer - 1
        end
        if nhs_cooldownTimer > 0 then
            nhs_cooldownTimer = nhs_cooldownTimer - 1
        end
    end
end)