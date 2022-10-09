---
layout: post
title: "Detect small memory leaks"
date: 2022-09-17 12:00:00 +0300
image: /assets/detect_memory_leak_image.jpg
description: "Detect small memory leaks in Android applications."
postImage:
  src: detect_memory_leak_image
  alt: Foam reveals a leak
---

## TLDR;

Story of how I wrote [perfetto trace analyzer](https://gist.github.com/VysotskiVadim/31a3de8fd38729f179750b9dfed689e3) to prove that [Mapbox Navigation SDK](https://github.com/mapbox/mapbox-navigation-android) doesn't leak memory in a certain scenario.

## Introduction

Regular Android application doesn't live long.
Users switch between applications and OS kills unused ones.
Even if an application leaks a little memory, it usually don't cause crash with out of memory exception (OOM).

Some Android applications do live long.
I had a case with navigator app that uses [Mapbox Navigation SDK](https://github.com/mapbox/mapbox-navigation-android).
The app was always in foreground, it was restarted only together with OS.
Small memory leak can cause OOM after a day, or a week, or a month.
How to detect a small memory leak if it can reveal itself only after a month?

## Detect memory leak

Small memory leak makes memory grow over time.
Constant memory grow for a long period means that it's just a question of time for an application to run out of memory.
The short answer is detect those small constant grow.

It's easier to say "detect constant memory grow" than to do it.
I had to spend 2 days to figure how to do this.


## Record long traces

Android studio can't record a long trace,
it becomes completely unresponsive after a few hours of recording.

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

Download the trace from the phone and open it in using [perfetto trace viewer](https://ui.perfetto.dev/).


Scroll the list and find find your process.
I usually press **ctrl+f** and write application package name.
Find RSS chart of the process, it is a physical memory used by a process.
Read [this](https://perfetto.dev/docs/case-studies/memory#linux-memory-management) to know more about other value.


<div style="overflow-x: auto;">
  <img
    height="54"
    width="3570"
    style="max-width: none"
    src="{{site.images.baseUrl}}/detect_memory_leak_rss_chart_perfetto.jpg"
    alt="RSS chart in perfetto UI">
</div>

I'm looking the the chart... and...
I don't know if there is a memory leak🥲

### Draw a chart

Let's try to draw a readable chart.
Perfetto provides instruments for trace analysis.
I'm going to use [queries](https://perfetto.dev/docs/analysis/trace-processor) and [batch processor](https://perfetto.dev/docs/analysis/batch-trace-processor).

Based on [examples](https://perfetto.dev/docs/data-sources/memory-counters#sql) and [docs](https://perfetto.dev/docs/analysis/sql-tables) I built a following query to receive RSS over time:
```sql
select c.ts / 1000000 as timestamp, c.value / 1000 as rss from counter as c left join process_counter_track as t on c.track_id = t.id left join process as p using (upid) where t.name like 'mem.rss' and p.name like '{packageName}' order by c.ts
```

I have 36 hours of traces.
I stopped and started recording again a few time to analyze intermediate result.
So it's not a single 36 hours trace, it's 3 traces around 12 hours each. 

Use [batch processor](https://perfetto.dev/docs/analysis/batch-trace-processor) to process a few traces in parallel.
Open all traces from the a folder with traces.

```python
files = glob.glob(f'{tracesFolder}/*.perfetto-trace')
if (len(files) == 0):
    print(f"no trace files found in {tracesFolder}")
    exit()


print("loading:" + ' '.join(files))
with BatchTraceProcessor(files) as btp:
```

Request memory usage over time from each of them.
```python
rssMemorySets = btp.query(f"select c.ts / 1000000 as timestamp, c.value / 1000 as rss from counter as c left join process_counter_track as t on c.track_id = t.id left join process as p using (upid) where t.name like 'mem.rss' and p.name like '{packageName}' order by c.ts")
```

Batch trace processor returns a list of results, 1 result per 1 file.
Contact memory usage from different files and order by time:

```python
rssMemory = pandas.concat(rssMemorySets)
rssMemory.sort_values(by=['timestamp'], inplace=True)
```

Draw a chart with memory usage.
```python
rssMemory.plot(x='timestamp', y='rss')
```

<div style="overflow-x: auto; margin-bottom: 30px">
  <img
    height="596"
    width="3986"
    style="max-width: none"
    src="{{site.images.baseUrl}}/detect_memory_leak_custom_chart.jpg"
    alt="RSS chart in perfetto UI">
</div>


That's better but... it's still arguable.
Some people may say that chart is okay, some may see a leak.
Does it look okay for you?

### Trend line

Liner trend line may suggest how a value is going to change in the future.
Let's draw it.

A linear function can be defined by the equation `y = b * x + c`.
[Polyfit function](https://numpy.org/doc/stable/reference/generated/numpy.polyfit.html) will help you find `b` and `c` for the trend line.
Pass your `x`(timestamp), `y`(memory), and 1 as a degree and you will get array of `b, c`.
If coefficient `b`(first element of array) is less than 0 trend line is decreasing, otherwise increasing.

```python
def drawTrendLine(dataFrame, xKey, yKey, color, label):
  ts = pandas.to_numeric(dataFrame[xKey])
  mem = pandas.to_numeric(dataFrame[yKey])
  coefficients = np.polyfit(ts, mem, 1)
  b = coefficients[0]
  print(f'{label} has coefficient {b:.20f}')
  p = np.poly1d(coefficients)
  plt.plot(ts, p(ts), color=color, label=label)
  plt.legend()
```

I see `rss trendline has coefficient -0.00000548365707914431` in the output.
It means that the trend line is flat.

<div style="overflow-x: auto; margin-bottom: 30px">
  <img
    height="596"
    width="3986"
    style="max-width: none"
    src="{{site.images.baseUrl}}/detect_memory_leak_custom_chart_with_tendline.jpg"
    alt="RSS chart in perfetto UI">
</div>


## So what?

See full script on .

Perfetto provides you great abilities for trace analysis.
Even if something isn't present out of the box, you can implement it on your own.

## Links

* [Full trace analyzer](https://gist.github.com/VysotskiVadim/31a3de8fd38729f179750b9dfed689e3)
* [Post image](https://flic.kr/p/FJgT4s)
* [perfetto](https://perfetto.dev/)
* [Record trace on device](https://developer.android.com/topic/performance/tracing/on-device)