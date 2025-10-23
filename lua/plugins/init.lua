return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "hyprlang",
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "c_sharp",
        "razor",
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
      ensure_installed = {
        "lua-language-server",
        "xmlformatter",
        "csharpier",
        "prettier",
        "stylua",
        "bicep-lsp",
        "html-lsp",
        "css-lsp",
        "eslint-lsp",
        "typescript-language-server",
        "json-lsp",
        "rust-analyzer",
        "roslyn",
        "rzls",
      },
    },
  },
  {
    "seblyng/roslyn.nvim",
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    ft = { "cs", "razor" },
    opts = {},

    dependencies = {
      {
        "tris203/rzls.nvim",
        config = true,
      },
    },
    lazy = false,
    config = function()
      -- Use one of the methods in the Integration section to compose the command.
      local mason_registry = require "mason-registry"

      local rzls_path = vim.fn.expand "$MASON/packages/rzls/libexec"
      local cmd = {
        "roslyn",
        "--stdio",
        "--logLevel=Information",
        "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
        "--razorSourceGenerator=" .. vim.fs.joinpath(rzls_path, "Microsoft.CodeAnalysis.Razor.Compiler.dll"),
        "--razorDesignTimePath=" .. vim.fs.joinpath(rzls_path, "Targets", "Microsoft.NET.Sdk.Razor.DesignTime.targets"),
        "--extension",
        vim.fs.joinpath(rzls_path, "RazorExtension", "Microsoft.VisualStudioCode.RazorExtension.dll"),
      }

      vim.lsp.config("roslyn", {
        cmd = cmd,
        handlers = require "rzls.roslyn_handlers",
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,

            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
          },
          ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
          },
        },
      })
      vim.lsp.enable "roslyn"
    end,
    init = function()
      -- We add the Razor file types before the plugin loads.
      vim.filetype.add {
        extension = {
          razor = "razor",
          cshtml = "razor",
        },
      }
    end,
  },
  { "tiagovla/tokyodark.nvim", version = "*" },
  { "nvim-telescope/telescope-ui-select.nvim" },
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    enabled = true,
    init = false,
    opts = function()
      local dashboard = require "alpha.themes.dashboard"
      local logo = [[
⠀  ⠲⣦⣤⣀⣀⠀⠀⠀⣀⣀⣠⣤⣀⣀⠀⢀⣀⣠⣤⣶⣶⠟⠀⠀⠀
⠀⠀⠀⠀⠙⣿⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠋⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠈⢿⣿⣿⠻⣿⣿⣿⣿⣿⣿⣿⠟⢻⣿⣿⡿⠃⠀⠀⠀⠀⠀
⠀⠀⠀⠲⣶⣶⣾⣿⣿⠀⢨⠙⢿⣿⣿⠏⣅⠀⢸⣿⣿⣷⣾⠟⠁⠀⠀⠀
⠀⠀⠀⠀⠈⠻⢿⣿⣿⢷⣶⣶⣾⣿⣿⣶⣶⣾⠟⣿⣿⣿⣋⠀⠀⠀⠀⠀
⠀⠀⢀⣀⣀⠐⢶⣿⣿⣧⠁⠀⠋⠁⠈⠋⠀⢀⣾⣿⣿⡿⣷⣶⠀⠀⠀⠀
⠀⠀⣼⣿⣿⣷⣤⣙⣿⣿⣷⣶⣶⣴⣴⣴⣶⣿⣿⣿⠟⣡⣿⣿⣧⣄⣀⡀
⢀⣤⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⠿⢿⣿⡿⠿⣿⣿⣿⣿
⣿⡿⠛⠿⠟⠉⠉⠉⠸⠋⠀⠻⡿⣿⣿⣿⣿⠻⠇⠀⠀⠈⠀⠀⠈⠉⢸⠃
⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠈⢿⢻⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ]]

      dashboard.section.header.val = vim.split(logo, "\n")
    -- stylua: ignore
    dashboard.section.buttons.val = {
      dashboard.button("f", " " .. " Find file",       "<cmd> lua LazyVim.pick()() <cr>"),
      dashboard.button("n", " " .. " New file",        [[<cmd> ene <BAR> startinsert <cr>]]),
      dashboard.button("r", " " .. " Recent files",    [[<cmd> lua LazyVim.pick("oldfiles")() <cr>]]),
      dashboard.button("g", " " .. " Find text",       [[<cmd> lua LazyVim.pick("live_grep")() <cr>]]),
      dashboard.button("c", " " .. " Config",          "<cmd> lua LazyVim.pick.config_files()() <cr>"),
      dashboard.button("s", " " .. " Restore Session", [[<cmd> lua require("persistence").load() <cr>]]),
      dashboard.button("x", " " .. " Lazy Extras",     "<cmd> LazyExtras <cr>"),
      dashboard.button("l", "󰒲 " .. " Lazy",            "<cmd> Lazy <cr>"),
      dashboard.button("q", " " .. " Quit",            "<cmd> qa <cr>"),
    }
      for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl = "AlphaButtons"
        button.opts.hl_shortcut = "AlphaShortcut"
      end
      dashboard.section.header.opts.hl = "AlphaHeader"
      dashboard.section.buttons.opts.hl = "AlphaButtons"
      dashboard.section.footer.opts.hl = "AlphaFooter"
      dashboard.opts.layout[1].val = 8
      return dashboard
    end,
    config = function(_, dashboard)
      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          once = true,
          pattern = "AlphaReady",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      require("alpha").setup(dashboard.opts)

      vim.api.nvim_create_autocmd("User", {
        once = true,
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          dashboard.section.footer.val = "⚡ Neovim loaded "
            .. stats.loaded
            .. "/"
            .. stats.count
            .. " plugins in "
            .. ms
            .. "ms"
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },
}
