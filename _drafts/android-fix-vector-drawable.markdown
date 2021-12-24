---
layout: post
title: "Fix vector drawables"
date: 2021-07-15 12:00:00 +0300
image: /assets/Asteracea_poster_3_part_2.jpg
description: "Fix vector drawables"
postImage:
  src: Asteracea_poster_3_part_2
  alt: Types of Asteraceaes
---

Error: Use -0.007690000000000197 instead of -.007690000000000197 to avoid crashes on some devices [InvalidVectorPath]

There're two cases

1. just add 0 before .
`([^0-9])(\.)([0-9])` replace by `$10$2$3`
this will replace .0 for cases 

1. add space between numbers
`(\.[0-9]*)(\.)([0-9])` replace by `$1 0$2$3`

https://github.com/mapbox/mapbox-navigation-android/pull/5312

