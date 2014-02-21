

local Db            = require "db"
local Helper        = require "helper"
local say           = ngx.say
local print_r       = Helper.print_r
local var_dump      = Helper.var_dump
local exit          = ngx.exit;
--default
local start_time ,cron_num ,limit_time = ngx.now() ,10 ,20

--args = ngx.req.get_uri_args()
--Helper.print_r(args)

--say( ngx.time() ..'======'.. ngx.utctime() ..'============'.. ngx.now()  );

--say(start_time)
--connect


local Cron = {
    dbObj = nil,
    --  检查数据库连接
    check_db            = function(self)
        if self.dbObj == nil then
            self.dbObj  = Db.conn_db()
        end
    end,

    --  取任务起始ID
    get_start_id        = function(self)
        self:check_db()
        local sql = 'SELECT oid FROM cmt_cron ORDER BY oid DESC LIMIT 1'
        local sid = Db.get_one(self.dbObj , sql)

        if not sid then
            sid = 0
        else
            sid = sid['oid']
        end

        return sid
    end,
    
    -- 从comment表取数据
    set_comment_data    = function(self)
        local sid = self:get_start_id()
        local sql = 'SELECT id,diary_id FROM ab_comment WHERE id>'.. sid ..' ORDER BY id ASC LIMIT '.. cron_num;

        local data = Db.get_all(self.dbObj , sql)


        local waste_time = 0
        --print_r(#data ,sql)
        if data and #data > 0 then
            local num ,oid = 0 ,0
            --  update
            for i, v in ipairs(data) do
                --say(v['id'])
                if v['diary_id'] > 0 then
                    local sql = 'Update ab_diary SET cmt_num = cmt_num+1 WHERE id='.. v['diary_id']
                    local rs = Db.query(self.dbObj , sql)

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
                    local data_arr = {
                        oid       =oid,
                        plan      =plan,
                        time      =ngx.time()
                    }
                    rs2 = Db:insert(data_arr , 'cmt_cron' ,self.dbObj)
                end
            end

            --say('<br />耗费时间：'.. waste_time)
            say("\n" .. '导了几条评论：'.. num)
        else
            say("\n" .. '当前没有新的评论数据可以跑！')
        end


    end -- end fn

}   -- end talbe


--  exec
Cron:set_comment_data()


say("\n" .. 'exectime: '.. ngx.now() - start_time)