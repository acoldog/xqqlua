--[[
	文章相关操作类
]]--
local Helper    = require "lib.helper"
local Config 	= require "lib.config"
local DbCmt 	= require "lib.db_xqq"
local ngx       = ngx
local say       = ngx.say
local print_r   = Helper.print_r

local setmetatable          = setmetatable
local type                  = type
local pairs                 = pairs
local ipairs                = ipairs
local tostring              = tostring
local tonumber              = tonumber
local next                  = next
local error                 = error
local table                 = table
local math 					= math
-- db setting
-- private
local db_set = Config.dbConfig()
local content_num = 8

-- db相关
local mysql = require "resty.mysql"


module(...)

_VERSION = '1.00'

--[[
	private fn
]]--
--	page:当前页	content_num:一页显示的数量  nums:数据总数
local function compute_db_pos(page , content_num , nums)
	local last_page = math.ceil( nums/content_num )
	local page = tonumber( page )
	local limit_X , limit_Y

	if page >= last_page then
		page = last_page
	end

	limit_X = (page - 1) * content_num
	if limit_X < 0 then limit_X = 0 end

	if (nums - limit_X) < content_num then
		limit_Y = nums - limit_X
	else
		limit_Y = content_num
	end

	return {x=limit_X ,y=limit_Y ,page=page ,last_page=last_page}
end


local mt = { __index = _M }

--  constructor
function new(self , ...)

    return setmetatable({data_nums_from_db = nil}, mt)
end

function conn(self)
	if not self.db_obj then
		self.db_obj = DbCmt:new()
	end
end

-- 取文章内容
function get_data(self , user ,page ,rows)
	if not user then return end
	if not page then page = 1 end

	self:conn()

	local data_nums_from_db ,res ,db_pos
	local rows = tonumber(rows or content_num)

	res = self.db_obj:get_one("SELECT COUNT(*) AS C FROM ab_diary WHERE username='".. user .."'")
	data_nums_from_db = res['C']

	db_pos = compute_db_pos(page ,rows ,data_nums_from_db)
	
	local sql = "SELECT * FROM ab_diary WHERE username='".. user .."' ORDER BY time DESC LIMIT ".. 
		db_pos['x'] ..','.. db_pos['y']
	res = self.db_obj:get_all(sql)
	
	return {
		data 		= res,
		page 		= db_pos['page'],
		last_page 	= db_pos['last_page'],
		total 		= data_nums_from_db
	}
end

-- 取指定文章评论数
function get_cmt_num(self , id)
	self:conn()

	local sql = "SELECT COUNT(*) AS C FROM ab_comment WHERE `sort`='say' AND `sort_id`=".. id
	local res = self.db_obj:get_one(sql)

	if not res then
		return 0
	else	
		return res['C']
	end
end


-- 关闭数据库连接
function close_db(self)
	if self.db_obj then
		self.db_obj:close()
	end
end





setmetatable(_M, {
    __newindex = function (table, key, val)
        ngx.log(ngx.EMERG ,'--attempt to write to undeclared variable "' .. key .. '" val:"'.. val ..'" in ' .. table._NAME);
    end
})