-- pip install pyright
return {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { 
        "pyproject.toml", 
        "setup.py", 
        "setup.cfg", 
        "requirements.txt", 
        "Pipfile", 
        "pyrightconfig.json",
        ".git" 
    },
    settings = {
        python = {
            analysis = {
                -- Type checking mode
                typeCheckingMode = "basic", -- "off", "basic", "strict"
                
                -- Auto-import completions
                autoImportCompletions = true,
                autoSearchPaths = true,
                
                -- Diagnostics
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace", -- "openFilesOnly", "workspace"
                
                -- Stub path for type information
                stubPath = "typings",
                
                -- Extra paths for analysis
                extraPaths = {},
                
                -- Diagnostic severity overrides
                diagnosticSeverityOverrides = {
                    reportGeneralTypeIssues = "none",
                    reportOptionalMemberAccess = "none",
                    reportOptionalSubscript = "none",
                    reportPrivateImportUsage = "none",
                    reportUnusedImport = "information",
                    reportUnusedClass = "information",
                    reportUnusedFunction = "information",
                    reportUnusedVariable = "information",
                    reportDuplicateImport = "warning",
                    reportWildcardImportFromLibrary = "warning",
                    reportAbstractUsage = "error",
                    reportArgumentType = "error",
                    reportAssertTypeFailure = "error",
                    reportAssignmentType = "error",
                    --reportAttributeAccessIssue = "error", -- For qali there are so many access issues
                    reportAttributeAccessIssue = "none",
                    reportCallIssue = "error",
                    reportInconsistentConstructor = "error",
                    reportIndexIssue = "error",
                    reportInvalidTypeVarUse = "error",
                    reportNoReturnInFunction = "error",
                    reportOperatorIssue = "error",
                    reportRedeclaration = "error",
                    reportReturnType = "error",
                    reportUntypedFunctionDecorator = "information",
                    reportUntypedClassDecorator = "information",
                    reportUntypedBaseClass = "none",
                    reportUntypedNamedTuple = "none",
                    reportPrivateUsage = "none",
                    reportConstantRedefinition = "error",
                    reportIncompatibleMethodOverride = "error",
                    reportIncompatibleVariableOverride = "error",
                    reportInvalidStringEscapeSequence = "error",
                    reportMissingTypeStubs = "none",
                    reportImportCycles = "error",
                    reportUnusedCoroutine = "error",
                    reportUnnecessaryIsInstance = "information",
                    reportUnnecessaryCast = "information",
                    reportUnnecessaryComparison = "information",
                    reportUnnecessaryContains = "information",
                    reportImplicitStringConcatenation = "none",
                    reportInvalidStubStatement = "error",
                    reportIncompleteStub = "error",
                    reportUnsupportedDunderAll = "warning",
                    reportUnusedCallResult = "none",
                    reportUnusedExpression = "none",
                    reportMatchNotExhaustive = "error",
                    reportShadowedImports = "none",
                    reportSelfClsParameterName = "warning",
                    reportImplicitOverride = "none",
                    reportInvalidTypeForm = "error",
                    reportMissingParameterType = "none",
                    reportMissingTypeArgument = "none",
                    reportInvalidTypeArguments = "error",
                    reportUnknownArgumentType = "none",
                    reportUnknownLambdaType = "none",
                    reportUnknownVariableType = "none",
                    reportUnknownMemberType = "none",
                    reportUnknownParameterType = "none",
                    reportMissingImports = "error",
                    reportMissingModuleSource = "warning",
                    reportInvalidImportForm = "error",
                },
                
                -- Inlay hints
                inlayHints = {
                    variableTypes = true,
                    functionReturnTypes = true,
                    callArgumentNames = true,
                    parameterNames = true,
                    parameterTypes = true,
                    pytestParameters = true,
                },
                
                -- Indexing
                indexing = true,
                
                -- Package indexing depths
                packageIndexDepths = {
                    {
                        name = "",
                        depth = 2,
                        includeAllSymbols = true,
                    }
                },
            },
            
            -- Linting with pylint, flake8, etc. (if you want to use them)
            linting = {
                enabled = false,
                pylintEnabled = false,
                flake8Enabled = false,
                mypyEnabled = false,
                banditEnabled = false,
                pylintArgs = {},
                flake8Args = {},
                mypyArgs = {},
                banditArgs = {},
            },
            
            -- Formatting (if you want to use pyright's formatting)
            formatting = {
                provider = "none", -- "autopep8", "black", "yapf", "none"
            },
            
            -- Python interpreter path (leave empty for auto-detection)
            pythonPath = "",
            
            -- Virtual environment path
            venvPath = "",
        },
    },
}
