/**
 * Controller for Node Detail
 */
const _ = require('lodash');
const mod = require('ui/modules').get('marvel', [ 'plugins/marvel/directives' ]);

function getPageData(timefilter, globalState, $route, $http, Private) {
  const timeBounds = timefilter.getBounds();
  const url = `../api/marvel/v1/clusters/${globalState.cluster}/nodes/${$route.current.params.node}`;
  return $http.post(url, {
    timeRange: {
      min: timeBounds.min.toISOString(),
      max: timeBounds.max.toISOString()
    },
    metrics: [
      'node_query_latency',
      'node_index_latency',
      'node_jvm_mem_percent',
      'node_cpu_utilization',
      'node_load_average',
      'node_segment_count'
    ]
  })
  .then(response => response.data)
  .catch((err) => {
    const ajaxErrorHandlers = Private(require('plugins/marvel/lib/ajax_error_handlers'));
    return ajaxErrorHandlers.fatalError(err);
  });
}

require('ui/routes')
.when('/nodes/:node', {
  template: require('plugins/marvel/views/node/node_template.html'),
  resolve: {
    marvel: function (Private) {
      var routeInit = Private(require('plugins/marvel/lib/route_init'));
      return routeInit();
    },
    pageData: getPageData
  }
});

mod.controller('nodeView', (timefilter, $route, globalState, Private, $executor, $http, marvelClusters, $scope) => {

  timefilter.enabled = true;

  function setClusters(clusters) {
    $scope.clusters = clusters;
    $scope.cluster = _.find($scope.clusters, { cluster_uuid: globalState.cluster });
  }
  setClusters($route.current.locals.marvel.clusters);

  $scope.pageData = $route.current.locals.pageData;

  const docTitle = Private(require('ui/doc_title'));
  docTitle.change(`Marvel - ${$scope.pageData.nodeSummary.name}`, true);

  $executor.register({
    execute: () => getPageData(timefilter, globalState, $route, $http, Private),
    handleResponse: (response) => $scope.pageData = response
  });

  $executor.register({
    execute: () => marvelClusters(),
    handleResponse: setClusters
  });

  // Start the executor
  $executor.start();

  // Destory the executor
  $scope.$on('$destroy', $executor.destroy);
});
