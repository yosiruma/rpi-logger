# Raspberry Pi への Docker 導入

## Docker のインストール

[公式ドキュメント](https://docs.docker.com/engine/install/debian/)に従ってインストールする．

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

## Docker インストール後の設定

インストール直後では，ルートユーザでなければ Docker を使えないので，[公式ドキュメント](https://docs.docker.com/engine/install/linux-postinstall/)に従って設定する．

```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```
