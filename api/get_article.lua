--[[
	xiaoqiqiu取文章接口

]]--
ngx.header["Cache-Control"] 	= "no-cache"
ngx.header["Expires"] 			= "Mon, 20 Jul 1999 23:00:00 GMT"
ngx.header["Content-Type"] 		= 'text/html; charset=UTF-8'

local Helper        = require "lib.helper"
local cjson         = require "cjson"
local Config    	= require "lib.config"
local say           = ngx.say
local print 		= ngx.print
local print_r       = Helper.print_r
local exit          = ngx.exit
local os			= os
local WEB_ROOT 		= 'http://xiaoqiqiu.com/'
local STATIC_ROOT 	= 'http://static.xiaoqiqiu.com/'

local config 		= Config.artConfig()

local args = ngx.req.get_uri_args()
local page ,user = args['page'] ,args['user']
local callback = args['callback'] or ''


function filter_something(data)
	if type(data) == 'table' then
		for k,v in pairs(data['data']) do

			data['data'][k]['content'] = string.gsub(data['data'][k]['content'], 'lazyload="0"', '')

			data['data'][k]['content'] = string.gsub(
					data['data'][k]['content'], 
					"<img ([^>]*) src=\"([^\"]*)\" ([^>]*)>", 
					"<img %1 src=\"".. STATIC_ROOT .."default.jpg\" data=\"%2\" lazyload=\"1\" %3>"
				)
			
			--data['data'][k]['content'] = string.gsub(data['data'][k]['content'], "<img (.*?)src=\"(.*?)(%.jpg|%.gif|%.png){1}\"([^>]*)>", "<img %1 src=\"".. WEB_ROOT .."view/default.jpg\" %4 data=\"%2%3\"  lazyload=\"1\" />")

			data['data'][k]['time'] = os.date("%c", data['data'][k]['time'])
		end
	end

	return data
end



--[[
	取默认列表
]]
if args['action'] == 'index' then
	
	local Article       = require "mod.article"
	local Art = Article:new()

	local data = Art:get_data(user , page , config['content_num'])

	data = filter_something(data)

	for k,v in pairs(data['data']) do

		data['data'][k]['comment_num'] = Art:get_cmt_num(data['data'][k]['id'])
	end

	Art:close_db()
	print( callback ..'('.. cjson.encode( data ) ..')' )

	-- http://xiaoqiqiu.com:8081/get_article?user=acol&action=index&page=2

--[[
	按分类取
]]
elseif args['action'] == 'sort' then
	
	local Sort       	= require "mod.sort"
	local sortObj 		= Sort:new()

	local type 			= args['type'] or 'time'
	local data 			= {}
	local time 			= args['time'] or os.date("%Y-%m", os.time())
	local other 		= args['other'] or ''
	
	if type == 'time' then
		data = sortObj:get_time_sort_article(user ,page ,config['content_num'] ,time ,other)
	end

	data = filter_something(data)

	sortObj:close_db()
	print( callback ..'('.. cjson.encode( data ) ..')' )
	--http://xiaoqiqiu.com:8081/api/get_article?user=acol&action=sort&time=2013-11
	
end

exit(ngx.HTTP_OK)
