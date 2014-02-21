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

	res = self.db_obj:get_one("SELECT COUNT(*) AS C FROM ab_photo WHERE username='".. user .."'")
	data_nums_from_db = res['C']

	db_pos = Helper.compute_db_pos(page ,rows ,data_nums_from_db)
	
	local sql = 'SELECT * FROM ab_photo WHERE username="'.. user ..'" ORDER BY id DESC LIMIT '.. 
		db_pos['x'] ..','.. db_pos['y']
	res = self.db_obj:get_all(sql)
	
	return {
		data 		= res,
		page 		= db_pos['page'],
		last_page 	= db_pos['last_page'],
		total 		= data_nums_from_db
	}
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