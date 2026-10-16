-- lua/plugins/render-markdown.lua
local file_types = {
    "markdown",
    "copilot-chat",
    "codecompanion",
    "Avante",
    "AvanteSelectedFiles",
    "AvanteInput",
    "AvanteConfirm",
    "AvantePromptInput",
    "AvanteTodos",
}

return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = file_types,
    opts = {
        file_types = file_types,
        render_modes = true,
        overrides = {
            filetype = {
                ["copilot-chat"] = {
                    heading = {
                        enabled = false, -- Disables header rendering so CopilotChat's icons look clean
                    },
                },
            },
        },
    },
}
