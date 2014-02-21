--[[
	xiaoqiqiu取图片列表接口

]]--

local Helper        = require "lib.helper"
local Img       	= require "mod.img"
local cjson         = require "cjson"
local say           = ngx.say
local print 		= ngx.print
local print_r       = Helper.print_r
local exit          = ngx.exit
local os			= os
local WEB_ROOT 		= 'http://xiaoqiqiu.com/'

local config 		= {
	page_listNum = 5,
	content_num = 18
}

local args = ngx.req.get_uri_args()

ngx.header["Cache-Control"] = "no-cache"
ngx.header["Expires"] = "Mon, 20 Jul 1999 23:00:00 GMT"
ngx.header["Content-Type"] = 'text/html; charset=UTF-8'

if args['action'] == 'imgList' then
	local page ,user 	= args['page'] ,args['user']
	local rows 			= args['rows'] or config['content_num']
	local callback 		= args['callback'] or ''

	local Img = Img:new()
	local data = Img:get_data('acol' , page ,rows)

	Img:close_db()
	print( callback ..'('.. cjson.encode( data ) ..')' )

end

exit(ngx.HTTP_OK)
-- http://xiaoqiqiu.com/api/imgWall/wall.php?action=imgList&user=acol&page=1&rows=18