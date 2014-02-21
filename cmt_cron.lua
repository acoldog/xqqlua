

local Db            = require "lib.db_xqq"
local Helper        = require "lib.helper"
local say           = ngx.say
local print_r       = Helper.print_r
local var_dump      = Helper.var_dump
local exit          = ngx.exit;
local tonumber      = tonumber
--default
local start_time ,cron_num ,limit_time = ngx.now() ,10 ,20


--  取任务起始ID
local db = Db:new()

local sid = db:get_one('SELECT oid FROM cmt_cron ORDER BY oid DESC LIMIT 1')

if not sid then
    sid = 0
else
    sid = sid['oid']
end
--  取全部未处理的评论
local sql = 'SELECT id,diary_id FROM ab_comment WHERE id>'.. sid ..' ORDER BY id ASC LIMIT '.. cron_num;

local data = db:get_all(sql)

local waste_time = 0

if data and #data > 0 then
    local num ,oid = 0 ,0
    --  update
    for i, v in ipairs(data) do
        --say(v['id'])
        if v['diary_id'] > 0 then
            --local sql = 'Update ab_diary SET cmt_num = cmt_num+1 WHERE id='.. v['diary_id']
            --local rs = db:query(sql)

            local rs = db:update('cmt_num = cmt_num+1' ,{id = tonumber(v['diary_id'])} ,'ab_diary')

            num = num + 1
            oid = v['id']
        end

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
        rs2 = db:insert(data_arr , 'cmt_cron')
    end

    --say('<br />耗费时间：'.. waste_time)
    say("\n" .. '导了几条评论：'.. num)
else
    say("\n" .. '当前没有新的评论数据可以跑！')
end


db:close()


say("\n" .. 'exectime: '.. ngx.now() - start_time)
exit(ngx.HTTP_OK)