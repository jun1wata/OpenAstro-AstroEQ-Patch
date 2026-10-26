# ASIAIR ProにOpenAstroとAstroEQ対応パッチを導入する手順

## 1. はじめに

この手順では、ZWO ASIAIR ProをOpenAstroで起動し、AstroEQ赤道儀をASCOM Alpaca経由で使用できるようにします。

**ASIAIR Pro自体はインターネットへ接続しません。**

必要なファイルは、あらかじめWindows PCへダウンロードしておきます。

その後、

```text
Windows PC
   ↓ Wi-Fi直接接続
ASIAIR Pro / OpenAstro
```

という構成で作業します。

今回使用するAstroEQ対応パッチZIPは、

```text
OpenAstro_AstroEQ_public_release.zip
```

です。

作業の流れは次のとおりです。

1. PCでOpenAstro起動用microSDカードを作る
2. ASIAIR ProをOpenAstroで起動する
3. PCをOpenAstroのWi-Fiへ接続する
4. PCからSSHでASIAIR Proへ接続する
5. PCに保存してあるAstroEQパッチZIPをASIAIR Proへ転送する
6. ASIAIR Pro上でZIPを展開する
7. SDカード内のオリジナルOpenAstroへパッチを適用する
8. AstroEQ対応版をビルドする
9. AstroEQ対応版を6801番ポートで自動起動するよう設定する
10. ASIAIR Proを再起動する
11. PCを再びOpenAstro Wi-Fiへ接続する
12. PCのブラウザからAstroEQを設定する

## このパッチを適用するOpenAstroイメージ
このAstroEQ対応パッチは、ZWO ASIAIR Pro用として公開されている OpenAstro for ZWO ASIAIR Pro v1.0.0 イメージに適用します。
OpenAstro ASIAIR Pro用イメージの公開ページ：
https://github.com/open-astro/openastro-zwo-asiar-pro/releases
まず上記ページからASIAIR Pro用OpenAstroイメージ OpenAstro for ZWO ASIAIR Pro v1.0.0 をWindows PCへダウンロードし、別のmicroSDカードへ書き込みます。
そのmicroSDカードからASIAIR ProをOpenAstroで起動した後、本リポジトリで配布している `OpenAstro_AstroEQ_public_release.zip` をPCからASIAIR Proへ転送し、AstroEQパッチを適用します。
**ZWO純正ASIAIRのmicroSDカードや純正システムへ直接このパッチを適用しないでください。**
ZWO純正microSDカードはそのまま保存し、OpenAstro専用の別microSDカードを使用してください。
---

# 2. 重要：ASIAIR Proはインターネットへ接続しない

この手順では、

```text
ASIAIR Pro → インターネット
```

という接続は行いません。

必要なファイルのダウンロードは、すべてWindows PC側で事前に行います。

ASIAIR ProとPCの通信は、

```text
OpenAstro-XXXX
```

というASIAIR Pro自身のWi-Fiアクセスポイントを使用します。

したがって、

```text
インターネット
     │
     │ 必要なファイルを事前ダウンロード
     ▼
Windows PC
     │
     │ OpenAstro-XXXX Wi-Fi
     ▼
ASIAIR Pro
```

という使い方になります。

---

# 3. 用意するもの

必要なものは次のとおりです。

- ZWO ASIAIR Pro
- OpenAstro用microSDカード
- microSDカードリーダー
- Windows PC
- ASIAIR Pro用12V電源
- Wi-Fi機能を持つWindows PC
- OpenAstro Raspberry Pi用イメージ OpenAstro for ZWO ASIAIR Pro v1.0.0
- AstroEQ公開パッチZIP

今回使用するパッチZIP：

```text
OpenAstro_AstroEQ_public_release.zip
```

例えばWindows PCの、

```text
C:\Users\junn\Downloads\
```

へ保存しておきます。

するとファイルは、

```text
C:\Users\junn\Downloads\OpenAstro_AstroEQ_public_release.zip
```

となります。

---

# 4. ZWO純正SDカードは保存する

ASIAIR Proに入っているZWO純正microSDカードは、絶対にOpenAstroで上書きしないでください。

純正カードを抜いて安全な場所に保存します。

そして別のmicroSDカードをOpenAstro専用として使用します。

こうしておけば、何か問題があっても、

```text
ASIAIR Pro電源OFF
↓
OpenAstroカードを抜く
↓
ZWO純正カードを戻す
↓
電源ON
```

だけで元のASIAIRへ戻せます。

---

# 5. OpenAstro起動用microSDカードを作る

## 5-1. PCへOpenAstroイメージをダウンロードしておく

インターネット接続可能なWindows PCを使用して、のpenAstro for ZWO ASIAIR Pro v1.0.0イメージをあらかじめダウンロードします。

```text
openastro-zwo-asiair-pro.img.xz
```

のイメージファイルです。

---

## 5-2. Raspberry Pi Imagerで書き込む

Windows PCへmicroSDカードを挿入します。

Raspberry Pi Imagerを起動します。

OS選択では、

```text
Use custom
```

または、

```text
カスタムイメージを使う
```

を選択します。

PCへ保存したOpenAstroイメージを指定します。

書き込み先として、OpenAstro専用microSDカードを指定します。

### 注意

ZWO純正ASIAIRカードを指定しないでください。

書き込みが完了したらmicroSDカードを安全に取り外します。

---

# 6. ASIAIR ProをOpenAstroで起動する

ASIAIR Proの電源を切ります。

OpenAstro用microSDカードを挿入します。

その後、ASIAIR Proの電源を入れます。

OpenAstroが起動すると、ASIAIR Pro自身がWi-Fiアクセスポイントになります。

---

# 7. Windows PCをOpenAstro Wi-Fiへ接続する

WindowsのWi-Fi設定を開きます。

Wi-Fi一覧の中から、

```text
OpenAstro-XXXX
```

を探します。

`XXXX` の部分は機器によって異なります。

接続します。

初期設定の場合、Wi-Fiパスワードは、

```text
12345678
```

です。

接続後、Windowsに、

```text
インターネットなし
```

と表示されることがあります。

**これは正常です。**

今回の作業ではインターネットは必要ありません。

PCとASIAIR Proが直接通信できれば問題ありません。

---

# 8. OpenAstroのIPアドレス

OpenAstro Wi-Fiへ接続した場合、ASIAIR Proのアドレスは、

```text
172.24.1.1
```

です。

今後、SSHやWebブラウザではこのアドレスを使います。

---

# 9. PCからSSH接続する

WindowsでPowerShellを開きます。

### 重要

ここから「Windows PowerShellで実行するコマンド」と「ASIAIR ProのLinuxで実行するコマンド」があります。

画面の先頭を見れば区別できます。

Windows PowerShell：

```text
PS C:\Users\junn>
```

ASIAIR Pro：

```text
astro@openastro:~ $
```

---

Windows PowerShellで、

```powershell
ssh astro@172.24.1.1
```

を実行します。

初回接続では、

```text
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

と表示されることがあります。

その場合は、

```text
yes
```

と入力します。

パスワードを要求された場合、初期設定では、

```text
astro
```

を入力します。

パスワード入力中は画面に文字が表示されません。

正常です。

ログインに成功すると、

```text
astro@openastro:~ $
```

のようになります。

これでWindows PCからASIAIR Pro内部を操作できるようになりました。

---

# 10. PCからASIAIR ProへパッチZIPを転送する

ここが今回の重要な部分です。

パッチZIPはすでにWindows PCへダウンロードしてあるものとします。

例えば、

```text
C:\Users\junn\Downloads\OpenAstro_AstroEQ_public_release.zip
```

です。

## 10-1. いったんSSH画面とは別にPowerShellを開く

Windowsで新しいPowerShellをもう1つ開きます。

ASIAIR Pro側の、

```text
astro@openastro:~ $
```

では実行しません。

必ずWindows側の、

```text
PS C:\Users\junn>
```

で実行します。

---

## 10-2. scpで転送する

Windows PowerShellで1行で入力します。

```powershell
scp C:\Users\junn\Downloads\OpenAstro_AstroEQ_public_release.zip astro@172.24.1.1:/home/astro/
```

パスワードを聞かれたら、

```text
astro
```

または自分で設定したSSHパスワードを入力します。

これで、

```text
Windows PC
C:\Users\junn\Downloads\OpenAstro_AstroEQ_public_release.zip
```

から、

```text
ASIAIR Pro
/home/astro/OpenAstro_AstroEQ_public_release.zip
```

へコピーされます。

### SSH鍵を使用する場合

SSH秘密鍵を、

```text
C:\Users\junn\.ssh\openastro_codex
```

に置いている場合は、

```powershell
scp -i C:\Users\junn\.ssh\openastro_codex C:\Users\junn\Downloads\OpenAstro_AstroEQ_public_release.zip astro@172.24.1.1:/home/astro/
```

とします。

### この転送にインターネットは不要

`scp` は、

```text
PC
↓
OpenAstro Wi-Fi
↓
ASIAIR Pro
```

というローカル通信だけを使用します。

ASIAIR Proをインターネットへ接続する必要はありません。

---

# 11. ZIPが届いたか確認する

SSH接続しているASIAIR Pro側の画面へ戻ります。

つまり、

```text
astro@openastro:~ $
```

の画面です。

次を実行します。

```bash
ls -lh /home/astro/OpenAstro_AstroEQ_public_release.zip
```

例えば、

```text
-rw-r--r-- 1 astro astro 33K ...
```

のように表示されれば転送成功です。

---

# 12. ZIPを展開する

ASIAIR Pro側で、

```bash
cd /home/astro
```

を実行します。

続いて、

```bash
unzip OpenAstro_AstroEQ_public_release.zip
```

を実行します。

展開後、

```bash
ls -l /home/astro/OpenAstro_AstroEQ_public_release
```

を実行します。

次のようなファイルが見えれば正常です。

```text
openastro_astroeq_full.patch
astroeq_patch_manifest.txt
02_apply_and_build_astroeq.sh
03_verify_astroeq_build.sh
README_ja.md
```

---

# 13. ASIAIR Proはインターネットへ接続しない

以前の手順にあった、

```bash
sudo apt update
```

や、

```bash
git clone https://...
```

は、このオフライン手順では使用しません。

また、

```text
家庭のWi-Fiへ接続
```

する必要もありません。

OpenAstro SDカード内にあるソースコードをそのまま使います。

---

# 14. SDカード内のオリジナルOpenAstroを確認する

今回使用しているOpenAstro環境では、AlpacaBridgeソースは、

```text
/home/astro/AlpacaBridge-main/AlpacaBridge-main
```

にあります。

まず確認します。

```bash
ls -l /home/astro/AlpacaBridge-main/AlpacaBridge-main
```

次に移動します。

```bash
cd /home/astro/AlpacaBridge-main/AlpacaBridge-main
```

現在位置を確認します。

```bash
pwd
```

次のようになれば正常です。

```text
/home/astro/AlpacaBridge-main/AlpacaBridge-main
```

---

# 15. オリジナルOpenAstroを確認する

次を実行します。

```bash
git status
```

可能なら、

```bash
git log --oneline -5
```

も確認します。

今回のAstroEQ公開パッチは、

```text
77a618b
```

をベースとして検証しています。

ただし、ここでインターネットからGitリポジトリを取得する必要はありません。

SDカードに入っているOpenAstroソースを使用します。

---

# 16. パッチ適用前に実行権限を設定する

次を実行します。

```bash
chmod +x /home/astro/OpenAstro_AstroEQ_public_release/02_apply_and_build_astroeq.sh
```

続いて、

```bash
chmod +x /home/astro/OpenAstro_AstroEQ_public_release/03_verify_astroeq_build.sh
```

---

# 17. AstroEQパッチをオリジナルOpenAstroへ適用する

OpenAstroソースディレクトリへ移動します。

```bash
cd /home/astro/AlpacaBridge-main/AlpacaBridge-main
```

まずパッチだけ適用可能か確認したい場合は、

```bash
git apply --check \
/home/astro/OpenAstro_AstroEQ_public_release/openastro_astroeq_full.patch
```

を実行します。

何もエラーが表示されなければ適用可能です。

---

# 18. パッチ適用とビルドを実行する

次を実行します。

```bash
/home/astro/OpenAstro_AstroEQ_public_release/02_apply_and_build_astroeq.sh \
/home/astro/OpenAstro_AstroEQ_public_release/openastro_astroeq_full.patch
```

スクリプトは、

```text
パッチ確認
↓
パッチ適用
↓
CMake設定
↓
コンパイル
```

を行います。

正常終了すれば、

```text
PASS: patch applied and build completed
```

と表示されます。

---

# 19. ビルドされたAstroEQ版を確認する

今回のビルド先は、

```text
AlpacaHTTP/build-astroeq-public
```

です。

実行ファイルを確認します。

```bash
ls -lh \
/home/astro/AlpacaBridge-main/AlpacaBridge-main/AlpacaHTTP/build-astroeq-public/alpacahttp_server
```

ファイルが存在すればビルド成功です。

---

# 20. AstroEQ実装を検証する

次を実行します。

```bash
cd /home/astro/AlpacaBridge-main/AlpacaBridge-main
```

続いて、

```bash
/home/astro/OpenAstro_AstroEQ_public_release/03_verify_astroeq_build.sh
```

を実行します。

AstroEQ関連の主要実装とテストを確認します。

---

# 21. 6800番は変更しない

OpenAstro標準AlpacaBridgeは、

```text
6800
```

番ポートを使用します。

これには手を加えません。

AstroEQ対応版は、

```text
6801
```

番ポートで動かします。

したがって、

```text
6800
オリジナルOpenAstro

6801
AstroEQ対応OpenAstro
```

という構成になります。

これにより、AstroEQ版で何か問題があっても6800番の元のOpenAstroを利用できます。

---

# 22. AstroEQ対応版を自動起動するよう設定する

ASIAIR Pro側で次を実行します。

```bash
sudo tee /etc/systemd/system/alpacabridge-astroeq.service >/dev/null <<'EOF'
[Unit]
Description=OpenAstro AlpacaBridge AstroEQ
After=network.target

[Service]
Type=simple
User=astro
WorkingDirectory=/home/astro/AlpacaBridge-main/AlpacaBridge-main
Environment=ALPACAHTTP_PORT=6801
Environment=ALPACACORE_SKYWATCHER_ASTROEQ_GOTO=1
ExecStart=/home/astro/AlpacaBridge-main/AlpacaBridge-main/AlpacaHTTP/build-astroeq-public/alpacahttp_server
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
```

設定を読み直します。

```bash
sudo systemctl daemon-reload
```

自動起動を有効化し、その場で起動します。

```bash
sudo systemctl enable --now alpacabridge-astroeq.service
```

---

# 23. AstroEQサービスを確認する

次を実行します。

```bash
systemctl status alpacabridge-astroeq.service --no-pager
```

正常なら、

```text
Active: active (running)
```

と表示されます。

---

# 24. AstroEQ Web UIが入っているか確認する

ASIAIR Pro側で、

```bash
curl -s http://127.0.0.1:6801/ | grep AstroEQ
```

を実行します。

例えば、

```text
<option value="astroeq">AstroEQ</option>
```

と表示されれば正常です。

この確認にもインターネットは必要ありません。

---

# 25. ASIAIR Proを再起動する

ASIAIR Pro側で、

```bash
sudo reboot
```

を実行します。

SSH接続は切断されます。

正常です。

---

# 26. 再起動後、PCをOpenAstro Wi-Fiへ再接続する

Windows PCのWi-Fi設定を開きます。

再び、

```text
OpenAstro-XXXX
```

を選択します。

必要ならパスワード、

```text
12345678
```

を入力します。

Windowsが、

```text
インターネットなし
```

と表示しても問題ありません。

むしろ今回の構成では正常です。

---

# 27. 再びSSH接続する

Windows PowerShellで、

```powershell
ssh astro@172.24.1.1
```

を実行します。

SSH鍵を使う場合は、

```powershell
ssh -i C:\Users\junn\.ssh\openastro_codex astro@172.24.1.1
```

です。

---

# 28. 再起動後もAstroEQ版が動いているか確認する

ASIAIR Pro側で、

```bash
systemctl status alpacabridge-astroeq.service --no-pager
```

を実行します。

```text
Active: active (running)
```

なら正常です。

---

# 29. PCのブラウザから設定する

Windows PCでChromeまたはEdgeを開きます。

AstroEQ対応版を開くには、

```text
http://172.24.1.1:6801
```

を入力します。

オリジナルOpenAstroは、

```text
http://172.24.1.1:6800
```

です。

整理すると、

```text
http://172.24.1.1:6800
    ↓
オリジナルOpenAstro

http://172.24.1.1:6801
    ↓
AstroEQ対応版
```

です。

---

# 30. AstroEQ赤道儀を接続する

AstroEQコントローラーをASIAIR ProのUSB端子へ接続します。

その後、

```text
http://172.24.1.1:6801
```

をブラウザで開きます。

新しい機器を登録します。

設定は、

```text
Device Type:
Telescope
```

次に、

```text
Vendor:
AstroEQ
```

を選択します。

接続方式は通常、

```text
Connection Type:
Auto
```

を選択します。

---

# 31. AstroEQが表示されない場合

ブラウザで、

```text
Ctrl + Shift + R
```

を押します。

これは強制再読み込みです。

それでも表示されない場合は、SSHから、

```bash
curl -s http://127.0.0.1:6801/ | grep AstroEQ
```

を実行します。

ここでAstroEQが表示されれば、ASIAIR Pro側は正常です。

ブラウザキャッシュを疑います。

---

# 32. AstroEQのUSB接続を確認する

AstroEQが認識されない場合は、

```bash
lsusb
```

を実行します。

USBシリアルの場合、

```bash
ls -l /dev/ttyUSB*
```

も確認します。

Arduino Mega系の場合は、

```bash
ls -l /dev/ttyACM*
```

を確認します。

代表例：

```text
CH340 AstroEQ
    ↓
/dev/ttyUSB0
```

Arduino Mega 2560系：

```text
Arduino Mega
    ↓
/dev/ttyACM0
```

AstroEQ対応版では、これらをAuto設定で検出します。

---

# 33. AstroEQサービスのログを見る

トラブルが発生した場合は、

```bash
journalctl -u alpacabridge-astroeq.service -n 100 --no-pager
```

を実行します。

リアルタイムで見る場合は、

```bash
journalctl -u alpacabridge-astroeq.service -f
```

です。

終了は、

```text
Ctrl + C
```

です。

---

# 34. ASIAIR Proの時計について

ASIAIR Proをインターネットへ接続しない場合、NTPによる自動時刻同期ができない場合があります。

時刻が大きくずれている場合は、SSHから確認します。

```bash
date
```

必要なら自動同期を停止します。

```bash
sudo timedatectl set-ntp false
```

タイムゾーンを日本へ設定します。

```bash
sudo timedatectl set-timezone Asia/Tokyo
```

例えば、

```bash
sudo timedatectl set-time "2026-10-26 22:16:25"
```

のように手動設定できます。

これはASIAIR Proをインターネットへ接続しない運用では重要です。

---

# 35. Windows PCとASIAIR Proの役割

初心者が混乱しやすいので、ここを覚えておいてください。

## Windows PCで実行するもの

```text
ssh
scp
Webブラウザ
```

例えば、

```powershell
ssh astro@172.24.1.1
```

や、

```powershell
scp C:\Users\junn\Downloads\OpenAstro_AstroEQ_public_release.zip astro@172.24.1.1:/home/astro/
```

です。

---

## ASIAIR Proで実行するもの

SSHログイン後、

```text
astro@openastro:~ $
```

となっている画面で、

```bash
unzip
git status
git apply
cmake
systemctl
journalctl
sudo reboot
```

などを実行します。

---

# 36. 全体の接続図

今回の構成は次のようになります。

```text
事前作業
────────────────────────────

インターネット
      │
      ▼
Windows PC
      │
      ├─ OpenAstro SDイメージを保存
      │
      └─ AstroEQパッチZIPを保存


実際のASIAIR Pro運用
────────────────────────────

インターネット
      X
      X 接続しない
      X

Windows PC
      │
      │ Wi-Fi
      ▼
OpenAstro-XXXX
      │
      ▼
ASIAIR Pro
172.24.1.1
      │
      ├─ SSH
      │
      ├─ :6800 オリジナルOpenAstro
      │
      ├─ :6801 AstroEQ対応OpenAstro
      │
      └─ USB
           │
           ▼
         AstroEQ
           │
           ▼
          赤道儀
```

---

# 37. 最低限覚えておく情報

OpenAstro Wi-Fi：

```text
SSID:
OpenAstro-XXXX
```

初期Wi-Fiパスワード：

```text
12345678
```

OpenAstro IP：

```text
172.24.1.1
```

SSH：

```powershell
ssh astro@172.24.1.1
```

ZIP転送：

```powershell
scp C:\Users\junn\Downloads\OpenAstro_AstroEQ_public_release.zip astro@172.24.1.1:/home/astro/
```

標準OpenAstro：

```text
http://172.24.1.1:6800
```

AstroEQ版：

```text
http://172.24.1.1:6801
```

サービス確認：

```bash
systemctl status alpacabridge-astroeq.service --no-pager
```

ログ：

```bash
journalctl -u alpacabridge-astroeq.service -n 100 --no-pager
```

---

# 38. まとめ

この方法ではASIAIR Proをインターネットへ接続する必要はありません。

必要なデータは、

```text
OpenAstro起動イメージ
AstroEQ公開パッチZIP
```

の2つを、あらかじめWindows PCへ保存しておきます。

その後、

```text
OpenAstro SDカード作成
↓
ASIAIR Pro起動
↓
PCをOpenAstro Wi-Fiへ接続
↓
SSH接続
↓
PCからscpでZIP転送
↓
ASIAIR ProでZIP展開
↓
SDカード内のオリジナルOpenAstroへパッチ適用
↓
ビルド
↓
6801番でAstroEQ版を起動
↓
ASIAIR Pro再起動
↓
PCをOpenAstro Wi-Fiへ再接続
↓
http://172.24.1.1:6801
↓
AstroEQを登録
```

という順番になります。

ASIAIR Pro側ではGitHubへのアクセス、`git clone`、インターネット経由のパッチ取得は行いません。

**PCとASIAIR ProだけのローカルWi-Fi通信で、AstroEQ対応OpenAstroを導入できます。**
