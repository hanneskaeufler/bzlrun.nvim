local stub = require('luassert.stub')
local bzlrun = require('bzlrun')
local util = require('bzlrun.util')

local setup_dummy_buffer = function(buffername)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, buffername)
    return buf
end

describe("bzlrun", function()
    local some_buffer = setup_dummy_buffer("sometest.java")

    bzlrun.setup({
        -- stub out the script for finding the target
        -- such that we don't actually need a
        -- working bazel workspace for this test
        finder = util.script_path() .. "/stub-finder.sh",
        -- stub out bazel itself as well such that we
        -- don't actually try to run any tests
        bazel = "/usr/bin/true"
    })

    describe("plugin", function()
        it("creates a command to set the bazel config", function()
            vim.cmd('BzlrunSetArgs "--config=foo"')

            stub(vim, "cmd")

            bzlrun.run_tests_for_buffer(some_buffer)

            assert.stub(vim.cmd).was_called_with({
                cmd = "terminal",
                args = {
                    "/usr/bin/true",
                    "test",
                    "//:dummy_target",
                    '"--config=foo"'
                }
            })

            vim.cmd:revert()
        end)
    end)

    describe("#run_tests_for_buffer", function()
        before_each(function()
            stub(vim, "cmd")
            bzlrun._args.has_value = false
        end)

        after_each(function()
            vim.cmd:revert()
        end)

        it("looks up the bazel target of the current buffer", function()
            bzlrun.run_tests_for_buffer(some_buffer)

            assert.stub(vim.cmd).was_called_with({
                cmd = "terminal",
                args = {
                    "/usr/bin/true",
                    "test",
                    "//:dummy_target"
                }
            })
        end)

        it("caches the target that was looked up", function()
            bzlrun.run_tests_for_buffer(some_buffer)

            local expected_cache = {}
            expected_cache["sometest.java"] = "//:dummy_target"
            assert.are.same(expected_cache, bzlrun._cache)
        end)

        it("if the buffer is not a test, it runs the last test", function()
            local test_buffer = setup_dummy_buffer("testfile.java")
            local some_buffer = setup_dummy_buffer("productioncode.txt")

            bzlrun.run_tests_for_buffer(some_buffer)

            assert.stub(vim.cmd).was_called_with({
                cmd = "terminal",
                args = {
                    "/usr/bin/true",
                    "test",
                    "//:dummy_target"
                }
            })
        end)
    end)
end)
