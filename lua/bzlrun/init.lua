local M = {}
local Job = require('plenary.job')
local Path = require('plenary.path')
local util = require('bzlrun.util')

M._settings = {
    bazel = "bazel",
    finder = util.script_path() .. '../../find-target-for-file.sh'
}

function M.setup(settings)
    M._settings = settings
    return M
end

function M.run_tests_for_current_buffer()
    M.run_tests_for_buffer(0)
end

function M.run_tests_for_buffer(buffer)
    local filepath = vim.api.nvim_buf_get_name(buffer)
    local relative_filepath = Path:new(filepath):make_relative()

    local job = Job:new({
        command = M._settings.finder,
        args = {
            vim.fn.getcwd(),
            M._settings.bazel,
            relative_filepath
        },
    })
    job:sync()
    vim.cmd({
        cmd = "terminal",
        args =  { M._settings.bazel, "test", job:result()[1] }
    })
end

return M
