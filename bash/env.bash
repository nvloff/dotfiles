export PATH=$PATH:$HOME/local/bin:$HOME/bin
export PATH=$PATH:$HOME/.gems/bin
export PATH="$HOME/.rbenv/bin:$PATH"
export JRUBY_OPTS="--server -Xcompile.invokedynamic=false -J-XX:+TieredCompilation -J-XX:TieredStopAtLevel=1 -J-noverify -J-Xms512m -J-Xmx1024m"
