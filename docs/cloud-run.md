# Cloud Run へのデプロイ

Shiny のデプロイ先としては RStudio Connect、shinyapps.io、Shiny Server、ShinyProxy などがある。
料金体系、マネージドレベル、性能、アクセス制御機構などの特性がそれぞれに異なる。

このプロジェクトではアプリケーションを Docker イメージとしてビルドしたので、コンテナが動かせる環境なら一応どこでも動作する。

[Cloud Run](https://cloud.google.com/run?hl=ja) はあまり Shiny のデプロイ先として使われている例を見ない。
もともと Websocket が使えなかったが、21年1月になって利用できるようになった。

🔗 [Cloud Run の WebSocket、HTTP/2、gRPC 双方向ストリームのご紹介 | Google Cloud Blog](https://cloud.google.com/blog/ja/products/serverless/cloud-run-gets-websockets-http-2-and-grpc-bidirectional-streams)

Cloud Run の特長としてはセットアップが容易であること、自動でスケールすることと、Scale-to-Zero の性質を持つことが挙げられる。
特に、Scale-to-Zero の性質 -- リクエストがない間は完全にコンテナを停止する -- があるため、利用者がいない間は固定料金が掛からない。

しかし、高負荷時には自動でスケールアウトするとはいえ ShinyProxy のように接続ユーザーごとにコンテナを割り当てる仕組みにはなっていないので、多人数による同時利用でうまく動作するかどうかは未知数である。
また HTTP リクエストのタイムアウト時間は最大 60 分で、それ以上の時間にわたって Websocket 接続（= Shiny セッション）を持続することはできない。

こうした制約にもかかわらず、Cloud Run への Shiny のデプロイは一部では Websocket サポート以前から模索されていた（例えば https://code.markedmondson.me/shiny-cloudrun/ など）。

少人数向けの実験的アプリケーションを素早く多数作ることができて、利用のない間は料金が掛からず保守の手間が掛からないというのが利点と考えられる。

---

## デプロイ手順

[gcloud CLI](https://cloud.google.com/sdk/gcloud?hl=ja) でのデプロイ手順を記す（GCP コンソール画面でも同様の操作は可能）。
Cloud SDK のセットアップは済んでいるものとする。

⚡️ Artifact Registry にリポジトリを作成

```sh
PROJECT=projectname # 自分のGCPプロジェクト名
LOCATION=asia-northeast1

gcloud config set project $PROJECT
gcloud config set artifacts/location $LOCATION

gcloud artifacts repositories create rhino-repo \
    --repository-format=docker
```

⚡️ Docker イメージをビルドしてリポジトリにプッシュ

```sh
IMAGE=$LOCATION-docker.pkg.dev/$PROJECT/rhino-repo/rhino-training:latest
docker build -t $IMAGE .
docker push $IMAGE
```

⚡️ Cloud Run にデプロイ

```sh
SERVICE=rhino-training
gcloud run deploy $SERVICE \
    --port=3838 \
    --timeout=3600 \
    --concurrency=80 \
    --image=$IMAGE \
    --allow-unauthenticated
```

自動的に発行されるサービス URL（例：<https://rhino-training-b6qdc4l5sa-uc.a.run.app>）を確認する。

Cloud Run の設定値について

- なるべく長くWebSocket接続が保つようにするため、リクエストタイムアウト（`timeout`）を3600秒に設定。
- ユーザーごとにコンテナを起動するためにコンテナあたりの最大リクエスト数（`concurrency`）を１にするパターン（[参考](https://cloud.google.com/run/docs/about-concurrency?hl=ja#concurrency-1)）もあるものの、Shinyの場合はコールドスタートのときcssやjsのリクエスト処理が失敗して上手く行かなかった。


## 参考

🔗 [Alternatives to Scaling Shiny with RStudio Connect or Custom Architecture](https://appsilon.com/alternatives-to-scaling-shiny/)

---

- [🏠 プロジェクトルートへ](https://github.com/terashim/rhino-training)
- [📗 ドキュメントフォルダへ `docs/`](./)
