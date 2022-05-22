# InfluxDB を GCE 上の Docker で運用する

GCP の DNS ゾーンに`influxdb.<domain name>`を対象とする A レコードを追加する．

`influxdb.<domain name>`を含むように SSL 証明書を拡張する．

```bash
sudo certbot certonly --standalone -d <domain name> -d influxdb.<domain name>
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
```
