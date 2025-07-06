return {
    {
        -- This is the main plugin that connects Neovim to language servers
        'neovim/nvim-lspconfig',

        dependencies = {
            -- blink.cmp: Modern completion engine for Neovim
            -- Connection: Provides autocompletion capabilities to LSP
            'saghen/blink.cmp',
            -- Mason: Package manager for LSP servers, DAP servers, linters, formatters
            -- Connection: Automatically installs and manages lua-language-server binary
            'williamboman/mason.nvim',
            -- Mason-LSPConfig: Bridge between mason.nvim and lspconfig
            -- Connection: Ensures mason-installed servers work with lspconfig
            'williamboman/mason-lspconfig.nvim',

            {
                -- LazyDev: Better Lua development in Neovim
                -- Connection: Provides better Lua intellisense for Neovim config files
                "folke/lazydev.nvim",
                opts = {
                    library = {
                        -- Add luv (libuv) library definitions for vim.uv functions
                        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                    },
                },
            },
        },

        -- Server configurations: Define settings for each language server
        opts = {
            servers = {
                -- lua_ls: Lua Language Server configuration
                -- This is what actually analyzes your Lua code
                lua_ls = {
                    settings = {
                        Lua = {
                            -- Diagnostics: Configure error/warning detection
                            diagnostics = {
                                -- Tell lua_ls that 'vim' is a valid global variable
                                -- Without this, you'd get "undefined global 'vim'" warnings
                                globals = { "vim" },
                            },
                            -- Workspace: Configure how the server understands your project
                            workspace = {
                                -- Add all Neovim runtime files to the workspace
                                -- This gives you completion for vim.api, vim.fn, etc.
                                library = vim.api.nvim_get_runtime_file("", true),
                                -- Don't ask about third-party libraries
                                checkThirdParty = false,
                            },
                            -- Telemetry: Disable data collection
                            telemetry = {
                                enable = false,
                            },
                        },
                    },
                },
                pyright = {
                    settings = {
                        python = {
                            analysis = {
                                typeCheckingMode = "basic",
                                autoSearchPaths = true,
                                useLibraryCodeForTypes = true,
                            }
                        }
                    }
                }
            }
        },

        -- Main configuration function: Sets up the LSP servers
        config = function(_, opts)
            -- Get the lspconfig module
            local lspconfig = require('lspconfig')

            -- Loop through each server defined in opts.servers
            for server, config in pairs(opts.servers) do
                -- CRITICAL CONNECTION: Merge blink.cmp capabilities with server config
                -- This tells the LSP server what completion features are supported
                -- Without this, autocompletion won't work properly
                config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)

                -- Actually start the language server with our configuration
                lspconfig[server].setup(config)
            end

            -- LspAttach autocommand: Runs when any LSP server attaches to a buffer or saves
            -- This is where we set up buffer-specific features
            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(args)
                    -- Get the LSP client that just attached
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if not client then return end

                    -- Only set up auto-formatting for Lua files
                    if vim.bo.filetype == "lua" then
                        -- Auto-format on save: Automatically format Lua files when saving
                        vim.api.nvim_create_autocmd('BufWritePre', {
                            buffer = args.buf, -- Only for this specific buffer
                            callback = function()
                                -- Use the LSP server to format the code
                                vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
                            end,
                        })
                    end
                    if vim.bo.filetype == "python" then
                        vim.api.nvim_create_autocmd('BufWritePre', {
                            buffer = args.buf,
                            callback = function()
                                vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
                            end,
                        })
                    end
                end,
            })
        end,
    }
}
