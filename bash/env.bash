export PATH=$PATH:$HOME/local/bin:$HOME/bin
export PATH=$PATH:$HOME/.gems/bin
export PATH="$HOME/.rbenv/bin:$PATH"

# JRuby x86_64 JVM works only in server mode which
# has slow startup, so start the i686 java in client mode
export JAVA_OPTS="-d32 -client"
