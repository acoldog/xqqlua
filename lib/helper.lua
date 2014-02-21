-- acol's lib

module(..., package.seeall);
local ngx       = ngx
local string    = string
local print = ngx.print;
local say   = ngx.say;

function pr (t, name, indent)   
    local tableList = {}   
    function table_r (t, name, indent, full)   
        local id = not full and name or type(name)~="number" and tostring(name) or '['..name..']'   
        local tag = indent .. id .. ' = '   
        local out = {}  -- result   
        if type(t) == "table" then   
            if tableList[t] ~= nil then   
                table.insert(out, tag .. '{} -- ' .. tableList[t] .. ' (self reference)')   
            else  
                tableList[t]= full and (full .. '.' .. id) or id  
                if next(t) then -- Table not empty   
                    table.insert(out, tag .. '{')   
                    for key,value in pairs(t) do   
                        table.insert(out,table_r(value,key,indent .. '|  ',tableList[t]))   
                    end   
                    table.insert(out,indent .. '}')   
                else table.insert(out,tag .. '{}') end   
            end   
        else  
            local val = type(t)~="number" and type(t)~="boolean" and '"'..tostring(t)..'"' or tostring(t)   
            table.insert(out, tag .. val)   
        end   
        return table.concat(out, '\n')   
    end   
    return table_r(t,name or 'Value',indent or '')   
end

function print_r (t, name)
    print(pr(t,name))   
end   
  
--local a = {x=1, y=2, label={text='hans', color='blue'}, list={'a','b','c'}}   
  
--print_r(a);


function var_dump(data, max_level, prefix)
	ngx.say(type(prefix))
    if type(prefix) ~= "string" then   
        prefix = ""  
    end   
    if type(data) ~= "table" then   
        print(prefix .. tostring(data))   
    else  
        --print(data)   
        if max_level ~= 0 then   
            local prefix_next = prefix .. "    "  
            print(prefix .. "{")   
            for k,v in pairs(data) do  
                io.stdout:write(prefix_next .. k .. " = ")   
                if type(v) ~= "table" or (type(max_level) == "number" and max_level <= 1) then   
                    print(v)   
                else  
                    if max_level == nil then   
                        var_dump(v, nil, prefix_next)   
                    else  
                        var_dump(v, max_level - 1, prefix_next)   
                    end   
                end   
            end   
            print(prefix .. "}")   
        end   
    end   
end


--[[
    计算分页
]]--
--  page:当前页    content_num:一页显示的数量  nums:数据总数
function compute_db_pos(page , content_num , nums)
    local last_page = math.ceil( nums/content_num )
    local page = tonumber( page )
    local limit_X , limit_Y

    if page >= last_page then
        page = last_page
    end

    limit_X = (page - 1) * content_num
    if limit_X < 0 then limit_X = 0 end

    if (nums - limit_X) < content_num then
        limit_Y = nums - limit_X
    else
        limit_Y = content_num
    end

    return {x=limit_X ,y=limit_Y ,page=page ,last_page=last_page}
end

--[[
    计算下个月日期
]]
function compute_next_month(_year , _month)
    local next_month = _month + 1
    local next_year  = _year

    if next_month > 12 then
        next_month = 1
        next_year = _year + 1
    end

    return {
        next_year = next_year,
        next_month = next_month
    }
end

--[[
    字符串分割成数组
]]
function split(szSeparator, szFullString)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
       local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
       if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
       end 

       nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
       nFindStartIndex = nFindLastIndex + string.len(szSeparator)
       nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end
