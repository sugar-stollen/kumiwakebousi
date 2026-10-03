# スプラッシュ画面の作成手順

このアプリでは、起動時のタイトル画面（スプラッシュ）と、帽子と会話するホーム画面を別の画面として管理しています。画面の見た目、表示場所、次の画面への遷移をそれぞれ別ファイルに置くことで、後から修正する場所を見つけやすくしています。

## 現在の画面遷移

```text
ルートURL (/)
  → SplashController#show
  → スプラッシュ画面
  → 「はじめる」
  → /home/index（帽子との会話）
  → 組み分け画面・結果画面
  → 「終わる」
  → /home/index（ホーム画面）
```

組み分けを終えたときは `root_path` ではなく `home_index_path` に戻ります。ルートURLはスプラッシュ画面を表示するため、終了時にルートへ戻すと再びスプラッシュが表示されます。

## ファイルの役割

| ファイル | 役割 |
| --- | --- |
| `app/controllers/splash_controller.rb` | スプラッシュ画面を表示するコントローラー |
| `app/views/splash/show.html.erb` | ロゴ、案内文、「はじめる」リンクを配置するビュー |
| `app/assets/stylesheets/splash.css.erb` | スプラッシュ画面専用の背景、配置、ロゴ、ボタンのスタイル |
| `app/controllers/home_controller.rb` | ホーム画面を表示するコントローラー |
| `app/views/home/index.html.erb` | 帽子とのオープニング会話を配置するビュー |
| `app/assets/stylesheets/home.css.erb` | ホーム画面と会話画面のスタイル |
| `config/routes.rb` | `/` をスプラッシュへ、`/home/index` をホームへ接続するルート設定 |
| `app/controllers/kumiwake_controller.rb` | 組み分け終了時にホームへ戻す処理 |
| `app/assets/images/kumiwakerogo.png` | スプラッシュ画面に表示するロゴ画像 |

スタイルシートは `app/assets/stylesheets/application.css` の `require_tree .` で読み込まれます。追加のCSSファイルを同じディレクトリに置けば、通常は個別の読み込み指定を増やす必要はありません。

## 作成・変更の手順

### 1. 画面を分ける

スプラッシュ用のコントローラー、ビュー、スタイルをそれぞれ `splash` にまとめます。ホーム画面のファイルは `home` に残します。

```text
app/controllers/splash_controller.rb
app/views/splash/show.html.erb
app/assets/stylesheets/splash.css.erb
```

コントローラーの `show` アクションは専用の追加処理がなければ空で構いません。Railsは `show` に対応する `app/views/splash/show.html.erb` を描画します。

### 2. URLを割り当てる

`config/routes.rb` でルートURLをスプラッシュ画面に割り当て、ホーム画面には既存の `home_index_path` を使います。

```ruby
get 'splash', to: 'splash#show', as: :splash
root 'splash#show'
get 'home/index'
```

`as: :splash` は `splash_path` という名前付きルートを作ります。ルートURLは `root_path` です。ホームへ移動するリンクは `home_index_path` を使います。

### 3. ロゴと開始リンクをビューに置く

Railsの `image_tag` に画像ファイル名を渡すと、アセット画像への参照を作れます。画像は `app/assets/images/` に置きます。

```erb
<%= image_tag "kumiwakerogo.png", class: "splash-logo", alt: "組み分け帽子" %>
<%= link_to "はじめる", home_index_path, class: "splash-start" %>
```

リンクは `/home/index` へ直接進みます。ホーム画面の会話を表示する処理はホーム側に置き、スプラッシュ用のStimulusコントローラーには持たせません。

### 4. スプラッシュ専用のCSSを書く

背景、中央揃え、ロゴ、ボタンなどの見た目は `splash.css.erb` に記述します。`.erb` 形式なので、背景画像には `asset_path` を使用できます。

```css
background: url("<%= asset_path('background.png') %>") center / cover no-repeat;
```

画面全体を覆うときは `min-height: 100vh`、中央揃えには Grid の `place-items: center` が使えます。狭い画面でロゴや余白が大きすぎる場合は、ファイル末尾の `@media` 内で調整します。

### 5. 終了後の戻り先をホームにする

組み分けを終える処理は `KumiwakeController#finish` にあります。終了後にホームへ戻す場合は、次のように `home_index_path` へリダイレクトします。

```ruby
def finish
  clear_round_state
  redirect_to home_index_path
end
```

ここを `root_path` にすると、トップURLのスプラッシュへ戻ります。戻り先を変えるときは、コントローラーのリダイレクト先と画面遷移の意図を一緒に確認します。

## ロゴサイズの調整

現在の `.splash-logo` は次の指定です。

```css
.splash-logo {
  width: min(100%, 940px);
  object-fit: contain;
}

.splash-content {
  width: min(90%, 660px);
}
```

ロゴ画像は親要素の幅を超えられません。親の最大幅が `660px` なので、ロゴ側の `940px` は上限として働かず、通常は親の幅で表示サイズが決まります。より大きく見せるには、まず `.splash-content` の幅を広げます。そのうえで `.splash-logo` の上限も必要に応じて調整します。

スマートフォンでは `@media (max-width: 600px)` 内の `max-height: 36vh` が画像の高さを制限します。幅を増やしても変化しない場合は、親要素の幅とこの高さ制限を確認してください。PNGのキャンバスに透明な余白が含まれている場合、画像要素の寸法が増えても、絵柄自体は同じ割合で大きく見えないことがあります。

## 変更後に確認すること

1. `/` を開くとスプラッシュが表示される。
2. ロゴ画像が表示され、「はじめる」リンクがホームへ移動する。
3. `/home/index` ではスプラッシュを経由せず、帽子との会話が始まる。
4. 組み分け結果の「終わる」操作で `/home/index` に戻る。
5. PCとスマートフォンの幅で、背景、ロゴ、開始リンクが画面内に収まる。

