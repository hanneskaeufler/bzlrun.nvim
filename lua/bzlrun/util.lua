local M = {}

M.script_path = function()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

M.is_testfile = function(buffer_name)
    return string.find(buffer_name:lower(), "test")
end

return M
