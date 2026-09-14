#!/usr/bin/env bash
# Sanity-check a built logstash-oss image: the plugins we install must be
# present, and a trivial pipeline must run end to end. Used by the
# update-upstream workflow and for local testing (see README).
#
# Usage: smoke-test.sh <image>
set -euo pipefail

image="${1:?usage: smoke-test.sh <image>}"
required_plugins=(
  logstash-output-opensearch
  logstash-input-opensearch
  logstash-filter-opensearch
  logstash-output-syslog
)

echo "== Plugin list for ${image}"
plugins="$(docker run --rm "$image" /usr/share/logstash/bin/logstash-plugin list --verbose)"
printf '%s\n' "$plugins"
for p in "${required_plugins[@]}"; do
  if ! printf '%s\n' "$plugins" | grep -q "^${p} "; then
    echo "::error::${p} missing from image"
    exit 1
  fi
done

echo "== Generator pipeline"
output="$(timeout 300 docker run --rm "$image" \
  logstash --log.level=error \
    -e 'input { generator { count => 1 } } output { stdout { codec => json_lines } }')"
printf '%s\n' "$output"
if ! printf '%s\n' "$output" | grep -q '"sequence":0'; then
  echo "::error::generator pipeline produced no event"
  exit 1
fi

echo "== Smoke test passed"
