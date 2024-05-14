const AWS = require('aws-sdk');
const BucketName = process.env.BUCKET_NAME;

exports.handler = (event) => {
  const s3 = new AWS.S3();
  console.log(JSON.stringify(event, null, 2));
  event.Records.forEach(async (record) => {
    // Kinesis data is base64 encoded so decode here
    const payload = Buffer.from(record.kinesis.data, 'base64').toString();
    console.log('Decoded payload ', payload);
    const parsed = JSON.parse(payload) || {};
    const {
      Queue,
      Agent,
      Channel,
      ContactId,
      Attributes,
      InitiationMethod,
      DisconnectTimestamp,
    } = parsed;

    if (
        Attributes.Q1 &&
        Channel === "VOICE" &&
        (InitiationMethod === "DISCONNECT" || InitiationMethod === "INBOUND")
    ) {
      if (!Queue && !Agent) {
        // Put the individual CTR object into S3
        const params = {
          Body: payload,
          Bucket: BucketName,
          Key: `${DisconnectTimestamp}_${ContactId}.json`,
        };

        // Adding a console log message with the filename
        console.log(`Processed and dumped into S3: ${params.Key}`);

        const response = await s3.putObject(params).promise();
        console.log(response);
      } else {
        console.log('Skipping record because both Queue and Agent values are present.');
      }
    } else {
      console.log('Skipping record due to filtering conditions.');
    }
  });
  console.log('Done!');
};
