
local Helper    = require "lib.helper"
local print_r   = Helper.print_r
--local c = require("mod.c");


where_arr = {12,3,3}
for k,v in pairs(where_arr) do
	--ngx.print(k , v)
end


local index = {}                  -- 私有的key，用来记录原始表在代理表中的下标
local mt = {                      -- 创建元表
    __index = function(t, k)
        print("访问了" .. tostring(k) .. "元素")
        return t[index][k]        -- 从代理表中获取原始表中k下标的数据
    end,
    
    __newindex = function(t, k, v)
        print("更新了 " .. tostring(k) .. " 元素的值为 " .. tostring(v))
        t[index][k] = v           -- 更新代理表中下标为index的原始表中的元素
    end
}

function setProxy(t)
    local proxy = {a=1,b=2}              -- 创建代理表
    proxy[index] = t              -- 把原始表加到代理表的index下标中
    proxy.c=3
    setmetatable(proxy, mt)       -- 设置代理表的元表
    return proxy                  -- 返回代理表，即所有操作都是直接操作代理表
end

p = setProxy({})

p['a'] = 'abcdefg'            -- 更新了 2 元素的值为 abcdefg
print_r(mt)