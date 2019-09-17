---
layout: post
title:  "Generic Programming"
date:   2019-09-15 12:00:00 +0300
---

According to [Wikipedia](https://en.wikipedia.org/wiki/Generic_programming):

> Generic programming is a style of computer programming in which algorithms are written in terms of types to-be-specified-later that are then instantiated when needed for specific types provided as parameters. 

i.e. you're adding one more layer of indirection: abstraction over concrete types in algorithms or data structures.

For example you'd like to create function which returns max element:

```js
function max(first, second) {
    if (first > second) {
        return first
    }
    return second
}
```
As you can see in JavaScript, as well as in any other week typed language, Generic Programming works out of the box: now we can use `max` function for any type

```js
max(5, 2) // returns 5
max("a", "d") // returns "d"
```

But what to do if you are using strong typed language? Well, different programming languages faced generic programming using different techniques. In post we consider popular now day strong typed languages. In week typed languages generic programming works without any effort, so we won't review them.

For every considered language we will answer following questions:
* How does it work under the hood?
* How did migration to generic happen(if actual)?
* How Variance works?
* What about known issues?

## Go

## C++

## Java

## C#

## Kotlin

## Swift