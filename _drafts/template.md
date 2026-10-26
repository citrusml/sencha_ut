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
- 写真を置いたら、コミット前に位置情報などを消す: perl tools/strip_metadata.pl strip assets/images/posts/（ファイル名）