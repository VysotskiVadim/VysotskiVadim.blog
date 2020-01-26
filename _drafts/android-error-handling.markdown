---
layout: post
title:  Error handling strategy for Android app
description: "How to organize error error handling in Android application."
---

There is something important, something that matters, something that I always miss - error handling strategy.
Strategy is a global plan applicable for all application code, it's a part of architecture.
I always use the straightforward one: when app crashes it's time for one more `try-catch`.

### The motivation

Default error handling strategy given out of the box by Java is far from perfect.
When something goes wrong code execution is interrupted by exception.
Exception contains some information regarding failure and can be handled by `try-catch` block.

Java's creators made a good attempt to divide exception into two categories: *checked* and *unchecked*.
Unchecked is something unexpected like bug in logic which is causes `NullPointerException`.
Checked is expected possible failure which is part of a method signature,
so that function called have to handle negative scenario,
like `IOException` when you open a file.
This perfect from the first glance approach,
failed when developers stated using it: reed
[Java's checked exceptions were a mistake](http://radio-weblogs.com/0122027/stories/2003/04/01/JavasCheckedExceptionsWereAMistake.html)
and
[The Trouble with Checked Exceptions](https://www.artima.com/intv/handcuffs.html).
Next generation of languages which is inspired by Java, like C#, Scala, Kotlin, missing checked exceptions feature.
The issue with unchecked exception is that developer should expect that every function call has two possible results:
successful one which is specified in function signature,
and in case of failure exception is your result.

Depside of checked exception failure
the idea of specifying successful and failed result in function signature is great.
Developers who use strongly typed languages want compiler to check their code rather then see errors in runtime.
Good exception error handling system should **force developers handle all scenarios, event negatives one,
by compile time checks**(1).

Exceptions based error handling mechanism has another advantage: developer can focus on positive scenario.
Consider the simple case:
```kotlin
try {
    val data = getData()
    val viewObject = processData()
    showResultOnUI(viewObject)
} catch (t: Throwable) {
    showErrorOnUI()
}
```
In this case when developer implements logic, he thinks only about positive scenario.
To avoid crash he wrap all logic with error handling so that it doesn't matter when exactly error happened.
Despite "one `tru-catch` to rule them all" approach works only for simple cases,
it's still very useful **to be able to concentrate on positive flow when you reading or wring code**.