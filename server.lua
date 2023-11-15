-- STRUCTURE --
-- gangs = gangs table (MySQL)
-- ranks = each gang -> gang.ranks[rank_name] = rank data

-- GETTING RANKS: gangs["gangname"].ranks

local gangs = {}

local initialized = {}

local zones = Config.Zones

local zones_waiting = {} 

ESX = exports['es_extended']:getSharedObject()

local function chatMessage(target, author, msg)
    TriggerClientEvent('chat:addMessage', target, {
        args = { author, msg }
    })
end

local function isAdmin(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local group = xPlayer.getGroup()
	
    return true
end

local function InitializeData()
    local data_gangs = MySQL.Sync.fetchAll('SELECT * FROM gangs', {})
    local data_ranks = MySQL.Sync.fetchAll('SELECT * FROM gang_ranks', {})
    for i=1, #data_gangs do
        gangs[data_gangs[i].name] = data_gangs[i]
        gangs[data_gangs[i].name].inventory = data_gangs[i].inventory ~= nil and json.decode(data_gangs[i].inventory) or {cash = 0, dcash = 0, items = {}}
        gangs[data_gangs[i].name].vehicles = Config.Gangs[data_gangs[i].name] ~= nil and (Config.Gangs[data_gangs[i].name].Vehicles ~= nil and Config.Gangs[data_gangs[i].name].Vehicles or {}) or {}
    end
    for i=1, #data_ranks do
        if (gangs[data_ranks[i].gang_name] ~= nil) then
            if (gangs[data_ranks[i].gang_name].ranks == nil) then 
                gangs[data_ranks[i].gang_name].ranks = {}
            end
            gangs[data_ranks[i].gang_name].ranks[data_ranks[i].name] = data_ranks[i]
        end
    end
end   

local function getPlayerGang(id)
    for a,b in pairs(gangs) do
        if (b.members ~= nil) then
            for k,v in pairs(b.members) do
                if (k == id) then
                    return a
                end
            end
        end
    end
end

local function getRankData(gang, rank)
    local _gang = gang
    local rank_id = rank
    for k,v in pairs(gangs[_gang].ranks) do
        if (v.ranking == rank_id) then
            return v
        end
    end
end

local function getPlayerRank(id, gang) 
    local _id = id
    local _gang = gang
    if (gangs[_gang] ~= nil) then 
        local members = gangs[_gang].members
        return getRankData(_gang, members[_id])
    end
end

local function isGangLeader(id, gang)
    local player = id
    local _gang = gang
    local gang_data = gangs[_gang]
    local members = gang_data.members
    local min_rank = gang_data.leadership_rank
    if (members[id] ~= nil and members[id] >= min_rank) then
        return true
    end
end

local function UpdatePlayerClient(id, gang, rank)
    local _id = id
    local _gang = {}
    local _rank = {}
    if (gang ~= nil) then 
        _gang = gangs[gang]
        _rank = getRankData(gang, rank)
    end
    if (_gang == nil or _rank == nil) then
        _gang = {}
        _rank = {}
    end
    TriggerClientEvent('esx_gangs:UpdateClient', _id, _gang, _rank)
end

local function InitializePlayerData(id)
    local source = id
    local xPlayer = nil 
    print(id)
    while xPlayer == nil do 
        xPlayer = ESX.GetPlayerFromId(source)
        Citizen.Wait(50)
    end
    local identifier = xPlayer.getIdentifier()
    local gang_data = MySQL.Sync.fetchAll('SELECT `gang`, `gang_rank` FROM `users` WHERE identifier=@identifier', {['@identifier'] = identifier})
    local gang_name = gang_data[1].gang
    local gang_rank = gang_data[1].gang_rank
    if (gangs[gang_name] ~= nil) then
        if (gangs[gang_name].members == nil) then
            gangs[gang_name].members = {}  
        end
        gangs[gang_name].members[source] = gang_rank
        UpdatePlayerClient(source, gang_name, gang_rank)
    end
end

local function RemovePlayerData(id)
    local source = id
    for k,v in pairs(gangs) do
        if (v.members ~= nil) then
            for a,b in pairs(v.members) do
                if (a == source) then
                    v.members[a] = nil
                end
            end
        end
    end
    if (ESX.GetPlayerFromId(source) ~= nil) then
        UpdatePlayerClient(source, nil, nil)
    end
end

local function InsertPlayer(ident, gang_name, ranking) 
    local tplayer = MySQL.Sync.fetchAll('SELECT `gang`, `firstname`, `lastname` FROM `users` WHERE identifier=@identifier', {['@identifier'] = ident})
    local player = tplayer[1]
    local gang_data = gangs[gang_name]
    local rank_data = getRankData(gang_name, ranking)
    chatMessage(-1, "[^1ESX Gangs^0]", player.firstname .. " " .. player.lastname .. " was set as ^2".. gang_data.label .. ": ".. rank_data.label .."^0.")
    MySQL.Sync.execute("UPDATE users SET gang=@gang, gang_rank=@gang_rank WHERE identifier=@identifier", {['@gang'] = gang_name, ['@gang_rank'] = ranking, ['@identifier'] = ident})
    if (ESX.GetPlayerFromIdentifier(ident) ~= nil) then
        local xPlayer = ESX.GetPlayerFromIdentifier(ident)
        if (xPlayer.source ~= nil) then
            RemovePlayerData(xPlayer.source)
            InitializePlayerData(xPlayer.source)
        end
    end
end

local function InvitePlayer(ident, gang_name)
    local tplayer = MySQL.Sync.fetchAll('SELECT `gang`, `firstname`, `lastname` FROM `users` WHERE identifier=@identifier', {['@identifier'] = ident})
    local player = tplayer[1]
    local gang_data = gangs[gang_name]
    chatMessage(-1, "[^1ESX Gangs^0]", player.firstname .. " " .. player.lastname .. " was ^2accepted^0 into ^2".. gang_data.label .. "^0.")
    MySQL.Sync.execute("UPDATE users SET gang=@gang, gang_rank=0 WHERE identifier=@identifier", {['@gang'] = gang_name, ['@identifier'] = ident})
    if (ESX.GetPlayerFromIdentifier(ident) ~= nil) then
        local xPlayer = ESX.GetPlayerFromIdentifier(ident)
        if (xPlayer.source ~= nil) then
            RemovePlayerData(xPlayer.source)
            InitializePlayerData(xPlayer.source)
        end
    end
end

function FirePlayer(ident)
    if not ident then return end
    print(ident)
    local tplayer = MySQL.Sync.fetchAll('SELECT `gang`, `firstname`, `lastname` FROM `users` WHERE identifier=@identifier', {['@identifier'] = ident})
    local player = tplayer[1]
    local gang_data = gangs[player.gang]
    chatMessage(-1, "[^1ESX Gangs^0]", player.firstname .. " " .. player.lastname .. " was ^1removed^0 from ^1".. gang_data.label .. "^0.")
    MySQL.Sync.execute("UPDATE users SET gang=NULL, gang_rank=NULL WHERE identifier=@identifier", {['@identifier'] = ident})
    if (ESX.GetPlayerFromIdentifier(ident) ~= nil) then
        local xPlayer = ESX.GetPlayerFromIdentifier(ident)
        if (xPlayer.source ~= nil) then
            RemovePlayerData(xPlayer.source)
        end
    end
end

local function PromotePlayer(ident)
    local tplayer = MySQL.Sync.fetchAll('SELECT `gang`, `gang_rank`, `firstname`, `lastname` FROM `users` WHERE identifier=@identifier', {['@identifier'] = ident})
    local player = tplayer[1]
    local gang_data = gangs[player.gang]
    if (getRankData(player.gang, player.gang_rank + 1) ~= nil) then
        chatMessage(-1, "[^1ESX Gangs^0]", "Promoted " .. player.firstname .. " " .. player.lastname .. " to ^2".. getRankData(player.gang, player.gang_rank + 1).label .. "^0.")
        MySQL.Sync.execute("UPDATE users SET gang_rank=@gang_rank WHERE identifier=@identifier", {['@gang_rank'] = player.gang_rank + 1, ['@identifier'] = ident})
        if (ESX.GetPlayerFromIdentifier(ident) ~= nil) then
            local xPlayer = ESX.GetPlayerFromIdentifier(ident)
            if (xPlayer.source ~= nil) then
                UpdatePlayerClient(xPlayer.source, player.gang, player.gang_rank + 1)
            end
        end
    else
        chatMessage(-1, "[^1ESX Gangs^0]", "Couldn't promote " .. player.firstname .. " " .. player.lastname .. " any higher.")
    end
end

local function DemotePlayer(ident)
    local tplayer = MySQL.Sync.fetchAll('SELECT `gang`, `gang_rank`, `firstname`, `lastname` FROM `users` WHERE identifier=@identifier', {['@identifier'] = ident})
    local player = tplayer[1]
    local gang_data = gangs[player.gang]
    if (getRankData(player.gang, player.gang_rank - 1) ~= nil) then
        chatMessage(-1, "[^1ESX Gangs^0]", "Demoted " .. player.firstname .. " " .. player.lastname .. " to ^1".. getRankData(player.gang, player.gang_rank - 1).label .. "^0.")
        MySQL.Sync.execute("UPDATE users SET gang_rank=@gang_rank WHERE identifier=@identifier", {['@gang_rank'] = player.gang_rank - 1, ['@identifier'] = ident})
        if (ESX.GetPlayerFromIdentifier(ident) ~= nil) then
            local xPlayer = ESX.GetPlayerFromIdentifier(ident)
            if (xPlayer.source ~= nil) then
                UpdatePlayerClient(xPlayer.source, player.gang, player.gang_rank - 1)
            end
        end
    else
        chatMessage(-1, "[^1ESX Gangs^0]", "Couldn't demote " .. player.firstname .. " " .. player.lastname .. " any lower.")
    end
end

local function UpdateItems(gang_name)
    local gang = gangs[gang_name]
    local pinventory = gang.inventory ~= nil and json.encode(gang.inventory) or nil
    MySQL.Sync.execute("UPDATE gangs SET inventory=@inventory WHERE name=@name", {['@name'] = gang_name, ['@inventory'] = pinventory})
end

local function DepositItem(_item, amount, id)
    local leader = id
    local xLeader = ESX.GetPlayerFromId(leader)
    local gang_name = getPlayerGang(id)
    if (gang_name ~= nil) then
        if (_item == "cash" or _item == "dcash") then 
            local count = _item == "cash" and xLeader.getMoney() or xLeader.getAccount('black_money').money
            if (count - amount >= 0) then
                if (_item == "cash") then 
                    xLeader.removeMoney(amount)
                    gangs[gang_name].inventory.cash = (gangs[gang_name].inventory.cash ~= nil and gangs[gang_name].inventory.cash + amount) or amount
                else 
                    xLeader.removeAccountMoney('black_money', amount)
                    gangs[gang_name].inventory.dcash = (gangs[gang_name].inventory.dcash ~= nil and gangs[gang_name].inventory.dcash + amount) or amount
                end
                UpdateItems(gang_name)
            else
                TriggerClientEvent('esx:showNotification', leader, "~r~You dont have enough.~w~")
            end
        else
            local item = xLeader.getInventoryItem(_item)
            if (item.count - amount >= 0) then
                xLeader.removeInventoryItem(item.name, amount)
                gangs[gang_name].inventory = gangs[gang_name].inventory == nil and {} or gangs[gang_name].inventory
                gangs[gang_name].inventory.items[item.name] = gangs[gang_name].inventory.items[item.name] ~= nil and (gangs[gang_name].inventory.items[item.name] + amount) or amount
                UpdateItems(gang_name)
            else
                TriggerClientEvent('esx:showNotification', leader, "~r~You dont have enough.~w~")
            end
        end
    end
end

local function RemoveItem(_item, amount, id)
    local leader = id
    local xLeader = ESX.GetPlayerFromId(leader)
    local gang_name = getPlayerGang(id)
    local gang_inventory = gangs[gang_name].inventory
    if (gang_name ~= nil) then
        if (_item == "cash" or _item == "dcash") then 
            local count = _item == "cash" and gang_inventory.cash or gang_inventory.dcash
            if (count ~= nil and count - amount >= 0) then 
                if (_item == "cash") then 
                    xLeader.addMoney(amount)
                    gangs[gang_name].inventory.cash = gangs[gang_name].inventory.cash - amount
                else 
                    xLeader.addAccountMoney('black_money', amount)
                    gangs[gang_name].inventory.dcash = gangs[gang_name].inventory.dcash - amount
                end
                UpdateItems(gang_name)
            else
                TriggerClientEvent('esx:showNotification', leader, "~r~You dont have enough.~w~")
            end
        else
            local item = gangs[gang_name].inventory.items[_item]
            if (item ~= nil and item - amount >= 0) then
                xLeader.addInventoryItem(_item, amount)
                gangs[gang_name].inventory.items[_item] = gangs[gang_name].inventory.items[_item] - amount
                UpdateItems(gang_name)
            else
                TriggerClientEvent('esx:showNotification', leader, "~r~You dont have enough.~w~")
            end
        end
    end
end

local function FinishCapturing(_zone)
    local zone = zones[_zone]
    local members = zone.members
    local dead = zone.deadmembers
    local counts = {["police"] = 0}
    local highest = {name = "", count = 0}
    for k,v in pairs(members) do
        if (dead[k] == nil) then
            local g_name = getPlayerGang(k)
            if (g_name ~= nil) then
                counts[g_name] = counts[g_name] ~= nil and counts[g_name] + 1 or 1
            end
        else
            members[k] = nil
        end
    end
    for k,v in pairs(counts) do
        if (v == highest.count and highest.count > 0) then
            highest.name = ""
            highest.count = 0
            break 
        elseif (v > highest.count) then
            highest.name = k
            highest.count = v
        end
    end
    if (highest.name == "") then
        chatMessage(-1, "[^1Turf Wars^0]", 'The turf "^3'.. zone.Label ..'^0" has ended in a ^3tie^0! No winners this time...')
    else
        local winner_label = highest.name
        local rewarded_depts = {}

        if (winner_label == "police") then
            winner_label = "the police"
        else
            winner_label = gangs[winner_label].label
        end
        
        local rewards = zone.Rewards
        local items = rewards['items']
        
        if (highest.name ~= "police") then
            for k,v in pairs(items) do
                gangs[highest.name].inventory = gangs[highest.name].inventory == nil and {} or gangs[highest.name].inventory
                gangs[highest.name].inventory.items[k] = gangs[highest.name].inventory.items[k] ~= nil and (gangs[highest.name].inventory.items[k] + v) or v
                UpdateItems(highest.name)
            end
            gangs[highest.name].inventory.cash = (gangs[highest.name].inventory.cash ~= nil and gangs[highest.name].inventory.cash + rewards['cash']) or rewards['cash']
            gangs[highest.name].inventory.dcash = (gangs[highest.name].inventory.dcash ~= nil and gangs[highest.name].inventory.dcash + rewards['dcash']) or rewards['dcash']
        end
        zones_waiting[_zone] = Config.CaptureCooldown
        local amount = highest.name == 'police' and ("Cash: ^2$" .. ((rewards['cash'] + rewards['dcash']) * 2) .. "^0" ) or ("Cash: ^2$" .. rewards['cash'] .. "^0 Dirty Cash: ^1$" .. rewards['dcash'] .. "^0")
        chatMessage(-1, "[^1Turf Wars^0]", 'The turf "^3'.. zone.Label ..'^0" was captured by ^1'.. winner_label..'^0! (Rewards: '.. amount ..'.')
    end
    zones[_zone].capturing = false
    zones[_zone].members = {}
    zones[_zone].deadmembers = {}
    TriggerClientEvent("esx_gangs:UpdateZones", -1, zones)
end

RegisterServerEvent("esx_gangs:InitializeClient")
AddEventHandler("esx_gangs:InitializeClient", function() 
    local _source = source
    initialized[_source] = true
    TriggerClientEvent("esx_gangs:UpdateZones", -1, zones)
    InitializePlayerData(_source)
end)

RegisterServerEvent("esx_gangs:FirePlayer")
AddEventHandler("esx_gangs:FirePlayer", function(ident) 
    local leader = source
    local identifier = ident
    local l_gang = getPlayerGang(leader)
    local l_rank = getPlayerRank(leader, l_gang)
    if (isGangLeader(leader, l_gang)) then
        local t_player = MySQL.Sync.fetchAll('SELECT `name`, `identifier`, `gang_rank` FROM `users` WHERE gang=@gang AND identifier=@identifier', {['@gang'] = l_gang, ['@identifier'] = identifier})
        if (#t_player == 1) then
            local player = t_player[1]
            if (l_rank.ranking > player.gang_rank) then
                FirePlayer(player.identifier)
            end
        end
    end
end)

RegisterServerEvent("esx_gangs:PromotePlayer")
AddEventHandler("esx_gangs:PromotePlayer", function(ident) 
    local leader = source
    local identifier = ident
    local l_gang = getPlayerGang(leader)
    local l_rank = getPlayerRank(leader, l_gang)
    if (isGangLeader(leader, l_gang)) then
        local t_player = MySQL.Sync.fetchAll('SELECT `firstname`, `lastname`, `name`, `identifier`, `gang_rank` FROM `users` WHERE gang=@gang AND identifier=@identifier', {['@gang'] = l_gang, ['@identifier'] = identifier})
        if (#t_player == 1) then
            local player = t_player[1]
            if (l_rank.ranking > player.gang_rank + 1) then
                PromotePlayer(player.identifier) 
            else
                chatMessage(leader, "[^1ESX Gangs^0]", "Couldn't promote " .. player.firstname .. " " .. player.lastname .. " any higher.")
            end
        end
    end
end)

RegisterServerEvent("esx_gangs:InvitePlayer")
AddEventHandler("esx_gangs:InvitePlayer", function(ident) 
    local leader = source
    local identifier = ident
    local xInvite = ESX.GetPlayerFromIdentifier(ident)
    local i_gang = getPlayerGang(xInvite.source)
    if (i_gang == nil) then
        local l_gang = getPlayerGang(leader)
        local l_rank = getPlayerRank(leader, l_gang)
        if (isGangLeader(leader, l_gang)) then
            InvitePlayer(ident, l_gang) 
        end
    else 
        chatMessage(leader, "[^1ESX Gangs^0]", "That person is already in another gang.")
    end
end)

RegisterServerEvent("esx_gangs:DemotePlayer")
AddEventHandler("esx_gangs:DemotePlayer", function(ident) 
    local leader = source
    local identifier = ident
    local l_gang = getPlayerGang(leader)
    local l_rank = getPlayerRank(leader, l_gang)
    if (isGangLeader(leader, l_gang)) then
        local t_player = MySQL.Sync.fetchAll('SELECT `firstname`, `lastname`, `name`, `identifier`, `gang_rank` FROM `users` WHERE gang=@gang AND identifier=@identifier', {['@gang'] = l_gang, ['@identifier'] = identifier})
        if (#t_player == 1) then
            local player = t_player[1]
            if (l_rank.ranking > player.gang_rank and 0 <= player.gang_rank - 1) then
                DemotePlayer(player.identifier) 
            else
                chatMessage(leader, "[^1ESX Gangs^0]", "Couldn't demote " .. player.firstname .. " " .. player.lastname .. " any lower.")
            end
        end
    end
end)

RegisterServerEvent("esx_gangs:zoneInteracted")
AddEventHandler("esx_gangs:zoneInteracted", function(_zone)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local zone = zones[_zone]
    local gang = getPlayerGang(_source)
    if (zones_waiting[_zone] == nil or zones_waiting[_zone] <= 0) then
        if (zone ~= nil and (gang ~= nil)) then
            if (not zone.capturing) then 
                zone.capturing = true
                zone.members = {}
                zone.deadmembers = {}
                zone.timer = Config.CaptureTimer
                chatMessage(-1, "[^1Turf Wars^0]", 'The turf "^3'.. zone.Label ..'^0" is now being ^1captured^0. It will be over in ^1'.. Config.CaptureTimer ..' second(s)^0.')
                zones[_zone] = zone
                TriggerClientEvent("esx_gangs:UpdateZones", -1, zones)
            end
        else
            TriggerClientEvent('esx:showNotification', _source, "~r~You are not in a gang.~w~")
        end
    else
        TriggerClientEvent('esx:showNotification', _source, "~r~This zone is on a cooldown for ".. zones_waiting[_zone] .." more second(s).~w~")
    end
end)

RegisterServerEvent("esx_gangs:PlayerEnteredZone")
AddEventHandler("esx_gangs:PlayerEnteredZone", function(_zone)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local zone = zones[_zone]
    local gang = getPlayerGang(_source)
    if (zone ~= nil and (gang ~= nil)) then
        if (zone.members ~= nil) then 
            zone.members[_source] = "gang"
        end
        zones[_zone] = zone
        TriggerClientEvent("esx_gangs:UpdateZones", -1, zones)
    else
        TriggerClientEvent('esx:showNotification', _source, "~r~You are not in a gang.~w~")
    end
end)

RegisterServerEvent("esx_gangs:PlayerExitedZone")
AddEventHandler("esx_gangs:PlayerExitedZone", function(_zone)
    local _source = source
    local zone = zones[_zone]
    zone.members[_source] = nil
end)

RegisterServerEvent("esx_gangs:AddDeadPlayer")
AddEventHandler("esx_gangs:AddDeadPlayer", function(last_zone)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local zone = zones[_zone]
    local gang = getPlayerGang(_source)
    if (zones_waiting[_zone] == nil or zones_waiting[_zone] <= 0) then
        if (zone ~= nil and (gang ~= nil)) then
            if (zone.capturing) then 
                zones[_zone].deadmembers[_source] = true
            end
        end
    end

end)

ESX.RegisterServerCallback('esx_gangs:getMembers', function(source, cb, gang_name)
	local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if (isGangLeader(_source, gang_name)) then
        local gang = gangs[gang_name]
        local gang_rank = getPlayerRank(_source, gang_name).ranking
        if (gang ~= nil) then 
            local players = {}
            local members = MySQL.Sync.fetchAll('SELECT `name`, `identifier`, `gang_rank` FROM `users` WHERE gang=@gang AND gang_rank<@gang_rank', {['@gang'] = gang_name, ['@gang_rank'] = gang_rank})
            for i=1, #members do
                local member = members[i]
                local trank = getRankData(gang_name, member.gang_rank)
                if (trank ~= nil) then  
                    table.insert(players, {id = member.identifier, name = member.name, rank = trank})
                end
            end
            cb(players)
        else
            cb(nil)
        end
    end
end)

ESX.RegisterServerCallback('esx_gangs:getInvitablePlayers', function(source, cb, gang_name)
	local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if (isGangLeader(_source, gang_name)) then
        local gang = gangs[gang_name]
        if (gang ~= nil) then 
            local players = {}
            local members = gang.members
            local xPlayers = ESX.GetPlayers()
            for i=1, #xPlayers, 1 do
                if (members[xPlayers[i]] == nil) then
                    local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
                    table.insert(players, {id = xPlayer.identifier, sid = xPlayers[i], name = xPlayer.getName()})
                end
            end
            cb(players)
        else
            cb(nil)
        end
    end
end)

ESX.RegisterServerCallback('esx_gangs:getMember', function(source, cb, gang_name, ident)
    local _source = source
    local identifier = ident
    local xPlayer = ESX.GetPlayerFromId(_source)
    if (isGangLeader(_source, gang_name)) then
        local gang = gangs[gang_name]
        if (gang ~= nil) then 
            local player = nil
            local members = gang.members
            local members = MySQL.Sync.fetchAll('SELECT `name`, `gang`, `gang_rank` FROM `users` WHERE identifier=@identifier', {['@identifier'] = identifier})
            if (#members == 1) then 
                player = members[1]
                player.rank = player.gang_rank
                player.identifier = identifier
                player.gang_rank = nil
            end
            cb(player)
        else
            cb(nil)
        end
    end
end)

ESX.RegisterServerCallback('esx_gangs:getPlayerInventory', function(source, cb, gang_name)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if (isGangLeader(_source, gang_name)) then
        local gang = gangs[gang_name]
        local data = {}
        data.inventory = {}
        local inventory = xPlayer.getInventory()
        for i=1, #inventory do 
            local item = inventory[i]
            if (item.count > 0) then
                table.insert(data.inventory, item)
            end
        end
        data.cash = xPlayer.getMoney()
        data.dcash = xPlayer.getAccount('black_money').money
        cb(data)
    end
end)

ESX.RegisterServerCallback('esx_gangs:getInventory', function(source, cb, gang_name)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if (isGangLeader(_source, gang_name)) then
        local gang = gangs[gang_name]
        local inventory = {}
        local tinventory = gang.inventory
        if (tinventory == nil) then
            inventory.cash = 0
            inventory.dcash = 0
            inventory.items = {}
            -- {cash = $cash, dcash = $dcash, items = {$item1=$quantity1, $item2=$quantity2, $item3=$quantity3} }
        else
            inventory.cash = gang.inventory.cash ~= nil and gang.inventory.cash or 0
            inventory.dcash = gang.inventory.dcash ~= nil and gang.inventory.dcash or 0
            inventory.items = {}
            for k,v in pairs(tinventory.items) do 
                local item = xPlayer.getInventoryItem(k)
                inventory.items[k] = item
                if (inventory.items[k] ~= nil) then
                    inventory.items[k].count = v
                end
            end
        end
        cb(inventory)
    end
end)

ESX.RegisterServerCallback('esx_gangs:getVehicles', function(source, cb, gang_name) 
    local leader = source
    local l_gang = getPlayerGang(leader)
    local l_rank = getPlayerRank(leader, l_gang)
    local vehicles = Config.Gangs[l_gang].Vehicles
    cb(vehicles)
end)

ESX.RegisterServerCallback('esx_gangs:spawnVehicle', function(source, cb, vehicle_name) 
    local leader = source
    local l_gang = getPlayerGang(leader)
    local l_rank = getPlayerRank(leader, l_gang)
    local vehicles = Config.Gangs[l_gang].Vehicles
    if (vehicles[vehicle_name] ~= nil) then 
        local xLeader = ESX.GetPlayerFromId(leader)
        cash = xLeader.getMoney()
        if (cash - vehicles[vehicle_name] >= 0) then
            xLeader.removeMoney(vehicles[vehicle_name])
            cb(true)
        else
            TriggerClientEvent('esx:showNotification', leader, "~r~You dont have enough.~w~")
            cb(false)
        end
    else 
        cb(false)
    end
end)

ESX.RegisterServerCallback('esx_gangs:allowedToManage', function(source, cb)
    local leader = source
    local l_gang = getPlayerGang(leader)
    if (isGangLeader(leader, l_gang)) then
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent("esx_gangs:DepositItem")
AddEventHandler("esx_gangs:DepositItem", function(item, amount) 
    local leader = source
    local l_gang = getPlayerGang(leader)
    if (isGangLeader(leader, l_gang)) then
        DepositItem(item, amount, leader)
    end
end)

RegisterServerEvent("esx_gangs:RemoveItem")
AddEventHandler("esx_gangs:RemoveItem", function(item, amount) 
    local leader = source
    local l_gang = getPlayerGang(leader)
    if (isGangLeader(leader, l_gang)) then
        RemoveItem(item, amount, leader)
    end
end)

AddEventHandler('playerDropped', function()
    local _source = source
    RemovePlayerData(_source)
end)

RegisterCommand("setgang", function(src, args, raw)
    local source = src
    if (isAdmin(source)) then 
        local target = args[1]
        local gang = args[2]
        local rank = args[3]
        if (target ~= nil) then
            target = tonumber(target) ~= nil and tonumber(target) or nil
        end
        if (gang ~= nil) then 
            gang = gangs[gang] ~= nil and gangs[gang] or nil
            if (gang ~= nil and rank ~= nil) then 
                rank = tonumber(rank) ~= nil and tonumber(rank) or nil
                if (rank ~= nil) then
                    rank = rank == -1 and rank or getRankData(gang.name, rank)
                end
            end
        end
        if (target ~= nil and gang ~= nil and rank ~= nil) then 
            local xTarget = ESX.GetPlayerFromId(target)
            if (rank == -1) then
                FirePlayer(xTarget.identifier)
            else
                InsertPlayer(xTarget.identifier, gang.name, rank.ranking)
            end
        else
            chatMessage(source, "[^1ESX Gangs^0]", "^1USAGE: ^3/setgang [player_id] [gang_name] [#rank]")
        end
    else
        chatMessage(source, "[^1ESX Gangs^0]", "^1You don't have permission to use this command.")
    end
end, false)

Citizen.CreateThread(function()
    InitializeData()
    while true do 
        Citizen.Wait(1000)
        if zones then
            for k,v in pairs(zones) do 
                zones[k].capturing = zones[k].capturing ~= nil and zones[k].capturing or false
                if (zones[k].timer ~= nil and zones[k].timer > 0) then 
                    zones[k].timer = zones[k].timer - 1
                    if (zones[k].timer <= 0) then
                        zones[k].timer = nil
                        FinishCapturing(k)
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1000)
        for k,v in pairs(zones_waiting) do
            if (zones_waiting[k] > 0) then
                zones_waiting[k] = zones_waiting[k] - 1
            end
        end
    end
end)


RegisterNetEvent('esx_gangs:server:KickPlayer', function(id)
    if type(source) == "number" and source > 0 then return end
    FirePlayer(id)
end)

RegisterNetEvent('esx_gangs:server:InvitePlayer', function(id, gang)
    if type(source) == "number" and source > 0 then return end
    InvitePlayer(id, gang)
end)