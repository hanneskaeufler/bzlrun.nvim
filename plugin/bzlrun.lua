vim.api.nvim_create_user_command(
    'BzlrunSetArgs',
    require("bzlrun").set_args,
    {}
)
