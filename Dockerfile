FROM docker.elastic.co/logstash/logstash-oss:7.16.3-amd64

MAINTAINER Justin Henderson justin@hasecuritysolutions.com

COPY logstash_plugins /logstash_plugins
USER root
RUN bash -c cat /logstash_plugins | while read line; do /usr/share/logstash/bin/logstash-plugin install $line; done
USER logstash

STOPSIGNAL SIGTERM
