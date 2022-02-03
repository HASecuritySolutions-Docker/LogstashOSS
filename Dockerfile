FROM docker.elastic.co/logstash/logstash-oss:7.16.3-amd64

MAINTAINER Justin Henderson justin@hasecuritysolutions.com

COPY logstash_plugins /logstash_plugins
USER root
RUN /usr/share/logstash/bin/logstash-plugin install logstash-filter-elasticsearch
RUN /usr/share/logstash/bin/logstash-plugin install logstash-filter-tld
USER logstash

STOPSIGNAL SIGTERM
