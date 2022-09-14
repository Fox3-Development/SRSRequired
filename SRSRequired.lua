local sCheck = {}

-- Configuration Begin

-- If this is set to false, no checking will happen.
-- We are also automatically disabled when not running a server.
sCheck.enable = true

-- The url to direct players to for connections to your SRS server
sCheck.srsUrl = "dcs.hoggitworld.com"
-- The location of your clients-list file.
-- Make sure that "Auto Export List" is set to "ON" on SR-Server.
sCheck.clients_file = [[D:\Program Files\DCS-SimpleRadio-Standalone\clients-list.json]]

-- Configuration END

sCheck.clients = {}
net.log("SRSRequired.lua ---- Loading")

sCheck.loadClients = function()
    --net.log("sCheck ---- Loading Clients")
    local f = io.open(sCheck.clients_file, "r")
    --net.log("sCheck ---- Opened file")
    local fileData = f:read("*a")
    --net.log("sCheck ---- Read file")
    local js = net.json2lua(fileData)
    --net.log("sCheck ---- Read Json")
    sCheck.clients = {}
    for _,c in pairs(js.Clients) do
        --net.log("sCheck ---- Reading client " .. c.Name)
        table.insert(sCheck.clients, c.Name)
    end
    --net.log("sCheck ---- Done reading")
    f:close()
end

sCheck.getPlayerName = function(playerId)
    return net.get_player_info(playerId, 'name')
end

sCheck.enabled = function()
    return (sCheck.enable and DCS.isServer and DCS.isMultiplayer)
end

sCheck.playerInSRS = function(playerId)
    local playerName = sCheck.getPlayerName(playerId)
    local found = false
    net.log("Checking ["..playerName.."] against srs clients")
        for _,p in pairs(sCheck.clients) do
        -- net.log("Checking ["..playerName.."] against srs client " .. p)
        -- For some reason, the clients-info.json file has the host as 'player', even though
        -- the server knows my name from the game.
        if p == "player" then
            p = sCheck.getPlayerName(1) -- If player is 'player' set them to the host.
        end
        if playerName == p then found = true end
    end
    return found
end

sCheck.message = "You must be connected to SRS to join a slot on this server.\n" ..
                 "Please connect to SRS at " .. sCheck.srsUrl .. " before joining a slot."

sCheck.playerEnterUnit = function(playerId)
    sCheck.loadClients()
    local playerInSRS = sCheck.playerInSRS(playerId)
    if not playerInSRS then
        net.send_chat_to(sCheck.message, playerId, playerId)
        net.force_player_slot(playerId, 0, '')
    end
end

sCheck.eventHandler = {}
--Be aware, the onGameEvent signature changes depending on which event comes in.
--slotId, the third argument, is only used for the `change_slot` event we look at.
--If it's another event, slotId may mean something else. For example, the takeoff event
--will populate it with `unit_missionID`. I'm naming it slotId because that's how it's
--being used.
sCheck.eventHandler.onGameEvent = function(eventName, playerId, slotId)
    if sCheck.enabled == false then return end
    local status, err = pcall(function(_event)
        if eventName == "change_slot" and slotId ~= "" then
            sCheck.playerEnterUnit(playerId)
        end
    end, _event)
end

DCS.setUserCallbacks(sCheck.eventHandler)
net.log("SRSRequired.lua ---- Loaded")
