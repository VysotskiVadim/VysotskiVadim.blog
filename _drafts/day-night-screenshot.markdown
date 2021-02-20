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

### How could screenshot tests help you?

Developers like to generalize their problems to build architecture/infrastructure.
Infrastructure is some code, that is used by many features.
For Android UI it is Styles, Themes, and custom Views.
Once you've defined styles guide and implemented it in styles,
adding a new screen is just a piece of cake.

Requirements are changing.
You get a new features that make you modify existing infrastructure a bit.
From time to time you alter styles hierarchy or 
add new capabilities to custom views.

TODO: something about regression

Screenshot tests don't let me break existing screens when I modify basic Themes, Syles, or custom views.
Test records image with UI that user should see.
After the code changes, test records new image and compare pixel by pixel with the previous one.
You shouldn't change even a single pixel during refactoring, otherwise test fails.

### How to do screenshot tests on Android?

We have been using [Shot](https://github.com/Karumi/Shot) for 1,5 year.
It's built on top of [facebook screenshot test for Android](https://github.com/facebook/screenshot-tests-for-android)
and provides more features.
Checkout [Shot's readme](https://github.com/Karumi/Shot/blob/master/README.md) to get a better understanding 

I tried many different techniques of making screenshots.
Some of them was extremely useful.
I mush share at least one technique with you!
Today we will talk about the top one - infrastructure for Day Night screenshot tests.

### Day night screenshot test

Dark theme support doubles testing effort.
You have to check 2 UIs per one feature: light and dark version.
I as a lazy developer want to avoid it by automation.

We defined 2 entry points `compareDayNightScreenshots` for screenshots recording, one for activities and the other for views.
When you call it, it automatically record screen 2 times: day and night UI.
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
After the execution we get [4 screenshots](https://github.com/VysotskiVadim/screenshot-tests-best-practice/tree/master/app/screenshots/debug).

### Entry point 1: Record an activity

There are 3 stages: record day UI, switch activity to the night mode, record night UI.

Activity is in the day mode by default.
Let's start from recording a day UI:
```kotlin
val dayActivity = activityScenario.waitForActivity()
compareScreenshot(dayActivity, name = screenshotName("day"))
```
I got the activity using `waitForActivity` [extension](https://github.com/Karumi/Shot/blob/master/shot-android/src/main/java/com/karumi/shot/ActivityScenarioUtils.kt#L14), and recorded with the overridden name.
The light mode screenshot is ready.

Why do we need to override screenshot name?
Library uses name of the test for the screenshot by default.
We generate 2 screenshots in one test.
To make the screenshot name unique add *_day* and *_night* postfix to the name.

Turn on the night mode.
```kotlin
dayActivity.runOnUiThread {
    dayActivity.delegate.localNightMode = AppCompatDelegate.MODE_NIGHT_YES
}
```
`AppCompatActivity` lets you switch between day and night modes.
Once you called `setLocalNightMode` activity restarts, i.e. Android recreates it.
New activity uses night resources.
For the user it seems like UI has just changed the colors.

Now activity is in the night mode.
You need to get a link to the new activity and record screenshot with overridden name.
```kotlin
val nightActivity = activityScenario.waitForActivity()
compareScreenshot(nightActivity, name = screenshotName("night"))
```

If you put it all together you will get the first entry point.
{% highlight kotlin %}
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
{% endhighlight %}

### Entry point 2: Record a view

There is only 2 stages in view day-night screenshot recording: record day and record night view.

View is in the day mode by default.
Do a regular actions to record screenshot: inflate, measure, layout, and draw.

```kotlin
// inflate
val dayView = LayoutInflater.from(context).inflate(viewId, null, false)
// measure and layout
runOnMainSync { setupView(dayView) }
// draw
Screenshot.snap(dayView).setName(screenshotName("day")).record()
```
Congratulations, day screenshot is ready.

How to record view in a night mode?
Inflater could use different resources with respect to configuration.
If configuration is day, it takes colors from `values/color.xml`,
and `values-night/color.xml` for the night configuration. 
Configuration is the part of the context.
To start using night resources create a new context with the overridden configuration.

```kotlin
val nightConfiguration = Configuration(context.resources.configuration)
nightConfiguration.uiMode =
    Configuration.UI_MODE_NIGHT_YES or (nightConfiguration.uiMode and Configuration.UI_MODE_NIGHT_MASK.inv())
val nightContext = context.createConfigurationContext(nightConfiguration)
```

### Links
* [Post image](https://flic.kr/p/qZYThs)
* [Shot](https://github.com/Karumi/Shot)
* [Example project](https://github.com/VysotskiVadim/screenshot-tests-best-practice)