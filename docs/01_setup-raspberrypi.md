# Raspberry Pi のセットアップ

[公式](https://www.raspberrypi.com/software/)より Raspberry Pi Imager をインストールして利用する．

OS は Raspberry Pi OS Lite (64bit) を選択した．

以下の設定も全て GUI でできるようになっているため，CUI で行う設定は無い．

- ホスト名
- SSH
- ユーザ名・パスワード
- Wi-Fi
- ロケール

OS 書き込み・起動が完了したら，SSH 接続し，`apt`のアップデートとアップグレードを行なっておく．

```bash
$ sudo apt update
$ sudo pat upgrade
```
