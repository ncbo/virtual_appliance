#!/bin/bash
# /opt/ontoportal/virtual_appliance/utils/lib/git_helpers.sh
# Common Git-related functions for use across setup and deployment scripts
#
[[ -n "${_GIT_HELPERS_LOADED:-}" ]] && return
_GIT_HELPERS_LOADED=1

checkout_release() {
    local component="$1"
    local release="$2"
    local repo_url="${GH}/${component}"

    # ANSI color codes
    RED="\e[31m"
    RESET="\e[0m"

    if [[ -z "$component" || -z "$release" ]]; then
        echo -e "${RED}Usage: checkout_release <component> <release>${RESET}"
        return 1
    fi

    if [[ ! -d "$component/.git" ]]; then
        echo "Repository '$component' not found locally. Cloning from $repo_url..."
        if ! git clone "$repo_url" "$component"; then
            echo -e "${RED}Error: Failed to clone repository $repo_url${RESET}"
            return 1
        fi
    fi

    pushd "$component" > /dev/null || return 1
    echo "Checking out '$release' in $(pwd)..."

    if [[ "$release" =~ ^v[0-9]+ ]]; then
        echo "'$release' looks like a tag, fetching tags..."
        git fetch --tags
        release="tags/$release"
    fi

    if ! git checkout "$release"; then
        echo -e "${RED}Error: Failed to check out $release. It may not exist.${RESET}"
        popd > /dev/null
        return 1
    fi

    popd > /dev/null
}

