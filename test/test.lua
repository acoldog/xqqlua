ngx.header.content_type = 'text/plain';
ngx.req.set_header("Foo", {"a", "abc"});
local Helper = require "lib.helper";

local print_r = Helper.print_r;
local say   = ngx.say;
local acol=12;

--  ȡget²Îýl 
args = ngx.req.get_uri_args()
-- for key, val in pairs(args) do
--     if type(val) == "table" then
--         say(key, ": ", table.concat(val, ", "))
--     else
--         say(key, ": ", val)
--     end
-- end


local a = {x=1, y=2, label={text='hans', color='blue'}, list={'a','b','c'}}   
  
--Helper.print_r(args);

local Obj = {
    key = 'acolkey',

    print = function(self , op)
        say(self.key .. op[1] );
    end,

}

--Obj:print( {123, 345} );
--Print:pr(a)

print_r('ngx.today=>'.. ngx.today() ..'\n')
print_r('ngx.time=>'.. ngx.time() ..'\n')
print_r('ngx.now=>'.. ngx.now() ..'\n')
--print_r('ngx.update_time=>'.. ngx.update_time() ..'\n')
print_r('ngx.localtime=>'.. ngx.localtime() ..'\n')
print_r('ngx.utctime=>'.. ngx.utctime() ..'\n')

print_r( os.date("%Y-%m", os.time()) ..'\n' )

print_r( os.time({day=1, month=11, year=2013, hour=0, minute=0, second=0}) ..'\n' )

a = Helper.split('-' ,'2013-11')
local b=3
a[2014]={'acol'}
a[12] = 11111
print_r(a)
