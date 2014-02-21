--[[
	文章相关操作类
]]--
local Helper    = require "lib.helper"
local Config 	= require "lib.config"
local XqqDb 	= require "lib.db_xqq"
local ngx       = ngx
local say       = ngx.say
local print_r   = Helper.print_r
local exit      = ngx.exit
local os 		= os

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
local this_month_nums 		= 0

-- db相关
local mysql = require "resty.mysql"


module(...)

_VERSION = '1.00'


local mt = { __index = _M }

--  constructor
function new(self , ...)
    return setmetatable({_dbname = nil}, mt)
end

function conn(self)
	if not self.db_obj then
		self.db_obj = XqqDb:new()
	end
end

--取用户列表
function get_user_list(self , cron_num)
	self:conn()

	local user_last_id = self.db_obj:get_one('SELECT id FROM ab_user WHERE status=1 ORDER BY id DESC LIMIT 1')
	local sid = self.db_obj:get_one('SELECT oid FROM update_sort_cron ORDER BY id DESC LIMIT 1')

	if sid and sid['oid'] >= user_last_id['id'] then
		self.db_obj:del(" oid<=".. user_last_id['id'] , 'update_sort_cron' , 10)
	end

	if (not sid) or (sid['oid'] >= user_last_id['id']) then
	    sid = 0
	else
	    sid = sid['oid']
	end

	local sql = "SELECT id,username FROM ab_user WHERE status=1 AND id>".. sid .." ORDER BY id ASC LIMIT ".. cron_num;
	return self.db_obj:get_all(sql)
end

--update update_sort_cron
function update_sort_cron(self , data_arr)
	return self.db_obj:insert(data_arr , 'update_sort_cron')
end

--取本月总数
function get_month_nums(self ,this_month_min ,this_month_max ,user)
	self:conn()

	--local sql = 'SELECT COUNT(*) AS C FROM ab_diary WHERE time>='.. tonumber(timestamp)
	--local res = self.db_obj:query(sql)

	this_month_nums = self.db_obj:count_nums('ab_diary', " username='".. user .."' AND  time >= "
		.. tonumber(this_month_min) ..' AND time < '.. tonumber(this_month_max) )
end
--更新本月文章总数
function update_this_month_nums(self ,this_month ,user)
	if this_month_nums < 1 then
		return
	end

	local sort_dbname = 'ab_diary_sort'
	--看看该分类是否存在
	--local this_sort_nums = self.db_obj:count_nums(sort_dbname, {name = this_month, type='time'})

	local this_sort = self.db_obj:get_one('SELECT num FROM '.. sort_dbname 
		.." WHERE name='".. this_month .."' AND type='time' AND username='".. user .."'")

	if not this_sort then

		--不存在则insert new one
		local insert_data = {
			name = this_month,
			num  = this_month_nums,
			type = 'time',
			username = user
		}
		local res = self.db_obj:insert(insert_data ,sort_dbname)
		say('\n insert')
	else
		if this_sort['num'] < this_month_nums then
			--update
			local update_data = {num = this_month_nums}
			local where_arr = {name = this_month, type='time' ,username=user}
			local res = self.db_obj:update(update_data ,where_arr ,sort_dbname)
			say('\n update')
		end
	end
	
	return res
end


--取time分类，暂时最多只展示最近5年的月份分类
function get_time_sort(self , user)
	self:conn()

	local sql = "SELECT * FROM ab_diary_sort WHERE username='".. user .."' ORDER BY id DESC LIMIT 60";
	return self.db_obj:get_all(sql)
end

--取time分类文章
-- 取文章内容
function get_time_sort_article(self , user ,page ,rows ,time ,other)
	if not user then return end
	if not page then page = 1 end

	self:conn()

	local data_nums_from_db ,res ,db_pos ,time_where_str
	local rows = tonumber(rows or content_num)

	local time_arr = Helper.split('-' , time)
	local time_data = Helper.compute_next_month(time_arr[1] ,time_arr[2])
	local this_month_min = os.time({day=1, month=time_arr[2], year=time_arr[1], hour=0, minute=0, second=0})
	local this_month_max = os.time({day=1, month=time_data['next_month'], 
		year=time_data['next_year'], hour=0, minute=0, second=0})

	--where condition
	if other == 'more' then
		time_where_str = ' AND time<'.. tonumber(this_month_max)
	else
		time_where_str = " AND time>=".. tonumber(this_month_min) ..' AND time<'.. tonumber(this_month_max)
	end

	res = self.db_obj:get_one("SELECT COUNT(*) AS C FROM ab_diary WHERE username='"..
		 user .."'".. time_where_str)
	data_nums_from_db = res['C']

	db_pos = Helper.compute_db_pos(page ,rows ,data_nums_from_db)
	
	local sql = "SELECT * FROM ab_diary WHERE username='".. user
		.."'".. time_where_str ..' ORDER BY time DESC LIMIT '.. db_pos['x'] ..','.. db_pos['y']


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