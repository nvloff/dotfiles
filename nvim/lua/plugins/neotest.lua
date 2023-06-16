return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-neotest/neotest-go',
    },
    keys = {
      {
        '<leader>rtn',
        function()
          require('neotest').run.run({extra_args={"-race"}})
        end,
        desc = 'Run the nearest test',
      },
      {
        '<leader>rtf',
        function()
          require('neotest').run.run({vim.fn.expand('%'), extra_args = {"-race"}})
        end,
        desc = 'Run the test file',
      },
      {
        '<leader>rto',
        function()
          require('neotest').output_panel.toggle()
        end,
        desc = 'Toggle test output',
      },
      {
        '<leader>rts',
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
