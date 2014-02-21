--[[
    更新日期分类的cron，每次只更新本月数据
    可传值更新指定月份：request: y / m
]]--

local Helper        = require "lib.helper"
local Sort        	= require "mod.sort"
local Config        = require "lib.config"
local say           = ngx.say
local print_r       = Helper.print_r
local exit          = ngx.exit
--default
local config = Config.cronConfig()
local start_time ,cron_num ,limit_time = ngx.now() ,config['sort']['cron_num'] ,config['sort']['limit_time']


local _year 				= os.date("%Y", os.time())
local _month 				= os.date("%m", os.time())

local sortObj = Sort:new()

local args = ngx.req.get_uri_args()

if args['y'] and args['m'] then
	_year 	= args['y']
	_month 	= args['m']
end

local this_month 			= _year ..'-'.. _month
local this_month_min 		= os.time({day=1, month=_month, year=_year, hour=0, minute=0, second=0})

--计算this_month_max
local next_month = _month + 1
local next_year  = _year

if next_month > 12 then
	next_month = 1
	next_year = _year + 1
end

local this_month_max 		= os.time({day=1, month=next_month, year=next_year, hour=0, minute=0, second=0})




--取用户列表
local user_list = sortObj:get_user_list(cron_num)

if user_list and #user_list > 0 then
	local num ,oid = 0 ,0

	for k,v in pairs(user_list) do
		
		--统计本月内文章数量
		sortObj:get_month_nums(this_month_min ,this_month_max ,v['username'])

		--update本月分类的num，如果不存在分类则insert
		sortObj:update_this_month_nums(this_month ,v['username'])

		oid = v['id']
		num = num + 1

		waste_time = ngx.now() - start_time
        if waste_time > limit_time then
            break;
        end
	end

	-- 更新oid
    local plan = 0
    if num > 0 then
        if num >= cron_num then 
            plan = 1;
        end

        local data_arr = {
            oid       =oid,
            plan      =plan,
            time      =ngx.localtime()
        }
        rs2 = sortObj:update_sort_cron(data_arr)
    end

end

sortObj:close_db()

say('\n耗费时间：'.. ( ngx.now() - start_time ))

exit(ngx.HTTP_OK)