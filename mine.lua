function lua_string_split(str, split_char)      
    local sub_str_tab = {};  
      
    while (true) do          
        local pos = string.find(str, split_char);    
        if (not pos) then              
            local size_t = table.getn(sub_str_tab)  
            table.insert(sub_str_tab,size_t+1,str);  
            break;    
        end  
        
        local sub_str = string.sub(str, 1, pos - 1);                
        local size_t = table.getn(sub_str_tab)  
        table.insert(sub_str_tab,size_t+1,sub_str);  
        local t = string.len(str);  
        str = string.sub(str, pos + 1, t);     
    end

    return sub_str_tab;  
end  

-- decoding
function decodeBase64(data)
    local b ='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end

function decodePassword(data)
    local password = {'H', 'A', 'N', 'E', 'P', 'U', 'M', 'R', 'O', 'D'}
    local bassword = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
    local newData = ''
    for i = 1, string.len(data) do
        for j = 1, #password do
            if password[j] == string.sub(data,i,i) then
                newData = newData .. bassword[j]
            end
        end
    end
    return newData
end

local urlArr = lua_string_split(ngx.var.request_uri, '/')
urlArr[3] = decodePassword(decodeBase64(urlArr[3]))
urlArr[2] = ngx.var.redirect_url
local newUrl = table.concat(urlArr, "/")
--ngx.print(newUrl)

return ngx.exec(newUrl, { name = urlArr[3]})
