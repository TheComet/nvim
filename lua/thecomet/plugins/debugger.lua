return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "debugloop/layers.nvim",
        },
        config = function()
            local dap = require("dap")

            -- Global keybindings
            vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)
            vim.keymap.set("n", "<leader>dr", dap.continue)
        end
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
        opts = {
            icons = {
                expanded = "▾",
                collapsed = "▸",
                current_frame = "",
            },
            layouts = {
                {
                    elements = {
                        -- Provide IDs as strings or tables with "id" and "size" keys
                        { id = "breakpoints", size = 0.15 },
                        { id = "stacks",      size = 0.25 },
                        { id = "scopes",      size = 0.40 },
                        { id = "watches",     size = 0.20 },
                    },
                    size = 40,
                    position = "left",
                },
                {
                    elements = {
                        { id = "repl", size = 0.5 },
                        { id = "rtt",  size = 0.5 },
                    },
                    size = 15,
                    position = "bottom",
                },
            },
            floating = {
                mappings = {
                    close = { "q", "<Esc>" },
                },
            },
            controls = {
                enabled = false,
                element = "repl",
                icons = {
                    pause = "",
                    play = "",
                    step_into = "",
                    step_over = "",
                    step_out = "",
                    step_back = "",
                    run_last = "",
                    terminate = "",
                    disconnect = "",
                },
            }
        },
        config = function(_, opts)
            local dap = require("dap")
            local widgets = require("dap.ui.widgets")
            local ui = require("dapui")
            local layers = require("layers")
            ui.setup(opts)

            local open_and_bind = function()
                ui.open({ reset = "true" })

                -- Keybindings that are only active during debugging
                local debug_map = layers.map.new()
                debug_map:set("n", "<leader>dr", dap.restart)
                debug_map:set("n", "<leader>dt", function() dap.terminate() ui.close() debug_map:clear() end)
                debug_map:set("n", "<leader>do", function() require("dapui").float_element("rtt") end)
                debug_map:set("n", "<leader>dc", function() ui.close() debug_map:clear() end)
                debug_map:set("n", "<A-r>", dap.continue)
                debug_map:set("n", "<C-n>", dap.step_over)
                debug_map:set("n", "<A-n>", dap.step_back)
                debug_map:set("n", "<C-s>", dap.step_into)
                debug_map:set("n", "<A-s>", dap.step_out)
                debug_map:set("n", "<C-f>", dap.down)
                debug_map:set("n", "<A-f>", dap.up)
                debug_map:set("n", "<C-c>", dap.run_to_cursor)
                debug_map:set("n", "<leader>h", widgets.hover)
                debug_map:set("n", "<leader>k", widgets.preview)
                debug_map:set("n", "<leader>e", dap.repl.open)
                debug_map:set("n", "<leader>i", function() require("nvim-dap-virtual-text").toggle() end)
                debug_map:set("n", "<leader>a", function() require("dapui").elements.watches.add(vim.fn.expand("<cword>")) end)
                debug_map:set("n", "<Leader>f", function() widgets.centered_float(widgets.frames) end)
                debug_map:set("n", "<Leader>s", function() widgets.centered_float(widgets.scopes) end)
                --dap.listeners.before.event_terminated["keymap_config"] = function()
                --    debug_map:clear()
                --    ui.close()
                --end
                --dap.listeners.before.event_exited["keymap_config"] = function()
                --    debug_map:clear()
                --    ui.close()
                --end
                --dap.listeners.before.event_terminated["dapui_config"] = function()
                --    debug_map:clear()
                --    ui.close()
                --end
                --dap.listeners.before.event_exited["dapui_config"] = function()
                --    debug_map:clear()
                --    ui.close()
                --end
            end

            vim.keymap.set("n", "<leader>do", open_and_bind)
            dap.listeners.before.event_initialized["dapui_config"] = open_and_bind
        end
    },
    {
        "theHamsta/nvim-dap-virtual-text",
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        opts = {
            enabled = true,
            enabled_commands = true,
            highlight_changed_variables = true,
            highlight_new_as_changed = false,
            show_stop_reason = true,
            commented = false,
            only_first_definition = true,
            all_references = false,
            clear_on_continue = false,
            virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',
            -- experimental features:
            all_frames = false,
            virt_lines = false,
            virt_text_win_col = nil,
            display_callback = function(variable, buf, stackframe, node, options)
                -- strip out newline characters
                local value = variable.value
                if options.virt_text_pos == "inline" then
                    value = " = " .. value:gsub("%s+", " ")
                else
                    value = variable.name .. " = " .. value:gsub("%s+", " ")
                end
                if value:len() > 80 then
                    value = value:sub(1, 80) .. " ..."
                end
                return value
            end,
        },
    },
    {
        "jay-babu/mason-nvim-dap.nvim",
        event = "VeryLazy",
        dependencies = {
            "williamboman/mason.nvim",
            "mfussenegger/nvim-dap",
        },
        opts = { handlers = {} },
        ensure_installed = { "codelldb" },
    },
    {
        "ldelossa/nvim-dap-projects",
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        config = function()
            local projects = require('nvim-dap-projects')
            projects.search_project_config()

            vim.api.nvim_create_autocmd(
                "BufWritePost",
                {
                    pattern = "*nvim-dap.lua",
                    callback = projects.search_project_config
                }
            )
        end
    },
    {
        "jedrzejboczar/nvim-dap-cortex-debug",
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        opts = {
            -- log debug messages
            debug = false,
            extension_path = "~/.local/share/nvim/mason/share/cortex-debug/dist/",
            lib_extension = nil,
            node_path = "node",
            dapui_rtt = true,
            -- make :DapLoadLaunchJSON register cortex-debug for C/C++,
            -- set false to disable
            dap_vscode_filetypes = false,
            rtt = {
                -- 'Terminal' or 'BufTerminal' for terminal buffer vs normal buffer
                buftype = "Terminal",
            },
        },
        config = function(_, opts)
            require("dap-cortex-debug").setup(opts)
        end
    }
}
