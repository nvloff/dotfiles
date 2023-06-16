vim.api.nvim_set_keymap(
    'n',
    '<leader>pp',
    ":lua require'telescope'.extensions.project.project{}<CR>",
    { noremap = true, silent = true }
)

require('telescope').setup {
    defaults = {
        vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--glob',
            '!vendor/*',
        }
    },
    extensions = {
        project = {
            base_dirs = {
                { path = '~/go/src', max_depth = 4 },
            },
            hidden_files = true, -- default: false
            theme = "dropdown",
            order_by = "asc",
            search_by = "title",
            sync_with_nvim_tree = true, -- default false
            -- default for on_project_selected = find project files
            on_project_selected = function(prompt_bufnr)
                -- Do anything you want in here. For example:
            end
        },
        repo = {
            list = {
                fd_opts = {
                    "--no-ignore-vcs",
                    "--exlcude",
                    "vendor"
                },
                search_dirs = {
                    "~/go/src",
                },
            },

        }
    }
}

require('telescope').load_extension('repo')

require('nvim-rooter').setup {
    rooter_patterns = { '.git' },
    trigger_patterns = { '*' },
    manual = false,
}
