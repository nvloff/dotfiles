__ruby_ps1() {
  command -v rbenv >/dev/null 2>&1 && echo "$(rbenv version-name)"
}
