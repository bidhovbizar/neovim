-- Highlight on yank and LSP document highlights (lightweight)
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking text',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

-- Read log files as json as the syntax highlighting is better
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"*.log", "*/logs/*", "*_log", "*logfile*"},
  command = "set filetype=json",
})

-- Same occurance of a variable in a file gets highlighted when the cursor is on it (Very heavy for server)
--
--vim.api.nvim_create_autocmd("LspAttach", {
--    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
--    callback = function(event)
--        local function client_supports_method(client, method, bufnr)
--            if vim.fn.has 'nvim-0.11' == 1 then
--                return client:supports_method(method, bufnr)
--            else
--                return client.supports_method(method, { bufnr = bufnr })
--            end
--        end
--
--        local client = vim.lsp.get_client_by_id(event.data.client_id)
--        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
--            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
--
--            -- When cursor stops moving: Highlights all instances of the symbol under the cursor
--            -- When cursor moves: Clears the highlighting
--            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
--                buffer = event.buf,
--                group = highlight_augroup,
--                callback = vim.lsp.buf.document_highlight,
--            })
--            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
--                buffer = event.buf,
--                group = highlight_augroup,
--                callback = vim.lsp.buf.clear_references,
--            })
--
--            -- When LSP detaches: Clears the highlighting
--            vim.api.nvim_create_autocmd('LspDetach', {
--                group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
--                callback = function(event2)
--                    vim.lsp.buf.clear_references()
--                    vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
--                end,
--            })
--        end
--    end,
--
--})
