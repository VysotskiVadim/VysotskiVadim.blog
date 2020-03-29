---
layout: post
title:  Don't use Jetpack Pagination
description: "Why I'm unhappy using Jatpack pagination library."
---

I like libraries provided by Google in Jetpack suite.
Libs do their work, and do it well, stable and fast.
I trusted they so much so when I faced task of showing paged result,
I didn't have any doubts to use [Jetpack Paging library](https://developer.android.com/topic/libraries/architecture/paging).
It was a mistake.
During the usage of Jetpack Paging library I had experienced many technical challenges because of it.
So this article not just a nagging about my pain,
it also includes workaround which I used.
If you use Jetpack Paging I believe you'll find them useful.

## Looks good at the first glance

When you start implementing custom DataSource, everything looks good.
You extend `PageKeyedDataSource` and implement 3 methods: `loadInitial`, `loadAfter`, and `loadAfter`.
```kotlin
override fun loadInitial(params: LoadInitialParams<String>, callback: LoadInitialCallback<String, RedditPost>) {
    // your implementation
}

override fun loadAfter(params: LoadParams<String>, callback: LoadCallback<String, RedditPost>) {
    // your implementation
}

override fun loadBefore(params: LoadParams<String>, callback: LoadCallback<String, RedditPost>) {
    // your implementation
}

```
each of the methods takes callback as a parameter,
so when asynchronous loading is finished you suppose to call
`callback.onResult(...)` or `callback.onError(...)`.

You `DataSource` is wrapped by `DataSource.Factory` which creates it.
Factory has an extension method `toLiveData` which transforms it to `LiveData<PagedList<T>>`.
`PagedList` is basically a lazy load list which loads data from its `DataSource` when user scrolls.
You're supposed to use special adapter for recycler view `PagedListAdapter`.
So every time live data with `PagedList<T>` changes you should call `PagedListAdapter.submitList`.

{% include_relative jetpack-paging-architecture.html %}

Looks good, isn't it?
You get a library with many features:
* loads data by pages
* data invalidation
* built-in diff util

## Issue 1: display the status

Users don't want just wait, even if data is loading,
they should see at least loading indicator.
Using Jetpack Paging you're just passing `PageList<T>` object to `PagedListAdapter`.
How do you supposed to show loading?
There is two strategies.

If you'd like to show place holder loading `PagedListAdapter` pass `null` as an item to view holder if it isn't loaded yet.

![place holder](https://raw.githubusercontent.com/zalog/placeholder-loading/HEAD/docs/imgs/placeholder-loading-demo-3.gif){: width="50%" align="center"}


But if you'd like to show some custom loading indicator,
it's going to be match harder because all you have is `PagedList<T>`.
All work to get date is hidden somewhere deep in Data layer.
There is a workaround, you can add 


## Issue 2: display custom data associated with the request
display all items count