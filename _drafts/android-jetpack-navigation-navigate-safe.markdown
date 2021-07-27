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
It's either work or doesn't.
There's not middle state of partially working.
Sometime it's useful, sometimes not.

I'm okay with unhandled exceptions during development or testing.
But it's not acceptable for production.
Imagine user opens settings screen and app crashes.
It's better to show error message or do nothing when something goes wrong during navigation.

In this article I will share how I used Jetpack Navigation on my last project.
My application doesn't crash even if something goes wrong.

Given approach also saved us from the issues related to double navigation ```java.lang.IllegalArgumentException: navigation destination XXX is unknown to this NavController```.
I can quickly click a few times on the button, which triggers navigation, but app navigates one one time.

## Safe navigation

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
In general you can have two options: ignore errors or send them to crash tracker.

I used to send errors as non-fatal crash in crashlytics.
It didn't go well.
We got too many false positive errors.
Every time user clicked simultaneously on two buttons the app sent not-fatal error ```java.lang.IllegalArgumentException: navigation destination XXX is unknown to this NavController```.
And there is no stable way to distinguish potentially fixable error from junk.

I decided to ignore any errors during navigation.
I just log it and this is it.
If app can't navigate - it does nothing.

### Always use navigateSafe

It's hard to remember that you and your teammates should prefer `navigateSafe` wrapper over default `navigate`.
Linter can help remind us when we forget.

{% include image.html src="safe-jetpack-navigation-linter" alt="Linter rule highlight error" %}

Checkout [linter rule on github](https://github.com/VysotskiVadim/jetpack-navigation-example/blob/master/lintrules/src/main/java/dev/vadzimv/jetpack/navigation/lintrules/UnsafeNavigationDetector.kt)
and checkout [the article about linter rules](https://proandroiddev.com/implementing-your-first-android-lint-rule-6e572383b292) if you aren't familiar with custom linter rules.

It's a lot of code, but don't worry it's simple.

Step 1: tell the linter method name that you'd like to inspect.
```kotlin
override fun getApplicableMethodNames(): List<String> = listOf("navigate")
```
Step 2: report error if method `navigate` is member of `androidx.navigation.NavController`.
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
`settingsButton` navigates user to the settings screen.
`homeButton` navigates user to the home screen.

Let's try navigating using destinations.
```kotlin
settingsButton.setOnClickListener {
    findNavController().navigateSafe(R.id.settingsFragment)
}
homeButton.setOnClickListener {
    findNavController().navigateSafe(R.id.homeFragment)
}
```

What does happen when user clicks two buttons simultaneously?
App navigates two times, to `settingsFragment` and than to `homeFragment`, or other way around.
I.e. user have both screens in the back stack.

Now replace destinations by actions and try click 2 buttons simultaneously again.
```kotlin
settingsButton.setOnClickListener {
    findNavController().navigateSafe(R.id.action_navigation_notifications_to_settingsFragment)
}
homeButton.setOnClickListener {
    findNavController().navigateSafe(R.id.action_navigation_notifications_to_homeFragment)
}
```
With actions, first of two simultaneous clicks causes navigation.
Second click causes `IllegalStateException` which is handled by `navigateSafe` wrapper.
I.e. first navigation wins, no crashes.

## Summary

Think about prod users.
You implement your app for them.
Don't let it crash if some screen can't be open.

## Links

* [Post image](https://flic.kr/p/a2rJ6x)
* [Example project](https://github.com/VysotskiVadim/jetpack-navigation-example)