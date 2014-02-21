--[[
	xiaoqiqiu 配置
]]--
module(...)

function dbConfig()
	return {
	    host    = '127.0.0.1',
	    port    = '3306',
	    user    = 'acol',
	    pass    = 'acol',
	    db_name = 'acol_blog',
	    charset = 'utf8'
	}
end

--article config
function artConfig()
	return {
		page_listNum 	= 5,
		content_num 	= 8
	}
end

--cron config
function cronConfig()
	return {
		cmt 	= {
			cron_num 	= 10,
			limit_time 	= 20
		},
		sort 	= {
			cron_num 	= 5,
			limit_time 	= 20
		}
	}
end