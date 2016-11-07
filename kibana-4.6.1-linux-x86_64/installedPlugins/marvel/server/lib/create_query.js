var _ = require('lodash');
const moment = require('moment');
module.exports = (options) => {
  options = _.defaults(options, { filters: [] });
  var clusterFilter;
  if (options.clusterUuid) {
    clusterFilter = { term: { cluster_uuid: options.clusterUuid } };
  }
  var timeRangeFilter = {
    range: {
      timestamp: {
        format: 'epoch_millis'
      }
    }
  };
  if (options.start) {
    timeRangeFilter.range.timestamp.gte = moment.utc(options.start).valueOf();
  }
  if (options.end) {
    timeRangeFilter.range.timestamp.lte = moment.utc(options.end).valueOf();
  }
  const filters = [clusterFilter].concat(options.filters);
  if (options.end || options.start) {
    filters.push(timeRangeFilter);
  }
  return {
    filtered: {
      filter: {
        bool: {
          must: filters
        }
      }
    }
  };
};
