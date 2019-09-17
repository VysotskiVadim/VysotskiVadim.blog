---
layout: post
title:  "Generic Programming"
date:   2019-09-15 12:00:00 +0300
---

According to [Wikipedia](https://en.wikipedia.org/wiki/Generic_programming):

> Generic programming is a style of computer programming in which algorithms are written in terms of types to-be-specified-later that are then instantiated when needed for specific types provided as parameters. 

What does it mean? Let's consider example: function which takes 2 arguments and returns max of them. Code was written using strong typed language (java)

```java
public static int max(int first, int second) {
    if (second > first) {
        return second;
    }
    return first;
}
```
Ok, but what about floating point numbers?

```java
public static double max(double first, double second) {
    if (second > first) {
        return second;
    }
    return first;
}
```

Oh, so should I implement it for every type I use?! For me as developer code looks almost the same. It would be so nice to write code with one more layer of indirection: abstraction of concrete types. That what is Generic programming about -- writing algorithms and data structure which can work with different types.

In week typed languages you use generic programming out of the box, for example implementation of `max` function in JavaScript looks like

```js
function max(first, second) {
    if (second > first) {
        return second
    }
    return first
}
```
You can use `max` function for any type

```js
max(5, 2) // returns 5
max("a", "d") // returns "d"
```

But what to do if you use strong typed language? Well, it depends on chosen language. We'll consider popular now day strong typed languages: Go, C++, Java, C#, Kotlin, Swift. **//TODO: links?!**

For every considered language we will answer following questions:
* How does generics work under the hood?
* How did migration to generic happen(if actual)?
* Variance(*don't be afraid of term, explanation will follow*)
* Pros and Cons

## Go

https://stackoverflow.com/questions/3912089/why-no-generics-in-go

## C++

## Java

## C#

## Kotlin

## Swift