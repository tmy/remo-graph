const AWS = require('aws-sdk');

const region = process.env.AWS_REGION;
const DashboardName = process.env.CLOUDWATCH_DASHBOARD_NAME;
const cloudwatch = new AWS.CloudWatch({ region });

// デバイス情報に応じたダッシュボードを生成
function putDashboard(devices, now) {
  const table = new Table();

  // デバイス毎に現在値を表示
  for (const device of devices) {
    table.add(markdownRow(`# ${device.name}`));

    const currentRow = new Row();
    currentRow.add(singleValue(
      '現在の温度',
      [metric('Temperature', device)]
    ));
    currentRow.add(singleValue(
      '現在の湿度',
      [metric('Humidity', device)]
    ));
    currentRow.add(singleValue(
      '現在の照度',
      [metric('Illumination', device)]
    ));
    currentRow.add(singleValue(
      '人を検知してから',
      [metric('Motion', device)]
    ));
    table.add(currentRow);
  }

  table.add(markdownRow(`# 履歴`));

  // 全デバイスを集約した時系列グラフを表示
  const timeSeriesRow = new Row();
  timeSeriesRow.add(timeSeries(
    '温度',
    devices.map(device => metric('Temperature', device))
  ));
  timeSeriesRow.add(timeSeries(
    '湿度',
    devices.map(device => metric('Humidity', device))
  ));
  timeSeriesRow.add(timeSeries(
    '照度',
    devices.map(device => metric('Illumination', device))
  ));
  timeSeriesRow.add(timeSeries(
    '人感',
    devices.map(device => metric('Motion', device))
  ));
  table.add(timeSeriesRow);

  const { widgets } = table;
  const body = {
    widgets,
  };
  const DashboardBody = JSON.stringify(body);
  return cloudwatch.putDashboard({ DashboardName, DashboardBody }).promise();
}

// ダッシュボード上にテーブル状にウィジェットをレイアウトする
class Table {
  #y = 0;
  // テーブルに追加されたウィジェットリスト
  widgets = [];
  // テーブルに行を追加
  add(row) {
    const { widgets } = row;
    const height = Math.max(...widgets.map(w => w.height));
    const cols = widgets.map(w => ({ y: this.#y, ...w }));
    this.widgets.push(...cols);
    this.#y += height;
  }
}

// テーブル内の 1 行分のレイアウト
class Row {
  #x = 0;
  // 行に追加されたウィジェットリスト
  widgets = [];
  // 行にウィジェットを追加
  add(widget) {
    const { width } = widget;
    this.widgets.push({ x: this.#x, ...widget });
    this.#x += width;
  }
}

// Markdown を表示する行
function markdownRow(markdown) {
  const row = new Row();
  row.add({
    type: 'text',
    width: 24,
    height: 1,
    properties: {
      markdown,
    }
  })
  return row;
}

// 現在値を表示するウィジェット
function singleValue(title, metrics) {
  return {
    type: 'metric',
    width: 6,
    height: 3,
    properties: {
      view: 'singleValue',
      metrics,
      region: 'ap-northeast-1',
      period: 300,
      title,
    }
  }
}

// 履歴グラフを表示するウィジェット
function timeSeries(title, metrics) {
  return {
    type: 'metric',
    width: 6,
    height: 6,
    properties: {
      metrics,
      view: 'timeSeries',
      stacked: false,
      region: 'ap-northeast-1',
      title,
      legend: {
        position: 'bottom'
      },
      period: 300,
      stat: 'Average',
    }
  };
}

// デバイスに対応する CloudWatch のメトリックパラメータを返す
function metric(metricName, device) {
  const { name, serial_number } = device;
  return [
    'Nature Remo',
    metricName,
    'Serial Number',
    serial_number,
    {
      label: name,
    },
  ];
}

module.exports = {
  putDashboard,
};
