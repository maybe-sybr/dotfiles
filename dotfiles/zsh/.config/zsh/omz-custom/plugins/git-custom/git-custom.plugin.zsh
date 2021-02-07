# Custom git bits and bobs
#
# Branch pruning helper - this could be a piped alias but it wouldn't deal with
# extra args so we define it as a function. We define a custom format and then
# a pattern to match against that format.
__GBP_FORMAT='%(if)%(HEAD)%(then)NOMATCH%(end)'
__GBP_FORMAT+='%(refname) %(upstream) %(upstream:track)'
#               v skip NOMATCH
#               |             v branch name
#               |             |        v upstream is some remote
#               |             |        |                  v same branch name
#               |             |        |                  |     v and gone
__GBP_PATT='(?<=^refs/heads/)(\S+)(?=\srefs/remotes/[^/]+/\1\s\[gone\]$)'
function __git_branch_prune () {
    if ! git rev-parse --show-toplevel &>/dev/null; then
        echo "[!] Not in a git repository"
        false ; return
    fi
    COUNT=0
    while read -r prunable_branch; do
        COUNT=$((${COUNT} + 1))
        git branch -d "${prunable_branch}"
    done < <(git branch --format="${__GBP_FORMAT}" | grep -Po "${__GBP_PATT}")
    if [ ${COUNT} -eq 0 ]; then
        echo "[I] No branches to prune"
    fi
}
alias gbp='__git_branch_prune'

# whatchanged patch reader
alias gwc='git whatchanged --stat --patch'
# more verbose branch listing
alias gbv='git branch -vv'
