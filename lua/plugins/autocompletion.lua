return {
    {
        'saghen/blink.cmp',
        dependencies = 'rafamadriz/friendly-snippets',
        -- SOLUTION 1: Use stable version with prebuilt binaries
        version = '1.*', -- This version includes prebuilt fuzzy matching binaries
        opts = {
            keymap = { preset = 'default' },
            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = 'none'
            },
            signature = { enabled = true },
        },
    },
}
