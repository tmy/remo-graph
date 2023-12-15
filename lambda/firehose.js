const { Firehose } = require('@aws-sdk/client-firehose');

const region = process.env.AWS_REGION;
const DeliveryStreamName = process.env.DELIVERY_STREAM_NAME;
const firehose = new Firehose({
  region,
});

// Kinesis Firehose にデータ送信
function putFirehose(devices, now) {
  const Records = devices.map((device) => {
    const timestamp = now.toISOString();
    const Data = Buffer.from(JSON.stringify({ ...device, timestamp }));
    return { Data };
  }).flat();
  const params = { DeliveryStreamName, Records };
  return firehose.putRecordBatch(params);
}

module.exports = {
  putFirehose,
};
