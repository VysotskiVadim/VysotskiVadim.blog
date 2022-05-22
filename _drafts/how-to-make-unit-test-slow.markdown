---
layout: post
title: "Slow unit tests"
date: 2022-03-14 12:00:00 +0300
image: /assets/slow-down.jpg
description: "Slow your tests down in a few simple steps."
postImage:
  src: slow-down
  alt: A slow down sign
---
## Intro

I've seen a test suite which could have completed in seconds but was executing for 20 minutes.
What did make it so slow?
This is the question I'm trying to answer.


I measured different factors that could slow tests down in isolation.
This numbers help you understand how different decisions affect execution time of your test suite. The way I measured is described in the [Measurements section](#measurements).

## Baseline

How long does it take to run [two tests](https://github.com/VysotskiVadim/slow-unit-tests/blob/main/app/src/test/java/dev/vadzimv/slowtests/Baseline.kt) which do almost nothing?

```kotlin
@Test
fun baseline() { // executes for 1.6 milliseconds
    assertEquals(4, 2 + 2)
}

@Test
fun `baseline copy`() { // executes for 0.2 milliseconds
    assertEquals(4, 2 + 2)
}
```

**1.8** milliseconds. First test always takes a bit more time.
Let's use those numbers as a baseline.
I will try adding different test doubles and libraries to see what can slow tests down.

## Regular objects

How logs does it take to run [two tests](https://github.com/VysotskiVadim/slow-unit-tests/blob/main/app/src/test/java/dev/vadzimv/slowtests/Objects.kt) which operates with a real object?

```kotlin
val plus = object : Plus {
    override fun doPlus(a: Int, b: Int): Int = a + b
}

@Test
fun `two plus two`() { // executes for 2.2 milliseconds
    assertEquals(4, plus.doPlus(2, 2))
}

@Test
fun `two plus two copy`() { // executes for 0.2 milliseconds
    assertEquals(4, plus.doPlus(2, 2))
}
```

**2.4** milliseconds. With respect to the [measurements accuracy](#measurements), results are the same. Subs and Fakes, which are just classes developer write for tests, don't slow tests down.

## Mock

Consider a simple `Plus` object.

## Coroutines
## Static mocking
## Robolectric
## Combine
## Summary
## Measurements

I run each test 5 times from Android Studio and gathered execution times in [the table](https://docs.google.com/spreadsheets/d/e/2PACX-1vQb3HN-M4jj417zp1hl77S2at7_3YUfbdMFZhpWLRjVKRBlRFmibZDS8KDidZlMmEBVuQ990FltpSv8/pubhtml) and calculated average time.
The numbers you've seen in the article are average execution time of a several tries.

Android Studio's UI displays time in milliseconds.
I don't know how exactly Android Studio rounds numbers.
I.e what does it show if result is 1.5 or 1.7?
It can either show 2 or 1.
Let's assume Android Studio rounds in a worst way for measurement - takes only integer part of a number, i.e. 1.7 displays as 1.
Expected measurements accuracy is ±0.9 milliseconds then.

I run tests using following hardware:
```
  Model Identifier:	MacBookPro16,1
  Processor Name:	6-Core Intel Core i7
  Processor Speed:	2,6 GHz
  Number of Processors:	1
  Total Number of Cores:	6
  L2 Cache (per Core):	256 KB
  L3 Cache:	12 MB
  Hyper-Threading Technology:	Enabled
  Memory:	32 GB
```

## Links
* [Post image](https://www.flickr.com/photos/88158306@N03/45968616764/)