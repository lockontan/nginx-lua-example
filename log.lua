function ToStringEx(value)
    if type(value)=='table' then
       return TableToStr(value)
    elseif type(value)=='string' then
        return '\"'..value..'\"'
    else
       return tostring(value)
    end
end

function TableToStr(t)
    -- 字段排序
    local keySort = {'ip', 'name', 'time'}
    if t == nil then return "" end
    local retstr= "{"

    local i = 1
    for key,value in pairs(t) do
        local signal = ", "
        if i==1 then
          signal = ""
        end

        if key == i then
            retstr = retstr..signal..ToStringEx(t[keySort[i]])
        else
            retstr = retstr..signal..ToStringEx(keySort[i])..': '..ToStringEx(t[keySort[i]])
        end

        i = i+1
    end

     retstr = retstr.."}"
     return retstr
end

local status = ngx.var.status
if string.sub(status,1,2) == '20' or string.sub(status,1,2) == '30' then
    local req = ngx.req.get_uri_args()
    --- 获取time,ip,ua,b,c参数
    local req_headers = ngx.req.get_headers()
    local curTime = ngx.localtime()
    local ip = ngx.var.remote_addr
    local ua = req_headers["User-Agent"]
    local name = ngx.req.get_uri_args()['name']
    --- 拼接一行日志中的内容
    local msg = {name = name, ip = ip, time = curTime}

    --- 落地日志内容
    log_file:write(TableToStr(msg)..'\n')
    log_file:flush()
end