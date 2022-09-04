---
layout: post
title: "Slow unit tests: static mocking"
date: 2022-09-04 11:00:00 +0200
image: /assets/slow-down.jpg
description: "What does make unit tests slow? Is it static mocking?"
postImage:
  src: slow-down
  alt: A slow down sign
linkToGithubText: "See the full file on the Github."
twitterLink: https://twitter.com/VysotskiVadim/status/1532672644809732098
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


## Summary


{% include slow-unit-tests-articles-list.markdown %}

{% include slow-unit-tests-measurements.markdown %}

## Links
* [Post image](https://www.flickr.com/photos/88158306@N03/45968616764/)
* [Mockito](https://github.com/mockito/mockito-kotlin)
* [Mockk](https://mockk.io/)
* [Examples](https://github.com/VysotskiVadim/slow-unit-tests)