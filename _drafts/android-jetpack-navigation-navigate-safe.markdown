---
layout: post
title: "Navigate without crashes using Android Jetpack Navigation"
date: 2021-07-26 19:00:00 +0300
image: /assets/parent-child-navigation.jpg
description: "Do not crash an app during navigation. Navigate safely."
postImage:
  src: parent-child-navigation
  alt: A scheme of a parent to a child navigation
---

## Introduction

Android Jetpack navigation throws an exception if something is wrong.
It's either work or not.
There's not middle state of partially working.

I'm okay with unhandled exceptions during development or testing.
But it's not acceptable for production.
Image user opens settings screen and app crashes.
It's better to show error message or do nothing when something goes wrong during navigation.

In this article I will share how I used Jetpack Navigation on my last project.
My application doesn't crash even if something goes wrong.

Given approach also saved us from the issues related to double navigation ```java.lang.IllegalArgumentException: navigation destination XXX is unknown to this NavController```.
I can quickly click a few times on the button, which triggers navigation, but app navigates one one time.

## Safe navigation

Safe navigation consists of a few steps. Let's consider them one by one.

### Error handling

To avoid crashes handle all exceptions from Jetpack Navigation library.
I use Jetpack navigation via wrappers functions, which handles all errors.

```kotlin
fun NavController.navigateSafe(@IdRes action: Int, args: Bundle? = null): Boolean {
    return try {
        navigate(action, args)
        true
    } catch (t: Throwable) {
        Log.e(NAVIGATION_SAFE_TAG, "navigation error for action $action")
        false
    }
}
```

What should an app do in case of navigation error?
It depends.
But in general you can ignore errors or send them to crash tracker.

I used to send errors as non-fatal crash in crashlytics.
It didn't go well.
We got too many false positive errors.
Every time user clicked simultaneously on two buttons the app sent not-fatal error ```java.lang.IllegalArgumentException: navigation destination XXX is unknown to this NavController```.
And there is no stable way to distinguish potentially fixable error from junk.

I decided to ignore any errors during navigation.
I just log it and that's it.
If app can't navigate - it does nothing.