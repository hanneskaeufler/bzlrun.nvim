local mock = require('luassert.mock')
local stub = require('luassert.stub')
local bzlrun = require('bzlrun')
local util = require('bzlrun.util')

local setup_dummy_buffer = function()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, "somefile.txt")
    return buf
end

describe("bzlrun", function()
    describe("#run_tests_for_buffer", function()
        before_each(function()
            bzlrun.setup({
                -- stub out the script for finding the target
                -- such that we don't actually need a
                -- working bazel workspace for this test
                finder = util.script_path() .. "/stub-finder.sh",
                -- stub out bazel itself as well such that we
                -- don't actually try to run any tests
                bazel = "/usr/bin/true"
            })
        end)


        it("looks up the bazel target of the current buffer", function()
            local some_buffer = setup_dummy_buffer()

            local cmd = stub(vim, "cmd")

            bzlrun.run_tests_for_buffer(some_buffer)

            assert.stub(cmd).was_called_with({
                cmd = "terminal",
                args = { "/usr/bin/true", "test", "//:dummy_target" }
            })
        end)
    end)
end)
