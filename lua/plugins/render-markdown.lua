-- lua/plugins/render-markdown.lua
return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = {
        "markdown",
        "copilot-chat",
        "codecompanion",
        "Avante",
        "AvanteSelectedFiles",
        "AvanteInput",
        "AvanteConfirm",
        "AvantePromptInput",
        "AvanteTodos",
    },
    opts = {
        file_types = {
            "markdown",
            "copilot-chat",
            "codecompanion",
            "Avante",
            "AvanteSelectedFiles",
            "AvanteInput",
            "AvanteConfirm",
            "AvantePromptInput",
            "AvanteTodos",
        },
        render_modes = true,
    },
}
