---
layout: post
title:  "Generic Programming - Introduction"
date:   2019-10-01 12:00:00 +0300
postImage:
  src: Asteracea_poster_3
  alt: Types of Asteraceaes
---

Generic programming makes developers' life easier by allowing us to
write code once and reuse across different types in typesafe manner.
The majority of strongly typed languages support generic programming.
You're probably already familiar with the *generic programming* term,
and know that there are some tricky parts, like variance, which is quite hard to understand.
But you need that understanding to write complex systems like an expert.

It's time to take one step back and start from the very begging to build a proper understanding.
Don't worry, it won't take long but will be rewarding in your development career. 

You're reading **Part 1 - Introduction**.
In this post, we'll figure out what is generic programming and
find out via simple examples what is covariance and contravariance.

If you're confident about your theory understanding, you can go directly to
[overview of different implementations of generic programming in Part 2]({% post_url 2019-11-29-generic-programming-part-2-implementation-overview %}). 

## Introduction

According to the [Wikipedia](https://en.wikipedia.org/wiki/Generic_programming):

> Generic programming is a style of computer programming in which algorithms are written in terms of types to-be-specified-later that are then instantiated when needed for specific types provided as parameters. 

What does it mean? Let's consider example: function which takes 2 arguments and returns max of them. Code was written using strongly typed language (java)

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

Create function per type? That's sucks! This is **not generic programming**: every implementation of `max` function can be called with only one specific type. And implementation for every type looks just the same!

Here generic programming comes. Let's recap definition -- *algorithms are written in terms of types to-be-specified-later*, i.e. we implement algorithms and don't specify specific types during implementation: 

```java
static <T extends Comparable<T>> T max(@NotNull T first, @NotNull T second) {
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

One implementation that works with all types(which extends `Comparable` of course). That what is Generic programming about -- writing algorithms and data structures which can work with different types.

In weekly typed languages you use generic programming out of the box, for example implementation of `max` function in JavaScript looks like

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

But what to do if you use strongly typed language? Well, it depends on chosen language. In the next post we'll consider popular nowadays strongly typed languages: C++, Java, C#, Kotlin, Swift, TypeScript.

For every considered language we will answer following questions:
* How does generics work under the hood?
* How did migration to generic happen(if actual)?
* Variance(*don't be afraid of term, explanation will follow*)
* Pros and Cons

## Variance

But before we start discovering different languages it worth understanding what variance is, because it's very important in context of generic programming and strongly typed languages.

Many developers use strongly typed languages in order to set some constrains on code, which leads to decreasing amount of runtime errors. I.e. compiler should not compile code which will cause runtime errors *(of course compiler can't prevent all errors, but for some cases it's obvious at compile time that it will fail at runtime)*. You've got the point -- ***compiler shouldn't allow you shoot in your own leg***.

```java
class Flower {  }
class Rose extends Flower { }
class Daisy extends Flower { }
```

There is simple class hierarchy: `Rose` and `Daisy`, each of them is `Flower`.

Term **variance** refers to how generic classes which use different generic parameters relates to each other,
in other words **variance** answers to the question of when an instantiation of a generic class can be a subtype of another class.

For instance if `Rose` is a subclass of `Flower` then I should be able to substitute `Flower` by `Rose`. Is it applicable to generic code?
Variance refers to questions like "Can I use a list of `Rose` as a list of `Flower`?".
```java
List<Flower> bouquet = new ArrayList<Rose>();
```
When somebody asks *"What about variance in language X?"*, he would like to know how can he cast generic classes with different generic parameters to each other. Usually there are some kinds of limitations in casting. Compiler won't let you shoot in your own leg, remember? With different limitations we have 4 types of variance:
* Covariance
* Contravariance
* Bivariance
* Invariance

We will consider 2 of them: co and contra variance. To make it fun let's do it by journey: you need to get a flower to gift it to a pretty girl.

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
FlowerShop<? extends Flower> tellMeShopAddress() {
    return new RoseShop();
}
```

Yep, `Rose` is `Flower`, if you need a flower you can go to `RoseShop` and buy flower there.

```java
// Warning: it's pseudocode, won't compile 
FlowerShop<Flower> shop = tellMeShopAddress();
Flower flower = shop.getFlower();
```

We have just considered example of **Covariance** - you are allowed to cast `A<C>` to `A<B>`, where `C` is a subclass of `B`, if `A` **produces** generic values *(returns as a result from the function)*. Covariance is about **producers**.

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
PrettyGirl<? super Rose> girlfriend = new AnyFlowerLover();
girlfriend.takeGift(new Rose());
```
Yes, if she likes all flowers she will like rose.

But when your girlfriend likes daisies, you can't consider her as somebody who loves flower -- she likes only daisies!
```java
// Warning: won't compile 
PrettyGirl<Flower> girlfriend = DaisyLover();
girlfriend.takeGift(new Rose()); // she won't like it!
```

We have just considered an example of **Contravariance** - you're allowed to cast `A<B>` to `A<C>`, where `C` is subclass of `B`, if `A` consumes generic value.
Contravariance is about **consumers**.

## What is next?

Nice! We've done with the idea of generic programming.
I hope it was understandable and enjoyable for you.
If wasn't please leave feedback or question in the comments.
Now you're ready to see [different implementations of generic programming in the Part 2]({% post_url 2019-11-29-generic-programming-part-2-implementation-overview %}). 