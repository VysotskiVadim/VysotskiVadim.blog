---
layout: post
title:  "Generic Programming"
date:   2019-09-15 12:00:00 +0300
---

There is a lot of different strongly typed languages that supports generic programming. They faced the same set of challenges but solved it in different time using different methods with different pros and cons. I find it fascinating, so I have to blog about it. But before we start it's worth to recap everything we know about generic programming in general. You're reading **Part 1 - Introduction**.

## Introduction

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

But what to do if you use strong typed language? Well, it depends on chosen language. In next post we'll consider popular now day strong typed languages: C++, Java, C#, Kotlin, Swift, TypeScript.

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

For example if `Rose` is subclass of `Flower` then I should be able to substitute `Flower` by `Rose`. Is it applicable to generic code?
Variance releates to questions like "Can I use list of `Rose` as a list of `Flower`?".
```java
List<Flower> bouquet = new ArrayList<Rose>();
```
When somebody ask "What about variance in language X?", he would like to know how can he cast generics classes with different generic parameters to each other. Usually there is some kinds of limitations in casting. Compiler won't let you let you shoot in your own leg, remember? With different limitations we have 4 types of variance:
* Covariance
* Contravariance
* Bivariance
* Invariance

We will consider 2 of them: co and contra variance. To make it fun let's do it by journey: you need to get a flower to gift it to pretty girl.

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

We have just considered example of **Covariance** - you are allowed to cast `A<C>` to `A<B>`, where `C` is subclass of `B`, if `A` **produces** generic values *(returns as a result from the function)*. Covariance is about **producers**.

### Contravariance 

Okay, now step 2 - present flower to a pretty girl:

```java
interface PrettyGirl<TFavouriteFlower extends Flower> {
    void takeGift(TFavouriteFlower flower);
}
```
Depending on her personal taste she could love different flowers:

```java
class AnyFlowerLover implements PrettyGirl<Flower> {
    @Override
    public void takeGift(Flower flower) {
        System.out.println("I like all flowers!");
    }
}

class DaisyLover implements PrettyGirl<Daisy> {
    @Override
    public void takeGift(Daisy flower) {
        System.out.println("wow, daisy, it's my favourite!");
    }
}
```

If your girlfriend likes all kinds of flowers and you gift her a rose, would it be okay?

```java
// Warning: it's pseudocode, won't compile 
PrettyGirl<Flower> girlfriend = AnyFlowerLover();
girlfriend.takeGift(new Rose());
```
Yes, if she likes all flowers she will like rose.

But when your girlfriend likes daisies, you can't consider her as somebody who loves flower -- she likes only daisies!
```java
// Warning: it's pseudocode, won't compile 
PrettyGirl<Flower> girlfriend = DaisyLover();
girlfriend.takeGift(new Rose()); // she won't like it!
```

We have just considered example of **Contravariance** - you're allowed to cast `A<B>` to `A<C>`, where `C` subclass of `B`, if `A` consumes generic value.
Contravariance is about **consumers**.

## To be continued

In next post I will blog about generic programming implementation in different languages. Follow me on twitter and you won't miss next part!