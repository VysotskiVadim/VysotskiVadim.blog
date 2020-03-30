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
Workarounds will be present in the same order I used them.
Usually old workaround was replaces by a new one.
So to get the best solution I recommend you read till the end of the article.

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

{% include_relative _jetpack-paging-architecture.html %}

Looks good, isn't it?
You get a library with many features:
* loads data by pages
* data invalidation
* built-in diff util

## Issue #1: Display current status {#current_status}

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

#### Workaround #1: Get current status {#get_current_status}

***Warning**: this workaround is just for your information, you'll see later that it's useless.*

`PagedList<T>` provides ability to add state listeners using `addWeakLoadStateListener`.
`PagedList<T>.addWeakLoadStateListener` is made for `PagedListAdapter` to update itself once data in `PageList<T>` is changed.
That's why listeners are weak.

## Issue #2: Network error handling {#network_errors}

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

#### Workaround #2: Parallel streams of data {#parallel_streams}

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

## Issue #3: Items mapping

When I work with View Model and `RecyclerView`,
I usually transform list of domain object to list of view objects in View Model.
If items appearance depends on data in domain object it usually different types of view object.
Recycler View maps different view objects to different views.
View model can add additional items like headers or
for example actions which should be at the end of the list.

{% include_relative _viewmodel-list-view-item.html %}

`DataSource.Factory` lets you `map` or `mapByPage` items.
Only one limitation -- you can't change items count during mapping.
I think this limitation prevent you from breaking Room's out-of-the-box data sources.

#### Workaround #3: Custom map {#custom_map}

*Warning: workaround works only if you use custom* `DataSource<T>`.

To be able to map pages and change items count you have to implement custom map in your `Listing` class.
My implementation differ from `Listing` proposed in [previous workaround](#parallel_streams).
I pass `DataSource.Factory` instead of `PagedList<T>` and have different state reporting.
```kotlin
class PagedResultImpl<Key, Value>(
    override val dataSourceFactory: DataSource.Factory<Key, Value>,
    override val loadingState: LiveData<PageLoadingState>
) : PagedResult<Key, Value> {

    ...
}
```
Code looks complex, but idea is strait-forward.
Copy `WrapperPageKeyedDataSource` and replace call to `DataSource.convert` function by function which doesn't throws exceptions like original.
```java
static <A, B> List<B> convert(Function<List<A>, List<B>> function, List<A> source) {
    return function.apply(source);
}
```
Then implement `map` and `mapByPage` in your `Listing` class.
You can copy them from `DataSource.Factory`.
```kotlin
override fun <NewValue> map(func: (Value) -> NewValue): PagedResult<Key, NewValue> =
        PagedResultImpl(dataSourceFactory.map(func), loadingState)

override fun <NewValue> mapByPage(func: (List<Value>) -> List<NewValue>) =
    PagedResultImpl(object : DataSource.Factory<Key, NewValue>() {
        override fun create(): DataSource<Key, NewValue> {
            return CustomWrapperPageKeyedDataSource<Key, Value, NewValue>(
                dataSourceFactory.create() as PageKeyedDataSource<Key, Value>
            ) { input ->
                func(input)
            }
        }
    }, loadingState)
```

## Issue #4: Unit Testing

I usually split feature in a few units:
1. UI behavior - View Model;
1. Business login - Use Case;
1. Data - Repository

Each of them I cover by tests.
Jetpack pagination causes issues on all layers.

It's hard to implement test double for your `Listing` object.
Don't even try to mock it.
Use stubs or fakes.

Another challenge is to test View Model.
View Model provides 

## Issue #4: Display custom data associated with the request
display all items count