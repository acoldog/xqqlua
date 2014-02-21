ngx.header.content_type = 'text/plain';
ngx.req.set_header("Foo", {"a", "abc"});
local Helper = require "lib.helper";

local Print = ngx.print;
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
  
Helper.print_r(args);

local Obj = {
    key = 'acolkey',

    print = function(self , op)
        say(self.key .. op[1] );
    end,

}

Obj:print( {123, 345} );
--Print:pr(a)