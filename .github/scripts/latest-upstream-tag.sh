#!/usr/bin/env bash
# Print the newest released Logstash version within a major line (default 8)
# whose docker.elastic.co/logstash/logstash-oss image tag actually exists.
#
# Release versions come from Elastic's artifacts API (fast, authoritative for
# what has shipped). Each candidate is then checked against the container
# registry, newest first, because a release can be listed there shortly before
# its image is published. SNAPSHOT and pre-release versions are ignored.
#
# Usage: latest-upstream-tag.sh [MAJOR]
set -euo pipefail

MAJOR="${1:-8}"
REGISTRY="https://docker.elastic.co"
REPO="logstash/logstash-oss"
ACCEPT="application/vnd.docker.distribution.manifest.list.v2+json, application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.v2+json"

candidates="$(curl -fsSL --retry 3 --max-time 60 "https://artifacts-api.elastic.co/v1/versions" \
  | python3 -c 'import sys,json; print("\n".join(json.load(sys.stdin)["versions"]))' \
  | grep -E "^${MAJOR}\.[0-9]+\.[0-9]+$" \
  | sort -t. -k1,1nr -k2,2nr -k3,3nr)"

if [ -z "$candidates" ]; then
  echo "No stable ${MAJOR}.x releases listed by artifacts-api.elastic.co" >&2
  exit 1
fi

token="$(curl -fsSL --retry 3 --max-time 60 \
  "https://docker-auth.elastic.co/auth?service=token-service&scope=repository:${REPO}:pull" \
  | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d.get("token") or d["access_token"])')"

for version in $candidates; do
  status="$(curl -sS --retry 3 --max-time 60 -o /dev/null -w '%{http_code}' -I \
    -H "Authorization: Bearer ${token}" -H "Accept: ${ACCEPT}" \
    "${REGISTRY}/v2/${REPO}/manifests/${version}")"
  case "$status" in
    200) echo "$version"; exit 0 ;;
    404) echo "${version} is released but has no image tag yet; trying older" >&2 ;;
    *)   echo "Unexpected HTTP ${status} checking ${REPO}:${version}" >&2; exit 1 ;;
  esac
done

echo "No ${MAJOR}.x release has a published image tag" >&2
exit 1
