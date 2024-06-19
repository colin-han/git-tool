############################################
# 定义常量
############################################

_REPO_DIR="$(dirname $(dirname $(realpath $0)))"
_COLOR_NORMAL="\033[0m"
_COLOR_TIP="\033[0;37m"
_COLOR_INFO="\033[32m"
_COLOR_WARN="\033[33m"
_COLOR_ERR="\033[31m"
_COLOR_HIGH="\033[37m"
_COLOR_VERBOSE="\033[1;34m"

_COLOR_REV="\033[7m"
_COLOR_REV_END="\033[27m"

_c_tip() {
    echo -e "$_COLOR_TIP$@$_COLOR_NORMAL"
}

_c_info() {
    echo -e "$_COLOR_INFO$@$_COLOR_NORMAL"
}

_c_warn() {
    echo -e "$_COLOR_WARN$@$_COLOR_NORMAL"
}

_c_err() {
    echo -e "$_COLOR_ERR$@$_COLOR_NORMAL"
}

_c_rev() {
    echo -e "$_COLOR_REV$@$_COLOR_REV_END"
}

############################################
# 工具函数
############################################

trim_begin() {
    local var="$1"
    # 使用正则表达式去除字符串开头的 # 和空格
    var="${var#"${var%%[!#[:space:]]*}"}"
    echo -n "$var"
}

############################################
# 日志函数
############################################

log_msg() {
    local color=$1
    shift

    if (( $# == 2 )); then
        echo -e "$(_c_tip "$1:") $color$2$_COLOR_NORMAL"
        return
    fi
    echo -e "$color$@$_COLOR_NORMAL"
}

log_info() {
    log_msg $_COLOR_INFO "$@"
}

log_warn() {
    log_msg $_COLOR_WARN "$@"
}

log_err() {
    log_msg $_COLOR_ERR "$@"
}

log_command() {
    log_msg $_COLOR_HIGH "$@"
}

log_verbose() {
    if [[ "$_arg_verbose" != "" ]]; then
        log_msg $_COLOR_VERBOSE "$@"
    fi
}

############################################
# Report函数
############################################

_REPORT=""

report_warn() {
    _REPORT+="$(_c_tip "[WARN]  - ") $(_c_warn $@)\n"
}

report_err() {
    _REPORT+="$(_c_tip "[ERROR] - ") $(_c_err $@)\n"
}

print_reports() {
    if [[ "$_REPORT" = "" ]]; then
        return
    fi
    log_info "Execution done with errors:"
    echo -e "$_REPORT"
}

############################################
# Git函数
############################################

get_branch() {
    git rev-parse --abbrev-ref HEAD
}

display_branch_and_pull() {
    log_info "Pulling on $(_c_rev $_dir) (branch: $(get_branch))..."
    git pull
    if [[ "$?" != "0" ]]; then
        report_err "Pull on $(_c_rev $_dir) (branch: $(get_branch)) failed"
    fi
}

checkout_branches() {
    local branches=$@
    local len=$#
    local successBranch=0
    log_info "Checkout branches ($branches) on $(_c_rev $_dir)..."
    for ((i=1; i<=len; i++)); do
        local branch=${!i}
        log_verbose command "git checkout $branch"
        git checkout $branch >/dev/null
        if [[ "$?" = "0" ]]; then
            successBranch=$i
            log_info "Checkout branch $branch on $(_c_rev $_dir)"
            break
        fi
        if [ $i -eq $((len)) ]; then
            break
        fi
    done

    if [[ "$successBranch" = "0" ]]; then
        report_err "No branch available on $(_c_rev $_dir) (curren branch $(_c_rev $(get_branch)))"
    elif [[ "$successBranch" != "1" ]]; then
        report_warn "Some branches not available on $(_c_rev $_dir) (finally branch $(_c_rev ${!successBranch}))"
    fi
}
