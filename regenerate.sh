#!/usr/bin/env bash

set -euo pipefail

urlencode() {
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
        *) printf '%%%02X' "'$c" ;;
        esac
    done
}


output=
repo=paketo-buildpacks/node-engine
tmpd="$(mktemp -d -t dashboardXXXX)"

git clone --bare https://github.com/"$repo" "${tmpd}/${repo}" 2> /dev/null

while read workflow; do
    name=$(yq r <(curl -sL 'https://raw.githubusercontent.com/'"$repo"'/master/'"$workflow") name)
    [ -z "$name" ] && name=workflow
    encoded_name="$(urlencode ${name})"
    output="${output}![${name}]\(https://github.com/${repo}/workflows/${encoded_name}/badge.svg\)"
done < <(git -C "${tmpd}/${repo}" ls-tree -r HEAD | awk '{print $4}' | grep '^.github/workflows/')

echo "$output" > README.md
echo Wrote to README.md
rm -rf "$tmpd"
