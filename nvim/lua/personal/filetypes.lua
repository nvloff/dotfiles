vim.filetype.add({
  pattern = {
    ['.*/.*[T|t]iltfile.*'] = 'starlark',
  },
})
