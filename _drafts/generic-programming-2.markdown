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

Java supports both co and contravariance via language feature called bounded wildcards.

TODO: what is unbounded wildcard?

```java
class A {}
class B extends A {}
class C extends B {}
class D extends B {}
```

If you want to use covariance you should specify *upper bound* like `extends T`:
```java
List<? extends B> listOfB;
listOfB = new ArrayList<C>(); // fine
listOfB = new ArrayList<D>(); // fine
listOfB = new ArrayList<A>(); // compilation error
```
`List` has many methods, some of them produces and some of them consumes generic values.
When you specify `extends T` you can use only methods producers:
```java
B b = listOfB.get(0); // fine
listOfB.add(new B()); // compilation error
```

If you want to use contravariance you should specify *lower bound* like `super T`:
```java
List<? super B> listOfB;
listOfB = new ArrayList<A>(); // fine
listOfB = new ArrayList<C>(); // won't compile
```
When you specify `super T` you can use only methods consumers:
```java
listOfB.add(new D()); // fine
B b = listOfB.get(0); // won't compile
```
In Java developers specify wildcards at the place of usage, it called *use-site variance*. 

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
* Because of type erasure you can't get at runtime any info about generics parameters;
* It's kind of consequence of previous point, but it's worth to mention as disadvantage:
 Arrays don't work well with generics, for example you can't create generic array like `new E[]`;

Just a few words about Array and generics.
Arrays in Java are covariant and all type checks happens in runtime:
```java
Object[] objectArray = new Long[1];
objectArray[0] = "secretly I'm a String"; // Throws ArrayStoreException
```
You can't create arrays like `new E[]` because of runtime check in array and type erasure in generics.
Oracle couldn't change arrays in Java 5, so arrays and generics in Java is a bad mix.
If you interested you can find more info in "Effective Java" by Joshua Bloch.
In third edition chapter is called *Item 28: prefer lists to arrays*.

## C#

C# supports generics since version 2.0 - September 2005.
```cs
public static T max<T>(T first, T second) where T: IComparable<T> {
    if (second.CompareTo(first) > 0) {
        return second;
    }
    return first;
}

public static void Main() {
    var maxValue = max(3, 4);
}
```

As you can see Microsoft decided to support generics at runtime level, so all generics data are present in intermediate language
*(visit [.Net fiddle](https://dotnetfiddle.net/A9PW6r) to see full version of IL code)*:
```il
.method public hidebysig static !!T  max<(class [mscorlib]System.IComparable`1<!!T>) T>(!!T first,
                                                                                          !!T second) cil managed
  {
    IL_000a:  callvirt   instance int32 class [mscorlib]System.IComparable`1<!!T>::CompareTo(!0)
```


## Kotlin

https://kotlinlang.org/docs/reference/inline-functions.html#reified-type-parameters

## Swift