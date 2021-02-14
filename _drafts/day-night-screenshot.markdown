---
layout: post
title:  Day and Night Screenshot Tests
description: "Best practice of using facebook screenshot tests: day night screenshots"
date:   2021-01-03 12:00:00 +0300
image: https://media.githubusercontent.com/media/VysotskiVadim/VysotskiVadim.github.io/master/assets/day-night-screenshots.jpg
postImage:
  src: day-night-screenshots
  alt: 'eclipse of the moon'
---

### What and Why Screenshot Tests

Imagine a regular software developer, let's call her Lucy.
Lucy works on a large project.
Her team reuses a lot of code and easily add new features.
Their code base is well designed.

Lucy wants to implement a new functionality, but requirements hardly fit existing architecture.
It's not a problem, because her team actively uses auto tests.
She could adopt existing architecture to any new requirements.
Then Lucy runs tests to make sure that she hasn't broken anything.
Now she could easily implement a new feature.

Developers handle rapidly changing requirements using **Refactoring + Auto Tests**.
It's easy to add new feature if it's aligned with existing infrastructure.
You aren't afraid to change app's infrastructure if you're confident in your tests.

Android UI is not an exception.
You can easily create new screens if you have well defines Styles and Themes.
But you need to change Styles and Theme from time to time with respect to new requirements.

Screenshot tests doesn't let me break existing UI when I modify basic Styles ans Themes.
Test record image of what user should see and saves it.
After the code changes, test record new image and compare pixel by pixel with an old one.
You shouldn't change even a single pixel during refactoring.

We have been using screenshot tests for 1,5 years.
I tried many different techniques and some of them was extremely useful.
I must share it with you.


I use [Shot](https://github.com/Karumi/Shot) for more than a year.
It's a fork of [facebook screenshot test for Android](https://github.com/facebook/screenshot-tests-for-android) with extra features.


### Links
* [Post image](https://flic.kr/p/qZYThs)