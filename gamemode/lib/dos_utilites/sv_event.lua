event = {}
local List = {}

function event.Add(name, id, func)
    List[name] = List[name] or {}
    List[name][id] = func
end

function event.Call(name, ...)
    local Result = 0 

    if List[name] then 
        for k, i in pairs(List[name]) do 
            local resultCallBack = i(...)
            if isnumber(resultCallBack) then Result = Result + resultCallBack end
        end
    end
    return Result
end