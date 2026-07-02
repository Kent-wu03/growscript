SendPacket(2,"action|input\ntext|`2Dirt Farm SC By `brockybandel")

function breakfarm(x, y)
    local pkt = {
        type = 3,
        value = 18,
        px = x,
        py = y,
        x = GetLocal().pos.x,
        y = GetLocal().pos.y
    }

    SendPacketRaw(false, pkt)
    Sleep(120)
end

function findTarget()
    for _, tile in ipairs(GetTiles()) do
        if (tile.y % 2 == 1 or tile.x <= 1 or tile.x >= 98) then
            if tile.fg == 2
            or (tile.bg == 14 and tile.fg == 0)
            or tile.fg == 10
            or tile.fg == 4 then
                return tile
            end
        end
    end
    return nil
end

while true do
    local tile = findTarget()

    if tile then
        FindPath(tile.x, tile.y - 2)
        breakfarm(tile.x, tile.y)
    else
        Sleep(500)
		LogToConsole("`9DONE")
		break
    end
end
