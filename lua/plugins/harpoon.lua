-- helper function to show harpoon files first, then allow live grep
local function toggle_telescope(harpoon_files, restored_paths)
    -- Move telescope requires here - only load when actually used
    local conf = require('telescope.config').values
    local themes = require('telescope.themes')
    local builtin = require('telescope.builtin')
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    local multi_select = require('telescope.pickers.multi'):new()

    local file_paths = {}
    local display_items = {}
    restored_paths = restored_paths or {}

    for i, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
        -- Create display with index and filename for easy reading
        local filename = vim.fn.fnamemodify(item.value, ":t")
        local relative_path = vim.fn.fnamemodify(item.value, ":.")
        table.insert(display_items, string.format("%d. %s (%s)", i, filename, relative_path))
    end

    if #file_paths == 0 then
        vim.notify("Harpoon list is empty", vim.log.levels.WARN)
        return
    end

    local function selected_path_set(picker)
        local paths = {}
        for _, selection in ipairs(picker:get_multi_selection()) do
            paths[selection.value] = true
        end
        return paths
    end

    local function open_grep(search_dirs, prompt_title, selected_paths)
        builtin.live_grep(themes.get_ivy({
            search_dirs = search_dirs,
            prompt_title = prompt_title,
            attach_mappings = function(grep_bufnr, map)
                map({ "n", "i" }, "<leader>fh", function()
                    actions.close(grep_bufnr)
                    toggle_telescope(harpoon_files, selected_paths)
                end)
                return true
            end,
        }))
    end

    local opts = themes.get_ivy({
        prompt_title = "Harpoon Files",
        initial_mode = "normal",
    })
    opts._multi = multi_select

    require("telescope.pickers").new(opts, {
        finder = require("telescope.finders").new_table({
            results = display_items,
            entry_maker = function(entry)
                local index = tonumber(entry:match("^(%d+)%."))
                local picker_entry = {
                    value = file_paths[index],
                    display = entry,
                    ordinal = entry,
                }
                if restored_paths[picker_entry.value] then
                    multi_select:add(picker_entry)
                end
                return picker_entry
            end
        }),
        previewer = conf.file_previewer(opts),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            -- Default action: open the selected file
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                vim.cmd("edit " .. selection.value)
            end)

            -- Custom mapping: <leader>fha to grep in all harpoon files once you are in harpoon
            map({ "n", "i" }, "<leader>fha", function()
                local selected_paths = selected_path_set(action_state.get_current_picker(prompt_bufnr))
                actions.close(prompt_bufnr)
                open_grep(file_paths, "Live Grep in All Harpoon Files", selected_paths)
            end)

            -- Custom mapping: <leader>fhs to grep in selected files
            map({ "n", "i" }, "<leader>fhs", function()
                local picker = action_state.get_current_picker(prompt_bufnr)
                local restored_selection_paths = selected_path_set(picker)
                local selections = picker:get_multi_selection()

                if #selections == 0 then
                    local selection = action_state.get_selected_entry()
                    if not selection then
                        vim.notify("No Harpoon file selected", vim.log.levels.WARN)
                        return
                    end
                    selections = { selection }
                end

                local grep_paths = {}
                local selected_filenames = {}
                for _, selection in ipairs(selections) do
                    table.insert(grep_paths, selection.value)
                    table.insert(selected_filenames, vim.fn.fnamemodify(selection.value, ":t"))
                end

                actions.close(prompt_bufnr)
                open_grep(
                    grep_paths,
                    "Live Grep in: " .. table.concat(selected_filenames, ", "),
                    restored_selection_paths
                )
            end)

            return true
        end,
    }):find()
end

return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim", -- Make sure telescope is a dependency
    },
    keys = {
        { "<M-a>", function() require('harpoon'):list():add() end,     desc = "Harpoon add file" },
        {
            "<M-h>",
            function()
                local harpoon = require('harpoon')
                harpoon.ui:toggle_quick_menu(harpoon:list(), {
                    ui_width_ratio = 0.9,
                    height_in_lines = 12,
                })
            end,
            desc = "Harpoon toggle menu"
        },
        {
            "<leader>fh",
            function()
                toggle_telescope(require('harpoon'):list())
            end,
            desc = "Search in harpoon files"
        },
        -- Quick access to first 4 files
        { "<M-1>", function() require('harpoon'):list():select(1) end, desc = "Harpoon file 1" },
        { "<M-2>", function() require('harpoon'):list():select(2) end, desc = "Harpoon file 2" },
        { "<M-3>", function() require('harpoon'):list():select(3) end, desc = "Harpoon file 3" },
        { "<M-4>", function() require('harpoon'):list():select(4) end, desc = "Harpoon file 4" },
        { "<M-5>", function() require('harpoon'):list():select(5) end, desc = "Harpoon file 5" },
    },
    config = function()
        local harpoon = require('harpoon')
        -- Setup harpoon with proper save settings without this removing a file won't be persistent across session
        harpoon:setup({
            settings = {
                save_on_toggle = true,
                save_on_change = true,
                sync_on_ui_close = true,
            }
        })
        -- Functionality Check:
        -- To delete an added file in harpoon please <M-h> open harpoon explorer and press d on the file you want to remove
        -- <M-h> + d → Remove files persistently

        -- <M-h>        → Shows Harpoon file list no previews
        -- <leader>fh   → Shows Harpoon file list with previews and option
        --     If you want to just open the file:
        --     Enter → Opens selected file
        --              OR
        --     Choose the following inside the picker for more options:
        --        <leader>fha → Live grep in ALL Harpoon files
        --        <leader>fhs → Live grep in files selected with <Tab>, or the highlighted file
        --        <leader>fh  → Return from grep to the Harpoon picker with selections restored

        --vim.keymap.set("n", "<C-p>", function() harpoon:list():prev() end)
        --vim.keymap.set("n", "<C-n>", function() harpoon:list():next() end)
    end
}
