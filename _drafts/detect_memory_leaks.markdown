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

Download the trace from phone and open it in perfetto trace viewer.
So much data!
Where is memory usage?
Find your process, then look for for RSS.
RSS is a physical memory used by process.
Read this to know more about other value.

Do you see a memory leak there?
I don't.
Are you confident enough to say that the process doesn't leak memory.
I don't trust my human's eyes in this question.
How to get a serious prove that there're no memory leak?

Perfetto provide instruments for trace analysis.
I'm going to use queries and batch processor.

Based on examples and docs I built a following query to receive RSS over time:
```sql
select * from TODO
```

I've been recording a trace for 36 hours.
I split it in a few files. 
To split traces in a few files, just stop and start recording again.
Batch processing let me process a few traces in parallel.

I open all traces from the folder and request memory usage over time from each of them.

Then contact memory usage from different files and order by time.

Now I can build a chart with memory usage.

Despite custom chard is more convinient then perfetto trace viwer, it's still not obvious if memory leaks is there.

I build a trendline of memory.
It reveal how memory usage changes over time.

Not it's clear that there are no memory leak.
Trend line is flat after 36 hours.