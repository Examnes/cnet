local rpc = require "rpc"

function execute(code)
    local func, error = load(code)
    if not func then
        return nil, error
    end
    local status, result = pcall(func)
    if not status then
        return nil, result
    end
    print("function executed")
    return result
end

function main()
    rpc.register("execute", execute)
    rpc.call("mainserv", "register_remote", "d21a6ad5")
end
main()




local rpc = require "rpc"
remotes = {}
function register_remote(ip)
    remotes[#remotes + 1] = ip
    print("registered remote " .. ip)
    return true
end

function get_remotes()
    return remotes
end

function main()
    rpc.register("register_remote", register_remote)
    rpc.register("get_remotes", get_remotes)
end
main()

rpc.call("mainserv", "register_remote", "d21a6ad5")
rpc.call("d21a6ad5", "execute", "return 1 + 1")
minitel.rsend("d21a6ad5", 100, "you are gay")
minitel.usend("~",420,"gay")


rpc.call("d21a6ad5", rem["d21a6ad5"]


function rpc.register(name,fn)
 if not rpcrunning then
  event.listen("net_msg",function(_, from, port, data)
   if port == rpc.port then
    local rpcrq = serial.unserialize(data)
    local rpcn, rpcid = table.remove(rpcrq,1), table.remove(rpcrq,1)
    if rpcf[rpcn] and isPermitted(from,rpcn) then
     local rt = {pcall(rpcf[rpcn],table.unpack(rpcrq))}
     if rt[1] == true then
      table.remove(rt,1)
     end
     minitel.send(from,port,serial.serialize({rpcid,table.unpack(rt)}))
    else
     minitel.send(from,port,serial.serialize({rpcid,false,"function unavailable"}))
    end
   end
  end)
  function rpcf.list()
   local rt = {}
   for k,v in pairs(rpcf) do
    rt[#rt+1] = k
   end
   return rt
  end
  rpcrunning = true
 end
 rpcf[name] = fn
end


function rpc.call(hostname,fn,...)
    if hostname == "localhost" then
        return rpcf[fn](...)
    end
    local rv = minitel.genPacketID()
    minitel.rsend(hostname,rpc.port,serial.serialize({fn,rv,...}),true)
    local st = computer.uptime()
    local rt = {}
    repeat
        local _, from, port, data = event.pull(30, "net_msg", hostname, rpc.port)
        rt = serial.unserialize(data) or {}
    until rt[1] == rv or computer.uptime() > st + 30
    if table.remove(rt,1) == rv then
        return table.unpack(rt)
    end
    return false
end