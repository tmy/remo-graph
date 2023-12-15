const { CloudWatch } = require('@aws-sdk/client-cloudwatch');

const region = process.env.AWS_REGION;
const cloudwatch = new CloudWatch({
  region,
});

// センサー情報を CloudWatch カスタムメトリックで送信
function putMetricData(devices, now) {
  const MetricData = devices.map((device) => {
    const { serial_number, newest_events } = device;
    const { te, hu, il, mo } = newest_events;
    const metrics = [];
    const Dimensions = [ { Name: 'Serial Number', Value: serial_number } ];
    if (te) {
      metrics.push({
        MetricName: 'Temperature',
        Dimensions,
        Value: te.val,
        Timestamp: now,
      });
    }
    if (hu) {
      metrics.push({
        MetricName: 'Humidity',
        Dimensions,
        Value: hu.val,
        Timestamp: now,
      });
    }
    if (il) {
      metrics.push({
        MetricName: 'Illumination',
        Dimensions,
        Value: il.val,
        Timestamp: now,
      });
    }
    if (mo) {
      metrics.push({
        MetricName: 'Motion',
        Dimensions,
        Value: now - new Date(mo.created_at),
        Unit: 'Milliseconds',
        Timestamp: now,
      });
    }
    return metrics;
  }).flat();

  const metric = { MetricData, Namespace: 'Nature Remo' };
  console.log(JSON.stringify(metric));
  return cloudwatch.putMetricData(metric);
}

module.exports = {
  putMetricData,
};
