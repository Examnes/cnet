Client = {
    instance = nil
}
function callLater(delay,func)
    local event = require("event")
    local timer = event.timer(delay, func)
end

function Client:new(clientName, serverName, serverPort)
    if Client.instance then
        return Client.instance
    end

    local rpc = require("rpc")
    local minitel = require("minitel")
    local event = require("event")
    local component = require("component")
    local shell = require("shell")

    local obj = {}
    obj.clientName = clientName
    obj.serverName = serverName
    obj.serverPort = serverPort

    function obj.onBroadcast(_,from, port, data)
        print("Received broadcast from " .. from .. " on port " .. port .. " with data " .. data)
        if port == obj.serverPort then
            if data == "getRemotes" then
                callLater(1, function() rpc.call(obj.serverName, "registerRemote", obj.clientName) end)
            end
        end
    end

    function obj.getAllComponents()
        print("Getting all components")
        local components = {}
        for address, componentType in component.list() do
            table.insert(components, {address = address, type = componentType})
        end
        return components
    end

    function obj.execute(code)
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

    function obj.shareAll()
        print("Sharing all components")
        for address, componentType in component.list() do
            shell.execute("exportcomponent " .. address)
        end
    end

    rpc.register("execute", obj.execute)
    rpc.register("getAllComponents", obj.getAllComponents)
    event.listen("net_broadcast", obj.onBroadcast)
    obj:shareAll()

    setmetatable(obj, self)
    self.__index = self
    Client.instance = obj
    return obj
end

Client:new("d21a6ad5", "mainserv", 420)
