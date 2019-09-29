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

But what to do if you use strong typed language? Well, it depends on chosen language. We'll consider popular now day strong typed languages: C++, Java, C#, Kotlin, Swift, TypeScript, Go. **//TODO: links?!**

For every considered language we will answer following questions:
* How does generics work under the hood?
* How did migration to generic happen(if actual)?
* Variance(*don't be afraid of term, explanation will follow*)
* Pros and Cons

## Variance

But before we start discovering different languages it worth to understand what variance is, because it's very important in context of generic programming and strong typed languages.

Many developers use strong typed languages in order to set some constrains on code, which leads to decreasing amount of runtime errors. I.e. compiler should not compile code which will causes runtime errors *(of course compiler can't prevent all errors, but for some cases it's obvious at compile time that it will fails at runtime)*. You've got the point -- ***compiler shouldn't allow you shoot in your own leg***.

```java
class Flower {  }
class Rose extends Flower { }
class Daisy extends Flower { }
```

There is simple class hierarchy: `Rose` and `Daisy`, each of them is `Flower`.

Term **variance** refers to how generic classes which use different generic parameters relates to each other. And we need to understand their relationships in order to do cast.

For example **Variance** refers questions like: Can I use list of `Rose` as a list of `Flower`?
```java
List<Flower> bouquet = new ArrayList<Rose>();
```

To answer we need to remember one of compilers purpose --  ***don't let you shoot in your own leg***. So let's consider how can we cast generic object safely.

We'll learn it by journey: you need to get a flower to give it to pretty girl.

### Covariance

Our task starts from getting flower. Let's go to a shop.

```java
interface FlowerShop<T extends Flower> {
    T getFlower();
}
```
And you have 2 flowers shop in your city:

```java
class RoseShop implements FlowerShop<Rose> {
    @Override
    public Rose getFlower() {
        return new Rose();
    }
}

class DaisyShop implements FlowerShop<Daisy> {
    @Override
    public Daisy getFlower() {
        return new Daisy();
    }
}
```

If you ask me where is the flower shop and tell you address of `RoseShop` would it be fine?

```java
// Warning: it's pseudocode, won't compile 
static FlowerShop<Flower> giveMeTheShop() {
    return new RoseShop();
}
```

Yep, `Rouse` is `Flower`, if you need a flower you can go to `RouseShop` and buy flower there.

```java
// Warning: it's pseudocode, won't compile 
FlowerShop<Flower> shop = giveMeTheShop();
Flower flower = shop.getFlower();
```

We have just considered example of **Covariance** - you are allowed to cast `A<C>` to `A<B>`, where `C` is subclass of `B`, if `A` **produces** generic values *(returns as a result from the function)*.

### Contravariance 

But when your girlfriend likes roses, you can't consider her as somebody who loves flower -- she likes only rouses! Pretty girl consumes flowers, so you can't cast `PrettyGirl<Rouse>` to `PrettyGirl<Flower>`.

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