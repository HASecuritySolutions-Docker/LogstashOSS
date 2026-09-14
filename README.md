# LogstashOSS

Supports dynamically installing plugins by installing plugins referenced in /logstash_plugins at start up.

You can then volume map /opt/elastic_stack/logstash/logstash_plugins to /logstash_plugins. /logstash_plugins needs to contain the logstash plugin you want installed such as:logstash-output-opensearchlogstash-filter-tld

Logstash will need internet access to pull down the additional plugin. These are the FQDNs Logstash needs access to:

artifacts.elastic.co
index.rubygems.org

It will also work with offline plugins if you want. The /logstash_plugins format would change to something like below.

file:///opt/elastic_stack/logstash/logstash-offline-output-opensearch.zip
file:///opt/elastic_stack/logstash/logstash-offline-filter-tld.zip

Above assumes you've volume mapped the offline files into the logstash image

## Automatic upstream updates

The `Update upstream Logstash` workflow (`.github/workflows/update-upstream.yml`) runs daily and can also be started by hand from the Actions tab. It looks up the newest stable 8.x release of `docker.elastic.co/logstash/logstash-oss`, and if the Dockerfile is behind it builds the image with the new base, runs a plugin and pipeline smoke test, and opens a pull request titled `Bump Logstash to <version>`. Merging that PR triggers the normal build and push to Docker Hub.

Only stable releases in the 8.x line are considered; SNAPSHOT and 9.x tags are ignored. To track a different line, change the `major` input when running the workflow manually, or edit the default in the workflow file.

Setup notes:

- In **Settings > Actions > General**, enable *Allow GitHub Actions to create and approve pull requests*. Despite the name, this only lets the bot open the PR; the workflow never approves or merges anything. A person reviews and merges each bump.
- Pull requests opened with the built-in `GITHUB_TOKEN` do not trigger other workflows, so the `Build` workflow will not run on the bot's PR. The update workflow performs its own test build to compensate. If you want the regular `Build` checks on the PR as well, add a repository secret named `UPSTREAM_BUMP_TOKEN` containing a personal access token with `contents` and `pull-requests` write access; the workflow uses it automatically when present.

### Testing locally

The workflow can be run end to end on a workstation with [nektos/act](https://github.com/nektos/act), so changes to it do not need to be pushed to find out whether they work. The pull request step is skipped automatically under act.

1. Docker must be reachable from the shell (on Windows: Docker Desktop running, with WSL integration enabled for your distro under Settings > Resources > WSL integration).
2. Install act once: `gh extension install nektos/gh-act`. The `.actrc` in the repo selects a runner image that matches `ubuntu-latest` closely enough.
3. Dry run: `gh act workflow_dispatch -W .github/workflows/update-upstream.yml`. Add `--input version=8.19.21` (any real version) to force a bump when the Dockerfile is already current.

Without act, the same pieces can be run by hand:

```
bash .github/scripts/latest-upstream-tag.sh 8        # newest 8.x with a published image
bash .github/scripts/bump-upstream.sh <version>      # rewrites FROM and LABEL version
docker build -t logstash-oss:test .
bash .github/scripts/smoke-test.sh logstash-oss:test
git checkout Dockerfile                              # undo the bump when done
```
