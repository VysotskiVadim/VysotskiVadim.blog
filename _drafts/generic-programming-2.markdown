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
* Generics slows down compilation.;
* Absolutely not helpful compiler error messages;
* You can't reuse generic binary, only source code; 
* Hard to validate: to make sure it works with type you need to test it with that type.

What about variance? **TODO: add examples**

## Java

Java type system is based on reference and value types. 
Objects are reference type, they are allocated in heap, and you work with them via reference. 
Value types are data primitives which allocated on stack(local variable) or heap(class field).
Before generics were introduced all generic code was written via cast to any base type.
For example class `Object` is the parent of all types, i.e. you can cast anything to it.
Or if you want to call some method in generic code you can cast them to base interface.

```java
static Comparable unsafeMax(@NotNull Comparable first, @NotNull Comparable second) {
    if (second.compareTo(first) > 0) {
        return second;
    }
    return first;
}
```
And the usage is:
```java
Integer first = 5;
Integer second = 7;
Integer dangerResult = (Integer) unsafeMax(first, second);
```

The main issue in given example is **unsafe** type cast. 
Every time you call `max` function you have to cast result back,
i.e. it's a chance to make a mistake which you'll find in run time.
It's not why people select strongly typed language.

When you work with reference types JVM doesn't really cares about object type.
```javabytecode
L0
 ICONST_5
 INVOKESTATIC java/lang/Integer.valueOf (I)Ljava/lang/Integer;
 ASTORE 1
L1
 BIPUSH 7
 INVOKESTATIC java/lang/Integer.valueOf (I)Ljava/lang/Integer;
 ASTORE 2
L2
 ALOAD 1
 ALOAD 2
 INVOKESTATIC Main.unsafeMax (Ljava/lang/Comparable;Ljava/lang/Comparable;)Ljava/lang/Comparable;
 CHECKCAST java/lang/Integer
 ASTORE 3
```

Generics were introduced in Java 5.0. 

## C#

## Kotlin

https://kotlinlang.org/docs/reference/inline-functions.html#reified-type-parameters

## Swift