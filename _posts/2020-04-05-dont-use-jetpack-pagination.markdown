---
layout: post
title:  Don't use Jetpack Pagination
date: 2020-04-05 13:30:00 +0300
description: "My experience of using Jetpack Pagination: display status, handle errors, unit testing, mapping, clean architecture."
image: https://github.com/VysotskiVadim/VysotskiVadim.github.io/raw/master/assets/resized/pages_768.jpg
postImage:
  src: pages
  alt: An open book with pages
diagrams: true
---

I like libraries provided by Google in Jetpack suite.
Libs do their work and do it well, stable, and fast.
I trusted them so much, so when I faced the task of showing a paged result,
I didn't have any doubts to use [Jetpack Paging library](https://developer.android.com/topic/libraries/architecture/paging).
It was a mistake.
During the usage of Jetpack Paging library,
I experienced many technical challenges.
This article not just nagging about my pain,
it also includes workaround which I used.
If you use Jetpack Paging I believe you'll find them useful.
Workarounds will be present in the same order I used them.
Usually, an old workaround was replaced by a new one.
So to get the best solution I recommend you read till the end of the article.

* [Workaround #1: Get current status](#get_current_status)
* [Workaround #2: Parallel streams of data](#parallel_streams)
* [Workaround #3: Custom map](#custom_map)
* [Workaround #4: Act as UI](#act_as_ui)
* [Workaround #5: Isolate workarounds](#isolate_workarounds)

## Looks good at the first glance

When you start implementing custom DataSource, everything looks good.
You extend `PageKeyedDataSource` and implement 3 methods: `loadInitial`, `loadAfter`, and `loadBefore`.
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
each of the methods takes the callback as a parameter,
so when asynchronous loading is finished you suppose to call
`callback.onResult(...)` or `callback.onError(...)`.

Your `DataSource` is wrapped by `DataSource.Factory` which creates it.
Factory has an extension method `toLiveData` which transforms it to `LiveData<PagedList<T>>`.
`PagedList` is a lazy loading list that loads data from its `DataSource` when a user scrolls.
You're supposed to use special adapter for recycler view -- `PagedListAdapter`.
Every time live data with `PagedList<T>` changes you should call `PagedListAdapter.submitList`.

{% include_relative _jetpack-paging-architecture.html %}

## Issue #1: Display current status {#current_status}

Users don't want just wait, even if data is loading, something should happening on the screen.
At least user should see some animations.
For page loading there are 2 standard approaches:
1. Show placeholder instead of each item which is loading right now;
1. Show usual progress bar at the end of the list.

![place holder](https://github.com/VysotskiVadim/VysotskiVadim.github.io/raw/master/assets/placeholder-loading-demo.gif){: height="200px"}
![place holder](https://github.com/VysotskiVadim/VysotskiVadim.github.io/raw/master/assets/progress-bar.gif){: height="200px"}

Using Jetpack Paging it's very easy to implement place holder based loading.
`PagedListAdapter` passes `null` as an item to view holder if it isn't loaded yet.
But if you want to show a progress bar, it will much harder.

The source of the difficulties is that View Model
*(presenter or any other class which is responsible for UI behavior)*
isn't a mediator in a data flow to UI.
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

The idea is to create few streams of data, so that page loading is always successful.
Second stream reports cases which library can't handle: loading status and errors.
In the sample guys return to View Model a `Listing` object:
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
Using this solution View Model just passes `PagedList<T>` through to UI 
and listen other streams of data to handle cases like showing loading indicator and error handling.

## Issue #3: Items mapping

When I work with View Model and `RecyclerView`,
I usually transform a list of domain objects to a list of view objects in View Model.
If items appearance depends on data in domain object it usually different types of view object.
Recycler View maps different view objects to different views.
View model can add additional items like headers or
actions which should be at the end of the list.

{% include_relative _viewmodel-list-view-item.html %}

`DataSource.Factory` lets you `map` or `mapByPage` items.
Only one limitation -- you can't change items count during mapping.
It prevents you from breaking Room's out-of-the-box data sources.

#### Workaround #3: Custom map {#custom_map}

*Warning: workaround works only if you use custom* `DataSource<T>`.

To be able to map pages and change items count you have to implement custom map in your `Listing` class.
My implementation differs from `Listing` proposed in [the previous workaround](#parallel_streams).
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

## Issue #4: Unit Testing {#unit_testing}

I usually split feature into a few units:
1. UI behavior - View Model;
1. Business login - Use Case;
1. Data - Repository

Each of them I cover by tests.
Jetpack pagination causes issues on all layers.
It's hard to implement test double for your `Listing` object.
Don't even try to mock it.
Use stubs or fakes.
Another challenge is to test View Model.
Basically, you need to trigger data loading in test, 
and then verify View Model state.
How can you start data loading if everything that you have is `LiveData<PagedList<T>>` property on View Model?

#### Workaround #4: Act as UI {#act_as_ui}

To trigger data loading in a unit test you have to act like UI.

Start with getting live data value via subscription.
```kotlin
fun <T> LiveData<T>.getValueForTest(): T? {
    var value: T? = null
    val observer = Observer<T> {
        value = it
    }
    observeForever(observer)
    removeObserver(observer)
    return value
}
```
When you got `PagedList<T>` using `getValueForTest` you can fetch first page by accessing `PagedList<T>`:

```kotlin
fun <T> LiveData<PagedList<T>>.fetchData() {
    getValueForTest()!!
}
```
`PagedList<T>` loads initial data when it's created.
Next page loading occurs when you request an item which is close to loaded items boundary.
So if you'd like to load the next page, just load around last loaded item.

```kotlin
fun <T> LiveData<PagedList<T>>.fetchOneMorePage() {
    val pagedList = getValueForTest()!!
    val lastLoadedItemIndex = pagedList.loadedCount - 1
    pagedList.loadAround(lastLoadedItemIndex)
}
```

Using given extension you're ready to test view model states switching during pagination:

```kotlin
listViewModel.items.getValueForTest()!!.fetchData()
assertEquals(State.OnlineDataLoaded(totalItemsCount = TEST_TOTAL_ITEMS_COUNT), listViewModel.state.getValueForTest())
```

## Issue #5: Display custom data associated with the request

Imagine super simple feature:
show items count on the screen with items list.
It's easy, you get it from server with data:
```json
{
    "totalItemsCount": 23423,
    "items": [
        ...
    ],
    "nextCursor": "akskdjf42efjowefij92jf"
}
```
If you pass
[parallel streams of data](#parallel_streams)
thought your architecture layers,
you will see that it just doesn't support this simple scenario without workarounds.
Every time you need to pass something else you have to create another stream,
or `LiveData<Any>`, no no no, stop it, don't even want to think about it.
At this moment I realized that architecture built on top of Jetpack Pagination forces
you to create new workarounds for every new feature.

### Workaround #5: Isolate workarounds {#isolate_workarounds}

To minimize damage from lib we can put all Jetpack Pagination related code
in the outside layer of architecture: UI.
`PageList` should survive after a configuration change,
so making View Model responsible for the connection between 
Jetpack Pagination and the rest of the architecture is a reasonable decision.


Let's get rid of workarounds at least in the core part of app architecture.
```kotlin
interface ItemsSearchUseCase {
    suspend fun getItemsSearchPage(criteria: ItemsSearchCriteria, pageParams: PaginationParams): ItemsPagedResult<Item>
}

data class PaginationParams(val cursor: PaginationCursor, val pageSize: Int)
```
Different screens require different data passed,
so I create specific `PagedResult` for every feature which requires pagination.
If the majority of your screens require the same data you can create only one.
```kotlin
sealed class ItemsPagedResult<T> {
    data class ItemsPage<T>(
        val itemsCount: Int,
        val items: List<T>,
        val nextCursor: PaginationCursor,
        val connectionType: ConnectionType
    ) : ItemsPagedResult<T>()

    data class Error<T>(val error: Throwable) : ItemsPagedResult<T>()
}
```
You're maybe wondering, if I make new result types for new features, why is it generic?
To support data mapping when it's going through layers.
```kotlin
fun <NewT> map(mapper: (List<T>) -> List<NewT>): ItemsPagedResult<NewT> = when (this) {
    is ItemsPage<T> -> ItemsPage(
        itemsCount = itemsCount,
        items = mapper(items),
        nextCursor = nextCursor,
        connectionType = connectionType
    )
    is Error<T> -> Error(error)
}
```

To create `LiveData<PagedList<T>>` in a View Model use following function:
```kotlin
fun <T> CoroutineScope.transformToJetpackPagedResult(pageLoader: ItemsPageLoader<T>): LiveData<PagedList<T>> {
    val scope = this
    return object : DataSource.Factory<PaginationCursor, T>() {
        override fun create(): DataSource<PaginationCursor, T> {
            return ItemsPaginationDataSource(scope, pageLoader)
        }
    }.toLiveData(Config(30, prefetchDistance = 30, enablePlaceholders = false))
}
```
`transformToJetpackPagedResult` uses 2 unknown for you types.

`ItemsPageLoader` is an abstraction over specific loading implementation.
Draw attention that it returns only positive result `ItemsPagedResult.ItemsPage<T>`, because
[as we've already discussed](#network_errors) Jetpack Paging doesn't handle errors.
```kotlin
typealias ItemsPageLoader<T> = suspend (ItemsPageLoadingParams) -> ItemsPagedResult.ItemsPage<T>
```

Custom `DataSource` which always successfully loads data form `ItemsPageLoader`.
In my implementation, we go always forward, so the case with load before isn't implemented.
```kotlin
private class ItemsPaginationDataSource<T>(
    private val scope: CoroutineScope,
    private val pageLoader: ItemsPageLoader<T>
) : PageKeyedDataSource<PaginationCursor, T>() {

    override fun loadInitial(params: LoadInitialParams<PaginationCursor>, callback: LoadInitialCallback<PaginationCursor, T>) {
        scope.launch {
            val result = pageLoader(ItemsPageLoadingParams(FIRST_PAGE, params.requestedLoadSize))
            callback.onResult(result.items, NO_PAGE, result.nextCursor)
        }
    }

    override fun loadAfter(params: LoadParams<PaginationCursor>, callback: LoadCallback<PaginationCursor, T>) {
        scope.launch {
            val result = pageLoader(ItemsPageLoadingParams(params.key, params.requestedLoadSize))
            callback.onResult(result.items, result.nextCursor)
        }
    }

    override fun loadBefore(params: LoadParams<PaginationCursor>, callback: LoadCallback<PaginationCursor, T>) {
        error("this should never happen")
    }
}
```

Consider example of pagination at View Model Layer.
```kotlin
class PaginationExampleViewModel(
    private val searchItemsUseCase: SearchItemsUseCase
) : ViewModel() {
   ...
}
```

View Model gets use case as a constructor parameter,
we all use DI nowadays, isn't it?

View Model has a state, which represents what is happening right now:
```kotlin
sealed class State {
    object Loading : State()
    class RetryableError(private val retry: () -> Unit) : State() {
        fun retry() = retry.invoke()
    }

    data class Loaded(val totalItemsCount: Int) : State()
}

private val _state = MutableLiveData<State>()
val state: LiveData<State> get() = _state
```
View observes `state` property and displays loading indicator,
or loading error with retry button,
or data associated with all result, in our example it's total items count.

Next step is to implement `loadPage` function in View Model.
We are going to use in `transformToJetpackPagedResult` function,
so it should have the same signature as `ItemsPageLoader`.
```kotlin
private suspend fun loadItemsPage(params: ItemsPageLoadingParams): ItemsPagedResult.ItemsPage<Item> {
    val loadPageResult = searchItemsUseCase.requestPage(searchCriteria, pageParams)
    return when (loadPageResult) {
        is ItemsPagedResult.ItemsPage -> loadPageResult
        is ItemsPagedResult.Error -> {
            retryWhenUserAskForIt(params)
        }
    }
}
```
View Model just gets a result from the use case and passes it to paging if it's successful.
If something goes wrong, it should be handled by view model.
In the example, we show an error message with retry button to user.
When user clicks retry *(view calls `retry` on error state)*,
view model repeats request.
```kotlin
private suspend fun retryWhenUserAskForIt(params: ItemsPageLoadingParams): ItemsPagedResult.ItemsPage<Item> {
    val retryAfterUserAction = CompletableDeferred<ItemsPagedResult.ItemsPage<Item>>()
    _state.value = State.RetryableError {
        viewModelScope.launch {
            retryAfterUserAction.complete(loadItemsPage(params))
        }
    }
    return retryAfterUserAction.await()
}
```

Last step is `PagedList` itself.
Now you can easily create it using `transformToJetpackPagedResult`
```kotlin
val pages = viewModelScope.transformToJetpackPagedResult {
    _state.value = State.Loading
    val page = loadItemsPage(it)
    _state.value = State.Loaded(page.itemsCount)
    page
}
```

Congratulations!
Now you have clean code at least in the core architecture layers.

## Summary

Jetpack Paging is a good library that reveals the complexity of pagination generalization.
Pagination itself isn't such a complex task,
the thing is it's difficult to create a silver bullet which handles different cases.
Nice try Google, but I say **NO** to Jetpack Pagination in my projects.
It's much easier to implement a custom mechanism that handles exactly what I need.
How to do it?
Stay tuned and I'll show it to you soon.

## Links
* Post image was taken from [flickr](https://flic.kr/p/7yv4t7)
* [Official architecture components samples repository](https://github.com/android/architecture-components-samples/tree/7057c6f3a5a10e2ce28cd000d2037f718008cab2/PagingWithNetworkSample)