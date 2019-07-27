---
layout: post
title:  "The biggest reason to love kotlin coroutines"
date:   2019-07-27 13:30:26 +0300
---

Kotlin coroutines like a breadth of fresh air for me. Before I started develop for Android platform I used C# for my daily job. In C# since 2011 (TODO: clarify) for developers available async/await mechanism. When I saw coroutines for a first time I thought "Just like I used to writing in C#, great!", but I was wrong - it's much better!

Kotlin coroutines solved the biggest problem we always have with C# async/await mechanism: cancellation. Cancellation is an issue for C# projects not because it's something hard to implement(you'll see it's easy), because developers aren't aware that cancellation is important. We had realized importance of correct cancellation implementation right after we started getting a lot of crash reports from production.

Let's consider typical C# async/await example (don't worry you will understand everything)
{% highlight C# %}
class WrongScreen { 

    private ConsoleView view;

    public async void initialize() {
        view = new ConsoleView();
        view.ShowLoading();
        var data = await FakeTaskManager.fetchDataAsync();
        view.HideLoading();
        view.ShowData(data);
    }

    public void destroy() {
        //cleanup resources
        view.Dispose();
    }
}
{% endhighlight %}

It's a kind of imitation of presenter from any platform: (Fragment or Activity from Android or ViewController from iOS). Code looks great - easy to read and understand asynchronous code looks just like usual.

Let's imitate page opening:
{% highlight C# %}
var screen = new WrongScreen();
screen.initialize();
{% endhighlight %}

{% highlight Console output %}
Loading...
Loading completed
Data is 5
{% endhighlight %}

It works, great! But what happens if user leave page before loading completed:

{% highlight C# %}
var screen = new WrongScreen();
screen.initialize();
screen.destroy();
{% endhighlight %}

{% highlight Console output %}
Loading...

Unhandled Exception: System.ObjectDisposedException: Cannot access a disposed object.
Object name: 'ConsoleView'.
{% endhighlight %}

The worst think about cancellation related crashes - it's hard to miss it and let it go to prod: local servers are fast, navigation could be not trivial and so on.

