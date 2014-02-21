--[[
	xiaoqiqiu取分类列表接口

]]--
ngx.header["Cache-Control"] = "no-cache"
ngx.header["Expires"] = "Mon, 20 Jul 1999 23:00:00 GMT"
ngx.header["Content-Type"] = 'text/html; charset=UTF-8'

local Helper        = require "lib.helper"
local Sort       	= require "mod.sort"
local cjson         = require "cjson"
local say           = ngx.say
local print 		= ngx.print
local print_r       = Helper.print_r
local exit          = ngx.exit
local os			= os
local tonumber      = tonumber
local WEB_ROOT 		= 'http://xiaoqiqiu.com/'

local args = ngx.req.get_uri_args()

--取时间分类，（按年份归类--暂不做）
if args['action'] == 'time' then
	local sortObj 		= Sort:new()
	local user 			= args['user'] or 'acol'
	local data 			= sortObj:get_time_sort(user)
	local callback 		= args['callback'] or ''
	local return_data 	= {}
	local time_sort 	= '2014'	--因为是排序过的

	return_data[time_sort] 	= {}
	return_data2 			= {}
	local i, j 				= 1, 1
	return_data2[i] 		= {}	--每个数组元素是数组时都要定义一下

	for k,v in pairs(data) do
		-- local name = Helper.split('-' , v['name'])
		-- data[k]['year'] = tonumber(name[1])
		-- data[k]['name'] = name[2]

		-- if name[1] == time_sort then
		-- 	return_data[time_sort][i] = v
		-- 	i = i + 1
		-- else
		-- 	time_sort = name[1]
		-- 	return_data[time_sort] 	= {}
		-- 	i = 1
		-- 	return_data[time_sort][i] = v
		-- 	i = i + 1
		-- end
		
		local name = Helper.split('-' , v['name'])
		data[k]['year'] = tonumber(name[1])
		data[k]['name'] = name[2]

		if name[1] == time_sort then
			return_data2[i][j] = v
			j = j + 1
		else
			i = i + 1
			time_sort = name[1]
			return_data2[i] 	= {}
			j = 1
			return_data2[i][j] = v
			j = j + 1
		end
	end

	print( callback ..'('.. cjson.encode( return_data2 ) ..')' )
end

exit(ngx.HTTP_OK)

-- http://xiaoqiqiu.com:8081/api/get_sort?action=time