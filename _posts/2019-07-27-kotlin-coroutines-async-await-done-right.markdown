---
layout: post
title:  "Kotlin Coroutines - async/await done right"
date:   2019-07-27 13:30:26 +0300
---

Before I switched to Android I was .Net developer and used C# intensively. I've written a lot of asynchronous code using C# *async/await* language feature. In this post I'm going to explain how Kotlin Coroutines solved the biggest problem I always had in asynchronous *async/await* code - **cancellations**.

## The issue

What is wrong with cancellations and *async/await*? Let's consider typical C# async/await example
```c#
class WrongScreen { 

    private ConsoleView view;

    public async void initialize() {
        view = new ConsoleView();
        view.ShowLoading();
        var data = await FakeTaskManager.fetchDataAsync(); //always returns 5
        view.HideLoading();
        view.ShowData(data);
    }

    public void destroy() {
        //cleanup resources
        view.Dispose();
    }
}
```

Wrong screen is imitation of presenter(you can find similar in any platform: Fragment or Activity from Android or ViewController from iOS). Code in `WrongScreen.initialize` method looks great: easy to read and understand, asynchronous but looks just like usual iterative.

When page opens everything works as expected:
```c#
var screen = new WrongScreen();
screen.initialize();
```


```console
Loading...
Loading completed
Data is 5
```

I wouldn't name it `WrongScreen` if everything were good. What will happen if user leave page before loading completed?

```c#
var screen = new WrongScreen();
screen.initialize();
//leave page immediately
screen.destroy();
```

```console
Loading...

Unhandled Exception: System.ObjectDisposedException: Cannot access a disposed object.
Object name: 'ConsoleView'.
```
**Crash!** View was destroyed while data was loading, and when loading completed and presenter tried to call `view.HideLoading()` it got `ObjectDisposedException`.

Is it hard to handle cancellation? NO!

```c#
class RightScreen { 

    private CancellationTokenSource cts;
    private ConsoleView view;

    public async void initialize() {
        try {
            view = new ConsoleView();
            view.ShowLoading();
            cts = new CancellationTokenSource();
            var data = await FakeTaskManager.fetchDataAsync(cts.Token);
            view.HideLoading();
            view.ShowData(data);
        } catch (OperationCanceledException) {
            Console.WriteLine("Operation was cancelled");
        }
    }

    public void destroy() {
        cts.Cancel();
        //cleanup the resources
        view.Dispose();
    }
}
```

In languages with *async/await* cancellation handling works via exceptions: as soon as operation cancelled - exception should be thrown. In case of cancellation exception mechanism used just to interrupt code execution.

Let's check:
```c#
var screen = new RightScreen();
screen.initialize();
screen.destroy();
```
It works, great!
```console
Loading...
Operation was cancelled
```

Cancellation is dangerous - most developers aren't aware of its importance. Tutorials doesn't tell you about cancellations, try to google C# or Ecma Script *async/await* tutorials. Even if you're experienced developer - it probably won't help because issue isn't actual for pre *async/await* approach like callbacks.

The worst thing about cancellation related crashes - it's easy not to notice it when you test: local servers are fast, navigation could be not trivial and so on. But believe me you will find all wrong handled cancellations in crash reports from prod.

The main point I've learned about *async/await* asynchronous code - you should always handle cases with cancellation. The only exception is backend development: http doesn't support cancellations.

Let's summarize *async/await* cancellations issue:

* easy to handle, but easy to make a mistake
* should be handled everywhere, every time
* many developers aren't aware

Can compiler handle it for us? **Yes!**

## The solution

Kotlin Coroutines comes with idea of [Structured Concurrency](https://kotlinlang.org/docs/reference/coroutines/basics.html#structured-concurrency): all Kotlin Coroutines must run in Coroutine Scope - just cancel scope and all coroutines in it will be cancelled.

```kotlin
class RightScreen: CoroutineScope by CoroutineScope(Dispatchers.Unconfined) {

    lateinit var view: ConsoleView

    fun initialize() {
        view = ConsoleView()
        launch {
            view.showLoading()
            val data = fetchData()
            view.hideLoading()
            view.showData(data)
        }
    }

    fun destroy() {
        cancel()
        view.dispose()
    }

}
```
Let's check:
```kotlin
val screen = RightScreen()
screen.initialize()
screen.destroy()
println("user successfully leaved the screen")
```
Output:
```console
loading...
user successfully leaved the screen
```

Under the hood cancellation mechanism in Kotlin Coroutines works similar to C# where you should catch `OperationCanceledException`, pass and manage `CancellationToken` every time you call async function. But in Kotlin **compiler and library handle cancellation for you and even if you make a mistake code won't compile**.