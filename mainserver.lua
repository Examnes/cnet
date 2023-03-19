require("pt")

-- class for a main server
ControlServer = 
{
    instance = nil
}
ControlServer.__index = ControlServer

function callLater(delay,func)
    local event = require("event")
    local timer = event.timer(delay, func, 1)
end

function ControlServer:new(serverName)
    if ControlServer.instance then
        return ControlServer.instance
    end
    local rpc = require "rpc"
    local minitel = require "minitel"
    local component = require("component")
    local shell = require("shell")
    local vcomponent = require("vcomponent")

    local obj = {}
    obj.serverName = serverName
    obj.remotes = {}
    obj.remoteControlPort = 420

    function obj.registerRemote(remoteName)
        print("Registering remote " .. remoteName)
        obj.remotes[remoteName] = {}
    end

    function obj.callRemote(remoteName, code)
        print("Calling remote " .. remoteName)
        local result = rpc.call(remoteName, "execute", code)
        return result
    end

    function obj.getAllRemotes()
        print("Getting all remotes")
        obj.remotes = 
        {
            ["d21a6ad5"] = {},
            ["d21a6ad6"] = {}
        }
        -- register vcomponents
        callLater(10, function()
            for remoteAddr, _ in pairs(obj.remotes) do
                comps = rpc.call(remoteAddr, "getAllComponents")
                for k, comp in pairs(comps) do
                    obj.remotes[remoteAddr][#obj.remotes[remoteAddr] + 1] = comp
                end
            end
        end)
    end

    function obj.getAllComponentsWithType(ctype)
        local filtered = {}
        for remoteAddr, comps in pairs(obj.remotes) do
            for k, comp in pairs(comps) do
                if comp.type == ctype then
                    local caller = {}
                    caller.mt = {}
                    caller.mt.__index = function(t, k)
                        local functor = {}
                        functor.mt = {}
                        functor.mt.__call = function(t, ...)
                            return rpc.call(remoteAddr, comp.type .."_".. comp.address .. "_" .. k, ...)
                        end
                        setmetatable(functor, functor.mt)
                        return functor
                    end
                    setmetatable(caller, caller.mt)
                    local accessor = {}
                    accessor.call = caller
                    accessor.address = comp.address
                    filtered[#filtered + 1] = accessor
                end
            end
        end
        return filtered
    end

    function obj.getAllComponents()
        local comps = {}
        for remoteAddr, comps in pairs(obj.remotes) do
            for k, comp in pairs(comps) do
                comps[#comps + 1] = {remoteAddr, comp}
            end
        end
        return comps
    end

    rpc.register("registerRemote", obj.registerRemote)  

    setmetatable(obj, self)
    self.__index = self
    ControlServer.instance = obj
    return obj
end

ControlServer:new("mainserv").getAllRemotes()

ControlServer:new("mainserv").getAllComponentsWithType("tank_controller")


