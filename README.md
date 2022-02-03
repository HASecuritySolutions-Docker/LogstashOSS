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
