local M = {}
local Job = require('plenary.job')
local Path = require('plenary.path')
local util = require('bzlrun.util')

M._settings = {
    bazel = "bazel",
    finder = util.script_path() .. '../../find-target-for-file.sh',
    asyncjob = function(opts)
        return Job:new(opts)
    end,
    schedule = vim.schedule
}

M._cache = {}
M._args = {
    has_value = false,
    value = nil
}

local run_test = function(bazel, target, args)
    local cmd_args = { bazel, "test", target }
    if args.has_value == true then
        cmd_args[#cmd_args+1] = args.value
    end
    vim.cmd({ cmd = "terminal", args = cmd_args })
end

function M.setup(settings)
    if settings["bazel"] then
        M._settings["bazel"] = settings["bazel"]
    end
    if settings["finder"] then
        M._settings["finder"] = settings["finder"]
    end
    if settings["asyncjob"] then
        M._settings["asyncjob"] = settings["asyncjob"]
    end
    if settings["schedule"] then
        M._settings["schedule"] = settings["schedule"]
    end
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
            local job = M._settings.asyncjob({
                command = M._settings.finder,
                args = {
                    vim.fn.getcwd(),
                    M._settings.bazel,
                    relative_filepath
                },
            })
            job:after_success(function(j)
                target = j:result()[1]
                M._cache[relative_filepath] = target
                M._last_target = target
                M._settings.schedule(function()
                    run_test(M._settings.bazel, target, M._args)
                end)
            end)
            job:start()
            return
        end
    end

    run_test(M._settings.bazel, target, M._args)
end

return M
