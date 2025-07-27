-- Install bash-language-server using the following command:
-- npm install -g bash-language-server
-- If you have enabled the shellcheck linter, ensure it is installed:
-- sudo apt install shellcheck  
    
return {
    cmd = {
        "bash-language-server",
        "start"
    },
    filetypes = {
        "sh",
        "bash",
        "zsh",
    },
    root_markers = {
        ".git",
        ".bashrc",
        ".bash_profile",
        ".zshrc",
        "*.sh",
    },
    settings = {
        bashIde = {
            globPattern = "**/*@(.sh|.inc|.bash|.command)",
            shellcheckPath = "shellcheck",
            enableSourceErrorDiagnostics = true,
            explainshellEndpoint = "", -- If you want to use explainshell, set the endpoint here. It converts commands into human readable explanations.
            backgroundAnalysisMaxFiles = 50,
            includeAllWorkspaceSymbols = false,
        },
    },
    single_file_support = true,
    log_level = vim.lsp.protocol.MessageType.Warning,
}
