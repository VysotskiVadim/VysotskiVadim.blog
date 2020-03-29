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
During the usage of Jetpack Paging library I had experienced many technical challenges.
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

## Issue 1: display current status

Users don't want just wait, even if data is loading, something should happening on the screen.
At least user should see some animations.
For page loading there is 2 standard approaches:
1. Show placeholder instead of each item which is loading right now;
1. Show usual progress bar at the end of the list.

![place holder](https://github.com/VysotskiVadim/VysotskiVadim.github.io/raw/master/assets/placeholder-loading-demo.gif){: height="200px"}
![place holder](https://github.com/VysotskiVadim/VysotskiVadim.github.io/raw/master/assets/progress-bar.gif){: height="200px"}

Using Jetpack Paging it's very easy to implement place holder based loading.
`PagedListAdapter` passes `null` as an item to view holder if it isn't loaded yet.
But if you'd like to show some different loading animations, it's going to be much harder.

The source of the difficulties is that
View Model
*(presenter or any other class which is responsible for UI behavior)*
isn't mediator in data flow to UI.
`PagedList<T>` hides data loading process from you.

#### Workaround 1: get status from `PagedList`

**Warning**: *this workaround is just for your information, you'll see later that it's useless.*

`PagedList<T>` provides ability to add state listeners using `addWeakLoadStateListener`.
`PagedList<T>.addWeakLoadStateListener` is made for `PagedListAdapter` to update itself once data in `PageList<T>` is changed.
That's why listeners are weak.

## Issue 2: network error handling



## Issue 3: display custom data associated with the request
display all items count