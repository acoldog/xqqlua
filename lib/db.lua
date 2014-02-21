module(..., package.seeall);
local Helper    = require "helper"
local Config    = require "lib.config"
local say       = ngx.say
local print_r   = Helper.print_r
-- db settingmodule("db", package.seeall);

-- db setting
-- private
local db_set = Config.dbConfig()
-- pulbic


-- db相关
local mysql = require "resty.mysql"

-- db连接
function conn_db(self)

    local db, err = mysql:new()

    if not db then
       ngx.say("failed to instantiate mysql: ", err)
       return
    end

    db:set_timeout(1000) -- 1 sec

    local ok, err, errno, sqlstate = db:connect{
                host = db_set['host'],
                port = db_set['port'],
                database = db_set['db_name'],
                user = db_set['user'],
                password = db_set['pass'],
                max_packet_size = 1024 * 1024 }

    if not ok then
        ngx.say("failed to connect: ", err, ": ", errno, " ", sqlstate)
        return
    end
    --ngx.say('yes');
    return db
end

--get one
function get_one(dbObj ,sql)
    local rs = dbObj:query(sql)
    return rs[1]
end

--get all
function get_all(dbObj ,sql)
    local rs = dbObj:query(sql)
    return rs
end

--query
function query(dbObj , sql)
    local res, err, errno, sqlstate = dbObj:query(sql)
    return res
end

--insert
function insert(self , insert_data ,table_name ,dbObj)
    local col ,val ,j ,sql = {} ,{} ,1 ,''

    for k,v in pairs(insert_data) do
        col[j] = '`'.. k ..'`'
        val[j] = '\''.. v ..'\''
        j = j + 1
    end

    col = table.concat(col , ',')
    val = table.concat(val , ',')

    --ngx.say(col)
    sql = 'INSERT INTO '.. table_name ..' ( '.. col ..' ) VALUES ( '.. val ..' )'
    local res, err, errno, sqlstate = dbObj:query(sql)
    return res

end


-- private
local db_set = {
    host    = '127.0.0.1',
    port    = '3306',
    user    = 'acol',
    pass    = 'acol',
    db_name = 'acol_blog',
    charset = 'utf8'
}
-- pulbic


-- db相关
local mysql = require "resty.mysql"

-- db连接
function conn_db(self)
    if not self.db then
        self.db, self.err = mysql:new()
    else
        return
    end

    if not self.db then
       ngx.say("failed to instantiate mysql: ", self.err)
       return
    end

    self.db:set_timeout(1000) -- 1 sec

    local ok, err, errno, sqlstate = self.db:connect{
                host = db_set['host'],
                port = db_set['port'],
                database = db_set['db_name'],
                user = db_set['user'],
                password = db_set['pass'],
                max_packet_size = 1024 * 1024 }

    if not ok then
        ngx.say("failed to connect: ", err, ": ", errno, " ", sqlstate)
        return
    end
    --ngx.say('yes');
    return self.db
end

--get one
function get_one(self ,sql)
    conn_db()
    local rs = self.db:query(sql)
    return rs[1]
end

--get all
function get_all(self ,sql)
    local rs = self.db:query(sql)
    return rs
end

--query
function query(self , sql)
    local res, err, errno, sqlstate = self.db:query(sql)
    return res
end

--insert
function insert(self , insert_data ,table_name)
    local col ,val ,j ,sql = {} ,{} ,1 ,''

    for k,v in pairs(insert_data) do
        col[j] = '`'.. k ..'`'
        val[j] = '\''.. v ..'\''
        j = j + 1
    end

    col = table.concat(col , ',')
    val = table.concat(val , ',')

    --ngx.say(col)
    sql = 'INSERT INTO '.. table_name ..' ( '.. col ..' ) VALUES ( '.. val ..' )'
    local res, err, errno, sqlstate = self.db:query(sql)
    return res

end

