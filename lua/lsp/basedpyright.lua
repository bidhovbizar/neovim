return {
    cmd = { "basedpyright-langserver", "--stdio" },
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
        basedpyright = {
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
                
                -- BasedPyright specific performance settings
                disableLanguageServices = false,
                disableOrganizeImports = false,
                
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
                    reportAttributeAccessIssue = "error",
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
                    
                    -- BasedPyright specific diagnostics
                    reportAny = "none",
                    reportIgnoreCommentWithoutRule = "none",
                    reportImplicitRelativeImport = "none",
                    reportInvalidCast = "error",
                    reportMissingModuleSource = "warning",
                    reportPropertyTypeMismatch = "error",
                    reportUnnecessaryTypeIgnoreComment = "information",
                    reportUnusedExcept = "information",
                },
                
                -- Inlay hints (enhanced in basedpyright)
                inlayHints = {
                    variableTypes = true,
                    functionReturnTypes = true,
                    callArgumentNames = true,
                    parameterNames = true,
                    parameterTypes = true,
                    pytestParameters = true,
                    genericTypes = true,
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
                
                -- BasedPyright specific performance optimizations
                logLevel = "Information",
                enableTypeIgnoreComments = true,
                
                -- Advanced type checking options
                strictListInference = true,
                strictDictionaryInference = true,
                strictSetInference = true,
                strictParameterNoneValue = true,
                enableExperimentalFeatures = false,
                
                -- Import resolution
                importFormat = "absolute",
                includeFileSpecs = {
                    "**/*.py",
                    "**/*.pyi",
                },
                excludeFileSpecs = {
                    "**/__pycache__",
                    "**/.pytest_cache",
                    "**/.mypy_cache",
                    "**/node_modules",
                    "**/.git",
                    "**/.tox",
                    "**/.venv",
                    "**/venv",
                    "**/.env",
                    "**/env",
                },
            },
            
            -- Linting integration
            linting = {
                enabled = false,
                pylintEnabled = false,
                flake8Enabled = false,
                mypyEnabled = false,
                banditEnabled = false,
            },
            
            -- Formatting
            formatting = {
                provider = "none", -- Let other tools handle formatting
            },
            
            -- Python interpreter path (auto-detected if empty)
            pythonPath = "",
            
            -- Virtual environment path
            venvPath = "",
            
            -- BasedPyright specific settings
            disableLanguageServices = false,
            disableOrganizeImports = false,
            
            -- Completion settings
            completions = {
                includeAutoimportCompletions = true,
                includeMethodSnippets = true,
                includeClassSnippets = true,
            },
        },
    },
}
