# Dockerビルドと実行手順

このドキュメントは、ローカルマシン上でプロジェクトのリポジトリをクローンし、Dockerイメージをビルドして、アプリケーションをDockerコンテナとして実行するまでの手順を説明します。

## 前提条件

*   ローカルマシンに[Docker](https://www.docker.com/products/docker-desktop)がインストールされ、実行中であること。
*   ローカルマシンでMySQLサーバーが実行中であり、`jc21ps_2024`データベースが存在すること。

## ステップ1: リポジトリのクローン

まず、ターミナルを開き、プロジェクトを保存したいディレクトリに移動して、リモートリポジトリをクローンします。

```sh
git clone https://github.com/TCC-SystemEngineeringDept/JC21PS_2025_Z
```

クローンが完了したら、プロジェクトのルートディレクトリに移動します。ディレクトリ名はリポジトリ名によって異なる場合があります。

```sh
cd JC21PS_2025_Z
```

## ステップ2: Dockerイメージのビルド

プロジェクトのルートディレクトリ（`Dockerfile`が存在する場所）から、以下のコマンドを実行してDockerイメージをビルドします。このコマンドは、イメージに`activity-management`という名前のタグを付けます。

```sh
docker build -t activity-management .
```

## ステップ3: Dockerコンテナの実行

イメージのビルドが成功したら、アプリケーションをコンテナとして実行できます。以下のコマンドはコンテナを起動し、ローカルのMySQLデータベースに接続します。

**重要:** このコマンドを実行する前に、ローカルのMySQLサーバーが起動していることを確認してください。

```sh
docker run -d -p 8080:8080 \
  --name activity-app \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://host.docker.internal:3306/jc21ps_2024 \
  -e SPRING_DATASOURCE_USERNAME=root \
  -e SPRING_DATASOURCE_PASSWORD=jc212024 \
  activity-management
```

### コマンドの解説:

*   `-d`: コンテナをデタッチモード（バックグラウンド）で実行します。
*   `-p 8080:8080`: ローカルマシンのポート8080を、コンテナのポート8080にマッピングします。
*   `--name activity-app`: コンテナに`activity-app`という名前を割り当て、管理しやすくします。
*   `-e ...`: コンテナ内で環境変数を設定します。
    *   `SPRING_DATASOURCE_URL=jdbc:mysql://host.docker.internal:3306/jc21ps_2024`: これが最も重要な部分です。コンテナ内で実行されているSpring Bootアプリケーションに、ホストマシンで実行されているMySQLサーバーへ接続するよう指示します。`host.docker.internal`は、Dockerがホストの内部IPアドレスに解決してくれる特別なDNS名です。
    *   `SPRING_DATASOURCE_USERNAME`: データベースのユーザー名を設定します。
    *   `SPRING_DATASOURCE_PASSWORD`: データベースのパスワードを設定します。**注意:** もしパスワードが異なる場合は、`jc212024`を実際のMySQLパスワードに置き換えてください。
*   `activity-management`: 実行するイメージの名前です。

## 実行の確認方法

コンテナのログを確認して、アプリケーションが正しく起動したかを見ることができます。

```sh
docker logs activity-app
```

また、現在実行中のコンテナを一覧表示することもできます。

```sh
docker ps
```

アプリケーションが正常に起動すれば、Webブラウザで `http://localhost:8080` にアクセスできるはずです。
