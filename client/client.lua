local rpc = require("rpc")
local minitel = require("minitel")
local config = require("clientconfig")
local component = require("component")
local shell = require("shell")
local util = require("coolutils")
local event = require("event")
local client = {}


function client:export()
    print("Sharing all components")
    for address, componentType in component.list() do
        shell.execute("exportcomponent " .. address)
    end
end

function client.handleBroadcast(_,from, port, data)
    if port == client.msPort then
        if data == "getRemotes" then
            util.callLater(1, function() rpc.call(client.msHostname, "registerRemote", client.hostname) end)
        end
    end
end

function client.getAllComponents()
    print("Getting all components")
    local components = {}
    for address, componentType in component.list() do
        table.insert(components, {address = address, type = componentType})
    end
    return components
end

function client.execute(code)
    print("Executing code: " .. code)
    local func, error = load(code)
    if not func then
        return nil, error
    end
    local status, result = pcall(func)
    if not status then
        return nil, result
    end
    return result
end

function client.init()
    client.hostname = io.open("/etc/hostname","rb"):read()
    client.msHostname = config.msHostname
    client.msPort = config.msPort
    client:export()
    event.listen("net_broadcast", client.handleBroadcast)
    rpc.register("getAllComponents", client.getAllComponents)
    rpc.register("execute", client.execute)
end

return client
