---
layout: post
title: "Slow unit tests: objects mocking."
date: 2022-06-03 11:00:00 +0200
image: /assets/slow-down.jpg
description: "What does make unit tests slow? Is it objects mocking?"
postImage:
  src: slow-down
  alt: A slow down sign
linkToGithubText: "See the full file on the Github."
---
## Intro

I work with a test suite that could have been executed in seconds but it is executing for 20 minutes.
What does make it so slow?
This is the question I'm trying to answer.

I measured different factors that could slow tests down in isolation.
Those numbers will help you understand how different decisions affect the execution time of your test suite. The way I measured is described in the [Measurements section](#measurements).

I did quite a lot of experiments and measurements.
It would be uncomfortable to read everything in one article.
I split the whole material into a few parts.
You're reading part one that is focused on objects mocking.

{% include slow-unit-tests-articles-list.markdown %}

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

**1.8** milliseconds. The first test always takes a bit more time.
Let's use those numbers as a baseline.
I will try adding different test doubles and libraries to see what can slow tests down.

The first letter in test names makes the execution order predictable.
All test classes in examples are marked with `@FixMethodOrder(MethodSorters.NAME_ASCENDING)`, so JUnit runs tests in alphabetical order. 

## Regular objects

How logs does it take to run two tests which operate with a real object?

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

**2.2** milliseconds. With respect to the [accuracy of the measurement](#measurements), the results are the same as in the [baseline](#baseline)

Subs and Fakes are classes that developers write manually for tests,
i.e. they are simple objects.
They don't slow tests down.

## Mock

How long does it take to run tests which use a mock?
There're many different mocking libraries.
I measured two I used at work: [Mockito](https://github.com/mockito/mockito-kotlin) and [Mockk](https://mockk.io/).

### Mockito

#### Small objects

Mocks have a more complex behavior than real objects.
We'll explore mocks using 2 interfaces that represent math operations.

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

You need **447.4** milliseconds to run 2 tests that use Mockito.
It's 248 times slower than the baseline!
The whole test suite of 5 tests is executed for 462.6 milliseconds.

Test `a` was the slowest - 446.8 milliseconds.
Mockito initializes when you create a mock for the first time.
The initialization happens 1 time per test run, no matter how many tests you have, 1 or 10000.

Tests `b` and `c` are as fast as the baseline.
Mockito doesn't slow tests down when you mock the same class for a second time or verify a behavior.

Test `d` took a bit more time than the baseline - 13.6 milliseconds.
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
Compare mocking a small object 13 ms vs mocking a new activity ~250 ms.
Mocking the same activity for a second time is as fast as the baseline.

#### Summary
Mockito slows you down whenever you mock a type for the first time.
The more complex class is, the more time it takes to mock.
The time Mockito takes doesn't seem critical even for a large core base.
1000 unit tests * 250ms = 4 minutes.

### Mockk

The same tests with a different mocking library.

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
It's 4.2 times slower than Mockito and 1065 times slower than the baseline.

Mockk is similar to Mockito in many aspects:
* The first usage is the slowest - 1915 ms;
* A second mocking of the same class is fast - 13 ms;
* Every time you mock a new class it's a bit slower - 39 ms;

The difference between Mockk and Mockito is that Mockk's verify slows a test down - 11.6 ms.
The slow down happens every time you verify the behavior of a new object, the second verification is fast.

Let's check the speed of mocking for different objects from the Android Framework.

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

At the first glance, it seems that Mockk is slower than Mockito.
But Mockk was faster in `c - create activity 2`.
If you mock many different activities, the whole test suite can run faster with mockk.

How much does Mockk affect test execution speed?
Imagine you have 1000 tests where you mock new Activities.
1000 tests * 41.8 ms = 42 seconds of execution.

## Summary

Objects mocking does slow unit tests down.
Active mocking can make your test suite execute for a few minutes.
But mocking doesn't seem like the main contributing factor in the 20 minutes I have.

When I work in the TDD cycle I find even 20 seconds of slow down annoying.
I enjoy working with a test suite that executes in less than a second.
The faster your tests are, the more often you run them.
The more often you run tests, the quicker you detect a regression.
The quicker you detect a regression, the easier it is for you to fix the regression.

I will measure other factors in the next articles.
Stay tuned.

{% include slow-unit-tests-articles-list.markdown %}

## Measurements

I run each test 5 times from Android Studio and gathered execution times in [the table](https://docs.google.com/spreadsheets/d/e/2PACX-1vQb3HN-M4jj417zp1hl77S2at7_3YUfbdMFZhpWLRjVKRBlRFmibZDS8KDidZlMmEBVuQ990FltpSv8/pubhtml) and calculated an average time.
The numbers you've seen in the article are the average execution time of several tries.

Android Studio's UI displays time in milliseconds.
I don't know how exactly Android Studio rounds numbers.
I.e what does it show if the result is 1.5 or 1.7?
It can either show 2 or 1.
Let's assume Android Studio rounds in the worst way for measurement - takes only an integer part of a number, i.e. 1.7 displays as 1.
The expected measurement accuracy is ±0.9 milliseconds then.

See versions of the libraries in the [gradle file](https://github.com/VysotskiVadim/slow-unit-tests/blob/main/app/build.gradle#L40).

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
* [Mockito](https://github.com/mockito/mockito-kotlin)
* [Mockk](https://mockk.io/).