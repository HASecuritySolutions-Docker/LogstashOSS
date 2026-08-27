FROM docker.elastic.co/logstash/logstash-oss:8.19.20

LABEL maintainer="Justin Henderson justin@hasecuritysolutions.com"
LABEL version="8.19.20"

COPY logstash_plugins /logstash_plugins
COPY docker-entrypoint /usr/local/bin/docker-entrypoint

USER root
# netbase is required for the Azure Sentinel output plugin:
# https://learn.microsoft.com/en-us/azure/sentinel/connect-logstash-data-connection-rules#known-issues
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends netbase \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && chmod +x /usr/local/bin/docker-entrypoint \
    && chmod +r /usr/local/bin/docker-entrypoint
# JRuby bundles a stale net-imap 0.2.5 (CVE-2026-42246 et al.); Logstash loads
# the patched net-imap from vendor/bundle via Bundler, so the bundled copy is
# unused. Delete it so it stops appearing in image scans.
RUN rm -rf /usr/share/logstash/vendor/jruby/lib/ruby/stdlib/net/imap.rb \
    /usr/share/logstash/vendor/jruby/lib/ruby/stdlib/net/imap \
    /usr/share/logstash/vendor/jruby/lib/ruby/stdlib/net/net-imap.gemspec \
    /usr/share/logstash/vendor/jruby/lib/ruby/gems/shared/specifications/net-imap-0.2.5.gemspec \
    /usr/share/logstash/vendor/jruby/lib/ruby/gems/shared/gems/net-imap-0.2.5

USER logstash
# The bundled RabbitMQ integration ships amqp-client 5.26.0 (3 HIGH CVEs with no
# fixed plugin release available). Removed here; it can still be installed at
# runtime via /logstash_plugins if needed.
RUN /usr/share/logstash/bin/logstash-plugin remove logstash-integration-rabbitmq \
    && /usr/share/logstash/bin/logstash-plugin update logstash-filter-xml \
    && /usr/share/logstash/bin/logstash-plugin install --preserve logstash-output-opensearch \
    && /usr/share/logstash/bin/logstash-plugin install --preserve logstash-input-opensearch \
    && /usr/share/logstash/bin/logstash-plugin install --preserve logstash-filter-opensearch \
    && /usr/share/logstash/bin/logstash-plugin install --preserve logstash-output-syslog

STOPSIGNAL SIGTERM
