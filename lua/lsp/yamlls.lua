-- Install via npm (requires Node.js)
-- npm install -g yaml-language-server

-- Verify installation
-- yaml-language-server --version
return {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml", "yml" },
    root_markers = { ".git", "package.json", "go.mod" },
    settings = {
        yaml = {
            validate = true,
            completion = true,
            hover = true,
            format = {
                enable = true,
                singleQuote = false,
                bracketSpacing = true,
            },
            schemas = {
                -- Docker Compose (comprehensive patterns)
                ["https://json.schemastore.org/docker-compose.json"] = {
                    "*docker-compose*.yml",
                    "*docker-compose*.yaml",
                    "docker-compose.yml",
                    "docker-compose.yaml",
                    "compose.yml",
                    "compose.yaml",
                    "docker-compose.*.yml",
                    "docker-compose.*.yaml"
                },

                -- Kubernetes manifests (using more current schema)
                ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.30.0-standalone-strict/all.json"] = {
                    "*.k8s.yaml",
                    "*.k8s.yml",
                    "k8s/*.yaml",
                    "k8s/*.yml",
                    "manifests/*.yaml",
                    "manifests/*.yml",
                    "deployment*.yaml",
                    "deployment*.yml",
                    "service*.yaml",
                    "service*.yml"
                },

                -- GitHub Actions workflows
                ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.{yml,yaml}",
                ["https://json.schemastore.org/github-action.json"] = ".github/action.{yml,yaml}",

                -- Ansible
                ["https://json.schemastore.org/ansible-stable-2.9.json"] = {
                    "roles/tasks/*.yml",
                    "roles/tasks/*.yaml",
                    "ansible/*.yml",
                    "ansible/*.yaml"
                },
                ["https://json.schemastore.org/ansible-playbook.json"] = {
                    "*play*.yml",
                    "*play*.yaml",
                    "playbook*.yml",
                    "playbook*.yaml"
                },

                -- Other schemas
                ["https://json.schemastore.org/chart.json"] = "Chart.{yml,yaml}",
                ["https://json.schemastore.org/helmfile.json"] = "helmfile.{yml,yaml}",
                ["https://json.schemastore.org/gitlab-ci.json"] = ".gitlab-ci.yml",
                ["https://json.schemastore.org/azure-pipelines.json"] = "azure-pipelines.{yml,yaml}",
                ["https://json.schemastore.org/circleciconfig.json"] = ".circleci/config.yml",
                ["https://json.schemastore.org/kustomization.json"] = "kustomization.{yml,yaml}",
                ["https://json.schemastore.org/pre-commit-config.json"] = ".pre-commit-config.yaml",
                ["https://json.schemastore.org/openapi.json"] = "*api*.{yml,yaml}",
                ["https://json.schemastore.org/swagger-2.0.json"] = "*swagger*.{yml,yaml}",

                -- Additional useful schemas
                ["https://json.schemastore.org/prometheus.json"] = "*prometheus*.{yml,yaml}",
                ["https://json.schemastore.org/traefik-v2.json"] = "*traefik*.{yml,yaml}",
                ["https://json.schemastore.org/renovate.json"] = "renovate.{yml,yaml}",
            },
            schemaStore = {
                enable = true,
                url = "https://www.schemastore.org/api/json/catalog.json"
            },
            customTags = {
                "!Base64",
                "!Cidr",
                "!FindInMap sequence",
                "!GetAtt",
                "!GetAZs",
                "!ImportValue",
                "!Join sequence",
                "!Ref",
                "!Select sequence",
                "!Split sequence",
                "!Sub"
            },
            maxItemsComputed = 5000,
            suggest = {
                parentSkeletonSelectedFirst = true
            },
            trace = {
                server = "off"  -- Set to "messages" or "verbose" for debugging if needed
            }
        }
    }
}
