local skynet = require "skynet"

-- limit tick time 0.01s
local limitTickTime = 1

-- weak table for memory leak
local objWeakMap = { }
setmetatable(objWeakMap, {__mode = "k"})

-- tick time count
local objTickTimeMax = { }

-- base obj
local bo = { }

function bo.new( o, ... )
    if o.onNew then o.onNew( ... ) end
end

function bo.clear( o, ... )
    bo.stopTick( )
    if o.onClear then o.onClear( ... ) end
end

function bo._tick( o, t )
    skynet.timeout( t, function()
        if not bo._updating then return end
        bo._tick( o, t )

        o['tick'..t]( )
    end)
end

function bo.startTick( o, ... )
    bo._tickInterval = { ... }
    bo._updating = true
    for _, t in ipairs( bo._tickInterval ) do
        assert( t >= limitTickTime )
        assert( o['tick'..t] )

        bo._tick( o, t )
    end
end

function bo.stopTick( )
    bo._tickInterval = nil
    bo._updating = nil
    print( 'stop' , bo._updating )
end

-- obj interface
local obj = { }

function obj.init( objname )
    assert( objname )
    local o = { }
    setmetatable( o, bo )
    bo.__index = bo
    objWeakMap[o] = objname
    o._objname = objname
    return o
end

function obj.debug_info( )
    local s = ""

    s = s + "==========objnum==========\n"
    local objnum = { }
    for _, v in pairs(objWeakMap) do
        objnum[v] = ( objnum[v] or 0 ) + 1
    end
    for k, v in pairs( objnum ) do
        s = s + k + ":" + v + "\n"
    end
    s = s + "==========objnum==========\n"

    -- s = s + "==========ticktimemax==========\n"
    -- for k, v in pairs(objTickTimeMax) do
    --     s = s + k + ":" + v + "\n"
    -- end
    -- s = s + "==========ticktimemax==========\n"

    return s
end

return obj


-- skynet.fork(function()
--     local lastnow = skynet.now( )
--     while bo._updating do
--         local now = skynet.now( )

--         for i, v in ipairs( bo._tickInterval ) do
--             bo._tickTimeCount[i] = bo._tickTimeCount[i] + ( now - lastnow )
--             if bo._tickTimeCount[i] >= v then
--                 bo._tickTimeCount[i] = bo._tickTimeCount[i] - v
--                 o['tick'..v]( )
--                 -- local ok, err = skynet.pcall(bo.onTick, i)
--                 print( 'loop' , bo._updating )
--             end
--         end

--         objTickTimeMax[o._objname] = math.max( objTickTimeMax[o._objname] or 0, skynet.now( ) - now )
--         lastnow = now
--     end
-- end)