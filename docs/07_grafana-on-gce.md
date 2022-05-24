# Grafana を GCE 上の Docker で運用する

GCP の DNS ゾーンに`grafana.<domain name>`を対象とする A レコードを追加する．

`grafana.<domain name>`を含むように SSL 証明書を拡張する．

```bash
sudo certbot certonly --standalone -d <domain name> -d influxdb.<domain name> -d grafana.<domain name>
```

docker でのマウント対象のディレクトリに証明書を反映させる．

```bash
sudo cp /etc/letsencrypt/live/<domain name>/fullchain.pem certs/server.crt
sudo cp /etc/letsencrypt/live/<domain name>/privkey.pem certs/server.key
```

nginx の`default.conf`にバーチャルホストの設定を追加する．

```
server {
    listen              443 ssl;
    server_name         <domain name>;
    ssl_certificate     /etc/nginx/certs/server.crt;
    ssl_certificate_key /etc/nginx/certs/server.key;

    location / {
        root   /usr/share/nginx/html;
    }
}

server {
    listen              443 ssl;
    server_name         influxdb.<domain name>;
    ssl_certificate     /etc/nginx/certs/server.crt;
    ssl_certificate_key /etc/nginx/certs/server.key;

    location / {
        proxy_pass http://influxdb:8086/;
    }
}

server {
    listen              443 ssl;
    server_name         grafana.<domain name>;
    ssl_certificate     /etc/nginx/certs/server.crt;
    ssl_certificate_key /etc/nginx/certs/server.key;

    location / {
        proxy_set_header Host $http_host;
        proxy_pass http://grafana:3000/;
    }
}
```

InfluxDB 用のプロビジョニング`datasources.yml`を記述する．

```yaml
apiVersion: 1

datasources:
  - name: InfluxDB_v2_Flux
    type: influxdb
    access: proxy
    url: http://influxdb:8086
    user: $DOCKER_INFLUXDB_INIT_USERNAME
    secureJsonData:
      token: $DOCKER_INFLUXDB_INIT_ADMIN_TOKEN
    jsonData:
      version: Flux
      organization: $DOCKER_INFLUXDB_INIT_ORG
      defaultBucket: $DOCKER_INFLUXDB_INIT_BUCKET
      tlsSkipVerify: true
```

docker compose を起動する．

```yaml
services:
  nginx:
    image: nginx
    ports:
      - 443:443
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./certs:/etc/nginx/certs
  influxdb:
    image: influxdb
    ports:
      - 8086:8086
    environment:
      - DOCKER_INFLUXDB_INIT_MODE=setup
      - DOCKER_INFLUXDB_INIT_USERNAME=${DOCKER_INFLUXDB_INIT_USERNAME}
      - DOCKER_INFLUXDB_INIT_PASSWORD=${DOCKER_INFLUXDB_INIT_PASSWORD}
      - DOCKER_INFLUXDB_INIT_ORG=${DOCKER_INFLUXDB_INIT_ORG}
      - DOCKER_INFLUXDB_INIT_BUCKET=${DOCKER_INFLUXDB_INIT_BUCKET}
      - DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN}
  grafana:
    image: grafana/grafana-oss
    ports:
      - 3000:3000
    volumes:
      - ./grafana/datasources.yml:/etc/grafana/provisioning/datasources/datasources.yml
    environment:
      - DOCKER_INFLUXDB_INIT_USERNAME=${DOCKER_INFLUXDB_INIT_USERNAME}
      - DOCKER_INFLUXDB_INIT_ORG=${DOCKER_INFLUXDB_INIT_ORG}
      - DOCKER_INFLUXDB_INIT_BUCKET=${DOCKER_INFLUXDB_INIT_BUCKET}
      - DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN}
```
