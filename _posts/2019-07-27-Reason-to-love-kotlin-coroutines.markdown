---
layout: post
title:  "The biggest reason to love kotlin coroutines"
date:   2019-07-27 13:30:26 +0300
---

Before I switched to Android I was .Net developer and used C# intensively. I've wrote a lot of asynchronous code using C# *async/await* language feature. In this post I'm going to explain how Kotlin Coroutines solved the biggest problem I always had in asynchronous *async/await* code - **cancellations**.

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

Wrong screen is a imitation of presenter(you can find similar in any platform: Fragment or Activity from Android or ViewController from iOS). Code in `WrongScreen.initialize` method looks great: easy to read and understand, asynchronous but looks just like usual iterative.

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

Cancellations is dangerous - most developers aren't aware of its importance. Tutorials doesn't tell you about cancellations, try to google C# or Ecma Script *async/await* tutorials. Even if you're experienced developer - it probably won't help because issue isn't actual for pre *async/await* approach like callbacks.

The worst thing about cancellation related crashes - it's easy not to notice it when you test: local servers are fast, navigation could be not trivial and so on. But believe me you will find all wrong handled cancellations in crash reports from prod.

The main point I've learned about *async/await* asynchronous code - you should always handle cases with cancellation. The only exceptions is backend development: http doesn't support cancellations.

In this article I expect that you're familiar with idea of [Structured Concurrency](https://medium.com/@elizarov/structured-concurrency-722d765aa952) in Kotlin Coroutines.

TODO: remove it don't need it any more

Kotlin coroutines like a breadth of fresh air for me. Before I started develop for Android platform I used C# for my daily job. In C# since 2011 (TODO: clarify) for developers available async/await mechanism. When I saw coroutines for a first time I thought "Just like I used to writing in C#, great!", but I was wrong - it's much better!

Kotlin coroutines solved the biggest problem we always have with C# async/await mechanism: cancellation. Cancellation is an issue for C# projects not because it's something hard to implement(you'll see it's easy), because developers aren't aware that cancellation is important. We had realized importance of correct cancellation implementation right after we started getting a lot of crash reports from production.