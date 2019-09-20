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

Create function per type? That's sucks! This is **not generic programming**: every implementation of `max` function can be called with only one concrete type. And implementation for every type looks just the same!

Here generic programming comes. Let's recap definition -- *algorithms are written in terms of types to-be-specified-later*, i.e. we implement algorithms and don't specify concrete types during implementation: 

```java
public static <T extends Comparable> T max(T first, T second) {
    if (second.compareTo(first) > 0) {
        return second;
    }
    return first;
}
```
Types are specified during usage:
```java
max(12.4, 11.5); // returns 12.4
max("ab", "abc"); // returns "abc"
```

One implementation that works with all types(which extends `Comparable` of course). That what is Generic programming about -- writing algorithms and data structure which can work with different types.

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

C++ supports generic programming via feature called [Template](https://en.wikipedia.org/wiki/Template_(C%2B%2B)):

```cpp
namespace generic {
    template <typename T>
    T max(T first, T second) {
        if (second > first) {
            return second;
        }
        return first;
    }
}
```

Word **Template** really reveals how does language feature work under the hood. Implemented function is just a template for compiler, which generates new functions for every type template is used with.

So If you use `max` function like this:
```cpp
cout << "int " << generic::max(1, 2) << ", char " << generic::max('a', 'b');
```
Compiler will generate 2 functions:

```cpp
int max(int first, int second) {
    if (second > first) {
        return second;
    }
    return first;
}

char max(char first, char second) {
    if (second > first) {
        return second;
    }
    return first;
}
```
Approach from C++ the most understandable for developers: 

## Java

## C#

## Kotlin

https://kotlinlang.org/docs/reference/inline-functions.html#reified-type-parameters

## Swift