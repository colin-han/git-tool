#!/bin/bash
. ./utils.sh
. ./base.sh

eval $(parse_args "$@")
eval set -- $(filter_args "$@")

validate_repo_dir

# log_info "args: $@, _arg_verbose: $_arg_verbose; _arg_vv: $_arg_vv"

if [[ $# > 0 ]]; then
    BRANCH="$1"
fi

if [[ "$BRANCH" != "" ]]; then
    log_info "Checkout branch $BRANCH"
    run_command_in_dirs git checkout $BRANCH
fi

# Pull the latest changes from the remote repository
log_info "Pull the latest changes from the remote repository"
run_command_in_dirs display_branch_and_pull

print_reports