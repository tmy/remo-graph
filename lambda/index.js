const { getDevices } = require('./remo');
const { putMetricData } = require('./cloudwatch_metric');
const { putDashboard } = require('./cloudwatch_dashboard')
const { putFirehose } = require('./firehose');

exports.handler = async () => {
  const devices = await getDevices();
  console.log(JSON.stringify(devices));
  const now = new Date();
  return Promise.all([
    putMetricData(devices, now),
    putDashboard(devices, now),
    putFirehose(devices, now),
  ]);
};
