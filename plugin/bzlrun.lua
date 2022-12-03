local bzlrun = require("bzlrun")

vim.api.nvim_create_user_command(
    "BzlrunSetArgs", bzlrun.set_args, {}
)

vim.api.nvim_create_user_command(
    "BzlrunClearCache", bzlrun.clear_cache, {}
)
