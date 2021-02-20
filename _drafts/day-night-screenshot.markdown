---
layout: post
title:  Day-Night Screenshot Tests
description: "The best practice of Android screenshot tests: day-night screenshots"
date:   2021-01-03 12:00:00 +0300
image: https://media.githubusercontent.com/media/VysotskiVadim/VysotskiVadim.github.io/master/assets/day-night-screenshots.jpg
postImage:
  src: day-night-screenshots
  alt: 'eclipse of the moon'
---

### Value of screenshot tests

Styles, Themes, and custom Views are infrastructure for Android app UI.
Once you've defined and implemented your style guide,
adding a new screen is just a piece of cake.

But it's hard to change infrastructure.
When you update some basic style, you have to retest all the screens that use it.
Do you like manual testing? I don't. I prefer automation!

Screenshot tests could be a solution for appearance auto testing.
Record exactly what user sees, i.e. pixels.
After refactoring record a new image to compare pixel by pixel with the previous one.
Refactoring shouldn't change even a single pixel, otherwise test fails.

### How to do screenshot tests on Android?

We have been using [Shot](https://github.com/Karumi/Shot) for 1,5 year.
It's built on top of [facebook screenshot test for Android](https://github.com/facebook/screenshot-tests-for-android)
and provides more features.
Checkout [Shot's readme](https://github.com/Karumi/Shot/blob/master/README.md) to know how it works.

I tried many different techniques of making screenshots.
Some of them was extremely useful.
I mush share at least one technique with you!
Today we will talk about the top one - infrastructure for Day Night screenshot tests.

### Day night screenshot test

Dark theme doubles testing effort.
You have to check 2 UIs per one feature: light and dark version.
But not for developer who has screenshot tests.

I defined 2 entry points with name `compareDayNightScreenshots` for screenshots recording,
one for activities and the other for views.
It records screen 2 times, for day and night mode.
```kotlin
@Test
fun activityScreenshotTest() {
    val scenario = ActivityScenario.launch(ScrollingActivity::class.java)
    compareDayNightScreenshots(scenario)
}

@Test
fun viewScreenshotTest() = compareDayNightScreenshots(R.layout.content_scrolling) {
    ViewHelpers.setupView(it).setExactWidthPx(800).setExactHeightPx(4000).layout()
}
```
After the execution I get [4 screenshots](https://github.com/VysotskiVadim/screenshot-tests-best-practice/tree/master/app/screenshots/debug).

### Entry point #1: Record whole activity

#### Record day Activity
Activity is in the day mode by default.
We can record day UI immediately:
```kotlin
val dayActivity = activityScenario.waitForActivity()
compareScreenshot(dayActivity, name = screenshotName("day"))
```
In the code above
I got the activity using `waitForActivity` [extension](https://github.com/Karumi/Shot/blob/master/shot-android/src/main/java/com/karumi/shot/ActivityScenarioUtils.kt#L14), and recorded with the overridden name.

Why do we need to override screenshot name?
Library uses name of the test for the screenshot by default.
But we're going to generate 2 screenshots in one test.
To make the screenshot name unique add *_day* and *_night* postfix to the name.

#### Switch Activity to the night mode

```kotlin
dayActivity.runOnUiThread {
    dayActivity.delegate.localNightMode = AppCompatDelegate.MODE_NIGHT_YES
}
```
`AppCompatActivity` lets you switch between day and night modes.
When you call `setLocalNightMode` activity restarts, i.e. Android recreates it.
Recreated activity uses night resources.
For the user it seems like UI has just changed the colors.

Get a link to the new activity and record screenshot with overridden name again.
```kotlin
val nightActivity = activityScenario.waitForActivity()
compareScreenshot(nightActivity, name = screenshotName("night"))
```

#### Result
Put it all together and you get the entry point for activity screenshot recording.
```kotlin
fun <T : AppCompatActivity> ScreenshotTest.compareDayNightScreenshots(
    activityScenario: ActivityScenario<T>
) {
    // record day ui
    val dayActivity = activityScenario.waitForActivity()
    compareScreenshot(dayActivity, name = screenshotName("day"))
    // turn on night mode
    dayActivity.runOnUiThread {
        dayActivity.delegate.localNightMode = AppCompatDelegate.MODE_NIGHT_YES
    }
    // record night mode
    val nightActivity = activityScenario.waitForActivity()
    compareScreenshot(nightActivity, name = screenshotName("night"))
}
```

### Entry point #2: Record a view

View's recording is even more straight-forward:

1. Inflate the view, i.e. create views hierarchy from xml using `LayoutInflater`;
2. Measure and Layout the view;
3. Record the screenshot.

Repeat it 2 times, for day and night view.

#### Record a day view
```kotlin
// inflate
val dayView = LayoutInflater.from(context).inflate(viewId, null, false)
// measure and layout
runOnMainSync { setupView(dayView) }
// draw
Screenshot.snap(dayView).setName(screenshotName("day")).record()
```

`setupView` is a function that measures and layouts a view.
I pass it as a parameter to entry point `compareDayNightScreenshots`.
If you don't know what is measure\layout\draw - read [the doc](https://developer.android.com/guide/topics/ui/how-android-draws).
```kotlin
compareDayNightScreenshots(R.layout.content_scrolling) {
    ViewHelpers.setupView(it).setExactWidthPx(800).setExactHeightPx(4000).layout()
}
```

`runOnMainSync` is custom utils function that executes block of code in main thread and blocks instrumentation thread.

#### Record a night view
For a night view `Inflater` uses night resources.
Instead of `values/color.xml`
it takes values from `values-night/color.xml`.
`Inflater` choses right file based on `Configuration`, that is the part of the context.

To start using night resources create a new context with the overridden configuration.
```kotlin
val nightConfiguration = Configuration(context.resources.configuration)
nightConfiguration.uiMode =
    Configuration.UI_MODE_NIGHT_YES or (nightConfiguration.uiMode and Configuration.UI_MODE_NIGHT_MASK.inv())
val nightContext = context.createConfigurationContext(nightConfiguration)
```

Now inflate and record the night view.
```kotlin
val nightView = LayoutInflater.from(nightContext).inflate(viewId, null, false)
runOnMainSync { setupView(nightView) }
Screenshot.snap(nightView).setName(screenshotName("night")).record()
```
#### Themes

To let the view access the app theme, wrap your context in theme wrapper.
```kotlin
val context = ContextThemeWrapper(
    InstrumentationRegistry.getInstrumentation().targetContext,
    theme
)
```

#### Result
Put all code above into one function to create entry point for views.
```kotlin
fun compareDayNightScreenshots(
    @LayoutRes viewId: Int,
    @StyleRes theme: Int = R.style.Theme_Screenshottestsbestpractice,
    setupView: (View) -> Unit
) {
    val context = ContextThemeWrapper(
        InstrumentationRegistry.getInstrumentation().targetContext,
        theme
    )
    val dayView = LayoutInflater.from(context).inflate(viewId, null, false)
    runOnMainSync { setupView(dayView) }
    Screenshot.snap(dayView).setName(screenshotName("day")).record()

    val nightConfiguration = Configuration(context.resources.configuration)
    nightConfiguration.uiMode =
        Configuration.UI_MODE_NIGHT_YES or (nightConfiguration.uiMode and Configuration.UI_MODE_NIGHT_MASK.inv())
    val nightContext = context.createConfigurationContext(nightConfiguration)
    val nightModeWrapper = ContextThemeWrapper(
        nightContext,
        theme
    )

    val nightView = LayoutInflater.from(nightModeWrapper).inflate(viewId, null, false)
    runOnMainSync { setupView(nightView) }
    Screenshot.snap(nightView).setName(screenshotName("night")).record()
}
```

### Summary

If you already use Shot of Facebook screenshot tests,
just copy my infrastructure to your project. 
You will get more screenshots and less testing effort.

### Links
* [Post image](https://flic.kr/p/qZYThs)
* [Shot](https://github.com/Karumi/Shot)
* [Example project](https://github.com/VysotskiVadim/screenshot-tests-best-practice)
* [How Android draws](https://developer.android.com/guide/topics/ui/how-android-draws)