# GCP でサーバを建てる

1. 独自ドメインを取得する
2. GCP の「VPC ネットワーク > IP アドレス」より静的 IP を予約する
3. GCP の「ネットワークサービス > Cloud DNS」より DNS ゾーンを作成する
4. ドメインを取得したレジストラに，3 で設定されたネームサーバを登録する
5. 3 で作成した DNS ゾーンに 2 で予約した IP アドレスを対象とする A レコードを追加する
6. VM インスタンスを作成し，2 で予約した IP アドレスを割り当てる
7. 6 で作成したインスタンスに公開鍵を追加する

`rsync`を入れておく．

```bash
sudo apt install rsync
```

SSH 接続し，Docker をインストールする．

```bash
sudo apt-get update
sudo apt-get install \
  ca-certificates \
  curl \
  gnupg \
  lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

GCP のコンソールから 80 番ポートを allow にして

```bash
docker run -p 80:80 --rm nginx
```

で nginx のページが表示できることを確認する．

SSL 化する．[lets enc](https://letsencrypt.org/getting-started/)を利用する．

```bash
sudo apt install snapd
sudo snap install core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot certonly --standalone
```

証明書を適当な場所に移動する

```bash
mkdir certs
sudo cp /etc/letsencrypt/live/<domain name>/fullchain.pem certs/server.crt
sudo cp /etc/letsencrypt/live/<domain name>/privkey.pem certs/server.key
```

`default.conf`を作成して

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
```

`compose.yaml`を記述する

```yaml
services:
  nginx:
    image: nginx
    ports:
      - 443:443
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./certs:/etc/nginx/certs
```

`docker compose up`して自分のドメインにアクセスし，nginx のページが表示されれば OK．
