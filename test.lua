local function processPacket(_, localModem, from, pport, _, packetID, packetType, dest, sender, vPort, data)
    pruneCache()
    if pport == cfg.port or pport == 0 then -- for linked cards
        dprint(cfg.port, vPort, packetType, dest)
        if checkPCache(packetID) then return end
        if dest == hostname then
            if packetType == 1 then
                sendPacket(genPacketID(), 2, sender, hostname, vPort, packetID)
            end
            if packetType == 2 then
                dprint("Dropping " .. data .. " from queue")
                pqueue[data] = nil
                computer.pushSignal("net_ack", data)
            end
            if packetType ~= 2 then
                computer.pushSignal("net_msg", sender, vPort, data)
            end
        elseif dest:sub(1, 1) == "~" then -- broadcasts start with ~
            computer.pushSignal("net_broadcast", sender, vPort, data)
        elseif cfg.route then         -- repeat packets if route is enabled
            sendPacket(packetID, packetType, dest, sender, vPort, data, localModem)
        end
        if not rcache[sender] then -- add the sender to the rcache
            dprint("rcache: " .. sender .. ":", localModem, from, computer.uptime())
            rcache[sender] = { localModem, from, computer.uptime() + cfg.rctime }
        end
        if not pcache[packetID] then -- add the packet ID to the pcache
            pcache[packetID] = computer.uptime() + cfg.pctime
        end
    end
end
