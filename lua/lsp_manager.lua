-- lua/lsp_manager.lua

local M = {}
local ns = vim.api.nvim_create_namespace("lsp_manager")

vim.api.nvim_set_hl(0, "LspManagerInstalled", { link = "DiagnosticOk", default = true })
vim.api.nvim_set_hl(0, "LspManagerMissing", { link = "DiagnosticError", default = true })
vim.api.nvim_set_hl(0, "LspManagerPending", { link = "DiagnosticWarn", default = true })
vim.api.nvim_set_hl(0, "LspManagerHint", { link = "Comment", default = true })
vim.api.nvim_set_hl(0, "LspManagerHeader", { link = "Title", default = true })

local CATEGORY_ORDER = { "LSP", "Linter", "Formatter", "DAP", "Compiler", "Runtime" }

-- Registry pulled + filtered from mason-org/mason-registry (npm/pypi sources only —
-- these are the ones that install cleanly on Termux via existing tools).
-- description/languages fields sourced from the same registry on 2026-07-08.
local registry = {
  { name = "lua_ls", category = "LSP", bin = "lua-language-server", method = "pkg", pkg = "lua-language-server",
    description = "Language server for Lua", languages = { "Lua" } },
  { name = "clangd", category = "LSP", bin = "clangd", method = "pkg", pkg = "clang",
    description = "Language server for C and C++, based on Clang", languages = { "C", "C++" } },
  { name = "ruff", category = "LSP", bin = "ruff", method = "pkg", pkg = "ruff",
    description = "An extremely fast Python linter and code formatter, written in Rust.", languages = { "Python" } },
  { name = "pyright", category = "LSP", bin = "pyright-langserver", method = "npm", pkg = "pyright",
    description = "Static type checker for Python.", languages = { "Python" } },
  { name = "ts_ls", category = "LSP", bin = "typescript-language-server", method = "npm", pkg = "typescript-language-server typescript",
    description = "TypeScript & JavaScript Language Server.", languages = { "TypeScript", "JavaScript" } },
  { name = "bashls", category = "LSP", bin = "bash-language-server", method = "npm", pkg = "bash-language-server",
    description = "A language server for Bash.", languages = { "Bash", "Csh", "Ksh", "Sh", "Zsh" } },
  { name = "vimls", category = "LSP", bin = "vim-language-server", method = "npm", pkg = "vim-language-server",
    description = "VimScript language server.", languages = { "VimScript" } },
  { name = "cssls", category = "LSP", bin = "vscode-css-language-server", method = "npm", pkg = "vscode-langservers-extracted",
    description = "Language Server Protocol implementation for CSS, SCSS & LESS.", languages = { "CSS", "SCSS", "LESS" } },
  { name = "html", category = "LSP", bin = "vscode-html-language-server", method = "npm", pkg = "vscode-langservers-extracted",
    description = "Language Server Protocol implementation for HTML.", languages = { "HTML" } },
  { name = "jsonls", category = "LSP", bin = "vscode-json-language-server", method = "npm", pkg = "vscode-langservers-extracted",
    description = "Language Server Protocol implementation for JSON.", languages = { "JSON" } },
  { name = "yamlls", category = "LSP", bin = "yaml-language-server", method = "npm", pkg = "yaml-language-server",
    description = "Language Server for YAML Files.", languages = { "YAML" } },
  { name = "emmet_language_server", category = "LSP", bin = "emmet-language-server", method = "npm", pkg = "@olrtg/emmet-language-server",
    description = "A language server for emmet.io.", languages = { "Emmet" } },
  { name = "eslint_d", category = "Linter", bin = "eslint_d", method = "npm", pkg = "eslint_d",
    description = "Makes eslint the fastest linter on the planet.", languages = { "TypeScript", "JavaScript" } },
  { name = "prettier", category = "Formatter", bin = "prettier", method = "npm", pkg = "prettier",
    description = "Prettier is an opinionated code formatter.", languages = { "Angular", "CSS", "Flow", "GraphQL", "HTML", "JSON", "JSX", "JavaScript", "LESS", "Markdown", "SCSS", "TypeScript", "Vue", "YAML" } },
  { name = "black", category = "Formatter", bin = "black", method = "pip", pkg = "black",
    description = "Black, the uncompromising Python code formatter.", languages = { "Python" } },

  -- LSP (96)
  { name = "angular-language-server", category = "LSP", bin = "ngserver", method = "npm", pkg = "@angular/language-server",
    description = "The Angular Language Service provides code editors with a way to get completions, errors, hints,...", languages = { "Angular" } },
  { name = "ansible-language-server", category = "LSP", bin = "ansible-language-server", method = "npm", pkg = "@ansible/ansible-language-server",
    description = "Ansible Language Server.", languages = { "Ansible" } },
  { name = "antlers-language-server", category = "LSP", bin = "antlersls", method = "npm", pkg = "antlers-language-server",
    description = "Provides rich language features for Statamic's Antlers templating language, including code comple...", languages = { "Antlers" } },
  { name = "astro-language-server", category = "LSP", bin = "astro-ls", method = "npm", pkg = "@astrojs/language-server",
    description = "The Astro language server, its structure is inspired by the Svelte Language Server.", languages = { "Astro" } },
  { name = "autotools-language-server", category = "LSP", bin = "autotools-language-server", method = "pip", pkg = "autotools-language-server",
    description = "Autotools language server, support configure.ac, Makefile.am, Makefile.", languages = {  } },
  { name = "awk-language-server", category = "LSP", bin = "awk-language-server", method = "npm", pkg = "awk-language-server",
    description = "Language Server for AWK.", languages = { "AWK" } },
  { name = "azure-pipelines-language-server", category = "LSP", bin = "azure-pipelines-language-server", method = "npm", pkg = "azure-pipelines-language-server",
    description = "A language server for Azure Pipelines YAML.", languages = { "Azure Pipelines" } },
  { name = "basedpyright", category = "LSP", bin = "basedpyright", method = "pip", pkg = "basedpyright",
    description = "Fork of the Pyright static type checker for Python, with extra Pylance features.", languages = { "Python" } },
  { name = "basics-language-server", category = "LSP", bin = "basics-language-server", method = "npm", pkg = "basics-language-server",
    description = "Buffer, path, and snippet completions", languages = {  } },
  { name = "biome", category = "LSP", bin = "biome", method = "npm", pkg = "@biomejs/biome",
    description = "Toolchain of the web. Successor to Rome.", languages = { "JSON", "JavaScript", "TypeScript" } },
  { name = "cds-lsp", category = "LSP", bin = "cds-lsp", method = "npm", pkg = "@sap/cds-lsp",
    description = "Language server for CDS", languages = { "CDS" } },
  { name = "cmake-language-server", category = "LSP", bin = "cmake-language-server", method = "pip", pkg = "cmake-language-server",
    description = "CMake LSP Implementation.", languages = { "CMake" } },
  { name = "coffeesense-language-server", category = "LSP", bin = "coffeesense-language-server", method = "npm", pkg = "coffeesense-language-server",
    description = "Language server for CoffeeScript.", languages = { "CoffeeScript" } },
  { name = "copilot-language-server", category = "LSP", bin = "copilot-language-server", method = "npm", pkg = "@github/copilot-language-server",
    description = "The Copilot Language Server enables any editor or IDE to integrate with GitHub Copilot via the la...", languages = {  } },
  { name = "cspell-lsp", category = "LSP", bin = "cspell-lsp", method = "npm", pkg = "@vlabo/cspell-lsp",
    description = "Language Server Protocol implementation for CSpell, a spell checker for code.", languages = {  } },
  { name = "css-variables-language-server", category = "LSP", bin = "css-variables-language-server", method = "npm", pkg = "css-variables-language-server",
    description = "Autocompletion and go-to-definition for project-wide CSS variables.", languages = { "CSS", "SCSS", "LESS" } },
  { name = "cssmodules-language-server", category = "LSP", bin = "cssmodules-language-server", method = "npm", pkg = "cssmodules-language-server",
    description = "Autocompletion and go-to-definition for cssmodules.", languages = { "CSS" } },
  { name = "cucumber-language-server", category = "LSP", bin = "cucumber-language-server", method = "npm", pkg = "@cucumber/language-server",
    description = "Cucumber Language Server.", languages = { "Cucumber" } },
  { name = "custom-elements-languageserver", category = "LSP", bin = "custom-elements-languageserver", method = "npm", pkg = "custom-elements-languageserver",
    description = "Custom Elements Language Server provides useful language features for Web Components. Features in...", languages = {  } },
  { name = "cypher-language-server", category = "LSP", bin = "cypher-language-server", method = "npm", pkg = "@neo4j-cypher/language-server",
    description = "Language Server for Cypher query language.", languages = { "Cypher" } },
  { name = "diagnostic-languageserver", category = "LSP", bin = "diagnostic-languageserver", method = "npm", pkg = "diagnostic-languageserver",
    description = "Diagnostic language server that integrates with linters.", languages = {  } },
  { name = "django-language-server", category = "LSP", bin = "djls", method = "pip", pkg = "django-language-server",
    description = "A language server for the Django web framework", languages = { "Python" } },
  { name = "django-template-lsp", category = "LSP", bin = "djlsp", method = "pip", pkg = "django-template-lsp",
    description = "A language server for Django templates.", languages = { "Python", "Django", "HTML" } },
  { name = "docker-compose-language-service", category = "LSP", bin = "docker-compose-langserver", method = "npm", pkg = "@microsoft/compose-language-service",
    description = "A language server for Docker Compose.", languages = { "Docker" } },
  { name = "dockerfile-language-server", category = "LSP", bin = "docker-langserver", method = "npm", pkg = "dockerfile-language-server-nodejs",
    description = "A language server for Dockerfiles powered by Node.js, TypeScript, and VSCode technologies.", languages = { "Docker" } },
  { name = "dot-language-server", category = "LSP", bin = "dot-language-server", method = "npm", pkg = "dot-language-server",
    description = "A language server for the DOT language.", languages = { "DOT" } },
  { name = "elm-language-server", category = "LSP", bin = "elm-language-server", method = "npm", pkg = "@elm-tooling/elm-language-server",
    description = "Language server implementation for Elm.", languages = { "Elm" } },
  { name = "ember-language-server", category = "LSP", bin = "ember-language-server", method = "npm", pkg = "@ember-tooling/ember-language-server",
    description = "Language Server Protocol implementation for Ember.js and Glimmer projects.", languages = { "Ember" } },
  { name = "emmet-ls", category = "LSP", bin = "emmet-ls", method = "npm", pkg = "emmet-ls",
    description = "Emmet support based on LSP.", languages = { "Emmet" } },
  { name = "esbonio", category = "LSP", bin = "esbonio", method = "pip", pkg = "esbonio",
    description = "A Language Server for Sphinx projects.", languages = { "Sphinx" } },
  { name = "eslint-lsp", category = "LSP", bin = "vscode-eslint-language-server", method = "npm", pkg = "vscode-langservers-extracted",
    description = "Language Server Protocol implementation for ESLint. The server uses the ESLint library installed...", languages = { "JavaScript", "TypeScript" } },
  { name = "fish-lsp", category = "LSP", bin = "fish-lsp", method = "npm", pkg = "fish-lsp",
    description = "LSP implementation for the fish shell language", languages = { "Fish" } },
  { name = "foam-language-server", category = "LSP", bin = "foam-ls", method = "npm", pkg = "foam-language-server",
    description = "A language server for OpenFOAM case files.", languages = { "OpenFOAM" } },
  { name = "fortls", category = "LSP", bin = "fortls", method = "pip", pkg = "fortls",
    description = "fortls - Fortran Language Server.", languages = { "Fortran" } },
  { name = "gh-actions-language-server", category = "LSP", bin = "gh-actions-language-server", method = "npm", pkg = "@actions/languageserver",
    description = "GitHub Actions Language Server", languages = { "YAML" } },
  { name = "glint", category = "LSP", bin = "glint", method = "npm", pkg = "@glint/core",
    description = "Glint is a set of tools to aid in developing code that uses the Glimmer VM for rendering, such as...", languages = { "Handlebars", "Glimmer", "TypeScript", "JavaScript" } },
  { name = "grammarly-languageserver", category = "LSP", bin = "grammarly-languageserver", method = "npm", pkg = "grammarly-languageserver",
    description = "A language server implementation on top of Grammarly's SDK.", languages = { "Markdown", "Text" } },
  { name = "graphql-language-service-cli", category = "LSP", bin = "graphql-lsp", method = "npm", pkg = "graphql-language-service-cli",
    description = "GraphQL Language Service provides an interface for building GraphQL language services for IDEs.", languages = { "GraphQL" } },
  { name = "hdl-checker", category = "LSP", bin = "hdl_checker", method = "pip", pkg = "hdl-checker",
    description = "HDL Checker is a language server that wraps VHDL/Verilg/SystemVerilog tools that aims to reduce t...", languages = { "VHDL", "Verilog", "SystemVerilog" } },
  { name = "herb-language-server", category = "LSP", bin = "herb-language-server", method = "npm", pkg = "@herb-tools/language-server",
    description = "Powerful and seamless HTML-aware ERB parsing and tooling.", languages = { "HTML", "Ruby" } },
  { name = "hoon-language-server", category = "LSP", bin = "hoon-language-server", method = "npm", pkg = "@urbit/hoon-language-server",
    description = "Language Server for Hoon. Middleware to translate between the Language Server Protocol and your U...", languages = { "Hoon" } },
  { name = "hydra-lsp", category = "LSP", bin = "hydra-lsp", method = "pip", pkg = "hydra-lsp",
    description = "LSP for Hydra config files", languages = { "YAML" } },
  { name = "intelephense", category = "LSP", bin = "intelephense", method = "npm", pkg = "intelephense",
    description = "Professional PHP tooling for any Language Server Protocol capable editor.", languages = { "PHP" } },
  { name = "jedi-language-server", category = "LSP", bin = "jedi-language-server", method = "pip", pkg = "jedi-language-server",
    description = "A Python language server exclusively for Jedi. If Jedi supports it well, this language server sho...", languages = { "Python" } },
  { name = "kos-language-server", category = "LSP", bin = "kls", method = "npm", pkg = "kos-language-server",
    description = "Language Server for Kerboscript from the kOS Kerbal Space Program mod.", languages = { "Kerboscript" } },
  { name = "language-server-bitbake", category = "LSP", bin = "language-server-bitbake", method = "npm", pkg = "language-server-bitbake",
    description = "A language server for BitBake.", languages = { "BitBake" } },
  { name = "lean-language-server", category = "LSP", bin = "lean-language-server", method = "npm", pkg = "lean-language-server",
    description = "Lean3 Language Server.", languages = { "Lean 3" } },
  { name = "lwc-language-server", category = "LSP", bin = "lwc-language-server", method = "npm", pkg = "@salesforce/lwc-language-server",
    description = "Language Server for Lightning Web Components.", languages = { "HTML", "JavaScript" } },
  { name = "m68k-lsp-server", category = "LSP", bin = "m68k-lsp-server", method = "npm", pkg = "m68k-lsp-server",
    description = "Language Server Protocol implementation for Motorola 68000 assembly", languages = { "M68K" } },
  { name = "marko-language-server", category = "LSP", bin = "marko-language-server", method = "npm", pkg = "@marko/language-server",
    description = "A language server (implementing the language server protocol) for Marko.", languages = { "Marko" } },
  { name = "mdx-analyzer", category = "LSP", bin = "mdx-language-server", method = "npm", pkg = "@mdx-js/language-server",
    description = "This package provides a language server for MDX. The language server provides IntelliSense based...", languages = { "MDX" } },
  { name = "mutt-language-server", category = "LSP", bin = "mutt-language-server", method = "pip", pkg = "mutt-language-server",
    description = "A language server for (neo)mutt's muttrc.", languages = { "Python" } },
  { name = "nginx-language-server", category = "LSP", bin = "nginx-language-server", method = "pip", pkg = "nginx-language-server",
    description = "A language server for nginx configuration files.", languages = { "nginx" } },
  { name = "nomicfoundation-solidity-language-server", category = "LSP", bin = "nomicfoundation-solidity-language-server", method = "npm", pkg = "@nomicfoundation/solidity-language-server",
    description = "Solidity language server by NomicFoundation", languages = { "Solidity" } },
  { name = "nxls", category = "LSP", bin = "nxls", method = "npm", pkg = "nxls",
    description = "A language server that provides code completion and more for Nx workspaces.", languages = { "JSON" } },
  { name = "oxlint", category = "LSP", bin = "oxlint", method = "npm", pkg = "oxlint",
    description = "High-performance linter for JavaScript and TypeScript written in Rust.", languages = { "JavaScript", "TypeScript" } },
  { name = "perlnavigator", category = "LSP", bin = "perlnavigator", method = "npm", pkg = "perlnavigator-server",
    description = "Perl Language Server that includes perl critic and code navigation.", languages = { "Perl" } },
  { name = "prisma-language-server", category = "LSP", bin = "prisma-language-server", method = "npm", pkg = "@prisma/language-server",
    description = "Any editor that is compatible with the Language Server Protocol can create clients that can use t...", languages = { "Prisma" } },
  { name = "purescript-language-server", category = "LSP", bin = "purescript-language-server", method = "npm", pkg = "purescript-language-server",
    description = "Node-based Language Server Protocol server for PureScript based on the PureScript IDE server (aka...", languages = { "PureScript" } },
  { name = "pyre", category = "LSP", bin = "pyre", method = "pip", pkg = "pyre-check",
    description = "Pyre is a performant type checker for Python compliant with PEP 484.", languages = { "Python" } },
  { name = "python-lsp-server", category = "LSP", bin = "pylsp", method = "pip", pkg = "python-lsp-server",
    description = "Fork of the python-language-server project, maintained by the Spyder IDE team and the community.", languages = { "Python" } },
  { name = "rassumfrassum", category = "LSP", bin = "rass", method = "pip", pkg = "rassumfrassum",
    description = "Connect an LSP client to multiple LSP servers.", languages = { "Python" } },
  { name = "remark-language-server", category = "LSP", bin = "remark-language-server", method = "npm", pkg = "remark-language-server",
    description = "A language server to lint and format markdown files with remark.", languages = { "Markdown" } },
  { name = "rescript-language-server", category = "LSP", bin = "rescript-language-server", method = "npm", pkg = "@rescript/language-server",
    description = "Language Server for ReScript.", languages = { "ReScript" } },
  { name = "robotcode", category = "LSP", bin = "robotcode", method = "pip", pkg = "robotcode",
    description = "The Ultimate Robot Framework Toolset", languages = { "Robot Framework" } },
  { name = "robotframework-lsp", category = "LSP", bin = "robotframework_ls", method = "pip", pkg = "robotframework-lsp",
    description = "Language Server Protocol implementation for Robot Framework.", languages = { "Robot Framework" } },
  { name = "rpm_lsp_server", category = "LSP", bin = "rpm_lsp_server", method = "pip", pkg = "rpm-spec-language-server",
    description = "Language server protocol (LSP) support for RPM Spec files.", languages = { "Spec" } },
  { name = "salt-lsp", category = "LSP", bin = "salt_lsp_server", method = "pip", pkg = "salt-lsp",
    description = "Salt Language Server Protocol Server.", languages = { "Salt" } },
  { name = "shopify-cli", category = "LSP", bin = "shopify", method = "npm", pkg = "@shopify/cli",
    description = "Command-line interface tool that helps you generate and work with Shopify apps, themes and custom...", languages = { "Liquid" } },
  { name = "snakeskin-cli", category = "LSP", bin = "snakeskin-cli", method = "npm", pkg = "@snakeskin/cli",
    description = "Snakeskin is an awesome JavaScript template engine with the best support for inheritance.", languages = { "Snakeskin" } },
  { name = "solidity-ls", category = "LSP", bin = "solidity-ls", method = "npm", pkg = "solidity-ls",
    description = "Solidity language server.", languages = { "Solidity" } },
  { name = "some-sass-language-server", category = "LSP", bin = "some-sass-language-server", method = "npm", pkg = "some-sass-language-server",
    description = "Full support for @use and @forward, including aliases, prefixes and hiding. Rich documentation th...", languages = { "SCSS" } },
  { name = "sourcery", category = "LSP", bin = "sourcery", method = "pip", pkg = "sourcery",
    description = "Sourcery is a tool available in your IDE, GitHub, or as a CLI that suggests refactoring improveme...", languages = { "Python" } },
  { name = "spyglassmc-language-server", category = "LSP", bin = "spyglassmc-language-server", method = "npm", pkg = "@spyglassmc/language-server",
    description = "This is a language server wrapped around some other Spyglass packages.", languages = { "MCFunction" } },
  { name = "sqlls", category = "LSP", bin = "sql-language-server", method = "npm", pkg = "sql-language-server",
    description = "SQL Language Server.", languages = { "SQL" } },
  { name = "stan-language-server", category = "LSP", bin = "stan-language-server", method = "npm", pkg = "stan-language-server-bin",
    description = "Language server for the Stan probabilistic programming language.", languages = { "Stan" } },
  { name = "stimulus-language-server", category = "LSP", bin = "stimulus-language-server", method = "npm", pkg = "stimulus-language-server",
    description = "Intelligent Stimulus tooling", languages = { "Blade", "HTML", "PHP", "Ruby" } },
  { name = "stylelint-language-server", category = "LSP", bin = "stylelint-language-server", method = "npm", pkg = "@stylelint/language-server",
    description = "A stylelint Language Server.", languages = { "Stylelint" } },
  { name = "stylelint-lsp", category = "LSP", bin = "stylelint-lsp", method = "npm", pkg = "stylelint-lsp",
    description = "A stylelint Language Server.", languages = { "Stylelint" } },
  { name = "svelte-language-server", category = "LSP", bin = "svelteserver", method = "npm", pkg = "svelte-language-server",
    description = "A language server (implementing the language server protocol) for Svelte.", languages = { "Svelte" } },
  { name = "svlangserver", category = "LSP", bin = "svlangserver", method = "npm", pkg = "@imc-trading/svlangserver",
    description = "A language server for systemverilog that has been tested to work with coc.nvim, VSCode, Sublime T...", languages = { "SystemVerilog" } },
  { name = "tabby-agent", category = "LSP", bin = "tabby-agent", method = "npm", pkg = "tabby-agent",
    description = "Tabby is a self-hosted AI coding assistant, offering an open-source and on-premises alternative t...", languages = {  } },
  { name = "tailwindcss-language-server", category = "LSP", bin = "tailwindcss-language-server", method = "npm", pkg = "@tailwindcss/language-server",
    description = "Language Server Protocol implementation for Tailwind CSS.", languages = { "CSS" } },
  { name = "termux-language-server", category = "LSP", bin = "termux-language-server", method = "pip", pkg = "termux-language-server",
    description = "A language server for some specific bash scripts.", languages = { "Bash" } },
  { name = "textlsp", category = "LSP", bin = "textlsp", method = "pip", pkg = "textLSP",
    description = "Language server for text spell and grammar check with various tools.", languages = { "Text", "LaTeX", "Org" } },
  { name = "tsgo", category = "LSP", bin = "tsgo", method = "npm", pkg = "@typescript/native-preview",
    description = "Native TypeScript compiler port. Language Server Protocol support with partial features including...", languages = { "TypeScript", "JavaScript" } },
  { name = "tsp-server", category = "LSP", bin = "tsp-server", method = "npm", pkg = "@typespec/compiler",
    description = "The language server for TypeSpec, a language for defining cloud service APIs and shapes.", languages = { "Typespec" } },
  { name = "turtle-language-server", category = "LSP", bin = "turtle-language-server", method = "npm", pkg = "turtle-language-server",
    description = "A language server (by Stardog) for Turtle", languages = { "Turtle" } },
  { name = "twiggy-language-server", category = "LSP", bin = "twiggy-language-server", method = "npm", pkg = "twiggy-language-server",
    description = "Twig Language Server.", languages = { "Twig", "HTML" } },
  { name = "unocss-language-server", category = "LSP", bin = "unocss-language-server", method = "npm", pkg = "unocss-language-server",
    description = "Language Server Protocol implementation for UnoCSS.", languages = { "CSS" } },
  { name = "vectorcode", category = "LSP", bin = "vectorcode", method = "pip", pkg = "VectorCode",
    description = "A code repository indexing tool to supercharge your LLM experience.", languages = { "Python" } },
  { name = "vetur-vls", category = "LSP", bin = "vls", method = "npm", pkg = "vls",
    description = "VLS (Vue Language Server) is a language server implementation compatible with Language Server Pro...", languages = { "Vue" } },
  { name = "vscode-solidity-server", category = "LSP", bin = "vscode-solidity-server", method = "npm", pkg = "vscode-solidity-server",
    description = "Solidity language server.", languages = { "Solidity" } },
  { name = "vtsls", category = "LSP", bin = "vtsls", method = "npm", pkg = "@vtsls/language-server",
    description = "LSP wrapper around the TypeScript extension bundled with VSCode.", languages = { "JavaScript", "TypeScript" } },
  { name = "vue-language-server", category = "LSP", bin = "vue-language-server", method = "npm", pkg = "@vue/language-server",
    description = "⚡ Explore high-performance tooling for Vue.", languages = { "Vue" } },
  { name = "yls-yara", category = "LSP", bin = "yls", method = "pip", pkg = "yls-yara",
    description = "Language server for the YARA language.", languages = { "YARA" } },
  -- Linter (53)
  { name = "alex", category = "Linter", bin = "alex", method = "npm", pkg = "alex",
    description = "Catch insensitive, inconsiderate writing.", languages = { "Markdown" } },
  { name = "ansible-lint", category = "Linter", bin = "ansible-lint", method = "pip", pkg = "ansible-lint",
    description = "Ansible Lint is a command-line tool for linting playbooks, roles and collections aimed toward any...", languages = { "Ansible" } },
  { name = "bandit", category = "Linter", bin = "bandit", method = "pip", pkg = "bandit",
    description = "Bandit, a security linter from PyCQA", languages = { "Python" } },
  { name = "bslint", category = "Linter", bin = "bslint", method = "npm", pkg = "@rokucommunity/bslint",
    description = "A BrighterScript CLI tool to lint your code without compiling your project.", languages = { "BrighterScript" } },
  { name = "cfn-lint", category = "Linter", bin = "cfn-lint", method = "pip", pkg = "cfn-lint",
    description = "CloudFormation Linter. Validate AWS CloudFormation YAML/JSON templates against the AWS CloudForma...", languages = { "YAML", "JSON", "CloudFormation" } },
  { name = "cmakelint", category = "Linter", bin = "cmakelint", method = "pip", pkg = "cmakelint",
    description = "cmakelint parses CMake files and reports style issues.", languages = { "CMake" } },
  { name = "codespell", category = "Linter", bin = "codespell", method = "pip", pkg = "codespell",
    description = "Check code for common misspellings.", languages = {  } },
  { name = "commitlint", category = "Linter", bin = "commitlint", method = "npm", pkg = "@commitlint/cli",
    description = "commitlint checks if your commit messages meet the conventional commit format.", languages = {  } },
  { name = "cpplint", category = "Linter", bin = "cpplint", method = "pip", pkg = "cpplint",
    description = "Cpplint is a command-line tool to check C/C++ files for style issues following Google's C++ style...", languages = { "C", "C++" } },
  { name = "cspell", category = "Linter", bin = "cspell", method = "npm", pkg = "cspell",
    description = "A Spell Checker for Code.", languages = {  } },
  { name = "curlylint", category = "Linter", bin = "curlylint", method = "pip", pkg = "curlylint",
    description = "Experimental HTML templates linting for Jinja, Nunjucks, Django templates, Twig, Liquid.", languages = { "Django", "Jinja", "Liquid", "Nunjucks", "Twig" } },
  { name = "flake8", category = "Linter", bin = "flake8", method = "pip", pkg = "flake8",
    description = "flake8 is a python tool that glues together pycodestyle, pyflakes, mccabe, and third-party plugin...", languages = { "Python" } },
  { name = "flakeheaven", category = "Linter", bin = "flakeheaven", method = "pip", pkg = "flakeheaven",
    description = "flakeheaven is a python linter built around flake8 to enable inheritable and complex toml configu...", languages = { "Python" } },
  { name = "gdtoolkit", category = "Linter", bin = "gdlint", method = "pip", pkg = "gdtoolkit",
    description = "A set of tools for daily work with GDScript.", languages = { "GDScript" } },
  { name = "gitlint", category = "Linter", bin = "gitlint", method = "pip", pkg = "gitlint",
    description = "Gitlint is a git commit message linter written in Python: it checks your commit messages for style.", languages = {  } },
  { name = "htmlhint", category = "Linter", bin = "htmlhint", method = "npm", pkg = "htmlhint",
    description = "The Static Code Analysis Tool for your HTML", languages = { "HTML" } },
  { name = "jsonlint", category = "Linter", bin = "jsonlint", method = "npm", pkg = "jsonlint",
    description = "A pure JavaScript version of the service provided at jsonlint.com.", languages = { "JSON" } },
  { name = "markdownlint", category = "Linter", bin = "markdownlint", method = "npm", pkg = "markdownlint-cli",
    description = "A Node.js style checker and lint tool for Markdown/CommonMark files.", languages = { "Markdown" } },
  { name = "markdownlint-cli2", category = "Linter", bin = "markdownlint-cli2", method = "npm", pkg = "markdownlint-cli2",
    description = "A fast, flexible, configuration-based command-line interface for linting Markdown/CommonMark file...", languages = { "Markdown" } },
  { name = "markuplint", category = "Linter", bin = "markuplint", method = "npm", pkg = "markuplint",
    description = "An HTML linter for all markup developers.", languages = { "HTML" } },
  { name = "mypy", category = "Linter", bin = "mypy", method = "pip", pkg = "mypy",
    description = "Mypy is a static type checker for Python.", languages = { "Python" } },
  { name = "npm-groovy-lint", category = "Linter", bin = "npm-groovy-lint", method = "npm", pkg = "npm-groovy-lint",
    description = "Lint, format and auto-fix your Groovy / Jenkinsfile / Gradle files using command line.", languages = { "Groovy" } },
  { name = "oelint-adv", category = "Linter", bin = "oelint-adv", method = "pip", pkg = "oelint-adv",
    description = "Linter for bitbake recipes.", languages = { "BitBake" } },
  { name = "proselint", category = "Linter", bin = "proselint", method = "pip", pkg = "proselint",
    description = "proselint is a linter for English prose. It places the world's greatest writers and editors by yo...", languages = { "Text", "Markdown" } },
  { name = "pydoclint", category = "Linter", bin = "pydoclint", method = "pip", pkg = "pydoclint",
    description = "A very fast Python docstring linter.", languages = { "Python" } },
  { name = "pydocstyle", category = "Linter", bin = "pydocstyle", method = "pip", pkg = "pydocstyle",
    description = "pydocstyle is a static analysis tool for checking compliance with Python docstring conventions.", languages = { "Python" } },
  { name = "pyflakes", category = "Linter", bin = "pyflakes", method = "pip", pkg = "pyflakes",
    description = "A simple program which checks Python source files for errors. Pyflakes analyzes programs and dete...", languages = { "Python" } },
  { name = "pylama", category = "Linter", bin = "pylama", method = "pip", pkg = "pylama",
    description = "Code audit tool for Python.", languages = { "Python" } },
  { name = "pylint", category = "Linter", bin = "pylint", method = "pip", pkg = "pylint",
    description = "Pylint is a static code analyser for Python 2 or 3.", languages = { "Python" } },
  { name = "pymarkdownlnt", category = "Linter", bin = "pymarkdownlnt", method = "pip", pkg = "pymarkdownlnt",
    description = "PyMarkdown is primarily a Markdown linter.", languages = { "Markdown" } },
  { name = "pyproject-flake8", category = "Linter", bin = "pflake8", method = "pip", pkg = "pyproject-flake8",
    description = "A monkey patching wrapper to connect flake8 with pyproject.toml configuration.", languages = { "Python" } },
  { name = "pyrefly", category = "Linter", bin = "pyrefly", method = "pip", pkg = "pyrefly",
    description = "Pyrefly, a faster Python type checker written in Rust", languages = { "Python" } },
  { name = "refurb", category = "Linter", bin = "refurb", method = "pip", pkg = "refurb",
    description = "A tool for refurbishing and modernizing Python codebases.", languages = { "Python" } },
  { name = "rpmlint", category = "Linter", bin = "rpmlint", method = "pip", pkg = "rpmlint",
    description = "Rpmlint is a tool for checking common errors in RPM packages.", languages = { "Python" } },
  { name = "rstcheck", category = "Linter", bin = "rstcheck", method = "pip", pkg = "rstcheck",
    description = "Checks syntax of reStructuredText and code blocks nested within it.", languages = { "reStructuredText" } },
  { name = "salt-lint", category = "Linter", bin = "salt-lint", method = "pip", pkg = "salt-lint",
    description = "A command-line utility that checks for best practices in SaltStack.", languages = { "Salt" } },
  { name = "semgrep", category = "Linter", bin = "semgrep", method = "pip", pkg = "semgrep",
    description = "Semgrep is a fast, open-source, static analysis engine for finding bugs, detecting vulnerabilitie...", languages = { "C#", "Go", "JSON", "Java", "JavaScript", "PHP", "Python", "Ruby", "Scala", "TypeScript" } },
  { name = "solhint", category = "Linter", bin = "solhint", method = "npm", pkg = "solhint",
    description = "Solhint is a linting utility for Solidity code.", languages = { "Solidity" } },
  { name = "sphinx-lint", category = "Linter", bin = "sphinx-lint", method = "pip", pkg = "sphinx-lint",
    description = "Linter for stylistic and formal issues in Sphinx documentation", languages = { "reStructuredText", "Python" } },
  { name = "sqlfluff", category = "Linter", bin = "sqlfluff", method = "pip", pkg = "sqlfluff",
    description = "SQLFluff is a dialect-flexible and configurable SQL linter.", languages = { "SQL" } },
  { name = "standardjs", category = "Linter", bin = "standard", method = "npm", pkg = "standard",
    description = "JavaScript Style Guide, with linter & automatic code fixer.", languages = { "JavaScript" } },
  { name = "stylelint", category = "Linter", bin = "stylelint", method = "npm", pkg = "stylelint",
    description = "A mighty CSS linter that helps you avoid errors and enforce conventions.", languages = { "CSS", "Sass", "SCSS", "LESS" } },
  { name = "systemdlint", category = "Linter", bin = "systemdlint", method = "pip", pkg = "systemdlint",
    description = "Systemd Unitfile Linter", languages = { "systemd" } },
  { name = "tclint", category = "Linter", bin = "tclint", method = "pip", pkg = "tclint",
    description = "Modern dev tools for Tcl • includes a linter, formatter, and editor integration.", languages = { "Tcl" } },
  { name = "textlint", category = "Linter", bin = "textlint", method = "npm", pkg = "textlint",
    description = "The pluggable natural language linter for text and markdown.", languages = { "Text", "Markdown" } },
  { name = "ts-standard", category = "Linter", bin = "ts-standard", method = "npm", pkg = "ts-standard",
    description = "Typescript style guide, linter, and formatter using StandardJS.", languages = { "TypeScript" } },
  { name = "ty", category = "Linter", bin = "ty", method = "pip", pkg = "ty",
    description = "An extremely fast Python type checker and language server, written in Rust.", languages = { "Python" } },
  { name = "vint", category = "Linter", bin = "vint", method = "pip", pkg = "vim-vint",
    description = "Fast and Highly Extensible Vim script Language Lint implemented in Python.", languages = { "VimScript" } },
  { name = "vulture", category = "Linter", bin = "vulture", method = "pip", pkg = "vulture",
    description = "Vulture finds unused code in Python programs. This is useful for cleaning up and finding errors i...", languages = { "Python" } },
  { name = "write-good", category = "Linter", bin = "write-good", method = "npm", pkg = "write-good",
    description = "Naive linter for English prose for developers who can't write good and wanna learn to do other st...", languages = { "Markdown" } },
  { name = "yamllint", category = "Linter", bin = "yamllint", method = "pip", pkg = "yamllint",
    description = "Linter for YAML files. yamllint does not only check for syntax validity, but for weirdnesses like...", languages = { "YAML" } },
  { name = "zizmor", category = "Linter", bin = "zizmor", method = "pip", pkg = "zizmor",
    description = "Static analysis for GitHub Actions", languages = { "YAML" } },
  { name = "zuban", category = "Linter", bin = "zuban", method = "pip", pkg = "zuban",
    description = "Zuban is a high-performant Mypy-compatible LSP and type checker built in Rust.", languages = { "Python" } },
  -- Formatter (50)
  { name = "autoflake", category = "Formatter", bin = "autoflake", method = "pip", pkg = "autoflake",
    description = "autoflake removes unused imports and unused variables from Python code.", languages = { "Python" } },
  { name = "autopep8", category = "Formatter", bin = "autopep8", method = "pip", pkg = "autopep8",
    description = "A tool that automatically formats Python code to conform to the PEP 8 style guide.", languages = { "Python" } },
  { name = "beanhub-cli", category = "Formatter", bin = "bh", method = "pip", pkg = "beanhub-cli",
    description = "A simple beancount formatter that keeps comments.", languages = { "Beancount" } },
  { name = "beautysh", category = "Formatter", bin = "beautysh", method = "pip", pkg = "beautysh",
    description = "beautysh - A Bash beautifier for the masses.", languages = { "Bash", "Csh", "Ksh", "Sh", "Zsh" } },
  { name = "bibtex-tidy", category = "Formatter", bin = "bibtex-tidy", method = "npm", pkg = "bibtex-tidy",
    description = "Cleaner and Formatter for BibTeX files", languages = { "LaTeX" } },
  { name = "blade-formatter", category = "Formatter", bin = "blade-formatter", method = "npm", pkg = "blade-formatter",
    description = "An opinionated blade template formatter for Laravel that respects readability.", languages = { "Blade" } },
  { name = "blue", category = "Formatter", bin = "blue", method = "pip", pkg = "blue",
    description = "blue is a somewhat less uncompromising code formatter than black, the OG of Python formatters. We...", languages = { "Python" } },
  { name = "brighterscript-formatter", category = "Formatter", bin = "bsfmt", method = "npm", pkg = "brighterscript-formatter",
    description = "A code formatter for BrightScript and BrighterScript.", languages = { "BrighterScript" } },
  { name = "brunette", category = "Formatter", bin = "brunette", method = "pip", pkg = "brunette",
    description = "A best practice Python code formatter", languages = { "Python" } },
  { name = "clang-format", category = "Formatter", bin = "clang-format", method = "pip", pkg = "clang-format",
    description = "clang-format is formatter for C/C++/Java/JavaScript/JSON/Objective-C/Protobuf/C# code.", languages = { "C", "C#", "C++", "JSON", "Java", "JavaScript" } },
  { name = "cmakelang", category = "Formatter", bin = "cmake-annotate", method = "pip", pkg = "cmakelang",
    description = "Language tools for cmake (format, lint, etc).", languages = { "CMake" } },
  { name = "darker", category = "Formatter", bin = "darker", method = "pip", pkg = "darker",
    description = "Apply black reformatting to Python files only in regions changed since a given commit.", languages = { "Python" } },
  { name = "djlint", category = "Formatter", bin = "djlint", method = "pip", pkg = "djlint",
    description = "HTML Template Linter and Formatter. Django - Jinja - Nunjucks - Handlebars - GoLang.", languages = { "Django", "Go", "Nunjucks", "Twig", "Handlebars", "Mustache", "Angular", "Jinja" } },
  { name = "docformatter", category = "Formatter", bin = "docformatter", method = "pip", pkg = "docformatter",
    description = "docformatter automatically formats docstrings to follow a subset of the PEP 257 conventions.", languages = { "Python" } },
  { name = "doctoc", category = "Formatter", bin = "doctoc", method = "npm", pkg = "doctoc",
    description = "API and CLI for generating a markdown TOC (table of contents) for a README or any markdown files.", languages = { "Markdown" } },
  { name = "elm-format", category = "Formatter", bin = "elm-format", method = "npm", pkg = "elm-format",
    description = "elm-format formats Elm source code according to a standard set of rules based on the official Elm...", languages = { "Elm" } },
  { name = "findent", category = "Formatter", bin = "findent", method = "pip", pkg = "findent",
    description = "findent indents/beautifies/converts and can optionally generate the dependencies of Fortran sources.", languages = { "Fortran" } },
  { name = "fixjson", category = "Formatter", bin = "fixjson", method = "npm", pkg = "fixjson",
    description = "A JSON file fixer/formatter for humans using (relaxed) JSON5.", languages = { "JSON" } },
  { name = "fprettify", category = "Formatter", bin = "fprettify", method = "pip", pkg = "fprettify",
    description = "fprettify is an auto-formatter for modern Fortran code that imposes strict whitespace formatting,...", languages = { "Fortran" } },
  { name = "gersemi", category = "Formatter", bin = "gersemi", method = "pip", pkg = "gersemi",
    description = "gersemi - A formatter to make your CMake code the real treasure.", languages = { "CMake" } },
  { name = "isort", category = "Formatter", bin = "isort", method = "pip", pkg = "isort",
    description = "isort is a Python utility / library to sort imports alphabetically.", languages = { "Python" } },
  { name = "json-repair", category = "Formatter", bin = "json_repair", method = "pip", pkg = "json-repair",
    description = "A package to repair broken json strings", languages = { "Python" } },
  { name = "jupytext", category = "Formatter", bin = "jupytext", method = "pip", pkg = "jupytext",
    description = "Jupyter Notebooks as Markdown Documents, Julia, Python or R scripts", languages = { "Python", "Julia", "R", "Markdown" } },
  { name = "kulala-fmt", category = "Formatter", bin = "kulala-fmt", method = "npm", pkg = "@mistweaverco/kulala-fmt",
    description = "kulala-fmt An opinionated .http and .rest files linter and formatter.", languages = { "http" } },
  { name = "markdown-toc", category = "Formatter", bin = "markdown-toc", method = "npm", pkg = "markdown-toc",
    description = "API and CLI for generating a markdown TOC (table of contents) for a README or any markdown files.", languages = { "Markdown" } },
  { name = "mbake", category = "Formatter", bin = "mbake", method = "pip", pkg = "mbake",
    description = "Makefile formatter and linter.", languages = { "Makefile" } },
  { name = "mdformat", category = "Formatter", bin = "mdformat", method = "pip", pkg = "mdformat",
    description = "CommonMark compliant Markdown formatter.", languages = { "Markdown" } },
  { name = "miss_hit", category = "Formatter", bin = "mh_style", method = "pip", pkg = "miss-hit",
    description = "Free and open source code quality tools for MATLAB and Octave.", languages = { "Matlab", "Octave" } },
  { name = "nginx-config-formatter", category = "Formatter", bin = "nginxfmt", method = "pip", pkg = "nginxfmt",
    description = "nginx config file formatter/beautifier written in Python with no additional dependencies.", languages = { "nginx" } },
  { name = "oxfmt", category = "Formatter", bin = "oxfmt", method = "npm", pkg = "oxfmt",
    description = "Prettier-compatible code formatter powered by Oxc", languages = { "Angular", "CSS", "Flow", "GraphQL", "HTML", "JSON", "JSX", "JavaScript", "LESS", "Markdown", "SCSS", "TypeScript", "Vue", "YAML" } },
  { name = "prettierd", category = "Formatter", bin = "prettierd", method = "npm", pkg = "@fsouza/prettierd",
    description = "Prettier, as a daemon, for ludicrous formatting speed.", languages = { "Angular", "CSS", "Flow", "GraphQL", "HTML", "JSON", "JSX", "JavaScript", "LESS", "Markdown", "SCSS", "TypeScript", "Vue", "YAML" } },
  { name = "prettydiff", category = "Formatter", bin = "prettydiff", method = "npm", pkg = "prettydiff",
    description = "Beautifier and language aware code comparison tool for many languages. It also minifies and a few...", languages = { "HTML" } },
  { name = "purescript-tidy", category = "Formatter", bin = "purs-tidy", method = "npm", pkg = "purs-tidy",
    description = "A syntax tidy-upper (formatter) for PureScript.", languages = { "PureScript" } },
  { name = "pyink", category = "Formatter", bin = "pyink", method = "pip", pkg = "pyink",
    description = "Pyink is a Python formatter, forked from Black with a few different formatting behaviors.", languages = { "Python" } },
  { name = "pyment", category = "Formatter", bin = "pyment", method = "pip", pkg = "pyment",
    description = "Create, update or convert docstrings in existing Python files, managing several styles.", languages = { "Python" } },
  { name = "pyproject-fmt", category = "Formatter", bin = "pyproject-fmt", method = "pip", pkg = "pyproject-fmt",
    description = "Format your pyproject.toml file", languages = { "Python", "TOML" } },
  { name = "reformat-gherkin", category = "Formatter", bin = "reformat-gherkin", method = "pip", pkg = "reformat-gherkin",
    description = "Reformat-gherkin automatically formats Gherkin files.", languages = { "Cucumber" } },
  { name = "remark-cli", category = "Formatter", bin = "remark", method = "npm", pkg = "remark-cli",
    description = "Command line interface to inspect and change markdown files with remark.", languages = { "Markdown" } },
  { name = "reorder-python-imports", category = "Formatter", bin = "reorder-python-imports", method = "pip", pkg = "reorder-python-imports",
    description = "Tool for automatically reordering python imports. Similar to isort but uses static analysis more.", languages = { "Python" } },
  { name = "rustywind", category = "Formatter", bin = "rustywind", method = "npm", pkg = "rustywind",
    description = "CLI for organizing Tailwind CSS classes.", languages = { "Angular", "HTML", "JSX", "JavaScript", "TypeScript", "Vue" } },
  { name = "snakefmt", category = "Formatter", bin = "snakefmt", method = "pip", pkg = "snakefmt",
    description = "The uncompromising Snakemake code formatter.", languages = { "Snakemake" } },
  { name = "sql-formatter", category = "Formatter", bin = "sql-formatter", method = "npm", pkg = "sql-formatter",
    description = "A whitespace formatter for different query languages.", languages = { "SQL" } },
  { name = "sqlfmt", category = "Formatter", bin = "sqlfmt", method = "pip", pkg = "shandy-sqlfmt",
    description = "sqlfmt formats your dbt SQL files so you don't have to. It is similar in nature to black, gofmt,...", languages = { "SQL" } },
  { name = "usort", category = "Formatter", bin = "usort", method = "pip", pkg = "usort",
    description = "Safe, minimal import sorting for Python projects.", languages = { "Python" } },
  { name = "vhdl-style-guide", category = "Formatter", bin = "vsg", method = "pip", pkg = "vsg",
    description = "Style guide enforcement for VHDL", languages = { "VHDL" } },
  { name = "vsg", category = "Formatter", bin = "vsg", method = "pip", pkg = "vsg",
    description = "VHDL Style Guide (VSG), Coding style enforcement for VHDL.", languages = { "VHDL" } },
  { name = "xmlformatter", category = "Formatter", bin = "xmlformat", method = "pip", pkg = "xmlformatter",
    description = "xmlformatter is an Open Source Python package that provides formatting of XML documents. xmlforma...", languages = { "XML" } },
  { name = "yamlfix", category = "Formatter", bin = "yamlfix", method = "pip", pkg = "yamlfix",
    description = "A simple and configurable YAML formatter that keeps comments.", languages = { "YAML" } },
  { name = "yapf", category = "Formatter", bin = "yapf", method = "pip", pkg = "yapf",
    description = "YAPF, Yet Another Python Formatter.", languages = { "Python" } },
  { name = "zprint-clj", category = "Formatter", bin = "zprint-clj", method = "npm", pkg = "zprint-clj",
    description = "Node.js wrapper for ZPrint Clojure source code formatter", languages = { "Clojure", "ClojureScript" } },
  -- DAP (1)
  { name = "debugpy", category = "DAP", bin = "debugpy", method = "pip", pkg = "debugpy",
    description = "An implementation of the Debug Adapter Protocol for Python.", languages = { "Python" } },
  -- Compiler (2)
  { name = "brighterscript", category = "Compiler", bin = "bsc", method = "npm", pkg = "brighterscript",
    description = "A superset of Roku's BrightScript language.", languages = { "BrighterScript" } },
  { name = "wing", category = "Compiler", bin = "wing", method = "npm", pkg = "winglang",
    description = "A programming language for the cloud", languages = { "Wing" } },
  -- Runtime (1)
  { name = "pymobiledevice3", category = "Runtime", bin = "pymobiledevice3", method = "pip", pkg = "pymobiledevice3",
    description = "Pure python3 implementation for working with iDevices (iPhone, etc...).", languages = { "Python" } },}

local state = { buf = nil, win = nil, entries = {}, line_to_entry = {} }

local function find_binary(name)
  local path = vim.fn.exepath(name)
  return path ~= "" and path or nil
end

local function refresh_status()
  for _, entry in ipairs(state.entries) do
    entry.path = find_binary(entry.bin)
    entry.installed = entry.path ~= nil
  end
end

local function render()
  local lines = {
    "  i:install  u:update  U:update-all",
    "  X:uninstall  <CR>:details  g?:help  q:close",
    "",
  }
  local line_to_entry = {}
  local highlights = {
    { line = 0, col_start = 0, col_end = -1, hl = "LspManagerHint" },
    { line = 1, col_start = 0, col_end = -1, hl = "LspManagerHint" },
  }

  for _, cat in ipairs(CATEGORY_ORDER) do
    local cat_entries = {}
    for idx, entry in ipairs(state.entries) do
      if entry.category == cat then table.insert(cat_entries, idx) end
    end
    if #cat_entries > 0 then
      table.insert(lines, "")
      table.insert(lines, "-- " .. cat .. " (" .. #cat_entries .. ") --")
      table.insert(highlights, { line = #lines - 1, col_start = 0, col_end = -1, hl = "LspManagerHeader" })

      for _, idx in ipairs(cat_entries) do
        local entry = state.entries[idx]
        local icon = entry.busy and "➜" or (entry.installed and "✓" or "✗")
        local hl = entry.busy and "LspManagerPending" or (entry.installed and "LspManagerInstalled" or "LspManagerMissing")
        local prefix = "  "
        table.insert(lines, prefix .. icon .. " " .. entry.name)
        line_to_entry[#lines] = idx
        table.insert(highlights, { line = #lines - 1, col_start = #prefix, col_end = #prefix + #icon, hl = hl })

        if entry.expanded then
          table.insert(lines, "      " .. (entry.description ~= "" and entry.description or "(no description)"))
          if entry.languages and #entry.languages > 0 then
            table.insert(lines, string.format("      languages : %s", table.concat(entry.languages, ", ")))
          end
          table.insert(lines, string.format("      binary    : %s", entry.bin))
          table.insert(lines, string.format("      path      : %s", entry.path or "(not found)"))
          table.insert(lines, string.format("      method    : %s (%s)", entry.method, entry.pkg))
        end
      end
    end
  end

  state.line_to_entry = line_to_entry
  vim.api.nvim_set_option_value("modifiable", true, { buf = state.buf })
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)
  for _, h in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(state.buf, ns, h.hl, h.line, h.col_start, h.col_end)
  end
  vim.api.nvim_set_option_value("modifiable", false, { buf = state.buf })
end

local function entry_under_cursor()
  local line = vim.api.nvim_win_get_cursor(state.win)[1]
  local idx = state.line_to_entry[line]
  return idx and state.entries[idx] or nil
end

local function split(str)
  local parts = {}
  for word in str:gmatch("%S+") do
    table.insert(parts, word)
  end
  return parts
end

local function run_pkg_cmd(entry, action)
  local cmd
  if entry.method == "pkg" then
    cmd = { "pkg", action == "install" and "install" or "uninstall", "-y" }
    vim.list_extend(cmd, split(entry.pkg))
  elseif entry.method == "npm" then
    cmd = { "npm", action == "install" and "install" or "uninstall", "-g" }
    vim.list_extend(cmd, split(entry.pkg))
  elseif entry.method == "pip" then
    cmd = action == "install"
      and { "pip", "install", "--break-system-packages", "--upgrade" }
      or { "pip", "uninstall", "-y" }
    vim.list_extend(cmd, split(entry.pkg))
  end
  return cmd
end

local function install_entry(entry)
  if entry.busy then return end
  entry.busy = true
  render()
  vim.fn.jobstart(run_pkg_cmd(entry, "install"), {
    on_exit = function(_, code)
      entry.busy = false
      vim.notify(
        entry.name .. (code == 0 and ": installed/updated successfully" or ": operation failed"),
        code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
      )
      refresh_status()
      render()
    end,
  })
end

local function uninstall_entry(entry)
  if entry.busy or not entry.installed then return end
  entry.busy = true
  render()
  vim.fn.jobstart(run_pkg_cmd(entry, "uninstall"), {
    on_exit = function(_, code)
      entry.busy = false
      refresh_status()
      render()
    end,
  })
end

local function setup_keymaps()
  local opts = { buffer = state.buf, nowait = true, silent = true }

  vim.keymap.set("n", "<CR>", function()
    local e = entry_under_cursor()
    if e then e.expanded = not e.expanded; render() end
  end, opts)

  vim.keymap.set("n", "i", function()
    local e = entry_under_cursor()
    if e then install_entry(e) end
  end, opts)

  vim.keymap.set("n", "u", function()
    local e = entry_under_cursor()
    if e then install_entry(e) end
  end, opts)

  vim.keymap.set("n", "U", function()
    for _, e in ipairs(state.entries) do
      if e.installed then install_entry(e) end
    end
  end, opts)

  vim.keymap.set("n", "X", function()
    local e = entry_under_cursor()
    if not e or not e.installed then return end

    local choice = vim.fn.confirm("Uninstall " .. e.name .. "?", "&Yes\n&No", 2)
    if choice == 1 then
      uninstall_entry(e)
    end
  end, opts)

  vim.keymap.set("n", "c", function()
    vim.notify("Version check: coming soon", vim.log.levels.INFO)
  end, opts)

  vim.keymap.set("n", "C", function()
    vim.notify("Check all updates: coming soon", vim.log.levels.INFO)
  end, opts)

  vim.keymap.set("n", "g?", function()
    vim.notify("i/u install-update | U update all | X uninstall | <CR> details | q close", vim.log.levels.INFO)
  end, opts)

  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(state.win, true)
  end, opts)
end

function M.open()
  state.entries = vim.deepcopy(registry)
  for _, e in ipairs(state.entries) do e.expanded = false; e.busy = false end
  refresh_status()

  state.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("modifiable", false, { buf = state.buf })

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.9)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = "editor", width = width, height = height,
    row = row, col = col, style = "minimal", border = "rounded",
    title = " LSP Manager ", title_pos = "center",
  })

  render()
  setup_keymaps()
end

vim.api.nvim_create_user_command("Mason", M.open, {})

return M
