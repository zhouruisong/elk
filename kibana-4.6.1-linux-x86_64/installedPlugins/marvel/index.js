var Promise = require('bluebird');
var join = require('path').join;
var requireAllAndApply = require('./server/lib/require_all_and_apply');
var pluginSelfCheck = require('./server/lib/plugin_self_check');

module.exports = function (kibana) {
  return new kibana.Plugin({
    require: ['elasticsearch'],
    name: 'marvel',

    uiExports: {
      app: {
        title: 'Marvel',
        description: 'Monitoring for Elasticsearch',
        main: 'plugins/marvel/marvel',
        injectVars: function (server, options) {
          var config = server.config();
          return {
            maxBucketSize: config.get('marvel.max_bucket_size'),
            minIntervalSeconds: config.get('marvel.min_interval_seconds'),
            kbnIndex: config.get('kibana.index'),
            esApiVersion: config.get('elasticsearch.apiVersion'),
            esShardTimeout: config.get('elasticsearch.shardTimeout'),
            statsReportUrl: config.get('marvel.stats_report_url'),
            reportStats: config.get('marvel.report_stats'),
            marvelIndexPrefix: config.get('marvel.index_prefix')
          };
        }
      }
    },

    config: function (Joi) {
      return Joi.object({
        enabled: Joi.boolean().default(true),
        index: Joi.string().default('.marvel-es-data-1'),
        index_prefix: Joi.string().default('.marvel-es-1-'),
        missing_intervals: Joi.number().default(12),
        max_bucket_size: Joi.number().default(10000),
        min_interval_seconds: Joi.number().default(10),
        report_stats: Joi.boolean().default(true),
        node_resolver: Joi.string().regex(/^(?:transport_address|name)$/).default('transport_address'),
        stats_report_url: Joi.when('$dev', {
          is: true,
          then: Joi.string().default('../api/marvel/v1/phone-home'),
          otherwise: Joi.string().default('https://marvel-stats.elasticsearch.com/appdata/marvelOpts')
        }),
        agent: Joi.object({
          interval: Joi.string().regex(/[\d\.]+[yMwdhms]/).default('10s')
        }).default()
      }).default();
    },

    init: function (server, options) {
      // Make sure the Marvel index is created and the Kibana version is supported
      pluginSelfCheck(this, server);
      // Require all the routes
      requireAllAndApply(join(__dirname, 'server', 'routes', '**', '*.js'), server);
    }
  });
};
