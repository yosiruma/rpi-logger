# telegraf を GCE 上の Docker で運用する

- 06_influxdb-on-gce.md
- 07_grafana-on-gce.md

と同様の手順で導入する．

telegraf 用設定ファイル`telegraf.conf`の中身は下記の通り．

```
[[inputs.http_listener_v2]]
  service_address = ":1234"
  path = "/receive"
  data_format = "prometheusremotewrite"

[[outputs.influxdb_v2]]
  urls = ["http://influxdb:8086"]
  token = "$DOCKER_INFLUXDB_INIT_ADMIN_TOKEN"
  organization = "$DOCKER_INFLUXDB_INIT_ORG"
  bucket = "$DOCKER_INFLUXDB_INIT_BUCKET"
```

上記で定義した http リスナーに，Prometheus で remote_write するよう`prometheus.yml`に記述する．．

```
remote_write:
  - url: "https://telegraf.<domain name>/receive"
```
