const formatLargeFloat = '0,0.[00]';
const formatSmallFloat = '0.[00]';
const formatLargeBytes = '0,0.0b';
const formatSmallBytes = '0.0b';
const formatLargeAbbreviated = '0,0.[0]a';

function calculateQueryLatency(last) {
  var required = last &&
      last.query_time_in_millis_deriv &&
      last.query_total_deriv &&
      last.query_total_deriv.value &&
      last.query_time_in_millis_deriv.value;

  if (required) {
    if (last.query_time_in_millis_deriv.value < 0 || last.query_total_deriv.value < 0) {
      return null;
    }
    return last.query_time_in_millis_deriv.value / last.query_total_deriv.value;
  }

  return 0;
}

function calculateIndexLatency(last) {
  var required = last &&
      last.index_time_in_millis_deriv &&
      last.index_total_deriv &&
      last.index_total_deriv.value &&
      last.index_time_in_millis_deriv.value;

  if (required) {
    if (last.index_time_in_millis_deriv.value < 0 || last.index_total_deriv.value < 0) {
      return null;
    }
    return last.index_time_in_millis_deriv.value / last.index_total_deriv.value;
  }

  return 0;
}

module.exports = {
  'cluster_index_request_rate': {
    active: true,
    field: 'indices_stats._all.primaries.indexing.index_total',
    label: 'Indexing Rate',
    description: 'The per index rate at which documents are being indexed.',
    format: formatLargeFloat,
    metricAgg: 'max',
    units: '/s',
    defaults: { warning: '>1000', critical: '>5000', interval: '1m', periods: 1 },
    type: 'index',
    derivative: true
  },
  'cluster_search_request_rate': {
    active: true,
    field: 'indices_stats._all.total.search.query_total',
    label: 'Search Rate',
    description: 'The cluster wide rate at which search reqeusts are being executed.',
    format: formatLargeFloat,
    metricAgg: 'max',
    units: '/s',
    defaults: { warning: '>100', critical: '>5000', interval: '1m', periods: 1 },
    type: 'cluster',
    derivative: true
  },
  'cluster_index_latency': {
    active: true,
    field: 'indices_stats._all.primaries.indexing.index_total',
    label: 'Indexing Latency',
    description: 'The average indexing latency across the entire cluster.',
    format: formatLargeFloat,
    metricAgg: 'sum',
    aggs: {
      index_time_in_millis: {
        max: { field: 'indices_stats._all.primaries.indexing.index_time_in_millis' }
      },
      index_total: {
        max: { field: 'indices_stats._all.primaries.indexing.index_total' }
      },
      index_time_in_millis_deriv: {
        derivative: { buckets_path: 'index_time_in_millis', gap_policy: 'skip' }
      },
      index_total_deriv: {
        derivative: { buckets_path: 'index_total', gap_policy: 'skip' }
      }
    },
    units: 'ms',
    defaults: { warning: '>100', critical: '>200', interval: '1m', periods: 1 },
    type: 'cluster',
    derivitave: false,
    calculation: calculateIndexLatency
  },
  'cluster_query_latency': {
    active: true,
    field: 'indices_stats._all.total.search.query_total',
    label: 'Search Latency',
    description: 'The average search latency across the entire cluster.',
    format: formatLargeFloat,
    metricAgg: 'sum',
    aggs: {
      query_time_in_millis: {
        max: { field: 'indices_stats._all.total.search.query_time_in_millis' }
      },
      query_total: {
        max: { field: 'indices_stats._all.total.search.query_total' }
      },
      query_time_in_millis_deriv: {
        derivative: { buckets_path: 'query_time_in_millis', gap_policy: 'skip' }
      },
      query_total_deriv: {
        derivative: { buckets_path: 'query_total', gap_policy: 'skip' }
      }
    },
    units: 'ms',
    defaults: { warning: '>100', critical: '>200', interval: '1m', periods: 1 },
    type: 'cluster',
    derivitave: false,
    calculation: calculateQueryLatency
  },
  'node_index_latency': {
    active: true,
    field: 'node_stats.indices.indexing.index_total',
    label: 'Indexing Latency',
    description: 'The average indexing latency',
    format: formatLargeFloat,
    metricAgg: 'sum',
    aggs: {
      index_time_in_millis: {
        max: { field: 'node_stats.indices.indexing.index_time_in_millis' }
      },
      index_total: {
        max: { field: 'node_stats.indices.indexing.index_total' }
      },
      index_time_in_millis_deriv: {
        derivative: { buckets_path: 'index_time_in_millis', gap_policy: 'skip' }
      },
      index_total_deriv: {
        derivative: { buckets_path: 'index_total', gap_policy: 'skip' }
      }
    },
    units: 'ms',
    defaults: { warning: '>100', critical: '>200', interval: '1m', periods: 1 },
    type: 'node',
    derivitave: false,
    calculation: calculateIndexLatency
  },
  'node_query_latency': {
    active: true,
    field: 'node_stats.indices.search.query_total',
    label: 'Search Latency',
    description: 'The average search latency',
    format: formatLargeFloat,
    metricAgg: 'sum',
    aggs: {
      query_time_in_millis: {
        max: { field: 'node_stats.indices.search.query_time_in_millis' }
      },
      query_total: {
        max: { field: 'node_stats.indices.search.query_total' }
      },
      query_time_in_millis_deriv: {
        derivative: { buckets_path: 'query_time_in_millis', gap_policy: 'skip' }
      },
      query_total_deriv: {
        derivative: { buckets_path: 'query_total', gap_policy: 'skip' }
      }
    },
    units: 'ms',
    defaults: { warning: '>100', critical: '>200', interval: '1m', periods: 1 },
    type: 'node',
    derivitave: false,
    calculation: calculateQueryLatency
  },
  'index_request_rate': {
    active: true,
    field: 'index_stats.primaries.indexing.index_total',
    label: 'Indexing Rate',
    description: 'The per index rate at which documents are being indexed.',
    format: formatLargeFloat,
    metricAgg: 'max',
    units: '/s',
    defaults: { warning: '>1000', critical: '>5000', interval: '1m', periods: 1 },
    type: 'index',
    derivative: true
  },
  'search_request_rate': {
    active: true,
    field: 'index_stats.total.search.query_total',
    label: 'Search Rate',
    description: 'The cluster wide rate at which search reqeusts are being executed.',
    format: formatLargeFloat,
    metricAgg: 'max',
    units: '/s',
    defaults: { warning: '>100', critical: '>5000', interval: '1m', periods: 1 },
    type: 'cluster',
    derivative: true
  },
  'index_latency': {
    active: true,
    field: 'index_stats.primaries.indexing.index_total',
    label: 'Indexing Latency',
    description: 'The average indexing latency across the entire cluster.',
    format: formatLargeFloat,
    metricAgg: 'sum',
    aggs: {
      index_time_in_millis: {
        max: { field: 'index_stats.primaries.indexing.index_time_in_millis' }
      },
      index_total: {
        max: { field: 'index_stats.primaries.indexing.index_total' }
      },
      index_time_in_millis_deriv: {
        derivative: { buckets_path: 'index_time_in_millis', gap_policy: 'skip' }
      },
      index_total_deriv: {
        derivative: { buckets_path: 'index_total', gap_policy: 'skip' }
      }
    },
    units: 'ms',
    defaults: { warning: '>100', critical: '>200', interval: '1m', periods: 1 },
    type: 'cluster',
    derivitave: false,
    calculation: calculateIndexLatency
  },
  'query_latency': {
    active: true,
    field: 'index_stats.total.search.query_total',
    label: 'Search Latency',
    description: 'The average search latency across the entire cluster.',
    format: formatLargeFloat,
    metricAgg: 'sum',
    aggs: {
      query_time_in_millis: {
        max: { field: 'index_stats.total.search.query_time_in_millis' }
      },
      query_total: {
        max: { field: 'index_stats.total.search.query_total' }
      },
      query_time_in_millis_deriv: {
        derivative: { buckets_path: 'query_time_in_millis', gap_policy: 'skip' }
      },
      query_total_deriv: {
        derivative: { buckets_path: 'query_total', gap_policy: 'skip' }
      }
    },
    units: 'ms',
    defaults: { warning: '>100', critical: '>200', interval: '1m', periods: 1 },
    type: 'cluster',
    derivitave: false,
    calculation: calculateQueryLatency
  },
  'node_cpu_utilization': {
    active: true,
    field: 'node_stats.process.cpu.percent',
    label: 'CPU Utilization',
    description: 'The percentage of CPU usage.',
    format: formatLargeFloat,
    metricAgg: 'avg',
    units: '%',
    defaults: { warning: '>70', critical: '>90', interval: '1m', periods: 1 },
    type: 'node',
    derivative: false
  },
  'node_segment_count': {
    active: true,
    field: 'node_stats.indices.segments.count',
    label: 'Segment Count',
    description: 'The average segment count.',
    format: formatLargeFloat,
    metricAgg: 'avg',
    units: '',
    defaults: { warning: '>70', critical: '>90', interval: '1m', periods: 1 },
    type: 'node',
    derivative: false
  },
  'node_jvm_mem_percent': {
    active: true,
    field: 'node_stats.jvm.mem.heap_used_percent',
    label: 'JVM Heap Usage',
    description: 'The amound of heap used by the JVM',
    format: formatLargeFloat,
    metricAgg: 'avg',
    units: '%',
    defaults: { warning: '>7', critical: '>9', interval: '1m', periods: 1  },
    type: 'node',
    derivative: false
  },
  'node_load_average': {
    active: true,
    field: 'node_stats.os.load_average',
    label: 'System Load Average',
    description: 'The amount of load used for the last 1 minute.',
    format: formatLargeFloat,
    metricAgg: 'avg',
    units: '',
    defaults: { warning: '>2', critical: '>4', interval: '1m', periods: 1 },
    type: 'node',
    derivative: false
  },
  'node_free_space': {
    active: true,
    field: 'node_stats.fs.total.available_in_bytes',
    label: 'Disk Free Space',
    description: 'The free disk space available on the node',
    format: formatSmallBytes,
    metricAgg: 'max',
    units: '',
    defaults: { warning: '>2', critical: '>4', interval: '1m', periods: 1 },
    type: 'node',
    derivative: false
  },
  'index_throttle_time': {
    active: true,
    field: 'index_stats.primaries.indexing.throttle_time_in_millis',
    label: 'Indexing Throttle Time',
    description: 'The amount of load used for the last 1 minute.',
    format: formatLargeFloat,
    metricAgg: 'max',
    units: 'ms',
    defaults: { warning: '>0', critical: '>0', interval: '1m', periods: 1 },
    type: 'index',
    derivative: true
  },
  'index_shard_query_rate': {
    active: false,
    field: 'index_stats.total.search.query_total',
    label: 'Index Shard Search Rate',
    description: 'Total number of requests (GET /_search)across an index (and across all relevant shards for that index) / <time range>',
    format: formatSmallFloat,
    metricAgg: 'max',
    units: '',
    defaults: { warning: '>0', critical: '>0', interval: '1m', periods: 1 },
    type: 'index',
    derivative: true
  },
  'index_document_count': {
    active: false,
    field: 'index_stats.primaries.docs.count',
    label: 'Document Count',
    description: 'Total number of documents (in primary shards) for an index',
    format: formatLargeAbbreviated,
    metricAgg: 'max',
    units: '',
    defaults: { warning: '>0', critical: '>0', interval: '1m', periods: 1 },
    type: 'index',
    derivative: false
  },
  'index_search_request_rate': {
    active: true,
    field: 'index_stats.total.search.query_total',
    label: 'Search Rate',
    description: 'The per index rate at which search reqeusts are being executed.',
    format: formatLargeFloat,
    metricAgg: 'max',
    units: '/s',
    defaults: { warning: '>100', critical: '>5000', interval: '1m', periods: 1 },
    type: 'index',
    derivative: true
  },
  'index_merge_rate': {
    active: true,
    field: 'index_stats.total.merges.total_size_in_bytes',
    label: 'Indexing Rate',
    description: 'The per index rate at which segements are being merged.',
    format: formatLargeFloat,
    metricAgg: 'max',
    units: '/s',
    defaults: { warning: '>1000', critical: '>5000', interval: '1m', periods: 1 },
    type: 'index',
    derivative: true
  },
  'index_size': {
    active: true,
    field: 'index_stats.total.store.size_in_bytes',
    label: 'Index Size',
    description: 'The size of the index.',
    format: formatLargeBytes,
    metricAgg: 'avg',
    units: '',
    defaults: { warning: '>1000', critical: '>5000', interval: '1m', periods: 1 },
    type: 'index',
    derivative: false
  },
  'index_lucene_memory': {
    active: true,
    field: 'index_stats.total.segments.memory_in_bytes',
    label: 'Lucene Memory',
    description: 'The amount of memory used by Lucene.',
    format: formatLargeBytes,
    metricAgg: 'avg',
    units: '',
    defaults: { warning: '>1000', critical: '>5000', interval: '1m', periods: 1 },
    type: 'index',
    derivative: false
  },
  'index_fielddata': {
    active: true,
    field: 'index_stats.total.fielddata.memory_size_in_bytes',
    label: 'Field Data Size',
    description: 'The amount of memory used by field data.',
    format: formatLargeBytes,
    metricAgg: 'avg',
    units: '',
    defaults: { warning: '>1000', critical: '>5000', interval: '1m', periods: 1 },
    type: 'index',
    derivative: false
  },
  'index_refresh_time': {
    active: true,
    field: 'total.refresh.total_time_in_millis',
    label: 'Total Refresh Time',
    description: 'The the amount of time a refresh takes',
    format: formatLargeFloat,
    metricAgg: 'max',
    units: '',
    defaults: { warning: '>1000', critical: '>5000', interval: '1m', periods: 1 },
    type: 'index',
    derivative: true
  }
};
