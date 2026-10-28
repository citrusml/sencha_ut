# CLAUDE.md

東京大学薫風流煎茶同好会の公式サイト（https://sencha-ut.com）。Jekyll 4 で、テーマは使わずレイアウトはすべて `_layouts/` の自作。構成は README.md を参照。

## コマンド

- プレビュー: `bundle exec jekyll serve --livereload` → http://127.0.0.1:4000/
- ビルド確認: `bundle exec jekyll build`（エラーなしで終わること）
- 下書きも見るとき: `bundle exec jekyll serve --livereload --drafts`
- 初回のみ: `git config core.hooksPath .githooks`（コミット前に画像のメタデータを自動チェックするフックを有効にする）と `git config core.quotepath false`（日本語ファイル名をそのまま表示する）

## 記事（_posts）のルール

- ファイル名: `YYYY-MM-DD-英数字のスラッグ.md`。テンプレートは `_drafts/template.md`
- front matter: `layout: post` / `title` / `date` / `image` / `tags`
- `image` は `/assets/images/posts/YYYY-MM-DD.jpg` のように先頭 `/` 付き。同日に複数枚なら `_1`, `_2` を付ける
- タグ: ご案内、イベント、新歓、駒場祭、お稽古、お手前、本日のお菓子。`新歓` と `駒場祭` は `shinkan.md` / `komabasai.md`（`tag_name`）の一覧ページに載る
- **本文は渡された原文から一字も変えない**。文責者（末尾の `（T.T.）` などのイニシャル）がいるため、手を入れると著作上の問題になる
  - 言い回しの修正・段落の分け直し・改行や空行の追加・絵文字の追加もしない。改行の位置も原文どおりにする
  - 誤字や表記の揺れに気づいても直さず、提案するだけにする
  - title・tags など原文にない部分を補ったときは、補ったことを報告で伝える
- 文体（原文がなく、こちらで文章を書くときだけ）: です・ます調、やわらかく親しみやすく。絵文字は控えめに使ってよい

## 画像

- 追加前に長辺 1800px 程度・1枚数百KB 以下に縮小する（スマホ写真をそのまま置かない）
  - 縮小は ImageMagick: `magick 元.jpg -auto-orient -resize "1800x1800>" -quality 85 assets/images/posts/YYYY-MM-DD.jpg`（HEIC もこれで JPEG にする。`-auto-orient` で向きを画素に焼き込む）
- 写真は JPEG で置く（PNG は透過が必要なロゴ・アイコンだけ）
- 大きさの目安は表示サイズの2倍: 記事・about の写真は幅 1400px 以上、トップのスライドは 1600×1000 を覆う大きさ、アイコンは表示 px の4倍程度
- 使われていない画像は残さない
- **位置情報などのメタデータを必ず消す**。リポジトリは公開なので、一度コミットした写真は消しても履歴から誰でも取り出せる（2025-11-30 撮影の写真で GPS が履歴に残った前例あり）
  - pre-commit フック（`.githooks/pre-commit`）が、ステージした JPEG / PNG にメタデータがあるとコミットを止める。フックを無効にして（`--no-verify`）コミットしない
  - 画像を追加・差し替えたら、コミット前に `perl tools/strip_metadata.pl report <ファイル>` で確認し、`(none)` 以外なら `perl tools/strip_metadata.pl strip <ファイル>` で削除して、もう一度 report で `(none)` を確認する
  - 対象は JPEG / PNG。GPS・撮影日時・機種名・コメント等を消す（再圧縮しないので画質は変わらない）。HEIC など他形式はそのまま置かず JPEG に変換してから処理する
  - 縮小・編集ソフトで書き出した後にも処理する（書き出しでメタデータが付き直すことがある）
  - 報告ではどのファイルから何（特に GPS・日時）を消したかを伝える

## 注意

- `_config.yml` の `recruitment` / `formurl` は年度ごとに更新する新歓情報
- `CNAME` は独自ドメイン設定なので変更しない
- 公開は `main` ブランチへの push で反映される。GitHub Actions（`.github/workflows/jekyll.yml`）が Gemfile.lock どおりの Jekyll 4.4 でビルドして公開するので、ローカルと本番は同じ結果になる
- main 向けのプルリクエストでは、同じワークフローがビルドと全画像のメタデータ確認だけを行う（公開はしない）。失敗したらマージしない
- Gemfile.lock は Windows 用（x64-mingw-ucrt）と GitHub の Linux 用（x86_64-linux）の両方を持つ。gem を追加・更新したら `bundle lock --add-platform x86_64-linux` で Linux 用が残っていることを確かめる
