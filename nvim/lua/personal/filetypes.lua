vim.api.nvim_create_autocmd("BufRead", {
  pattern = "Tiltfile",
  callback = function ()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_option(buf, "filetype", "tiltfile")
  end
})

vim.filetype.add({
  pattern = {
    ['*.[T|t]iltfile.*'] = 'starlark',
  },
})
