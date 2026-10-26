# CLAUDE.md

東京大学薫風流煎茶同好会の公式サイト（https://sencha-ut.com）。Jekyll 4 + minima テーマ。構成は README.md を参照。

## コマンド

- プレビュー: `bundle exec jekyll serve --livereload` → http://127.0.0.1:4000/
- ビルド確認: `bundle exec jekyll build`（エラーなしで終わること。Sass の DEPRECATION WARNING は minima 由来なので無視してよい）
- `--drafts` は付けない（`_drafts/template.md` の日付が仮の `2026-00-00` でビルドが落ちる）

## 記事（_posts）のルール

- ファイル名: `YYYY-MM-DD-英数字のスラッグ.md`。テンプレートは `_drafts/template.md`
- front matter: `layout: post` / `title` / `date` / `image` / `tags`
- `image` は `/assets/images/posts/YYYY-MM-DD.jpg` のように先頭 `/` 付き。同日に複数枚なら `_1`, `_2` を付ける
- タグ: お知らせ、イベント、新歓、駒場祭、お稽古、お手前、本日のお菓子。`新歓` と `駒場祭` は `shinkan.md` / `komabasai.md`（`tag_name`）の一覧ページに載る
- 文体: です・ます調、やわらかく親しみやすく。絵文字は控えめに使ってよい

## 画像

- 追加前に長辺 1800px 程度・1枚数百KB 以下に縮小する（スマホ写真をそのまま置かない）
- 使われていない画像は残さない

## 注意

- `_config.yml` の `recruitment` / `formurl` は年度ごとに更新する新歓情報
- `CNAME` は独自ドメイン設定なので変更しない
- 公開は `main` ブランチへの push で反映される（GitHub Pages の標準ビルド）。push 前にビルドが通ることを確認する
- 本番の GitHub Pages は Gemfile を使わず Jekyll 3.10 でビルドする。ローカルは Jekyll 4.4 なので、Jekyll 4 でしか動かない書き方やプラグインは使わない
