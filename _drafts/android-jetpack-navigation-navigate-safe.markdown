---
layout: post
title: "Navigate without crashes using Android Jetpack Navigation"
date: 2021-07-26 19:00:00 +0300
image: /assets/jetpack-safe-helmets.jpg
description: "Do not crash an app during navigation. Navigate safely."
postImage:
  src: jetpack-safe-helmets
  alt: Helmets makes navigation safe
---

## Introduction

Android Jetpack navigation throws an exception if something is wrong.
It's either work or not.
There's not middle state of partially working.

I'm okay with unhandled exceptions during development or testing.
But it's not acceptable for production.
Imagine user opens settings screen and app crashes.
It's better to show error message or do nothing when something goes wrong during navigation.

In this article I will share how I used Jetpack Navigation on my last project.
My application doesn't crash even if something goes wrong.

Given approach also saved us from the issues related to double navigation ```java.lang.IllegalArgumentException: navigation destination XXX is unknown to this NavController```.
I can quickly click a few times on the button, which triggers navigation, but app navigates one one time.

If you don't want to read the article,
feel free jumping directly to [the code](https://github.com/VysotskiVadim/jetpack-navigation-example/blob/master/app/src/main/java/dev/vadzimv/jetpack/navigation/example/navigation/SafeNavigationi.kt)

## Safe navigation

Safe navigation consists of a few steps. Let's consider them one by one.

### Error handling

To avoid crashes handle all exceptions from Jetpack Navigation library.
I use Jetpack navigation via wrappers functions, which handles all errors.

```kotlin
@SuppressLint("UnsafeNavigation")
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
I just log it and this is it.
If app can't navigate - it does nothing.

### Always use navigateSafe

It's hard to remember that you and your teammates should prefer `navigateSafe` over default `navigate`.
I implemented a linter rule that reminds us about safe navigation.

{% include image.html src="safe-jetpack-navigation-linter" alt="Linter rule highlight error" %}

Checkout [linter rule on github](https://github.com/VysotskiVadim/jetpack-navigation-example/blob/master/lintrules/src/main/java/dev/vadzimv/jetpack/navigation/lintrules/UnsafeNavigationDetector.kt)
and checkout [the article about linter rules](https://proandroiddev.com/implementing-your-first-android-lint-rule-6e572383b292) if you aren't familiar with custom linter rules.

It's a lot of code in the rule, but don't worry it's simple.

Step 1: tell the linter method name that you'd like to inspect.
```kotlin
override fun getApplicableMethodNames(): List<String> = listOf("navigate")
```
Step 2: report error if `navigate` is member of `androidx.navigation.NavController`.
```kotlin
if (evaluator.isMemberInClass(method, "androidx.navigation.NavController")) {
    context.report(...)
}
```
### Prefer actions to directions

I always use actions instead of directions.
It helps handle double navigation.
Consider following example.

You have a screen with 2 buttons.
`settingsButton` navigates user to 

## Links

* [Post image](https://flic.kr/p/a2rJ6x)