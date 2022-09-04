---
layout: post
title: "Slow unit tests: static mocking"
date: 2022-09-04 11:00:00 +0200
image: /assets/slow-down.jpg
description: "What does make unit tests slow? Is it static mocking? Mockk vs Mockito."
postImage:
  src: slow-down
  alt: A slow down sign
linkToGithubText: "See the full file on the Github."
twitterLink: https://twitter.com/VysotskiVadim/status/1532672644809732098
---
## Intro

You're reading the second article where I explore slow unit tests.
Every article from the "Slow unit test" series explore one aspect.

This time I will measure static mocking.
I will use two mocking libraries: Mockk and Mockito.
The way I measured is described in the [Measurements section](#measurements).

How do you think, who's going to be faster: Mockk or Mockito?
Make your bet and find the answer in the article!


{% include slow-unit-tests-articles-list.markdown %}

## Baseline

I will use the same baseline: two unit tests which check `2+2`:

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

You can run both tests in **1.8** milliseconds. 
I will add static mocking and we will see if tests become slower.

Why do test have some letter in the begining?
The first letter in test names makes the execution order predictable.
All test classes in examples are marked with `@FixMethodOrder(MethodSorters.NAME_ASCENDING)`, so JUnit runs tests in alphabetical order. 

## Mockito

Here's a static function which adds two numbers:
```kotlin
fun plus(a: Int, b: Int) = a + b
```

Let's mock unrealistic answer using Mockito:

```kotlin
inline fun mockPlus(block: () -> Unit) {
    Mockito.mockStatic(::plus.declaringKotlinFile.java).use {
        it.`when`<Int> { plus(2, 2) }.thenReturn(5)
        block()
    }
}
```
Mockito replaces a real implementation of `plus` by a mock which always returns 5 when you add 2 to 2.
After adding the mock, the following the test passes:

```kotlin
@Test
fun `a - two + two`() {
    mockPlus {
        assertEquals(5, plus(2, 2))
    }
}
```

### How fast is Mockito's static mocking?

```kotlin
@Test
fun `a - two + two`() { // 1235ms
    mockPlus {
        assertEquals(5, plus(2, 2))
    }
}

@Test
fun `b - two + two copy 1`() { // 1.4ms
    mockPlus {
        assertEquals(5, plus(2, 2))
    }
}
```

The result is similar to the object mocking:
first mocking is slow, sequential mocking is fast.

### Static mocking vs real implementation on big numbers

What if you call a static function really often in your tests?

```kotlin
@Test
fun `dc - two + two 10000 times`() { // 299.2ms
    mockPlus {
        repeat(10000) {
            assertEquals(5, plus(2, 2))
        }
    }
}

@Test
fun `e - two + two 10000 times no static mocking`() { // 2.6ms
    repeat(10000) {
        assertEquals(4, plus(2, 2))
    }
}
```

Wow, real implementation is more than 100 times faster!

### Mockito summary

How does Mockito affect a big test suites?
Imagine you have 1000 unit tests.
The execution time is going to be ~ 1235ms + 999 * 1.4 ms = **2.6** seconds.
The test suite could have taken 0.2 seconds to execute without any mocking. But does it make a big difference for you?

## Mockk



## Summary


{% include slow-unit-tests-articles-list.markdown %}

{% include slow-unit-tests-measurements.markdown %}

## Links
* [Post image](https://www.flickr.com/photos/88158306@N03/45968616764/)
* [Mockito](https://github.com/mockito/mockito-kotlin)
* [Mockk](https://mockk.io/)
* [Examples](https://github.com/VysotskiVadim/slow-unit-tests)