# 2.1.3
  - Depend on logstash-core-plugin-api instead of logstash-core, removing the need to mass update plugins on major releases of logstash
# 2.1.2
  - New dependency requirements for logstash-core for the 5.0 release
## 2.1.1
 - Support Elasticsearch 2.1.0
 - Fix issue where transport client w/o port specified breaks
## 2.1.0
 - Port option no longer allowed
 - Majority of code now shared with logstash-output-elasticsearch
## 2.0.2
 - Update loading of addons to conform with new naming scheme (replaced - with _)
## 2.0.1
 - Make the default template doc_value aware
## 2.0.0
 - Plugins were updated to follow the new shutdown semantic, this mainly allows Logstash to instruct input plugins to terminate gracefully, 
   instead of using Thread.raise on the plugins' threads. Ref: https://github.com/elastic/logstash/pull/3895
 - Dependency on logstash-core update to 2.0

## 2.0.0
  - Initial Release. Only supports Node/Transport in ES2.x