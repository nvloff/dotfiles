__chruby_ps1() {
  local ruby=${RUBY_ROOT##*/}

  case "$ruby" in
     *[!\ ]*) echo $ruby;;
      *) echo "system";;
  esac
}

__ruby_ps1() {
  command -v chruby >/dev/null 2>&1 && __chruby_ps1
}
