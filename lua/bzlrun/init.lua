local M = {}
local Job = require('plenary.job')
local Path = require('plenary.path')
local util = require('bzlrun.util')

M._settings = {
    bazel = "bazel",
    finder = util.script_path() .. '../../find-target-for-file.sh'
}

M._cache = {}
M._args = {
    has_value = false,
    value = nil
}

function M.setup(settings)
    M._settings = settings
    return M
end

function M.set_args(args)
    M._args.value = args.args
    M._args.has_value = true
end

function M.run_tests_for_current_buffer()
    M.run_tests_for_buffer(0)
end

function M.run_tests_for_buffer(buffer)
    local filepath = vim.api.nvim_buf_get_name(buffer)
    local relative_filepath = Path:new(filepath):make_relative()

    local target = M._cache[relative_filepath]
    if not target then
        if not util.is_testfile(relative_filepath) then
            target = M._last_target
        else
            local job = Job:new({
                command = M._settings.finder,
                args = {
                    vim.fn.getcwd(),
                    M._settings.bazel,
                    relative_filepath
                },
            })
            job:sync()
            target = job:result()[1]
            M._cache[relative_filepath] = target
            M._last_target = target
        end
    end

    local args
    if M._args.has_value == true then
        args = { M._settings.bazel, "test", M._args.value, target }
    else
        args = { M._settings.bazel, "test", target }
    end
    vim.cmd({ cmd = "terminal", args = args })
end

return M
