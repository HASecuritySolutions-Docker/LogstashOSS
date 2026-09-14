#!/usr/bin/env bash
# Rewrite the Dockerfile's FROM tag and version LABEL to the given Logstash
# version. Prints "current=<old> target=<new> changed=<true|false>" so the
# workflow can decide whether there is anything to build and open a PR for.
#
# Usage: bump-upstream.sh <version> [Dockerfile]
set -euo pipefail

target="${1:?usage: bump-upstream.sh <version> [Dockerfile]}"
dockerfile="${2:-Dockerfile}"
image="docker.elastic.co/logstash/logstash-oss"

current="$(sed -nE "s#^FROM ${image}:([^[:space:]]+).*#\1#p" "$dockerfile" | head -n 1)"
if [ -z "$current" ]; then
  echo "Could not find 'FROM ${image}:<tag>' in ${dockerfile}" >&2
  exit 1
fi

if [ "$current" = "$target" ]; then
  echo "current=${current} target=${target} changed=false"
  exit 0
fi

sed -i -E \
  -e "s#^(FROM ${image}:)[^[:space:]]+#\1${target}#" \
  -e "s#^(LABEL +version *= *\")[^\"]+(\")#\1${target}\2#" \
  "$dockerfile"

echo "current=${current} target=${target} changed=true"
