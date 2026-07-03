ids = 5640 -- magplant remote
delay = 100
wplace = "SVJGL"
delay_recon = 3500
-- do not touch

isplace = true
dc = false

function ltc(text)
    LogToConsole("`^" .. text)
end

function inv(id)
    for _, item in pairs(GetInventory()) do
        if item.id == id then return item.amount end
    end
    return 0
end

function placeb(x,y)
pkt = {}
pkt.type = 3
pkt.value = ids
pkt.px = x
pkt.py = y
pkt.x = GetLocal().pos.x
pkt.y = GetLocal().pos.y
SendPacketRaw(false,pkt)
Sleep(180)
end

function getdata()
    for _, tile in ipairs(GetTiles()) do
        if tile.fg == 0 then
            return tile
        end
    end
    return nil
end


function placing()
    while isplace do
        local world = GetWorld()
        if not world or world.name ~= wplace then
            Sleep(1300)
            ltc("Reconnecting to " .. wplace)
            RequestJoinWorld(wplace)
            Sleep(delay_recon)
            world = GetWorld()
            if world and world.name == wplace then
                dc = true
            end
        end

        if dc then
            log("Going back to pos")
            dc = false
        end

        Sleep(200)

        local tile = getdata()
            if tile then
                FindPath(tile.x, tile.y+1, 500)
                local t = GetTile(tile.x, tile.y)
                if t and t.fg == 0 then
                    placeb(tile.x, tile.y)
                end
            else
                log("Done Place")
                Sleep(500)
                isplace = false
                break            
            end

        Sleep(100)
    end
end

while true do
    if not isplace then
        break
    end

    local ok, err = pcall(placing)
    if not ok then
        ltc("Error: " .. tostring(err))
        Sleep(3000)
    end
    Sleep(200)
end