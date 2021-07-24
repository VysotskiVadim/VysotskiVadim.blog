---
layout: post
title: "Jetpack Navigation. A convenient API for returning a result to the previous Destination."
date: 2021-07-24 19:00:00 +0300
image: /assets/Asteracea_poster_3_part_2.jpg
description: "Return a result to the previous Destination using Android Jetpack Navigation with beautiful API"
postImage:
  src: Asteracea_poster_3_part_2
  alt: Types of Asteraceaes
---

## Introduction

I often need to launch a screen **B***(child)* from a screen **A***(parent)*.
A user does some actions on screen B, for example, picks color using a full-screen color picker.
When the user picked the color, he presses the "Done" button.
The app navigates back to screen **A**.
Child screen **B** needs to pass the picked color to its parent screen **A**.

Jetpack Navigation Architecture component calls passing result from child to parent screen a ["Returning a result to the previous Destination"](https://developer.android.com/guide/navigation/navigation-programmatic#returning_a_result)

But I don't like the code from the official guide.
It looks too complex for such a task.
Don't worry if you don't understand it.
```kotlin
val navController = findNavController();
// After a configuration change or process death, the currentBackStackEntry
// points to the dialog destination, so you must use getBackStackEntry()
// with the specific ID of your destination to ensure we always
// get the right NavBackStackEntry
val navBackStackEntry = navController.getBackStackEntry(R.id.your_fragment)

// Create our observer and add it to the NavBackStackEntry's lifecycle
val observer = LifecycleEventObserver { _, event ->
    if (event == Lifecycle.Event.ON_RESUME
        && navBackStackEntry.savedStateHandle.contains("key")) {
        val result = navBackStackEntry.savedStateHandle.get<String>("key");
        // Do something with the result
    }
}
navBackStackEntry.lifecycle.addObserver(observer)

// As addObserver() does not automatically remove the observer, we
// call removeObserver() manually when the view lifecycle is destroyed
viewLifecycleOwner.lifecycle.addObserver(LifecycleEventObserver { _, event ->
    if (event == Lifecycle.Event.ON_DESTROY) {
        navBackStackEntry.lifecycle.removeObserver(observer)
    }
})

```

The approach above works fine.
But I don't want to see this code in many fragments of my app.
An obvious solution for me was to write a wrapper that uses the official approach under the hood but provides a convenient API.

I implemented the wrapper. Here's how I get a result from a child screen(previous destination):
```kotlin
findNavController().handleResult<PickIntervalResult>(
    viewLifecycleOwner,
    R.id.navigation_notifications, // current destination
    R.id.pickNotificationIntervalFragment // child destination
) { result ->
    binding.textNotifications.text = result.toString()
}
```
And here's how to return a result to a parent from a child:
```kotlin
findNavController().finishWithResult(PickIntervalResult.WEEKLY)
```

Hope this wrapper can be useful for you as well.
To implement a similar wrapper read this article or go straight to the [code in github](https://github.com/VysotskiVadim/jetpack-navigation-example/blob/master/app/src/main/java/dev/vadzimv/jetpack/navigation/example/navigation/Result.kt) and play with the example app.


## Pass result to a parent from a child screen

To pass result to a parent screen, just put it in the saved state handle of parent's back stack entry.

```kotlin
fun <T : Parcelable> NavController.finishWithResult(result: T) {
    val currentDestinationId = currentDestination?.id
    if (currentDestinationId != null) {
        previousBackStackEntry?.savedStateHandle?.set(resultName(currentDestinationId), result)
    }
    popBackStack()
}

private fun resultName(resultSourceId: Int) = "result-$resultSourceId"
```

The saved state handle is a map of keys and values.
I put the result as a value.
Key is generated based on the child screen destination id by `resultName` function.
Key contains the id of the child screen because the parent could have a few children,
and it needs to know the source of the result.

Passing a result to a parent is the last step on every children's screen.
Close the current screen on the last step calling `popBackStack()`.

`SavedStateHandle` doesn't work with any class because it deals with a process death.
That's why generic type `T` must implement `Parcelable`.

## Get result in a parent from a child

To get result back in a parent just take the result from the saved state handle.
```kotlin
private fun <T : Parcelable> handleResultFromChild(
    @IdRes childDestinationId: Int,
    currentEntry: NavBackStackEntry,
    handler: (T) -> Unit
) {
    val expectedResultKey = resultName(childDestinationId)
    if (currentEntry.savedStateHandle.contains(expectedResultKey)) {
        val result = currentEntry.savedStateHandle.get<T>(expectedResultKey)
        handler(result!!)
        currentEntry.savedStateHandle.remove<T>(expectedResultKey)
    }
}

```

Handle result only when the app navigates back from a child to a parent.
To do so observe lifecycle of the parent's back stack entry, handle result on `ON_RESUME` event.

```kotlin
fun <T : Parcelable> NavController.handleResult(
    lifecycleOwner: LifecycleOwner,
    @IdRes currentDestinationId: Int,
    @IdRes childDestinationId: Int,
    handler: (T) -> Unit
) {
    // `getCurrentBackStackEntry` doesn't work in case of recovery from the process death when dialog is opened.
    val currentEntry = getBackStackEntry(currentDestinationId)
    val observer = LifecycleEventObserver { _, event ->
        if (event == Lifecycle.Event.ON_RESUME) {
            handleResultFromChild(childDestinationId, currentEntry, handler)
        }
    }
    currentEntry.lifecycle.addObserver(observer)
    lifecycleOwner.lifecycle.addObserver(LifecycleEventObserver { _, event ->
        if (event == Lifecycle.Event.ON_DESTROY) {
            currentEntry.lifecycle.removeObserver(observer)
        }
    })
}
```
The code above also stops all listeners when the parent screen dies.

## This is it

Go and try the wrapper in the [example app](https://github.com/VysotskiVadim/jetpack-navigation-example/blob/master/app/src/main/java/dev/vadzimv/jetpack/navigation/example/navigation/Result.kt).
Hope the wrapper makes your code easier as well.