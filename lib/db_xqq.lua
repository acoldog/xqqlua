local Helper    = require "lib.helper"
local Config    = require "lib.config"
local ngx       = ngx
local say       = ngx.say
local print_r   = Helper.print_r
local exit      = ngx.exit

local setmetatable          = setmetatable
local type                  = type
local pairs                 = pairs
local ipairs                = ipairs
local tostring              = tostring
local tonumber              = tonumber
local next                  = next
local error                 = error
local table                 = table
-- db setting
-- private
local db_set = Config.dbConfig()

-- db相关
local mysql = require "resty.mysql"


module(...)

_VERSION = '1.00'

--[[
    private function
]]--

-- where
local function where(where_arr)
    local i ,where = 1 ,{}

    if where_arr then
        if type(where_arr) == 'table' then
            for k,v in pairs(where_arr) do
                where[i] = k ..'=\''.. v ..'\''
                i = i + 1
            end
            where = table.concat(where , ' AND ')
        else
            where = tostring(where_arr)
        end

        return " WHERE ".. where
    else
        return ""
    end
end

--[[
    public
]]--
local mt = { __index = _M }

--  constructor
function new(self , ...)
    --local db, err = mysql:new()

    return setmetatable({_connDb = nil}, mt)
end



-- db连接
function conn_db(self)
    if not self._db then
        self._db, self._err = mysql:new()
    end

    -- 保证只conn一次
    if self._connDb then
        return
    end

    if not self._db then
       ngx.say("failed to instantiate mysql: ", self._err)
       return
    end

    self._db:set_timeout(1000) -- 1 sec

    local ok, err, errno, sqlstate = self._db:connect{
                host = db_set['host'],
                port = db_set['port'],
                database = db_set['db_name'],
                user = db_set['user'],
                password = db_set['pass'],
                max_packet_size = 1024 * 1024 }

    --  set names要在connect之后
    local charset = db_set['charset'] or 'utf8';
    self._db:query("SET NAMES " .. charset);

    if not ok then
        ngx.say("failed to connect: ", err, ": ", errno, " ", sqlstate)
        return
    end

    --  正在连接的库
    self._connDb = db_set['db_name']
    --ngx.say('yes');
    --return self._db
end

--query
function query(self , sql)
    self:conn_db()

    return self._db:query(sql)
end

--get one
function get_one(self ,sql)
    self:conn_db()

    local rs = self._db:query(sql)

    return rs[1]
end

--get all
function get_all(self ,sql)
    self:conn_db()

    local rs = self._db:query(sql)
    return rs
end

--count nums
function count_nums(self ,table_name ,where_arr)
    self:conn_db()

    local sql = 'SELECT COUNT(*) AS C FROM '.. table_name .. where(where_arr)
    local res = self._db:query(sql)

    if not res then
        return 0
    else
        return tonumber(res[1]['C'])
    end
end

--insert
function insert(self , insert_data ,table_name)
    self:conn_db()
    
    local i ,col ,val ,sql = 1 ,{} ,{} ,''

    for k,v in pairs(insert_data) do
        col[i] = '`'.. k ..'`'
        val[i] = '\''.. v ..'\''
        i = i + 1
    end

    col = table.concat(col , ',')
    val = table.concat(val , ',')

    --ngx.say(col)
    sql = 'INSERT INTO '.. table_name ..' ( '.. col ..' ) VALUES ( '.. val ..' )'

    local res, err, errno, sqlstate = self._db:query(sql)
    return res

end

--update
function update(self , update_data ,where_arr ,table_name)
    self:conn_db()
    local sql ,update_str;
    
    if type(update_data) == 'table' then
        local i ,update_arr ,sql = 1 ,{} ,''

        for k,v in pairs(update_data) do
            update_arr[i] = '`'.. k ..'`=\''.. v ..'\''
            i = i + 1
        end

        update_str = table.concat(update_arr , ',')
    else
        update_str = tostring(update_data)
    end

    --ngx.say(col)
    sql = 'UPDATE `'.. table_name ..'` SET '.. update_str .. where(where_arr)

    local res, err, errno, sqlstate = self._db:query(sql)
    return res

end

--db del
function del(self ,where_arr ,table_name ,limit)
    self:conn_db()
    local sql
    if not limit then
        local limit = 1
    end

    sql = 'DELETE FROM '.. table_name ..' WHERE '.. where_arr ..' LIMIT '.. limit
    print_r(sql)
    local res, err, errno, sqlstate = self._db:query(sql)
    return res
end

--db close
function close(self)
    if self._db then
        self._db:close()
    end
end


-- 原话：to prevent use of casual module global variables
-- 这个可以防止new出来的实例table产生全局变量，所以要注意table实体里的参数都要是局部变量，否则就报error
setmetatable(_M, {
    __newindex = function (table, key, val)
        ngx.log(ngx.EMERG ,'--attempt to write to undeclared variable "' .. key .. '" val:"'.. val ..'" in ' .. table._NAME);
    end
})