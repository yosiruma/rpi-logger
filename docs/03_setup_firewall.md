# ファイアウォールの設定

`ufw`を使用する．

```bash
sudo apt install ufw
sudo ufw default deny
sudo ufw allow from 192.168.0.0/24 to any port ssh
sudo ufw allow from 192.168.0.0/24 to any port domain
sudo ufw enable
```
