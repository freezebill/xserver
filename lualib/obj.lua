local skynet = require "skynet"

-- limit update time 0.01s
local limitUpdateTime = 10

-- weak table for memory leak
local objWeakMap = { }
setmetatable(objWeakMap, {__mode = "k"})

-- update time count
local objUpdateTimeMax = { }

local bo = { } -- base obj

function bo.new( ... )
    if bo.onNew then bo.onNew( ... ) end
end

function bo.clear( ... )
    bo.stopUpdate( )
    if bo.onClear then bo.onClear( ... ) end
end

function bo.startUpdate( ... )
    bo._updateInterval = { ... }
    bo._updateTimeCount = { }
    for i, v in ipairs( bo._updateInterval ) do
        -- bo._updateInterval[i] = bo._updateInterval[i] >= limitUpdateTime and bo._updateInterval[i] or limitUpdateTime
        assert( v >= limitUpdateTime )
        assert( bo['onUpdate'..v]( ) )
        bo._updateTimeCount[i] = 0
    end
    bo._updating = true

    skynet.fork(function()
        local lastnow = skynet.now( )
        while bo._updating do
            local now = skynet.now( )

            for i, v in ipairs( bo._updateInterval ) do
                bo._updateTimeCount[i] = bo._updateTimeCount[i] + ( now - lastnow ) * 10
                if bo._updateTimeCount[i] >= v then
                    bo._updateTimeCount[i] = bo._updateTimeCount[i] - v
                    bo['onUpdate'..v]( )
                    -- local ok, err = skynet.pcall(bo.onUpdate, i)
                end
            end

            objUpdateTimeMax[bo._objname] = math.max( objUpdateTimeMax[bo._objname] or 0, ( skynet.now( ) - now ) * 10 )
            lastnow = now
        end
    end)
end

function bo.stopUpdate( )
    bo._updateInterval = nil
    bo._updateTimeCount = nil
    bo._updating = nil
end

local obj = { }
function obj.new( objname )
    assert( objname )
    local o = { }
    setmetatable( o, bo )
    bo.__index = bo
    objWeakMap[o] = objname
    o._objname = objname
    return o
end

function obj.info( )
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

    s = s + "==========updatetimemax==========\n"
    for k, v in pairs(objUpdateTimeMax) do
        s = s + k + ":" + v + "\n"
    end
    s = s + "==========updatetimemax==========\n"

    return s
end

return obj