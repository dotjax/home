# alias atest='echo Test...'
alias wmirror='wget --mirror --convert-links --adjust-extension --page-requisites --no-parent -e robots=off -U "Mozilla/5.0 (X11; Linux x86_64)" --random-wait'
alias zombie_find="ps -eo stat,ppid,pid,cmd | grep -e '^[Zz]'"
alias zombie_nuke="ps -eo stat,ppid | awk '\$1 ~ /^Z/ { print \$2 }' | sort -u | xargs -r kill -9"
alias ardownload="aria2c -x 16 -s 16 -c --file-allocation=falloc"
alias trim_full="sudo fstrim --all --verbose"
alias mv="mv -iv"
alias rm="rm -iv"