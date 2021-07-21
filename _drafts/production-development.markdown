---
layout: post
title: "Production development"
date: 2021-07-15 12:00:00 +0300
image: /assets/Asteracea_poster_3_part_2.jpg
description: "A story of how a young developer learned to write production code"
postImage:
  src: Asteracea_poster_3_part_2
  alt: Types of Asteraceaes
---

everything could happen when you have enough users. 

I prefer sealed classes as a result everywhere. Otherwise it's hard to think what can happen.

Checklist
* Component with lifecycle
    * what if component is destroyed when asynchronous operation is in progress
    * how does component restore its state after recreation 
* Network\Filesystem any call can fail. Only RAM is reliable enough.
