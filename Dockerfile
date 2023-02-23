FROM docker.elastic.co/logstash/logstash-oss:8.6.2

MAINTAINER Justin Henderson justin@hasecuritysolutions.com

COPY logstash_plugins /logstash_plugins
COPY docker-entrypoint /usr/local/bin/docker-entrypoint
USER root
RUN apt update \
    && apt install wget -y \
    #&& wget https://download.java.net/java/GA/jdk18/43f95e8614114aeaa8e8a5fcf20a682d/36/GPL/openjdk-18_linux-x64_bin.tar.gz \
    #&& tar xvf openjdk-18_linux-x64_bin.tar.gz \
    #&& mv jdk-18/ /opt/ \
    #&& rm openjdk-18_linux-x64_bin.tar.gz \
    #&& chown -R logstash /opt/jdk-18 \
    #&& echo 'export LS_JAVA_HOME=/opt/jdk-18' | tee -a ~/.bashrc \
    #&& echo 'export PATH=$PATH:$LS_JAVA_HOME/bin '|tee -a ~/.bashrc \
    && chmod +x /usr/local/bin/docker-entrypoint \
    && chmod +r /usr/local/bin/docker-entrypoint
USER logstash
RUN /usr/share/logstash/bin/logstash-plugin install --preserve logstash-output-opensearch \
    && /usr/share/logstash/bin/logstash-plugin install --preserve logstash-input-opensearch \
    && /usr/share/logstash/bin/logstash-plugin install --preserve logstash-filter-opensearch

STOPSIGNAL SIGTERM
