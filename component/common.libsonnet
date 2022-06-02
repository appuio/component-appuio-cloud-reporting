local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.appuio_cloud_reporting;

local labels = {
  'app.kubernetes.io/name': 'appuio-cloud-reporting',
  'app.kubernetes.io/managed-by': 'commodore',
  'app.kubernetes.io/part-of': 'syn',
};

local cronJob = function(name, schedule, jobSpec) kube._Object('batch/v1', 'CronJob', name) {
  metadata+: {
    namespace: params.namespace,
    labels+: labels,
  },
  spec: {
    schedule: schedule,
    successfulJobsHistoryLimit: 3,
    failedJobsHistoryLimit: 3,
    jobTemplate: {
      metadata: {
        labels+: labels {
          'cron-job-name': name,
        },
      },
      spec: {
        template: {
          metadata: {
            labels+: labels,
          },
          spec: {
            restartPolicy: 'OnFailure',
            initContainers: [],
            containers: [],
          } + jobSpec,
        },
      },
    },
  },
};


{
  Labels: labels,
  CronJob: cronJob,
}
