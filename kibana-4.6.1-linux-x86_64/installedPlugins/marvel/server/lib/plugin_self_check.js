const ensureVersions = require('./ensure_versions');

module.exports = function pluginSelfCheck(plugin, server) {
  plugin.status.yellow('Waiting for Elasticsearch');
  var client = server.plugins.elasticsearch.client;

  server.plugins.elasticsearch.status.on('green', () => {
    // check if kibana is minimum supported version
    const {
      isKibanaSupported,
      kibanaVersion,
      marvelVersion,
      kbnVersionDisplay
    } = ensureVersions(plugin);

    if (isKibanaSupported) {
      plugin.status.green('Marvel ready');
    } else if (!isKibanaSupported) {
      plugin.status.red(
          `Marvel version ${marvelVersion} is not supported with Kibana ${kibanaVersion}.
          Kibana version ${kbnVersionDisplay} is expected.`
      );
    }
  });

};
