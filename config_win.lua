-- path
root = "./"
skynetroot = "./skynet_mingw/"

-- main
thread = 2
bootstrap = "snlua bootstrap"
cpath = skynetroot.."cservice/?.so"
start = "start"
lualoader = skynetroot .. "lualib/loader.lua"
lua_path = skynetroot.."lualib/?.lua;"..root.."lualib/?.lua"
lua_cpath = skynetroot .. "luaclib/?.so"
luaservice = skynetroot.."service/?.lua;"..root.."service/?.lua"
snax = root.."snax/?.lua"
profile = true
harbor = 0

-- log
-- logger = nil
-- logservice = "logger"
-- logpath = root..'logs'

-- cluster
-- standalone = "0.0.0.0:2013"
-- master = "0.0.0.0:2013"
-- address = "127.0.0.1:2526"
-- harbor = 1