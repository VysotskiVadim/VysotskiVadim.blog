---
layout: post
title: "Slow unit tests"
date: 2022-03-14 12:00:00 +0300
image: /assets/slow-down.jpg
description: "Slow your tests down in a few simple steps."
postImage:
  src: slow-down
  alt: A slow down sign
linkToGithubText: "See full file on github."
---
## Intro

I've seen a test suite which could have completed in seconds but was executing for 20 minutes.
What did make it so slow?
This is the question I'm trying to answer.


I measured different factors that could slow tests down in isolation.
This numbers help you understand how different decisions affect execution time of your test suite. The way I measured is described in the [Measurements section](#measurements).

## Baseline

How long does it take to run two tests which do almost nothing?

```kotlin
@Test
fun `a - baseline`() { // executes for 1.6 milliseconds
    assertEquals(4, 2 + 2)
}

@Test
fun `b - baseline copy`() { // executes for 0.2 milliseconds
    assertEquals(4, 2 + 2)
}
```

*[{{page.linkToGithubText}}](https://github.com/VysotskiVadim/slow-unit-tests/blob/main/app/src/test/java/dev/vadzimv/slowtests/Baseline.kt)*

**1.8** milliseconds. First test always takes a bit more time.
Let's use those numbers as a baseline.
I will try adding different test doubles and libraries to see what can slow tests down.

A first letter in tests name make the execution order predictable.
All tests classes are marked with `@FixMethodOrder(MethodSorters.NAME_ASCENDING)`, so JUnit runs tests in an alphabetical order. 

## Regular objects

How logs does it take to run two tests which operates with a real object?

```kotlin
interface Plus {
    fun doPlus(a: Int, b: Int): Int
}
```
*[{{page.linkToGithubText}}](https://github.com/VysotskiVadim/slow-unit-tests/blob/main/app/src/main/java/dev/vadzimv/slowtests/Math.kt)*

```kotlin
@Test
fun `a - two plus two`() { // executes for 2 milliseconds
    val plus = createPlus()
    assertEquals(4, plus.doPlus(2, 2))
}

@Test
fun `b - two plus two copy`() { // executes for 0.2 milliseconds
    val plus = createPlus()
    assertEquals(4, plus.doPlus(2, 2))
}

private fun createPlus() = object : Plus {
    override fun doPlus(a: Int, b: Int): Int = a + b
}
```

*[{{page.linkToGithubText}}](https://github.com/VysotskiVadim/slow-unit-tests/blob/main/app/src/test/java/dev/vadzimv/slowtests/Objects.kt)*

**2.2** milliseconds. With respect to the [measurements accuracy](#measurements), results are the same as in the [baseline](#baseline)

Subs and Fakes are classes that a developer write manually for tests,
i.e. they are simple objects.
They don't slow tests down.

## Mock

How long does it take to run tests which use a mock?
There're many different mocking libraries.
I measured two I used at work: [Mockito](https://github.com/mockito/mockito-kotlin) and [Mockk](https://mockk.io/).

### Mockito

#### Small objects

Mocks have a more complex behaviour than real objects.
I need more interfaces to mock to explore their behavior.

```kotlin
interface Plus {
    fun doPlus(a: Int, b: Int): Int
}

interface Minus {
    fun doMinus(a: Int, b: Int): Int
}
```
*[{{page.linkToGithubText}}](https://github.com/VysotskiVadim/slow-unit-tests/blob/main/app/src/main/java/dev/vadzimv/slowtests/Math.kt)*

```kotlin
@Test
fun `a - two plus two`() { // executes for 446.8 milliseconds
    val plus = createMockPlus()
    assertEquals(4, plus.doPlus(2, 2))
}

@Test
fun `b - two plus two copy`() { // executes for 0.6 milliseconds
    val plus = createMockPlus()
    assertEquals(4, plus.doPlus(2, 2))
}

@Test
fun `c - two plus two copy with verify`() { // executes for 1.2 milliseconds
    val plus = createMockPlus()
    assertEquals(4, plus.doPlus(2, 2))
    verify(plus) { plus.doPlus(2,2) }
}

@Test
fun `d - two minus two`() { // executes for 13.6 milliseconds
    val minus = createMockMinus()
    assertEquals(0, minus.doMinus(2, 2))
}

@Test
fun `e - two minus two copy 1`() { // executes for 0.4 milliseconds
    val minus = createMockMinus()
    assertEquals(0, minus.doMinus(2, 2))
}

private fun createMockPlus() = mock<Plus> {
    on { doPlus(2, 2) } doReturn  4
}

private fun createMockMinus() = mock<Minus> {
    on { doMinus(2, 2) } doReturn 0
}
```

*[{{page.linkToGithubText}}](https://github.com/VysotskiVadim/slow-unit-tests/blob/main/app/src/test/java/dev/vadzimv/slowtests/ObjectMockingMockito.kt)*

You need **447.4** milliseconds to run 2 tests which uses Mockito.
It's 248 times slower than the baseline!
Whole test suite of 5 tests executed for 462.6 milliseconds.

Test `a` was the slowest - 446.8 milliseconds.
Mockito initializes when you create a mock for the first time.
The initialization happens 1 time per test run, no matter how many tests you have, 1 or 10000.

Tests `b` and `c` are as fast as the baseline.
Mockito doesn't slow tests down when you mock something for a second time or verify a behavior.

The test `d` took a bit more time than the baseline - 13.6 milliseconds.
It created a mock for a new interface.
No tests had used an interface `Minus` before.
Mockito needs more time when it deals with a new type.

#### Big objects

How much time does Mockito need to create a mock of a new type?
It depends on the type.
See examples of different Android classes.

```kotlin
@Test
fun `a - warm up mockito`() { // executes for 436.8 milliseconds
    mock<Any>()
}

open class Activity1 : Activity()
open class Activity2 : Activity()

@Test
fun `b - create activity 1`() { // executes for 607 milliseconds
    val activity = mock<Activity1>()
}

@Test
fun `c - create activity 2`() { // executes for 274.6 milliseconds
    val activity = mock<Activity2>()
}

@Test
fun `d - create context`() { // executes for 57.8 milliseconds
    val context = mock<Context>()
}

@Test
fun `e - create context 2`() { // executes for 0.4 milliseconds
    val context = mock<Context>()
}

@Test
fun `f - create location`() { // executes for 34.2 milliseconds
    val location = mock<Location>()
}

@Test
fun `g - create location 2`() { // executes for 0.2 milliseconds
    val location = mock<Location>()
}
```

*[{{page.linkToGithubText}}](https://github.com/VysotskiVadim/slow-unit-tests/blob/main/app/src/test/java/dev/vadzimv/slowtests/AndroidClassesMockito.kt)*

It took more time to mock `Activity1` than `Activity2`: 607 vs 274 ms.
If you mock `Activity3`, `Activity4`, etc, each of them would take ~250 ms to initialize.
Compare mocking a new object 13 ms vs mocking a new activity ~250 ms.
Mocking the same activity for a second time is as fast as the baseline.

Summary.
Mockito slows you down whenever you mock a type for a first time.
The more complex class is, the more time it takes to mock.
The time Mockito takes doesn't seem critical even for a large core base.
1000 unit tests * 250ms = 4 minutes.

### Mockk

```kotlin
@Test
fun `a - two plus two`() { // executes for 1915.8 milliseconds
    val plus = createMockPlus()
    assertEquals(4, plus.doPlus(2, 2))
}

@Test
fun `b - two plus two copy`() { // executes for 1.2 milliseconds
    val plus = createMockPlus()
    assertEquals(4, plus.doPlus(2, 2))
}

@Test
fun `c - two plus two copy with verify`() { // executes for 11.6 milliseconds
    val plus = createMockPlus()
    assertEquals(4, plus.doPlus(2, 2))
    verify { plus.doPlus(2, 2) }
}

@Test
fun `d - two minus two`() { // executes for 39.6 milliseconds
    val minus = createMockMinus()
    assertEquals(0, minus.doMinus(2, 2))
}

@Test
fun `e - two minus two copy 1`() { // executes for 1.2 milliseconds
    val minus = createMockMinus()
    assertEquals(0, minus.doMinus(2, 2))
}

private fun createMockPlus() = mockk<Plus> {
    every { doPlus(2, 2) } returns 4
}

private fun createMockMinus() = mockk<Minus> {
    every { doMinus(2, 2) } returns 0
}
```

You need **1918** ms to run 2 tests if you mock using Mockk library.
It's 4.2 time slower than Mockito and 1065 time slower than the baseline.

Mockk is similar to Mockito in many aspects:
* A first usage is the slowest - 1915 ms;
* A second mocking of the same class is fast - 13 ms;
* Every time you mock a new class it's a bit slower - 39 ms;

The difference between Mockk and Mockito is that Mockk's verify slows a test down - 11.6 ms.
The slow down happens every time you verify behavior of a new object, the second verification is fast.

Let's check speed of mocking for different objects from Android Framework.

```kotlin
@Test
fun `a - warm up mockk`() { // executes for 966.8 milliseconds
    mockk<Any>()
}

open class Activity1 : Activity()
open class Activity2 : Activity()

@Test
fun `b - create activity 1`() { // executes for 676.6 milliseconds
    val activity = mockk<Activity1>()
}

@Test
fun `c - create activity 2`() { // executes for 41.8 milliseconds
    val activity = mockk<Activity2>()
}

@Test
fun `d - create context`() { // executes for 288.4 milliseconds
    val context = mockk<Context>()
}

@Test
fun `e - create context 2`() { // executes for 0 milliseconds
    val context = mockk<Context>()
}

@Test
fun `f - create location`() { // executes for 65.2 milliseconds
    val location = mockk<Location>()
}

@Test
fun `g - create location 2`() { // executes for 0.4 milliseconds
    val location = mockk<Location>()
}
```

Pattern is very similar to Mockito:
* First mocking ot a class slower than a second

From the first glance it seems that Mockk slower than Mockito.
Mockk was faster in `c - create activity 2`.
If you mock many different activities, whole test suite can run faster with mockk.

How much Mockk affects tests execution speed?
Imaging you have 1000 tests where you mock new Activities.
1000 tests * 41.8 ms = 42 seconds of execution.
Doesn't seem critical for me.

#### Static mocking



## Robolectric
## Coroutines
## Slowest test
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

See version of the libraries in the [gradle file](https://github.com/VysotskiVadim/slow-unit-tests/blob/main/app/build.gradle#L40).

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