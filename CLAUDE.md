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
- 写真を複数枚載せるときは `images:` に並べ、`image` にもその1枚目を書く。`image` がないと、X などで共有したときのカードに画像が出ない
- タグ: ご案内、イベント、新歓、駒場祭、お稽古、お手前、本日のお菓子。`新歓` と `駒場祭` は `shinkan.md` / `komabasai.md`（`tag_name`）の一覧ページに載る
- **本文は渡された原文から一字も変えない**。文責者（末尾の `（T.T.）` などのイニシャル）がいるため、手を入れると著作上の問題になる
  - 言い回しの修正・段落の分け直し・改行や空行の追加・絵文字の追加もしない。改行の位置も原文どおりにする
  - 誤字や表記の揺れに気づいても直さず、提案するだけにする
  - title・tags など原文にない部分を補ったときは、補ったことを報告で伝える
- 文体（原文がなく、こちらで文章を書くときだけ）: です・ます調、やわらかく親しみやすく。絵文字は控えめに使ってよい

## 画像

縮小とメタデータ削除の手順・コマンドは README の「写真の準備」にある（ここには書かない）。画像を足す・差し替える前に読む。

- 追加前に長辺 1800px 程度・1枚数百KB 以下に縮小する（スマホ写真をそのまま置かない）
- 写真は JPEG で置く（PNG は透過が必要なロゴ・アイコンだけ）。HEIC など他形式はそのまま置かず、JPEG に変換する
- 大きさの目安は表示サイズの2倍: 記事・about の写真は幅 1400px 以上、トップのスライドは 1600×1000 を覆う大きさ、アイコンは表示 px の4倍程度
- 置き場所: 記事の写真は `assets/images/posts/`、トップと行事の写真は `slide/`、ロゴとアイコンは `logos/`、固定ページ（about・join・新歓）だけで使う写真は `assets/images/` 直下
- 使われていない画像は残さない
- **位置情報などのメタデータを必ず消す**。リポジトリは公開なので、一度コミットした写真は消しても履歴から誰でも取り出せる（2025-11-30 撮影の写真で GPS が履歴に残った前例あり）
  - pre-commit フック（`.githooks/pre-commit`）が、ステージした JPEG / PNG にメタデータがあるとコミットを止める。フックを無効にして（`--no-verify`）コミットしない
  - 画像を追加・差し替えたら、コミット前に `tools/strip_metadata.pl` の `report` が `(none)` になるまで `strip` する。縮小・編集ソフトで書き出した後にも行う（書き出しでメタデータが付き直すことがある）
  - 対象は JPEG / PNG。GPS・撮影日時・機種名・コメント等を消す（再圧縮しないので画質は変わらない）
  - 報告ではどのファイルから何（特に GPS・日時）を消したかを伝える

## コードの決まり

つぎはぎを防ぐための決まり。その場で動く形を足す前に、ここに合う置き場所を使う。

- 見た目は `assets/css/style.css` にだけ書く。HTML に `style=` を書かない。色・画面幅の区切り・Bootstrap の上書きの仕方は、そのファイルの冒頭の「決まり」に従う（`!important` を使わない）
- Bootstrap のクラス（`mt-4` `d-flex` など）で足りるものは、CSS を足さずにクラスで書く
- 見出し（h1〜h3）は自動で明朝になるので、書体のクラスを付けない。固定ページ（about.md / join.md）の中見出しは Markdown の `## 見出し` で書く
- JS は `assets/js/` に置き、使うページだけが `<script type="module" src="…">` で読む。HTML の中に `<script>` で書かない
- 2か所以上に出てくる部品は `_includes/` に置く。記事カードは `post-card.html`、タグは `tag-chip.html` を必ず使う（同じものを別の形で書き直さない）
- 記事の一覧やカードに出す写真は、記事の `image`（1枚）を使う
- ヘッダーのメニューの項目は `_config.yml` の `nav` に書く
- タグ別の一覧ページを足すときは、`shinkan.md` と同じ形（`layout: tag_landing` と `tag_name`）のファイルを足す。タグのリンク先は自動で切り替わる
- 使わなくなった CSS・JS・画像・設定は、その変更の中で消す
- ファイルを足したり役割を変えたりしたら、README の「フォルダ構成」を直す

## 注意

- 年度ごとに更新する箇所（`_config.yml` の `recruitment` / `formurl`、`join.md` のサークル情報、お稽古の日時）は README の「年度が替わったら直すところ」に一覧がある。箇所が増減したらその表を直す
- `_config.yml` の `formurl` はキー名を変えない（記事 `2026-04-05-kengakuannai.md` の本文が参照している）
- 手順は README に、規則はこのファイルに書く。同じ内容を2か所に書かない
- `CNAME` は独自ドメイン設定なので変更しない
- 公開は `main` ブランチへの push で反映される。GitHub Actions（`.github/workflows/jekyll.yml`）が Gemfile.lock どおりの Jekyll 4.4 でビルドして公開するので、ローカルと本番は同じ結果になる
- main 向けのプルリクエストでは、同じワークフローがビルドと全画像のメタデータ確認だけを行う（公開はしない）。失敗したらマージしない
- Gemfile.lock は Windows 用（x64-mingw-ucrt）と GitHub の Linux 用（x86_64-linux）の両方を持つ。gem を追加・更新したら `bundle lock --add-platform x86_64-linux` で Linux 用が残っていることを確かめる
