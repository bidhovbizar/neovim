-- Install lua-language-server using the following command:
-- We can either install using Mason which I don't prefer or manually clone and build it and put in your $PATH
return {
    cmd = {
        "lua-language-server",
    },
    filetypes = {
        "lua",
    },
    root_markers = {
        ".git",
        ".luacheckrc",
        ".luarc.json",
        ".luarc.jsonc",
        ".stylua.toml",
        "selene.toml",
        "selene.yml",
        "stylua.toml",
    },
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
                path = vim.split(package.path, ';'),
            },
            diagnostics = {
                globals = {
                    'vim',
                },
                disable = {
                    "missing-parameters",
                    "missing-fields",
                    "duplicate-set-field",
                },
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file('', true),  -- This is the key part!
                checkThirdParty = false,
            },
            format = {
                enable = true,
                defaultConfig = {
                    indent_style = "space",
                    indent_size = "4",
                }
            },
            telemetry = {
                enable = false,
            },
        },
    },
    single_file_support = true,
    log_level = vim.lsp.protocol.MessageType.Warning,
}
