_G.Net = { }

Net.cache = { }
-- key=address, status, net,
-- status disconnect, connecting, connected

Net.timeout = 600
Net.maxdatasize = 65535
Net.headsize = 2

function IntPackToString(num)
	local byte1 = math.floor(num/256)
	local byte2 = num%256
	local char1 = string.char(byte1)
	local char2 = string.char(byte2)
	return char1..char2
end

function StringPackToInt(str)
	k1,k2 = string.byte(str,1,2)
	local num1 = tonumber(k1)
	local num2 = tonumber(k2)
	return num1*256+num2
end


function Net.sendn( net, data, from, to )
    print( 'sendn', net, data, from ,to )
    local sended = net:send(data, from, to, true)
    if sended < to then
        Net.sendn( net, data, sended, to )
    end
end

function Net.onConnect( key, net )
    -- parse net stream
    local str, datasize
    function onBody( net, data )
        Net.onReceive( key, data:tostr() )

        net:receive(Net.headsize, onHead, Net.timeout)
    end
    function onHead( net, data )
        datasize = StringPackToInt(data) -- 1-2

        if datasize < 0 or datasize > Net.maxdatasize then
            Error('datasize error')
            Net.close( key, 'datasize error' )
        elseif datasize == 0 then
            onBody(net, nil)
        else
            net:receive(datasize, onBody, Net.timeout)
        end
    end

    net:nagle( false )
    local nt = Net.cache[key]
    nt.net = net
    nt.status = 'connected'
    if nt.onConnect then nt.onConnect( ) end

    net:receive(Net.headsize, onHead, Net.timeout)
end

function Net.onClose( key )
    local nt = Net.cache[key]
    nt.net = nil
    nt.status = 'disconnect'
    if nt.onClose then nt.onClose( nt.closeReason ) end
    nt.closeReason = nil
end

function Net.onFail( key )
    local nt = Net.cache[key]
    nt.net = nil
    nt.status = 'disconnect'
    if nt.onFail then nt.onFail( ) end
end

function Net.onReceive( key, data )
    local nt = Net.cache[key]
    if nt.onReceive then nt.onReceive( data ) end
end

-- public
function Net.connect( key, address, onConnect, onFail, onClose, onReceive, connecttimeout )
    Net.cache[key] = Net.cache[key] or { status = 'disconnect' }

    local nt =  Net.cache[key]
    if nt.status ~= 'disconnect' then return end
    nt.address = address
    nt.onConnect = onConnect
    nt.onFail = onFail
    nt.onClose = onClose
    nt.onReceive = onReceive
    nt.status = 'connecting'
    nt.connecttimeout = connecttimeout or 10

    _connect( address,
        function (net)
            Net.onConnect( key, net )
        end,
        function (net)
            if nt.status == 'connected' then
                Net.onClose( key )
            else
                Net.onFail( key )
            end
        end,
        connecttimeout
    )
end

function Net.close( key, reason )
    local nt = Net.cache[key]
    if not nt then return end

    if nt.net then
        nt.net:close()
        nt.net = nil
    end

    nt.closeReason = reason
end

function Net.send( key, data )
    local nt = Net.cache[key]
    assert( nt and nt.status == 'connected', 'not connected key:'..key )
    assert( nt.net, 'net nil error' )

    local size = #data
    assert( size <= Net.maxdatasize, 'send data so big：' .. data )

    Net.sendn( nt.net, IntPackToString(size) .. data, 0, 2 + size )
end

function Net.isConnected( key )
    local nt = Net.cache[key]
    return nt and nt.net and nt.status == 'connected'
end