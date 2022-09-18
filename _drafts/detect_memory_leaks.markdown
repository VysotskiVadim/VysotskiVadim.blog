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
Even if an application leaks a little memory, it usually don't cause crash with out of memory exception (OOM).

Some Android applications do live long.
I had a case with navigation app that uses [Mapbox Navigation SDK](https://github.com/mapbox/mapbox-navigation-android).
The app was always in foreground, it was restarted only together with OS.
Small memory leak can cause OOM after a day, or week, or month.
How to detect a small memory leak if it can reveal itself only after a month?

## Detect memory leak

Small memory leak makes memory grow over time.
Constant memory grow for a long period means that it's just a question of time for an application to run out of memory.
The short answer is detect those small constant grow.

It's easier to say "detect constant memory grow" than to do it.
I had to spend 2 days to figure how to do this.


## Record long traces

Android studio has a built-in profile.
I can just record memory trace, can't it?
You can, but not for a long time.
Android Studio becomes completely unresponsive after a few hours of recording.

[Android supports system's trace recording since version 9](https://developer.android.com/topic/performance/tracing/on-device).
Your phone don't even need to be connected to the PC.
You can use the phone anywhere while trace is being captured.

Prepare your phone for long traces.
Make sure it has some available space in memory.
Increase max trace size and length.
Record only memory-related activities to reduce trace file size.

Feel free to split trace in a few files.
Stop recording and start it again.
I will show you later how to work with a few traces.

### Analyze trace

Phone records perfetto trace.
You can open in web trace viewer.

The trace has quite a lot of data.
How to find memory usage there?


