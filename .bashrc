
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias l='ls -CF'
alias la='ls -A'
alias lh='ll -lh'
alias ll='ls -alF'
alias ls='ls --color=auto'

alias acs='apt-cache search'
alias agd='sudo apt-get dist-upgrade'
alias agg='sudo apt-get upgrade'
alias agi='sudo apt-get install'
alias agr='sudo apt-get remove'
alias agu='sudo apt-get update'

alias lockscreen='gnome-screensaver-command  -l'

alias findgrep="find . -type f -not -path '*/.git/*' -a -not -path '*/.svn/*' -print0 | xargs -0 grep --color=auto"
alias findpm="find . -type f -not -path '*/.git/*' -a -not -path '*/.svn/*' -name '*.pm' -print0 | xargs -0 grep --color=auto"
alias findpl="find . -type f -not -path '*/.git/*' -a -not -path '*/.svn/*' -a \( -name '*.pl' -or -name '*.pm' -or -name '*.cgi' \) -print0 | xargs -0 grep --color=auto"
alias findpy="find . -type f -not -path '*/.git/*' -a -not -path '*/.svn/*' -a \( -name '*.py' \) -print0 | xargs -0 grep --color=auto"

