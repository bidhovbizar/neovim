-- Remembers the last visual selection in a file buffer, so CodeCompanion's
-- #{selection} works after switching windows (like CopilotChat's #selection).
--  * The selection is read when the message is sent, not when the chat opens.
--  * While a CodeCompanion chat is focused, the remembered selection is
--    highlighted in its source buffer (group `CcSelection`, linked to Visual).
--  * Sending a message that contains #{selection} with nothing selected is
--    blocked with a "no selection found" warning.

local M = {}

local last = nil -- { bufnr, start_line, start_col, end_line, end_col, linewise }
local ns = vim.api.nvim_create_namespace("CcSelectionHighlight")

local function is_file_buffer(bufnr)
    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return false
    end
    local ft = vim.bo[bufnr].filetype
    if vim.bo[bufnr].buftype ~= "" then
        return false
    end
    if ft == "codecompanion" or ft == "netrw" or ft == "help" or ft == "qf" then
        return false
    end
    return vim.api.nvim_buf_get_name(bufnr) ~= ""
end

---------------------------------------------------------------------------
-- Highlight of the remembered selection (shown while the chat is focused)
---------------------------------------------------------------------------

local function define_highlight()
    vim.api.nvim_set_hl(0, "CcSelection", { link = "Visual", default = true })
end

local function clear_highlight()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
            vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        end
    end
end

function M.refresh_highlight()
    clear_highlight()
    if vim.bo.filetype ~= "codecompanion" then
        return
    end
    if not last or not is_file_buffer(last.bufnr) then
        return
    end

    local bufnr = last.bufnr
    local count = vim.api.nvim_buf_line_count(bufnr)
    if last.start_line < 1 or last.start_line > count then
        return
    end
    local end_line = math.min(last.end_line, count)

    for l = last.start_line, end_line do
        if last.linewise then
            vim.api.nvim_buf_set_extmark(bufnr, ns, l - 1, 0, { line_hl_group = "CcSelection", priority = 200 })
        else
            local text = vim.api.nvim_buf_get_lines(bufnr, l - 1, l, false)[1] or ""
            local s_col, e_col = 0, #text -- 0-based start, exclusive end
            if l == last.start_line then
                s_col = last.start_col - 1
            end
            if l == end_line then
                e_col = math.min(last.end_col, #text)
            end
            s_col = math.min(math.max(s_col, 0), #text)
            e_col = math.max(e_col, s_col)
            vim.api.nvim_buf_set_extmark(bufnr, ns, l - 1, s_col, {
                end_row = l - 1,
                end_col = e_col,
                hl_group = "CcSelection",
                priority = 200,
                strict = false,
            })
        end
    end
end

---------------------------------------------------------------------------
-- Tracking
---------------------------------------------------------------------------

local function set_last(bufnr, s_line, s_col, e_line, e_col, linewise)
    last = {
        bufnr = bufnr,
        start_line = s_line,
        start_col = s_col,
        end_line = e_line,
        end_col = e_col,
        linewise = linewise,
    }
    M.refresh_highlight()
end

-- Called after visual mode has ended: '< and '> are set for the buffer.
local function remember_from_marks(bufnr, linewise)
    if not is_file_buffer(bufnr) then
        return
    end
    local s = vim.api.nvim_buf_get_mark(bufnr, "<") -- {row, 0-based col}
    local e = vim.api.nvim_buf_get_mark(bufnr, ">")
    if s[1] == 0 or e[1] == 0 then
        return
    end
    set_last(bufnr, s[1], s[2] + 1, e[1], e[2] + 1, linewise)
end

-- Called while visual mode is still active (e.g. leaving the window with a selection).
local function remember_live(bufnr, mode)
    if not is_file_buffer(bufnr) then
        return
    end
    local v = vim.fn.getpos("v")
    local c = vim.fn.getpos(".")
    local s, e = v, c
    if v[2] > c[2] or (v[2] == c[2] and v[3] > c[3]) then
        s, e = c, v
    end
    set_last(bufnr, s[2], s[3], e[2], e[3], mode == "V")
end

-- Returns the remembered selection as lines plus metadata, or nil.
function M.current()
    if not last or not is_file_buffer(last.bufnr) then
        return nil
    end
    local bufnr = last.bufnr
    local count = vim.api.nvim_buf_line_count(bufnr)
    if last.start_line < 1 or last.start_line > count then
        return nil
    end
    local end_line = math.min(last.end_line, count)
    local lines = vim.api.nvim_buf_get_lines(bufnr, last.start_line - 1, end_line, false)
    if #lines == 0 then
        return nil
    end

    if not last.linewise then
        if #lines == 1 then
            lines[1] = lines[1]:sub(last.start_col, last.end_col)
        else
            lines[1] = lines[1]:sub(last.start_col)
            lines[#lines] = lines[#lines]:sub(1, last.end_col)
        end
    end

    return {
        lines = lines,
        filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":."),
        filetype = vim.bo[bufnr].filetype,
        start_line = last.start_line,
        end_line = end_line,
    }
end

---------------------------------------------------------------------------
-- Guard: #{selection} needs a selection
---------------------------------------------------------------------------

-- True (and warns) when the pending chat message uses #{selection} but nothing is selected.
function M.blocked_without_selection(chat)
    if not chat or not chat.bufnr or not vim.api.nvim_buf_is_valid(chat.bufnr) then
        return false
    end

    local from = math.max((chat.header_line or 1) - 1, 0)
    local text = table.concat(vim.api.nvim_buf_get_lines(chat.bufnr, from, -1, false), "\n")
    local prefix = require("codecompanion.triggers").mappings.editor_context
    local tag = prefix .. "{selection}"
    if not text:find(tag, 1, true) then
        return false
    end

    if M.current() then
        return false
    end
    -- Same fallback the plugin uses: a selection captured when the chat was created
    local ctx = chat.buffer_context
    if ctx and ctx.is_visual and ctx.lines and #ctx.lines > 0 then
        return false
    end

    vim.notify(
        "CodeCompanion: no selection found for " .. tag .. ". Select text with v/V first, then send again (message not sent).",
        vim.log.levels.WARN
    )
    return true
end

local function patch_chat_submit()
    local ok, Chat = pcall(require, "codecompanion.interactions.chat")
    if not ok or type(Chat) ~= "table" or type(Chat.submit) ~= "function" or Chat._cc_selection_patched then
        return
    end
    Chat._cc_selection_patched = true

    local orig = Chat.submit
    Chat.submit = function(self, opts)
        opts = opts or {}
        -- Skip automatic submits (tool results) and requests already running
        if not opts.auto_submit and not self.current_request and M.blocked_without_selection(self) then
            return
        end
        return orig(self, opts)
    end
end

---------------------------------------------------------------------------
-- Selection editor context: use the remembered selection
---------------------------------------------------------------------------

-- Replace CodeCompanion's selection editor context so it uses the tracked selection.
-- Falls back to the original behaviour when nothing has been selected yet.
local function patch_selection_context()
    local ok, Selection = pcall(require, "codecompanion.interactions.shared.editor_context.selection")
    if not ok or type(Selection) ~= "table" or not Selection.chat_render then
        return
    end
    if Selection._cc_selection_patched then
        return
    end
    Selection._cc_selection_patched = true

    local orig = Selection.chat_render
    Selection.chat_render = function(self)
        local sel = M.current()
        if not sel or not self.Chat then
            return orig(self)
        end

        local config = require("codecompanion.config")
        local markdown = require("codecompanion.utils.markdown")
        local tags = require("codecompanion.interactions.shared.tags")

        self.Chat:add_message({
            role = config.constants.USER_ROLE,
            content = string.format(
                "Visual selection from `%s` (lines %d-%d):\n\n%s",
                sel.filename,
                sel.start_line,
                sel.end_line,
                markdown.form_codeblock(table.concat(sel.lines, "\n"), { ft = sel.filetype or "" })
            ),
        }, { _meta = { source = "editor_context", tag = tags.SELECTION }, visible = false })

        vim.notify(
            string.format(
                "CodeCompanion: sending selection from %s lines %d-%d (%d lines)",
                sel.filename,
                sel.start_line,
                sel.end_line,
                #sel.lines
            ),
            vim.log.levels.INFO
        )
    end
end

function M.setup()
    local group = vim.api.nvim_create_augroup("CcSelectionTracker", { clear = true })

    define_highlight()
    vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = define_highlight })

    -- Leaving visual mode in a file buffer: read the marks once they are set.
    vim.api.nvim_create_autocmd("ModeChanged", {
        group = group,
        callback = function()
            local old = vim.v.event.old_mode or ""
            if not old:match("^[vV\22]") then
                return
            end
            local bufnr = vim.api.nvim_get_current_buf()
            local linewise = old == "V"
            vim.schedule(function()
                remember_from_marks(bufnr, linewise)
            end)
        end,
    })

    -- Leaving the window or buffer while still in visual mode: capture it now.
    vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
        group = group,
        callback = function()
            local mode = vim.fn.mode()
            if not mode:match("^[vV\22]") then
                return
            end
            remember_live(vim.api.nvim_get_current_buf(), mode)
        end,
    })

    -- Show the remembered selection while the chat is focused, hide it otherwise.
    vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "FileType" }, {
        group = group,
        callback = function()
            vim.schedule(M.refresh_highlight)
        end,
    })

    patch_selection_context()
    patch_chat_submit()
end

return M
