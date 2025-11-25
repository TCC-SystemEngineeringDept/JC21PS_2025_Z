# Portainerを使ったアプリケーションデプロイ手順

このドキュメントは、Portainerが稼働しているサーバー上で、プロジェクトのリポジトリをクローンし、Dockerイメージをビルドして、最終的にPortainerのWebインターフェースを使ってアプリケーションをコンテナとして実行するまでの手順を説明します。

## 前提条件

*   サーバーに[Docker](https://www.docker.com/)および[Portainer](https://www.portainer.io/)がインストールされ、実行中であること。
*   サーバー（またはアクセス可能な他のマシン）でMySQLサーバーが実行中であり、`jc21ps_2024`データベースが存在すること。

---

## ステップ1: リポジトリのクローン（コマンドライン）

まず、Portainerが稼働しているサーバーのターミナルに接続します。
プロジェクトを保存したいディレクトリ（例: ホームディレクトリ）に移動し、リモートリポジトリをクローンします。

```sh
# 例: ホームディレクトリに移動
cd ~

# Gitリポジトリをクローン
git clone https://github.com/TCC-SystemEngineeringDept/JC21PS_2025_Z
```

---

## ステップ2: Dockerイメージのビルド（コマンドライン）

次に、クローンしたソースコードからDockerイメージをビルドします。Portainerのデフォルト設定ではサーバーのファイルシステムにアクセスできないため、このステップもコマンドラインで実行するのが確実です。

まず、クローンして作成されたプロジェクトディレクトリに移動します。

```sh
cd JC21PS_2025_Z
```

次に、`Dockerfile`が存在するこのディレクトリ内で、以下のコマンドを実行してDockerイメージをビルドします。イメージには`activity-management`というタグが付けられます。

```sh
docker build -t activity-management .
```

ビルドが完了すると、`Successfully built ...` というメッセージが表示されます。このイメージは自動的にPortainerからも認識されます。

---

## ステップ3: Dockerコンテナの実行（Portainer UI）

コマンドラインで作成したイメージを、PortainerのWebインターフェースを使ってコンテナとして起動します。

1.  **Portainerにログインし、「Images」メニューへ**
    *   ブラウザでPortainerを開き、左側メニューから「Images」を選択します。
    *   `activity-management` という名前のイメージがリストに表示されていることを確認します。

2.  **コンテナの新規作成**
    *   左側メニューから「Containers」を選択し、「+ Add container」ボタンをクリックします。

3.  **基本情報の入力**
    *   **Name:** `activity-app` と入力します。
    *   **Image:** テキストボックスをクリックし、ドロップダウンから `activity-management:latest` を選択します。

4.  **ポートのマッピング**
    *   「Network ports configuration」セクションで、「+ publish a new network port」ボタンをクリックします。
    *   **host** と **container** の両方に `8080` と入力します。（`8080:8080` のマッピング）

5.  **環境変数の設定**
    *   ページ下部にある「Advanced container settings」をクリックして開きます。
    *   **「Env」タブ**を選択します。
    *   「+ add environment variable」ボタンを**3回**クリックし、アプリケーションに必要な環境変数をそれぞれ入力します。

| Name                         | Value                                                 |
| ---------------------------- | ----------------------------------------------------- |
| `SPRING_DATASOURCE_URL`      | `jdbc:mysql://サーバーのIPアドレス:3306/jc21ps_2024` |
| `SPRING_DATASOURCE_USERNAME` | `root`                                                |
| `SPRING_DATASOURCE_PASSWORD` | `jc212024`                                            |

    **【重要】**
    `SPRING_DATASOURCE_URL`の`サーバーのIPアドレス`の部分は、`localhost`や`host.docker.internal`ではなく、**MySQLサーバーが稼働しているマシンの実際のIPアドレス**（例: `192.168.54.238`）に置き換えてください。

6.  **コンテナのデプロイ**
    *   すべての設定が完了したら、ページ上部または下部にある**「Deploy the container」ボタンをクリックします。**

---

## ステップ4: 実行の確認（Portainer UI）

コンテナが正常に起動したかを確認します。

1.  **コンテナの状態確認**
    *   「Containers」のリスト画面で、`activity-app` コンテナの状態（State）が `running` になっていることを確認します。

2.  **ログの確認**
    *   `activity-app` の行にあるログアイコン（📄）をクリックすると、アプリケーションの起動ログが表示されます。エラーなくSpring Bootが起動しているかを確認できます。

3.  **ブラウザでのアクセス**
    *   Webブラウザを開き、`http://サーバーのIPアドレス:8080` にアクセスします。アプリケーションの画面が表示されれば成功です。
