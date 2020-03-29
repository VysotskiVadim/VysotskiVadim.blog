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

## Issue #1: Display current status

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

#### Workaround #1: Get current status

***Warning**: this workaround is just for your information, you'll see later that it's useless.*

`PagedList<T>` provides ability to add state listeners using `addWeakLoadStateListener`.
`PagedList<T>.addWeakLoadStateListener` is made for `PagedListAdapter` to update itself once data in `PageList<T>` is changed.
That's why listeners are weak.

## Issue #2: Network error handling

Network is unstable.
We're always ready to get an error during data loading.
When you implement `DataSource` and see `onError` callback,
you tend to think that Jetpack Paging ready to handle errors as well.
Well... It's 99% ready.
`ContiguousPagedList` version 2.1.1:
```java
@Override
public void onPageError(@PageResult.ResultType int resultType,
        @NonNull Throwable error, boolean retryable) {
    LoadState errorState = retryable ? LoadState.RETRYABLE_ERROR : LoadState.ERROR;

    if (resultType == PageResult.PREPEND) {
        mLoadStateManager.setState(LoadType.START, errorState, error);
    } else if (resultType == PageResult.APPEND) {
        mLoadStateManager.setState(LoadType.END, errorState, error);
    } else {
        // TODO: pass init signal through to *previous* list
        throw new IllegalStateException("TODO");
    }
}
```
Library throws exception with message **TODO** if you call `onError` callback during initial page load.

#### Workaround #2: Parallel streams of data

Maybe I should have called it best practice instead of workaround.
Because solution was found in the 
[official architecture components samples repository](https://github.com/android/architecture-components-samples/tree/7057c6f3a5a10e2ce28cd000d2037f718008cab2/PagingWithNetworkSample).

The idea is to create few streams of data, so that page loading in always successful.
Second stream reports cases which library can't handle: loading status and errors.
In sample guys return to View Model a `Listing` object:
```kotlin
data class Listing<T>(
    // the LiveData of paged lists for the UI to observe
    val pagedList: LiveData<PagedList<T>>,
    // represents the network request status to show to the user
    val networkState: LiveData<NetworkState>,
    // represents the refresh status to show to the user. Separate from networkState, this
    // value is importantly only when refresh is requested.
    val refreshState: LiveData<NetworkState>,
    // refreshes the whole data and fetches it from scratch.
    val refresh: () -> Unit,
    // retries any failed requests.
    val retry: () -> Unit)
```
Using this solution View Model just passes through to UI `PagedList<T>`
and listen other streams of data to handle cases like showing loading indicator and error handling.

## Issue 4: Items mapping

## Issue 3: Display custom data associated with the request
display all items count