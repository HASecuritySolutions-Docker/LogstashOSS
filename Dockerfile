FROM docker.elastic.co/logstash/logstash-oss:8.1.2

MAINTAINER Justin Henderson justin@hasecuritysolutions.com

COPY logstash_plugins /logstash_plugins
COPY docker-entrypoint /usr/local/bin/docker-entrypoint
USER root
RUN chmod +x /usr/local/bin/docker-entrypoint \
    && chmod +r /usr/local/bin/docker-entrypoint
USER logstash
RUN /usr/share/logstash/bin/logstash-plugin install --preserve logstash-output-opensearch

STOPSIGNAL SIGTERM
