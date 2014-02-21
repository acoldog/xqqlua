-- TEST

local Helper = require "lib.helper"
local say = ngx.say
local print_r = Helper.print_r
local var_dump = Helper.var_dump

local data_arr = {
            oid       =1,
            plan      =2,
            time      =ngx.time()
        }
local d = {}
for i,v in pairs(data_arr) do
	--print_r(i..'==='..v)
end



function acol(data , i)
	print_r(data )
	print_r(i)
end

--acol(data_arr,'123')
--print_r(data_arr.oid)

function greet()
    ngx.print("hello world\n")
end

co = coroutine.create(greet) -- 创建 coroutine

ngx.print(coroutine.status(co),"\n")  -- 输出 suspended
ngx.print(coroutine.resume(co),"\n")  -- 输出 hello world
                             -- 输出 true (resume 的返回值)
ngx.print(coroutine.status(co),"\n")  -- 输出 dead
ngx.print(coroutine.resume(co),"\n")  -- 输出 false    cannot resume dead coroutine (resume 的返回值)
ngx.print(type(co),"\n")              -- 输出 thread



print_r( string.gsub("hello, world", "(o)", "%1-%1") )