const https = require('https');

const url = 'https://api.nature.global/1/devices';
const apiKey = process.env.API_KEY;

// Nature Remo のデバイス情報を取得
function getDevices() {
  return new Promise((resolve, reject) => {
    const options = {
      headers: {
        Authorization: ` Bearer ${apiKey}`,
      },
    };
    https.get(url, options, res => {
      const { statusCode } = res;
      if (statusCode !== 200) {
        reject(new Error(`Request Failed! (Status Code: ${res.statusCode})`));
        res.resume();
        return;
      }
      let rawData = '';
      res.setEncoding('utf8');
      res.on('data', chunk => rawData += chunk);
      res.on('end', () => resolve(JSON.parse(rawData)));
    }).on('error', e => reject(e));
  });
}

module.exports = {
  getDevices,
};
