# Raspberry Pi の Docker で Prometheus を利用する

[公式ドキュメント](https://prometheus.io/docs/prometheus/latest/installation/)に従う．

まずはテスト

```bash
docker run --rm -p 9090:9090 prom/prometheus
```

PC から`raspberrypi.local`に接続して Prometheus のページが表示されれば OK．

Docker Compose を用いて起動できるよう設定する．

```yaml:compose.yaml
services:
  prometheus:
    image: prom/prometheus
    ports:
      - 9090:9090
```

```bash
docker compose up
```
