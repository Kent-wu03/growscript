Config = {
    wRota = {"world|world1"},
    wStorage = {"worldstorage|doorid"},
    wBlock = 4584,
    wDelay = 200,
    wPack = "world_lock",
    wPackPrice = 2000,
    wTrash = {7162, 5044, 5042, 5026},
    wHit = 4,
    wPosBreak = {3, 1},
    wPackID = {192},
    wDropPos = {79, 23}
}

ChangeValue("[C] Modfly v2", true)

Config.wSeed = Config.wBlock + 1

function log(x)
    SendVariantList({[0] = "OnTextOverlay", [1] = "`w[ `eDoctor Script `w] : " .. x})
    LogToConsole("`w[ `eDoctor Script `w] : " .. x)
end

function inv(id)
    for _, item in pairs(GetInventory()) do
        if item.id == id then return item.amount end
    end
    return 0
end

function trsh(ids)
    for _, id in ipairs(ids) do
        wC = inv(id)
        if wC >= 15 then
            SendPacket(2, "action|trash\n|itemID|"..id)
            Sleep(1000)
            SendPacket(2, "action|dialog_return\ndialog_name|trash_item\nitemID|"..id.."|\ncount|"..wC)
            Sleep(1010)
            log("Trashed "..id.." x"..wC)
        end
    end
end

function rw(t, s, id, x, y)
    SendPacketRaw(false, { type = t, state = s, value = id, px = x, py = y, x = x*32, y = y*32 })
end

function m(tx, ty, s, h)
    s = s or 4
    while true do
        local x, y = GetLocal().pos.x // 32, GetLocal().pos.y // 32
        if x == tx and y == ty then return true end
        local dx, dy, nx, ny = tx - x, ty - y, x, y
        if h then 
            nx = x + math.max(-s, math.min(s, dx)) 
            if nx == x then ny = y + math.max(-s, math.min(s, dy)) end
        else 
            ny = y + math.max(-s, math.min(s, dy)) 
            if ny == y then nx = x + math.max(-s, math.min(s, dx)) end 
        end
        FindPath(nx, ny)
        Sleep(300 + math.random(30, 80))
    end
end

function cBlock(id, radius)
    local px = math.floor(GetLocal().pos.x / 32)
    local py = math.floor(GetLocal().pos.y / 32)
    for _, obj in pairs(GetObjectList()) do  
        local ox = math.floor((obj.pos.x + 8) / 32)  
        local oy = math.floor((obj.pos.y + 8) / 32)  
        if obj.id == id and math.abs(px - ox) <= radius and math.abs(py - oy) <= radius then  
            SendPacketRaw(false, {  
                type = 11,  
                value = obj.oid,  
                x = obj.pos.x,  
                y = obj.pos.y  
            })  
            Sleep(10)  
        end  
    end
end

function cAll(radius)
    cBlock(Config.wBlock, radius)
    cBlock(Config.wSeed, radius)
    cBlock(112, radius)
    for _, y in ipairs(Config.wTrash) do
        cBlock(y, radius)
    end
end

function wDropItem(id, limit)
    for attempts = 1, 20 do
        if inv(id) >= limit then
            log("Dropping "..id.." Trying: ["..attempts.." / 20]")
            m(Config.wDropPos[1], Config.wDropPos[2])
            Sleep(1000)
            SendPacket(2, "action|drop\n|itemID|"..id)
            Sleep(1000)
            SendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|"..id.."|\ncount|"..inv(id))
            Sleep(1000)
        else
            return
        end
    end
    if inv(id) >= limit then
        Config.wDropPos[2] = Config.wDropPos[2] - 2
        m(Config.wDropPos[1], Config.wDropPos[2], 1, false)
        Sleep(1000)
        SendPacket(2, "action|drop\n|itemID|"..id)
        Sleep(1000)
        SendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|"..id.."|\ncount|"..inv(id))
        Sleep(1000)
    end
end

function wBuyPack()
    while GetPlayerInfo().gems >= Config.wPackPrice do
        SendPacket(2, "action|buy\nitem|" .. Config.wPack)
        log("Buying Pack: "..Config.wPack)
        Sleep(1000)
    end
end

function wPnb()
    m(Config.wPosBreak[1], Config.wPosBreak[2])
    Sleep(200)
    while inv(Config.wBlock) >= 15 do
        local x = math.floor(GetLocal().pos.x / 32)
        local y = math.floor(GetLocal().pos.y / 32 - 1)
        for i = -2, 2 do
            rw(3, nil, Config.wBlock, x + i, y)
            Sleep(150)  
        end      
        for h = 1, Config.wHit do
            for i = -2, 2 do
                rw(3, nil, 18, x + i, y)
                Sleep(170)  
                cAll(2)
            end
        end
        Sleep(150)    
    end
end

function wPlant()
    for _, tile in pairs(GetTiles()) do
        if tile.fg == 0 and GetTile(tile.x, tile.y + 1).fg ~= 0 
        and GetTile(tile.x, tile.y + 1).fg % 2 == 0 
        and inv(Config.wSeed) > 0 then
            FindPath(tile.x, tile.y)
            Sleep(Config.wDelay)
            rw(3, nil, Config.wSeed, tile.x, tile.y)
            log("Planted seed at (" .. tile.x .. "," .. tile.y .. ")")
            Sleep(Config.wDelay)
        end
    end
end

wCont = 1
while true do
    if wCont > #Config.wRota then wCont = 1 end
    local currWorld = Config.wRota[wCont]:lower()
    log("Join World: "..currWorld)
    RequestJoinWorld(currWorld)
    Sleep(5000)
    
    for _, tile in pairs(GetTiles()) do
        if tile.fg == Config.wSeed and tile.extra and tile.extra.progress == 1.0 then
            FindPath(tile.x, tile.y)
            Sleep(Config.wDelay - 10)
            rw(3, nil, 18, tile.x, tile.y)
            log("Harvest (" .. tile.x .. "," .. tile.y .. ")")
            Sleep(Config.wDelay -10)
            cAll(3)
            
            if inv(Config.wBlock) > 80 then
                log("Break Block And Buying Pack...")
                trsh(Config.wTrash)
                wPnb()
                wBuyPack()
                for _, g in ipairs(Config.wPackID) do
                    if inv(g) >= 15 then
                        for _, p in ipairs(Config.wStorage) do
                            log("Warping To Storage (Drop Pack & Seed): " .. p)
                            RequestJoinWorld(p)
                            Sleep(3000)
                            wDropItem(g, inv(g))
                            wDropItem(Config.wSeed, inv(Config.wSeed))
                            log("Dropped pack item: " .. g)
                            Sleep(500)
                            log("Returning to farm: " .. currWorld)
                            RequestJoinWorld(currWorld)
                            Sleep(3000)
                            break
                        end
                    end
                end
            end
            if inv(Config.wBlock) < 15 then
                log("Planting...")
                wPlant()
                Sleep(1000)
            end
        end
    end

    if inv(Config.wSeed) > 0 then
        for _, h in ipairs(Config.wStorage) do
            log("Warping To Storage (Drop Seed): " .. h)
            RequestJoinWorld(h)
            Sleep(3000)
            wDropItem(Config.wSeed, inv(Config.wSeed))
            log("Dropped " .. inv(Config.wSeed) .. " seeds")
            Sleep(1000)
            log("Returning to farm: " .. currWorld)
            RequestJoinWorld(currWorld)
            Sleep(3000)
            break
        end
        log("Resting for 1 minute...")
        Sleep(60 * 1000)
    end
    log("World " .. currWorld .. " done, moving to next world!")
    wCont = wCont + 1
    Sleep(5000)
end