--[[
	xiaoqiqiu取文章接口

]]--

local Helper        = require "lib.helper"
local Article       = require "mod.article"
local cjson         = require "cjson"
local say           = ngx.say
local print 		= ngx.print
local print_r       = Helper.print_r
local exit          = ngx.exit
local os			= os
local WEB_ROOT 		= 'http://xiaoqiqiu.com/'

local config 		= {
	page_listNum = 5,
	content_num = 8
}

local args = ngx.req.get_uri_args()

ngx.header["Cache-Control"] 	= "no-cache"
ngx.header["Expires"] 			= "Mon, 20 Jul 1999 23:00:00 GMT"
ngx.header["Content-Type"] 		= 'text/html; charset=UTF-8'

if args['action'] == 'index' then
	local page ,user = args['page'] ,args['user']
	local callback = args['callback'] or ''

	local Art = Article:new()
	local data = Art:get_data('acol' , page , config['content_num'])

	for k,v in pairs(data['data']) do
		data['data'][k]['comment_num'] = Art:get_cmt_num(data['data'][k]['id'])

		data['data'][k]['content'] = string.gsub(data['data'][k]['content'], 'lazyload="0"', '')

		data['data'][k]['content'] = string.gsub(
				data['data'][k]['content'], 
				"<img ([^>]*) src=\"([^\"]*)\" ([^>]*)>", 
				"<img %1 src=\"".. WEB_ROOT .."view/default.jpg\" data=\"%2\" lazyload=\"1\" %3>"
			)
		
		--data['data'][k]['content'] = string.gsub(data['data'][k]['content'], "<img (.*?)src=\"(.*?)(%.jpg|%.gif|%.png){1}\"([^>]*)>", "<img %1 src=\"".. WEB_ROOT .."view/default.jpg\" %4 data=\"%2%3\"  lazyload=\"1\" />")

		data['data'][k]['time'] = os.date("%c", data['data'][k]['time'])
	end

	Art:close_db()
	print( callback ..'('.. cjson.encode( data ) ..')' )
    --exit(ngx.HTTP_OK);

end

exit(ngx.HTTP_OK)
-- http://xiaoqiqiu.com:8081/get_article?user=acol&action=index&page=2