---
layout: post
title:  "Generic Programming - Implementation Overview"
date:   2019-10-07 12:00:00 +0300
---


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

Word **Template** reveals how does language feature work under the hood. Implemented function is just a template for compiler, which generates new functions for every type template is used with.

So If you use `max` function like this:
```cpp
cout << "int " << generic::max(1, 2) << ", char " << generic::max('a', 'b');
```
under the hood compiler generates 2 functions:

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
Approach from C++ the most understandable for developers, it's easy to imagine how code would work if you replace generic parameter with the specific type.
It's really easy work with generic types - you can do what ever you want with them, all type checks take place after code generation phase, just write code so that it compile with specific type you use it with.

But generics aren't really popular in C++ world. It's too many disadvantages:
* Generics slows down compilation;
* Absolutely not helpful compiler error messages;
* You can't reuse generic binary, only source code; 
* Hard to validate: to make sure it works with type you need to test it with that type.

What about variance?
As I sad before C++ templates very intuitive:
there is just code generation behind it.
What kind of variance will it be if you write the same class or function using different types.
**Invariance**.
There is no relationships between generated classes and functions.

But since C++ 17 std library supports co and contravariance via `std::function`.
Functions produces are covariant, functions consumers are contravariant.

## Java

Java type system is based on reference and value types.
Any objects are reference type, they are allocated in the heap, and you work with them via reference.
Value types are data primitives which allocated on the stack(local variable) or heap(class field).
If you use Java most of the time you work with reference types.

Feature **generics** [was released in Java 5](https://en.wikipedia.org/wiki/Java_version_history#J2SE_5.0) in September 2004.
Java had been existing for more then 8 years.
It was a lot*(I mean really a lot!)* of code written since java became popular.

How did people live without generics?
You can cast objects to the same base class or interface and then pass them to function.

```java
static Comparable unsafeMax(@NotNull Comparable first, @NotNull Comparable second) {
    if (second.compareTo(first) > 0) {
        return second;
    }
    return first;
}
```

Generics in Java implemented like compile time feature: generics aren't present in Bytecode.
On Bytecode level you're just working with `Object`.
But when you use generics compiler checks types and you don't have to use explicit cast.
The process when compiler doesn't leave any meta information about generics also called **type erasure**.

```java
static <T extends Comparable<T>> T max(@NotNull T first, @NotNull T second) {
    if (second.compareTo(first) > 0) {
        return second;
    }
    return first;
}

static void main(String[] args) {
    Integer first = 5;
    Integer second = 7;
    Integer dangerResult = (Integer) unsafeMax(first, second);
    Integer result = max(first, second);
}
```

In examples above we have 2 implementations of `max` function: generic(`max`) and not generic(`unsafeMax`).
As you can see at Java Bytecode level they are the same.

*If you feel terrified when you see Java Bytecode, learn it in 47 minutes on [youtube](https://www.youtube.com/watch?v=e2zmmkc5xI0).*

Here how `max` function calls `Comparable<T>.compareTo`:
```bytecode
static max(Ljava/lang/Comparable;Ljava/lang/Comparable;)Ljava/lang/Comparable;
    ALOAD 1
    ALOAD 0
    INVOKEINTERFACE java/lang/Comparable.compareTo (Ljava/lang/Object;)I (itf)
```

And here how `unsafeMax` calls `Comparable.compareTo`:
```bytecode
static unsafeMax(Ljava/lang/Comparable;Ljava/lang/Comparable;)Ljava/lang/Comparable;
    ALOAD 1
    ALOAD 0
    INVOKEINTERFACE java/lang/Comparable.compareTo (Ljava/lang/Object;)I (itf)
```

And here how they are called in `main` function:
```bytecode
L2
    ALOAD 1
    ALOAD 2
    INVOKESTATIC Main.unsafeMax (Ljava/lang/Comparable;Ljava/lang/Comparable;)Ljava/lang/Comparable;
    CHECKCAST java/lang/Integer
    ASTORE 3
L3
    ALOAD 1
    ALOAD 2
    INVOKESTATIC Main.max (Ljava/lang/Comparable;Ljava/lang/Comparable;)Ljava/lang/Comparable;
    CHECKCAST java/lang/Integer
    ASTORE 4
L4
```

No difference at Bytecode level.

Java Runtime Environment is shipped with a lot of useful packages.
As you remember generics were released in Java 5, more then 8 years passed since Java release.
So many built-in classes was rewritten using generics feature, for example `ArrayList` became `ArrayList<T>`.
To achieve compatibility with already written not generic code Oracle's engineers added feature **raw types**.
When you use generic type as not generic, for example `ArrayList` instead of `ArrayList<T>`
compiler treats it like `ArrayList<Object>`.

As you can see all C++ templates disadvantages which we mentioned above have been solved.
Compiler produce only one function or class for all possible generics parameter,
where all generics types are `Object`, so:
* no noticeable compilation slowdown;
* you are able to use generic code from binary(Bytecode);
* compilation error messages don't come from generated code, so they're understandable;
* easy validation: if code works for one type, then it would work for others.

But there is still some disadvantages.

* Generics code works only for reference types.
It means that you can't use `Map<integer>`, only `Map<Integer>`.
I.e. in order to pass `integer` to generic code you have to box in object `Integer`;
* Because of type erasure you can't get via reflection which typed used as generic parameter.


## C#

## Kotlin

https://kotlinlang.org/docs/reference/inline-functions.html#reified-type-parameters

## Swift