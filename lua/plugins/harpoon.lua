-- helper function to show harpoon files first, then allow live grep
local function toggle_telescope(harpoon_files)
    -- Move telescope requires here - only load when actually used
    local conf = require('telescope.config').values
    local themes = require('telescope.themes')
    local builtin = require('telescope.builtin')

    local file_paths = {}
    local display_items = {}

    for i, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
        -- Create display with index and filename for easy reading
        local filename = vim.fn.fnamemodify(item.value, ":t")
        local relative_path = vim.fn.fnamemodify(item.value, ":.")
        table.insert(display_items, string.format("%d. %s (%s)", i, filename, relative_path))
    end

    local opts = themes.get_ivy({
        prompt_title = "Harpoon Files"
    })

    require("telescope.pickers").new(opts, {
        finder = require("telescope.finders").new_table({
            results = display_items,
            entry_maker = function(entry)
                local index = tonumber(entry:match("^(%d+)%."))
                return {
                    value = file_paths[index],
                    display = entry,
                    ordinal = entry,
                }
            end
        }),
        previewer = conf.file_previewer(opts),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            -- Default action: open the selected file
            require("telescope.actions").select_default:replace(function()
                local selection = require("telescope.actions.state").get_selected_entry()
                require("telescope.actions").close(prompt_bufnr)
                vim.cmd("edit " .. selection.value)
            end)

            -- Custom mapping: <leader>ga to grep in all harpoon files
            map("i", "<leader>ga", function()
                require("telescope.actions").close(prompt_bufnr)
                builtin.live_grep({
                    search_dirs = file_paths,
                    prompt_title = "Live Grep in All Harpoon Files",
                    theme = "ivy"
                })
            end)

            -- Custom mapping: <leader>gs to grep in selected file only
            map("i", "<leader>gs", function()
                local selection = require("telescope.actions.state").get_selected_entry()
                require("telescope.actions").close(prompt_bufnr)
                builtin.live_grep({
                    search_dirs = { selection.value },
                    prompt_title = "Live Grep in " .. vim.fn.fnamemodify(selection.value, ":t"),
                    theme = "ivy"
                })
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
        "nvim-telescope/telescope.nvim" -- Make sure telescope is a dependency
    },
    keys = {
        { "<M-a>", function() require('harpoon'):list():add() end, desc = "Harpoon add file" },	
        { "<M-h>", function() 
            local harpoon = require('harpoon')
            harpoon.ui:toggle_quick_menu(harpoon:list()) 
        end, desc = "Harpoon toggle menu" },
        { "<leader>fh", function() 
            toggle_telescope(require('harpoon'):list()) 
        end, desc = "Search in harpoon files" },
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
        -- To delete an added file in harpoon please <C-e> open explorer and press d on the file you want to remove
        
        -- <leader>fh → Shows Harpoon file list with previews
        --      then:
        -- <leader>ga → Live grep in ALL Harpoon files
        -- <leader>gs → Live grep in SELECTED file only
        --      If you want to just open the file:
        -- Enter → Opens selected file
        
        -- <M-h> + d → Remove files persistently

        --vim.keymap.set("n", "<C-p>", function() harpoon:list():prev() end)
        --vim.keymap.set("n", "<C-n>", function() harpoon:list():next() end)
    end
}
