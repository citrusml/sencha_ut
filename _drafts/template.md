---
layout: post
title: "タイトルを入力"
date: 2026-01-01  # 投稿日に書き換える
image: "/assets/images/posts/YYYY-MM-DD.jpg"
tags: [お稽古]
---
（title, date, image, tags を設定して本文を入力）

共有用画像メモ:
- image は /assets/images/... のように先頭 / 付きで書く
- 活動記録ごとに使う画像を 1 枚設定すると、共有時にその画像が大きく表示される
- ファイル名は YYYY-MM-DD.jpg。同日に複数枚なら YYYY-MM-DD_1.jpg, YYYY-MM-DD_2.jpg
- 縮小（HEIC もこれで JPEG になる）: magick 元の写真 -auto-orient -resize "1800x1800>" -quality 85 assets/images/posts/（ファイル名）
- コミット前に位置情報などを消す:
  1. perl tools/strip_metadata.pl report assets/images/posts/（ファイル名）
  2. (none) 以外なら perl tools/strip_metadata.pl strip assets/images/posts/（ファイル名）
  3. もう一度 report して (none) を確認