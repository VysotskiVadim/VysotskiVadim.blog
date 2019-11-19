---
layout: post
title:  "Generic Programming - Implementation Overview"
date:   2019-11-04 12:00:00 +0300
---

![Types of Asteraceae](https://media.githubusercontent.com/media/VysotskiVadim/VysotskiVadim.github.io/a9ae80c482ebd479ccbc702e9a8ac3d67b369ecb/assets/Asteracea_poster_3_part_2.jpg){: style="width:100%"}

During my career I've been working with different strongly typed languages that support generic programming.
They faced the same set of challenges but solved it in different time using different methods with different pros and cons.
I find it fascinating, that's why I blogged about it.

If you don't have much experience with generic programming -
read [the introduction to generic programming]({% post_url 2019-10-01-generic-programming-part-1-introduction %}).

For every considered language we will answer the following questions:
* How do generics work under the hood?
* How did migration to generic happen?
* [Variance]({% post_url 2019-10-01-generic-programming-part-1-introduction %}#variance)
* Pros and Cons

I won't compare languages in order to understand which one is better,
because they all are nice!
My point is to show how different preconditions like language and runtime design,
ecosystem, or even market competition affected the way how generics were implemented.

## C++ {#cpp}

In C++ developers control all aspects of memory usage:
you can allocate objects on stack or heap,
you're in charge of freeing memory,
you can even develop your own heap allocator.
Decisions of how memory would be allocated are made in the place of usage:

```cpp
class Product {
    private:
        double price;
    public:
        Product(double price): price(price) { }
        void printPrice() {
            std::cout << "my price is " << price << "\n";
        }
    };
 
   int main()
   {
        Product stackAllocatedProduct(1.5);
        stackAllocatedProduct.printPrice();
        Product* heapAllocatedProduct = new Product(2.5);
        heapAllocatedProduct->printPrice();
        return 0;
    }
```

In C++ methods are invoked by 2 different ways.
If method declared using `virtual` keyword it's invoked via [virtual method table](https://en.wikipedia.org/wiki/Virtual_method_table).
Other methods are invoked directly, i.e. compiler puts in machine code function call by its address.

In the light of all discussed aspects of C++
implementing generic programming looks like a quite challenging task:
all types are very different,
so it's impossible to get one code that handle all possible types with respect to all given freedom.
But the task was solved using usual for C++ world technique - code generation.

C++ supports generic programming via feature called [Template](https://en.wikipedia.org/wiki/Template_(C%2B%2B)),
which was added to language long long time ago - in 1986.

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


#### Under the hood {#cpp_templates_under_the_hood}


Word **Template** reveals how does language feature works under the hood.
Implemented function is just a template for compiler,
which generates new functions for every type template is used with.

So If you use `max` function like this:
```cpp
cout << "int " << generic::max(1, 2) << ", char " << generic::max('a', 'b');
```
under the hood compiler generates 2 functions:

```cpp
template<> int max<int>(int first, int second) {
    if (second > first) {
        return second;
    }
    return first;
}
template<> char max<char>(char first, char second) {
    if (second > first) {
        return second;
    }
    return first;
}
```

#### Migration to generics {#cpp_migration_to_generics}

*I haven't found any info regarding migration to templates,
so it's just my assumptions which is based on logic.*

Templates as a language feature doesn't break existing code,
if you recompile your code using compiler which supports templates
it should work.
The main issue for migration is how to migrate libraries so that
it would work with new and old compilers.
Happily in old good times developers weren't so good at reusing code.
First release of STL(Standard Template Library) where generic code was necessary happened in 1992,
and library code based on templates.
So I think that migration wasn't ever considered as a problem.

#### Advantages {#cpp_templates_advantages}

Approach from C++ is the most understandable for developers,
it's easy to imagine how code would work if you replace generic parameter with the specific type.
So it's very easy to work with generic types - you can do what ever you want with them,
all type checks take place after code generation phase,
just write code so that it compile with specific type you use it with.

Templates are also very flexible,
you can use just anything inside template:
it would work if it works with template parameter.

#### Disadvantages {#cpp_templates_disadvantages}

But templates aren't very popular in C++ world.
Many developers don't use that feature.
There are too many disadvantages:

* Templates slow down compilation;
* Absolutely useless compiler error messages;
* You can't reuse generic binary, only source code; 
* You don't know does generic code work until you try;
* Code bloat.

**Code bloat** it's when you get much bigger executable file after compilation than you expected.
Every time you use a new generic parameter you get a new generated class or function,
its code is stored on disk and has to be loaded in the RAM during execution.

#### Variance {#cpp_templates_variance}
As I sad before C++ templates are very intuitive:
there is just code generation behind it.
What kind of variance will it be if you write the same class or function using different types?
**Invariance**.
There is no relationships between generated classes and functions.

But since C++ 17 std library supports co and contravariance via `std::function`.
Functions produces are covariant, functions consumers are contravariant.

## Java {#java}

Java type system is based on reference and value types.
Any object is reference type, it's allocated in the heap, and you work with it via reference.
Value types are data primitives which allocated on the stack(local variable) or heap(class field).
There are only 8 value types in Java: `byte`, `short`, `int`, `long`, `float`, `double`, `char`, and `boolean`.
So if you use Java most of the time you work with reference types.
Developers can only allocate objects.
How objects allocated and how they will be freed depends on Java runtime.
Java code is compiled to Java Byte code,
which is interpreted by Java Virtual Machine(JVM) on running device.

Java didn't support generics at first release.
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
Doesn't seems hard,
but difficulties in life without generics is that
you should cast result of the function explicitly at the place of usage.
And of course whenever programming language gives to developers a chance to make a mistake,
we alway do
*(because all developers are humans, and humans always makes mistakes)*.

#### Under the hood {#java_generics_under_the_hood}

Generics in Java implemented like compile time feature: generics aren't present in Bytecode.
On Bytecode level you're just working with `Object`.
But when you use generics compiler checks types and you don't have to use explicit cast.
The process when compiler doesn't leave for runtime any information about generics is called **type erasure**.

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


#### Migration to generics {#java_migration_to_generics}

Feature **generics** [was released in Java 5](https://en.wikipedia.org/wiki/Java_version_history#J2SE_5.0) in September 2004.
Java had been existing for more then 8 years.
A lot*(I mean really a lot!)* of code had been written since Java became popular.

Sun didn't control whole or even majority of libraries in Java ecosystem,
so it was clear that migration will take some time
and it won't happen simultaneously.
For example you are a library developer,
some of library users updated to new Java and want you to provide generic API,
and other users develop enormous application so it would take years to update to new Java,
but they want to get fixes and improvements from you.
In order to support all mentioned cases by one library
[migration capability became the first constraint in the requirements](https://www.jcp.org/en/jsr/detail?id=14):
> C1) Upward compatibility with existing code. Pre-existing code must work on the new system. This implies not only upward compatibility of the class file format, but also interoperability of old applications with parameterized versions of pre-existing libraries, in particular those used in the platform library and in standard extensions.

To achieve compatibility with already written not generic code
Sun's engineers implemented generics through type erasure and added **raw types** feature.

Raw type lets developers use generic code as it was not generic.
For example `ArrayList` instead of `ArrayList<T>` would be treated by
compiler like `ArrayList<Object>`.

Java Runtime Environment(JRE) is shipped with a lot of useful packages.
Many built-in classes was rewritten to provide generic API, for example `ArrayList` became `ArrayList<T>`.

Basically migration strategy is following:
if you write new code - use generics,
if you have existing code which works well - don't touch it,
it would work well with raw types from new packages.

*To know more about why Sun chose type erasure reed [Neal Gafter blog](http://gafter.blogspot.com/2004/09/puzzling-through-erasure-answer.html).*

#### Variance {#java_generics_variance}
Java supports variance via language feature called wildcards.

To use **invariance** specify unbounded wildcard like `T<?>`.
It means that you don't care about type and use generic object just like regular `Object`:
```java
static void printItems(List<?> list) {
    for (Object item : list) {
        System.out.println(item);
    }
}
```

If you specify lower or upper bound it's called bounded wildcards.
Let's consider it via simple examples:

```java
class A {}
class B extends A {}
class C extends B {}
class D extends B {}
```

If you want to use **covariance** you should specify *upper bound* like `extends T`:
```java
List<? extends B> listOfB;
listOfB = new ArrayList<C>(); // fine
listOfB = new ArrayList<D>(); // fine
listOfB = new ArrayList<A>(); // compilation error
```
`List` has many methods, some of them produce and some of them consume generic values.
When you specify `extends T` you can use only methods producers:
```java
B b = listOfB.get(0); // fine
listOfB.add(new B()); // compilation error
```

If you want to use **contravariance** you should specify *lower bound* like `super T`:
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
In Java, developers specify wildcards at the place of usage, that approach is called *use-site variance*. 

#### Pros {#java_generics_pros}
As you can see all C++ templates disadvantages which we mentioned above have been solved.
Compiler produces only one function or class for all possible generic parameters,
where all generic types are `Object`, so:
* no noticeable compilation slowdown;
* you are able to use generic code from binary(Bytecode);
* compilation error messages don't come from generated code, so they're understandable;
* support of co- and contravariance;
* easy validation: if code works for one type, then it will work for others.

#### Cons  {#java_generics_cons}
But there are still some disadvantages.

* Generic code works only for reference types.
It means that you can't use `Map<integer>`, only `Map<Integer>`.
I.e. in order to pass `integer` to generic code you have to box in object `Integer`;
* Generic parameters aren't reified (not available at runtime because of type erasure);
* It's a kind of consequence of previous point, but it's worth to mention as disadvantage:
 Arrays don't work well with generics, for example you can't create generic array like `new E[]`;

As for using value types and reified generics
I must say that majority of industry
*(I mean backend development, where Java's extremely popular)*
doesn't really suffer because of their absence.
But some people do.
There is the project called [valhalla](https://wiki.openjdk.java.net/display/valhalla/Main)
which is experiment to bring value types and reified generics in Java,
read [this article](https://wiki.openjdk.java.net/display/valhalla/Main) to know more about it.

And just a few words about Array and generics.
Arrays in Java are covariant and all type checks happen in runtime:
```java
Object[] objectArray = new Long[1];
objectArray[0] = "secretly I'm a String"; // Throws ArrayStoreException
```
You can't create arrays like `new E[]` because of runtime check in array and type erasure in generics.
Oracle couldn't change arrays in Java 5, so arrays and generics in Java is a bad mix.
If you interested you can find more info in "Effective Java" by Joshua Bloch,
in third edition chapter is called *Item 28: prefer lists to arrays*.

## C# (.Net) {#cs}

C# is similar to Java,
but it's not a coincident,
there is a story behind their similarity.
At the early 2000 one of the main Microsoft's products was Windows OS.
It was easy to imagine how language + runtime like Java's one
could increase productivity of developers as well as improve quality of software for Windows.
And Microsoft wanted to implement better integration with Windows OS.
So they started to change JVM, and Sun*(which then was acquired by Oracle)* didn't like it so they baned Microsoft's changes.
Then Microsoft decided create it's own platform.
At that time all Java disadvantages and design errors were obvious,
so Microsoft tried to fix it from the very beginning.
*[More about why Microsoft created C#](https://www.forbes.com/sites/quora/2018/03/02/why-did-microsoft-create-c/#7c51ffda70f3)*

C# type system lets developers create both custom value(`struct`) and reference(`class`) types.
Value types are allocated on heap or stack, reference - only in heap.
.Net runtime, which is called CLR, is in charge of memory allocation and cleaning.
C# compiler produces Intermediate Language(IL),
which is then compiled to machine code on running device.

C# supports generics since version 2.0 - September 2005, 3 years after C# 1.0 release.
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

#### Under the hood {#cs_generics_under_the_hood}

Microsoft didn't have much choice,
given support of custom value type and [revelled disadvantages of type erasure in Java](#java_generics_cons),
they had to support generics in runtime.
And they did it.

*(visit [.Net fiddle](https://dotnetfiddle.net/A9PW6r) to see full version of IL code)*:
```il
.method public hidebysig static !!T  max<(class [mscorlib]System.IComparable`1<!!T>) T>(!!T first,
                                                                                          !!T second) cil managed
  {
    IL_000a:  callvirt   instance int32 class [mscorlib]System.IComparable`1<!!T>::CompareTo(!0)
```

After compilation we get the same IL code with respect to generics as in C#.

So to answer the question how C# generics work under the hood
we have to go one level deeper.

All optimizations work at machine code generation level.
Most of the time you work with reference type.
Under the hood all references are the same data type: address in the memory, i.e. just a number.
So CLR generates one generic implementation for all reference types.
Works like in Java, but on 1 level deeper, at machine code.

Unfortunately it's not possible to apply the same optimization for value types,
because all value types have a different size and structure.
So for custom value types generic code works like in C++:
CLR generates implementation per every value type which is used as generic parameter.

*If you want to know more about generics implementation in .Net I recommend you [this article](https://alexandrnikitin.github.io/blog/dotnet-generics-under-the-hood/) as entry point.*

#### Migration to generics {#cs_migration_to_generics}

As well as in Java and C++
generics as a language feature don't break existing code,
so main challenge is not simultaneous migration of libraries and applications
to language version that support generics.

Microsoft provided majority of infrastructure and "ready to go" solutions for developers,
so migration of third party library wasn't important case for C#.
This fact let Microsoft to make a breaking change in runtime.
Libraries was migrated without breaking changes,
new API with generic support was added.

```cs
var notGenericList = new System.Collections.ArrayList();
var genericList = new System.Collections.Generic.List<object>();
```

#### Variance {#cs_variance}

C# supports both co and contra variance using declaration site variance:
There are 2 keywords: `in` and `out` which marks generic parameters as contra and covariant.
Let's try them by rewriting examples from 
[co]({% post_url 2019-10-01-generic-programming-part-1-introduction %}#covariance)
and
[contravariance]({% post_url 2019-10-01-generic-programming-part-1-introduction %}#contravariance)
explanation.

```c#
class Flower {  }
class Rose: Flower { }
class Daisy: Flower { }

interface FlowerShop<out T> where T: Flower {
    T getFlower();
}

class RoseShop: FlowerShop<Rose> {
    public Rose getFlower() {
        return new Rose();
    }
}

class DaisyShop: FlowerShop<Daisy> {
    public Daisy getFlower() {
        return new Daisy();
    }
}
```
Generic parameter in `FlowerShop<T>` marked as `out`.
It means that `FlowerShop<T>` can only produce values of type `T`
i.e. it's safe to use covariance:

```c#
static FlowerShop<Flower> tellMeShopAddress() {
    return new RoseShop();
}
```

And when you mark generic parameter as `out`,
it means that interface implementation can only consume values of type `T`.

```c#
interface PrettyGirl<in TFavoriteFlower> where TFavoriteFlower: Flower {
    void takeGift(TFavoriteFlower flower);
}

class AnyFlowerLover: PrettyGirl<Flower> {
    public void takeGift(Flower flower) {
        Console.WriteLine("I like all flowers!");
    }
}
```

So it's save to use contravariance:

```c#
PrettyGirl<Rose> girlfriend = new AnyFlowerLover();
girlfriend.takeGift(new Rose());
```

Variance is supported on CLR level:
The [CLI](https://stackoverflow.com/questions/480752/clr-and-cli-what-is-the-difference)
supports covariance and contravariance of generic parameters,
but only in the signatures of interfaces and delegate classes.

#### Proc {#cs_generic_proc}

C# as many language before it tried to solve issues of its predecessors.
C# predecessor as well as the main competitor is Java,
so C# language designers put a lot of effort to solve [Java generics design issues](#java_generics_cons):
* Generic code available for value types;
* [Some people thinks that declaration site variance is superior to use site](https://github.com/dotnet/csharplang/issues/1992#issuecomment-438082037);
* Generic types is reified, i.e. type of generic parameter is available at runtime.

Other major reason for .Net to support value type in generic code is custom value types - `struct`.
It would be very strange to let developer create custom value type,
but don't allow them to use `struct` in generic code.

#### Cons {#cs_generic_cons}

* Possible code bloat with value types;
* Some people thinks that use site variance is more convenient;
* [Arrays are still covariant with runtime assentation](https://dotnetfiddle.net/uKTPl7).


## Use site variance VS declaration site variance {#use_vs_declaration_site_variance}

In other words we can say that we're comparing Java wildcards and C# declaration site `in` `out`.

People have been using generics for many years.
Maybe now we have some experience and we could agree that some kind of variance is better then other?
I'm afraid no.
There is still debates across the Internet, so developers divided into two camps.

Most people agreed on that use site variance is more powerful,
i.e. it gives developers more freedom and flexibility.
So even if designers didn't create their class for variant usage you still can,
and compiler helps you don't shoot in your own leg.
As a disadvantage of wildcard it's annoying to write it every time when you need a variance.

Declaration site variance is less powerful
but it also requires less effort from developers,
so it more convenient.
If you have good types system, 
where all functions grouped in different interfaces and marked as `in` or `out`,
the declaration site variance works amazing.
By the way guys from Microsoft*(especially those who implemented wildcards in Java)* are so 
[confident about declaration site variance superiority](https://github.com/dotnet/csharplang/issues/1992#issuecomment-438082037),
that variance had been embedded into CLR,
so now it's not something that can be easily changed.

As for me I like languages where use site variance and declaration site variance coexists,
for example Kotlin.
Because most of the time*(I can't say that I use variance often)* you can use already defined variance.
But when class isn't designed with the variance in mind,  you still able to apply variance at use site.

## Conclusion

I didn't try to find out the best generic implementation,
my point is that
3 considered languages had different preconditions
and different goals.

C++ gives developers a complete freedom in terms of memory management,
code generation approach was already common in sphere of C and C++ development,
so I believe that templates are really great approach for C++,
it's fast*(only in runtime)*,
easy to understand,
and the most flexible among considered languages.

Generics in Java was created
to improve existing, popular, and wildly used technology.
Given Java memory model, ecosystem, and use cases,
I must say that Sun's engineers did a good job! 

Generics in C# (.Net) as well as language itself is the youngest.
To be successful in a sphere where problem is already solved,
your need so solve it much better then your competitors.
Direct competitor for C# is Java.
C# creators did their best to make their language amazing.
There is also a different reasons which affected generics design:
different from Java memory model and libraries ecosystem.

As you can see all implementations are reasonable,
they provide to developer ability to write generic and do it good.
But because of different preconditions, history, ideology,
*good* means different for every language.

Hope you enjoyed the reading and found something useful for you.
Don't hesitate to ask questions in comments, or reach me in twitter.
I will appreciate your feedback, it means much for me.