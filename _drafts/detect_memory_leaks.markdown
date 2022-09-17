---
layout: post
title: "Detect memory leaks"
date: 2022-09-17 12:00:00 +0300
image: /assets/Asteracea_poster_3_part_2.jpg
description: "Detect small memory leaks in Android applications."
postImage:
  src: Asteracea_poster_3_part_2
  alt: Types of Asteraceaes
---

## Introduction

Regular Android application doesn't live long.
Users switch between applications and OS kills unused applications.
Even if an application leaks a little memory, it usually don't cause crash out of memory (OOM).

Some Android applications do live long.
I had a case with navigation app that uses Mapbox Navigation SDK.
The app was always in foreground.
It restarts only together with OS.

Small memory leak can cause OOM after a day, or week, or month.
How to detect a small memory leak?
I don't want to wait a week to check if application crash with OOM.

## Detect memory leak

Small memory leak makes memory grow over time.
Constant memory grow over a long period means that it's just a question of time for an application to run out of memory.
The short answer is detect those constant grow.

It's easier to say "detect constant memory grow" do it.
I had to spend 2 days to figure how to do this having so many tools.

Android Studio's profiler won't help you.
It can record memory traces, but it can't record it for a long time.