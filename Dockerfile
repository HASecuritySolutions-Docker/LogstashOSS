FROM docker.elastic.co/logstash/logstash-oss:7.16.3-amd64

MAINTAINER Justin Henderson justin@hasecuritysolutions.com

COPY logstash_plugins /logstash_plugins
COPY docker-entrypoint /usr/local/bin/docker-entrypoint
USER root
RUN chmod +x /usr/local/bin/docker-entrypoint \
    && chmod +r /usr/local/bin/docker-entrypoint
USER logstash

STOPSIGNAL SIGTERM
