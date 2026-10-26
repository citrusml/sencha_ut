# 東京大学薫風流煎茶同好会 Webサイト

https://sencha-ut.com のソースです。[Jekyll](https://jekyllrb.com/)（テーマ: minima）で作られています。

## ローカルでのプレビュー

必要なもの: Ruby（Windows は RubyInstaller の「Ruby+Devkit」）と Bundler

```bash
bundle install                          # 初回のみ
bundle exec jekyll serve --livereload   # http://127.0.0.1:4000/ で確認
```

ファイルを保存するとページが自動で更新されます。`_config.yml` を変えたときだけ再起動が必要です。

## フォルダ構成

```
├── _config.yml          # サイト全体の設定（タイトル、新歓情報、フォームURL など）
├── _layouts/
│   ├── default.html     # 全ページ共通のヘッダー・フッター・スライドショー
│   ├── page.html        # 通常ページ（about / join）
│   ├── post.html        # 活動記録の記事
│   └── tag_landing.html # タグ別の記事一覧（新歓・駒場祭）
├── _posts/              # 活動記録の記事（YYYY-MM-DD-英数字.md）
├── _drafts/             # 下書き・記事テンプレート（公開されない）
├── assets/
│   ├── css/style.css    # デザイン
│   └── images/
│       ├── logos/       # ロゴ・SNSアイコン
│       ├── posts/       # 記事ごとの画像
│       └── slide/       # トップページのスライド・行事写真
├── index.html           # トップページ
├── about.md             # 煎茶道・薫風流について
├── join.md              # 入会案内
├── gallery.html         # 活動記録・行事紹介（記事一覧）
├── shinkan.md           # 新歓の活動記録（/tags/shinkan/）
├── komabasai.md         # 駒場祭の活動記録（/tags/komabasai/）
└── CNAME                # 独自ドメイン sencha-ut.com
```

## 活動記録の書き方

1. `_drafts/template.md` をコピーして `_posts/YYYY-MM-DD-英数字.md` を作る
2. `title` / `date` / `image` / `tags` を埋めて本文を書く
3. 画像は `assets/images/posts/YYYY-MM-DD.jpg` に置き、`image` には `/assets/images/...` と先頭に `/` を付けて書く

よく使うタグ: お知らせ、イベント、新歓、駒場祭、お稽古、お手前、本日のお菓子
（`新歓` と `駒場祭` は専用の一覧ページに載ります）

画像はスマホの写真をそのまま置かず、長辺 1800px 程度・1枚数百KB 以下に縮小してから追加してください。
