local skynet = require "skynet"

-- limit tick time 0.01s
local limitTickTime = 1

-- weak table for memory leak
local objWeakMap = { }
setmetatable( objWeakMap, { __mode = "k" })

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
        if not bo._ticking or not  bo._ticking[t] then return end

        bo._tick( o, t )

        local tt = skynet.now( )
        o['tick'..t]( )
        objTickTimeMax[t] = math.max( ( objTickTimeMax[t] or 0 ), skynet.now( ) - tt )
    end)
end

function bo.startTick( o, ... )
    bo._tickInterval = { ... }
    bo._ticking = bo._ticking or { }
    for _, t in ipairs( bo._tickInterval ) do
        assert( t >= limitTickTime )
        assert( o['tick'..t] )
        assert( bo._ticking[t] )
        bo._ticking[t] = 1
        bo._tick( o, t )
    end
end

function bo.stopTick( )
    bo._tickInterval = nil
    bo._ticking = nil
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

    s = s + "==========ticktimemax==========\n"
    for k, v in pairs(objTickTimeMax) do
        s = s + k + ":" + v + "\n"
    end
    s = s + "==========ticktimemax==========\n"

    return s
end

return obj