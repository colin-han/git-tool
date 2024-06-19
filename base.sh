############################################
# 参数处理函数
############################################

parse_args() {
    local args="export "
    local found=""

    # 遍历所有参数
    for arg in "$@"; do
        # 如果参数等于 "-v"，则跳过
        if [ "$arg" = "-v" ]; then
            args+="_arg_verbose=1"
            found="1"
            continue
        fi

        # 将参数添加到新的参数数组中
        filtered_args+="\"${arg//\"/\\\"}\" "
    done

    if [[ "$found" != "" ]]; then
        echo "$args"
    else
        echo ""
    fi
}

filter_args() {
    filtered_args=""

    # 遍历所有参数
    for arg in "$@"; do
        # 如果参数等于 "-v"，则跳过
        if [ "$arg" = "-v" ]; then
            continue
        fi

        # 将参数添加到新的参数数组中
        filtered_args+="\"${arg//\"/\\\"}\" "
    done

    echo $filtered_args
}

############################################
# 功能函数
############################################

SKIP_COMMENTS=1
validate_repo_dir_one() {
    local dir=$1

    if [[ "$dir" = "" ]]; then
        export SKIP_COMMENTS=0
        continue
    fi
    if [[ "$dir" = "#"* ]]; then
        if [[ "$SKIP_COMMENTS" != "1" ]]; then
            log_warn "Skip directory" "$(trim_begin "$dir")"
        fi
        continue
    fi

    if [[ ! -d "$_REPO_DIR/$dir" ]]; then
        log_err "The directory does not exist" $(realpath "$_REPO_DIR/$dir")
        exit 1
    fi
}

validate_repo_dir() {
    log_verbose "Starting to validate the repository directory" "$_REPO_DIR"

    if [[ ! -f "$_REPO_DIR/bin/repo.txt" ]]; then
        log_err "The repository directory does not exist: $_REPO_DIR"
        exit 1
    fi

    while IFS= read -r dir; do
        validate_repo_dir_one "$dir"
    done < $_REPO_DIR/bin/repo.txt

    if [[ -d "$_REPO_DIR/bin/repo.d" ]]; then
        for file in $_REPO_DIR/bin/repo.d/*.txt; do
            while IFS= read -r dir; do
                validate_repo_dir_one "$dir"
            done < $file
        done
    fi

    log_verbose "The repository directory is valid" "$_REPO_DIR"
}

run_command_in_one_dir() {
    local current_dir=$(pwd)

    local dir=$1
    local command=$2
    shift 2
    local args="$@"

    if [[ "$dir" = "" ]]; then
        continue
    fi
    if [[ "$dir" = "#"* ]]; then
        log_verbose "Skip directory" "$(trim_begin "$dir")"
        continue
    fi

    log_verbose "Enter directory" "$dir"
    cd "$(realpath "$_REPO_DIR/$dir")"
    log_verbose "Run command" "$command $args"
    _dir="$dir" $command "$@"
    cd $current_dir
    echo ""
}

# Run command in all repos
run_command_in_dirs() {
    while IFS= read -r dir; do
        run_command_in_one_dir "$dir" "$@"
    done < $_REPO_DIR/bin/repo.txt

    if [[ -d "$_REPO_DIR/bin/repo.d" ]]; then
        for file in $_REPO_DIR/bin/repo.d/*.txt; do
            while IFS= read -r dir; do
                run_command_in_one_dir "$dir" "$@"
            done < $file
        done
    fi
}