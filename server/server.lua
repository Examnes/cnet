local rpc = require("rpc")
local minitel = require("minitel")
local config = require("serverconfig")
local component = require("component")
local shell = require("shell")
local util = require("coolutils")
local server = {}

function server.registerRemote(remoteName)
    print("Registering remote " .. remoteName)
    server.remotes[remoteName] = {}
end

function server.callRemote(remoteName, code)
    print("Calling remote " .. remoteName)
    local result = rpc.call(remoteName, "execute", code)
    return result
end

function server.getAllRemotes()
    server.remotes = config.remotes
    print("Getting all remotes")
    for remoteAddr, _ in pairs(server.remotes) do
        comps = rpc.call(remoteAddr, "getAllComponents")
        for k, comp in pairs(comps) do
            server.remotes[remoteAddr][#server.remotes[remoteAddr] + 1] = comp
        end
    end
end

function server.filterComponentsByType(type)
    print("Filtering components by type " .. type)
    local filtered = {}
    for remoteAddr, comps in pairs(server.remotes) do
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

function server.init()
    server.remotes = config.remotes
    server.hostname = config.hostname
    server.port = config.port
    server.getAllRemotes()
    rpc.register("registerRemote", server.registerRemote) 
end

return server