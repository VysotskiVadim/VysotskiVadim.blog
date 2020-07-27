---
layout: post
title:  Jetpack Pagination on steroids
description: "My experience of using Jetpack Pagination: clean architecture, unit testing, refresh and update list."
image: https://github.com/VysotskiVadim/VysotskiVadim.github.io/raw/master/assets/resized/pages_768.jpg
postImage:
  src: pagination-2
  alt: An opened book with many pages
---

Some time ago we needed to implement pagination for the Android application.
As I trusted Jetpack library suite a lot,
I chose [Jetpack Paging library](https://developer.android.com/topic/libraries/architecture/paging) 2 without any doubts,
and convinced my team that this is the best choice for us.
But it appeared that Jetpack paging has many limitations and disadvantages.
Let's see what is wrong with it.

### Jetpack Paging issues and limitations

Jetpack paging is build on top of idea that data base should be the single source of truth.
App immediately shows cached result from a data base and then load more when user reaches the end of the list.
So that Jetpack Paging has good integration with Room, and let you load more data to the DB using boundary callbacks.
Despite the idea having DB as a single source of truth has many advantages,
it doesn't work for all app.

My app displays search result.
Our product guys decided that app shouldn't display cached data immediately because it could be outdated.
But we want to show cached data if user is offline, but not in case of server error.
Despite this logic is simple,
it doesn't fit well Jetpack Pagination Architecture.

One other limitation is that Jetpack Paging forces you to use it's type `DataSourceFactory<T>` on all architecture layers:
from data source(data base) to UI(view).
Code cleanliness is only small part of the problem,
the other parts are:
1. Complexity of mocking of `DataSourceFactory<T>`
2. `DataSourceFactory<T>` isn't extendable, i.e you can transfer any data together with page items(total count for example).
Given that Jetpack Paging doesn't handle errors(it's just crashes)
recommended approach is use parallel data streams based on `LiveData`, **IS STILL ACTUAL FOR JETPACK 3?**
That is even more complicated to mock and work with.

In my core architecture layer I would prefer to see only my classes,
so that I can implement different requirement without saying that lib doesn't support it,
and I can easily test all my logic using test doubles.

### Great part of Jetpack Paging

Jetpack Paging contains logic that is actual for any project regardless of business requirements.
You need to load the first page immediately and then, when user is close to the end, app should load next page.
At least I can't imagine project where requirements regarding pagination are different.

### Our way of using Jetpack Paging

My motivation is following:
1. I don't want to use Jetpack's type `DataSourceFactory` on all architecture layers
2. I want to use pages loading and appending logic from the lib
3. All error handling should be done in view model

Therefore I can use only `PagedList`,
that is responsible to load pages to put them together in one list,
and `PagedListAdapter`,
that is `RecyclerViewAdapter` for `PagedList`.

Unfortunately I didn't come to this conclusion during the integration with the library.
I started from the recommended approach.
But every time I needed to integrate a new feature with pagination
I struggled a lot trying to overcame pagination limitations.
And I've come to current implementation step by step.
I'm very comfortable with current approach,
it's flexible and easy to unit test.
I'm happy that I can share my hard-won way of using Jetpack Pagination with you!

## Let's cook

We will implement simple app that loads data by pages as user scrolls,
and to make things funnier,
we will add few interesting features:
displaying of total items count,
swipe to refresh,
and remove item from the list.
Example will use [cursor based pagination like twitter does](https://developer.twitter.com/en/docs/basics/cursoring).
You can find all code
[here](https://github.com/VysotskiVadim/jetpack-pagination-example).

We start from the core.
Our app will operate with pages of data,
and every page has cursor.

```kotlin
interface Page<T> {
    val items: List<T>
    val nextCursor: PaginationCursor
}
```

With
[cursoring](https://developer.twitter.com/en/docs/basics/cursoring)
technique pages identifies by the cursor,
that is just string.
But to make code little bit cleaner we introduce a
type alias and a few constants

```kotlin
typealias PaginationCursor = String?

val NO_PAGE: PaginationCursor = null
val FIRST_PAGE: PaginationCursor = null
```

Despite the fact that in our implementation `null` could mean two different things,
we give it different name to make developer's intent clean when you read the code.




Now let's thing about example app use case:
user enters the screen, scrolling and load data by pages.

```kotlin
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

## Issue #6: Refresh pages

### Workaround #6: Inner scopes

## Issue #7: Remove item

Removing item from list is common thing, required for many features.
You can see an example in any email client:
TODO: put example here

As an Android developer you probably think:
I just need to remove item from `PagedList` and call `notifyItemRemoved`.
Easy!
But then you notice that `PagedList` doesn't let you change loaded items.

### Workaround #7: Don't change - update

When you submit a new `PagedList` to a `PagedAdapter`,
it uses `DiffUtil` to compare lists and show you updates.
Let's try to do it.

First of all you need to be able to update `PagedList` inside view model.
To achieve this, we need to stop using standard `toLiveData` builder
and build `PagedList` manually.

```kotlin
fun <T> CoroutineScope.createPagedList(
    pageLoader: ItemsPageLoader<T>
): PagedList<T> {
    val scope = this
    val immediateExecutor = Executor { it.run() }
    val config = Config(
        pageSize = 30,
        prefetchDistance = 30 / 2,
        initialLoadSizeHint = PAGE_SIZE
    )
    val dataSource = PaginationDataSource(scope, pageLoader)
    return PagedList.Builder(dataSource, config)
        .setNotifyExecutor(immediateExecutor)
        .setFetchExecutor(immediateExecutor)
        .setInitialKey(FIRST_PAGE)
        .build()
}
```
and change pages creation in the view model
```kotlin
private val _pages = MutableLiveData<PagedList<ExampleListItem>>()
val pages : LiveData<PagedList<ExampleListItem>> by lazy {
    _pages.value = viewModelScope.createPagedList {
        _state.value = State.Loading
        val page = loadItemsPage(it)
        _state.value = State.Loaded(page.itemsCount)
        page
    }
    _pages
}
```

Now you're ready to implement removing item from the list in 3 simple stems:
1. Get loaded items
2. Remove an item
3. Create new `PagedList` with new item

To get loaded items call `PagedList.snapshot`.
Don't forget to filter `null`s if you use placeholders loading animation.
```kotlin
val loadedItems = _pages.value?.snapshot()!!.filterNotNull()
```

It's straight forward to remove an item:
```kotlin
val updatedList = loadedItems.filter { it.id != id }
```

The third step is a bit more complex.
To create a new `PagedList` with predefined content
you need to pass `DataSource` that calls back immediately on `loadInitial`.
As for this case we need to pass only data required by `Page`,
let's create implementation that doesn't have anything else.
```kotlin
class SimplePage<T>(
    override val items: List<T>,
    override val nextCursor: PaginationCursor
) : Page<T>
```
Now we can make an optional parameter `initialContent` in the data source,
so that, if initial content is given, callbacks triggers immediately.

```kotlin
private class PaginationDataSource<T>(
    private val scope: CoroutineScope,
    private val pageLoader: PageLoader<T>,
    private val initialContent: Page<T>?
) : PageKeyedDataSource<PaginationCursor, T>() {

    override fun loadInitial(
        params: LoadInitialParams<PaginationCursor>,
        callback: LoadInitialCallback<PaginationCursor, T>
    ) {
        if (initialContent != null) {
            callback.onResult(initialContent.items, NO_PAGE, initialContent.nextCursor)
        } else {
            scope.launch {
                val result = pageLoader(ItemsPageLoadingParams(FIRST_PAGE, params.requestedLoadSize))
                callback.onResult(result.items, NO_PAGE, result.nextCursor)
            }
        }
    }

    ...

}
```

And we need to pass initial content through the `createPagedList` function:
```kotlin
fun <T> CoroutineScope.createPagedList(
    initialContent: Page<T>? = null,
    pageLoader: PageLoader<T>
): PagedList<T>
```

Given that we're ready to implement the last step of items update:
just create a new data source with preloaded content:
```kotlin
  _pages.value = viewModelScope.createPagedList(::getPage, SimplePage(updatedList, nextPageCursorToLoad))
```

And you put everything together you will get:
```kotlin
fun removeItemWithId(id: Long) {
    val loadedItems = _pages.value?.snapshot()!!.filterNotNull()
    val updatedList = loadedItems.filter { it.id != id }
    _pages.value = viewModelScope.createPagedList(::getPage, SimplePage(updatedList, nextPageCursorToLoad))
}
```

## Summary

Jetpack Paging is a great library that reveals the complexity of pagination generalization.
Pagination itself isn't such a complex task,
the thing is it's difficult to create a silver bullet which handles different cases.
Jetpack Paging is well applicable for simple apps: *display exactly what you have in a database and load more on the fly*.
I would say **NO** to Jetpack Pagination in my projects.
Unfortunately, the majority of them don't fit the *"simple projects"* category.
It's much easier to implement a custom mechanism that handles exactly what I need.
I will write an article about it, stay tuned.

## Links
* Post image was taken from [flickr](https://flic.kr/p/SdnH1B)
* [Official architecture components samples repository](https://github.com/android/architecture-components-samples/tree/7057c6f3a5a10e2ce28cd000d2037f718008cab2/PagingWithNetworkSample)