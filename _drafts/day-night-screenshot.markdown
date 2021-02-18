---
layout: post
title:  Day-Night Screenshot Tests
description: "Best practice of using facebook screenshot tests: day-night screenshots"
date:   2021-01-03 12:00:00 +0300
image: https://media.githubusercontent.com/media/VysotskiVadim/VysotskiVadim.github.io/master/assets/day-night-screenshots.jpg
postImage:
  src: day-night-screenshots
  alt: 'eclipse of the moon'
---

### Introduction

Imagine a regular software developer, let's call her Lucy.
She wants to implement a new functionality, but requirements hardly fits existing architecture.
It's not a problem, because her team actively uses auto tests.
She could change and adopt existing architecture to any requirement.
Then Lucy runs tests to make sure that she hasn't broken anything.
Now she could easily implement a new feature.

Developers handle rapidly changing requirements using **Refactoring + Auto Tests**.
It's straight forward to add new feature if requirements is aligned with existing architecture.
You aren't afraid to change app's architecture if you're confident in your tests.
Android UI is not an exception.

### Screenshots tests

You can easily create new screens if you have well designed infrastructure: Styles, Themes, and custom Views.
But you need to change it from time to time with respect to new features.

Screenshot tests don't let me break existing UI when I modify basic Themes, Syles, or custom views.
Test records image with UI that user should see.
After the code changes, test record new image and compare pixel by pixel with the previous one.
You shouldn't change even a single pixel during refactoring, otherwise test fails.

### Our way of doing screenshots tests

We have been using [Shot](https://github.com/Karumi/Shot) for 1,5 year.
It's built on top of [facebook screenshot test for Android](https://github.com/facebook/screenshot-tests-for-android)
and provides more features.
Checkout [Shot's readme](https://github.com/Karumi/Shot/blob/master/README.md) to get a better understanding 

I tried many different techniques of making screenshots.
Some of them was so useful,
so I mush share it with you!
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

#### Entry point 1: Record activity

Try read the code.
Don't worry if something isn't clear,
explanation is right after the code.

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

There is 3 stages: record day, switch to the night, record night.

Activity is in the day mode by default.
I get the activity using `waitForActivity` [extension](https://github.com/Karumi/Shot/blob/master/shot-android/src/main/java/com/karumi/shot/ActivityScenarioUtils.kt#L14), and record with the overridden name.
The light mode screenshot is ready.

Should I override screenshot name?
Yes.
Library uses name of the test for screenshot by default.
We generate 2 screenshots in one test.
To make the screenshot name unique add *_day* and *_night* postfix to the name.

`AppCompatActivity` lets you switch between day and night modes.
Once you call `setLocalNightMode` activity restarts, i.e. Android recreates it.
New activity uses night resources.
For the user it seems like UI has just changed the colors.

Now activity is in the night mode.
You need to get a link to a new activity and record it with overridden name.

### Links
* [Post image](https://flic.kr/p/qZYThs)
* [Shot](https://github.com/Karumi/Shot)
* [Example project](https://github.com/VysotskiVadim/screenshot-tests-best-practice)