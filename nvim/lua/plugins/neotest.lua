return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvloff/neotest-go',
    },
    keys = {
      {
        '<leader>tt',
        function()
          require('neotest').run.run({extra_args={"-race"}})
        end,
        desc = 'Run the nearest test',
      },
      {
        '<leader>tf',
        function()
          require('neotest').run.run({vim.fn.expand('%'), extra_args = {"-race"}})
        end,
        desc = 'Run the test file',
      },
      {
        '<leader>to',
        function()
          require('neotest').output_panel.toggle()
        end,
        desc = 'Toggle test output',
      },
      {
        '<leader>ts',
        function()
          require('neotest').summary.toggle()
        end,
        desc = 'Toggle test summary',
      },
    },
    config = function()
      require('neotest').setup({
        adapters = {
          require('neotest-go'),
        },
      })
    end,
  },
}
