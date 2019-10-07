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

What about variance? 

## Java

## C#

## Kotlin

https://kotlinlang.org/docs/reference/inline-functions.html#reified-type-parameters

## Swift