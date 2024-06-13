#!/bin/bash
. ./utils.sh
. ./base.sh

eval $(parse_args "$@")
eval set -- $(filter_args "$@")

validate_repo_dir

if [[ $# = 0 ]]; then
    echo "Usage: $0 <branch>"
    exit 1
fi

run_command_in_dirs checkout_branches "$@"

print_reports
