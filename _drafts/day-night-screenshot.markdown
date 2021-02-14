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

### Introduction

Imagine a regular software developer, let's call her Lucy.
Lucy works on a large project.
Her team reuses a lot of code and easily add new features.
Their code base is well designed.

Lucy wants to implement a new functionality, but requirements hardly fit existing architecture.
It's not a problem, because her team actively uses auto tests.
She could prepare existing architecture to any requirement.
Then Lucy runs tests to make sure that she hasn't broken anything.
Now she could easily implement a new feature.

Developers handle rapidly changing requirements using **Refactoring + Auto Tests**.
It's easy to add new feature if it's aligned with existing infrastructure.
You aren't afraid to change app's infrastructure if you're confident in your tests.
Android UI is not an exception.

### Screenshots tests

You can easily create new screens if you have well designed infrastructure: Styles, Themes, and custom Views.
But you need to change it from time to time with respect to new requirements.

Screenshot tests don't let me break existing UI when I modify basic Themes, Syles, or custom views.
Test records image with UI, that user should see.
After the code changes, test record new image and compare pixel by pixel with the previous one.
You shouldn't change even a single pixel during refactoring.

We have been using [Shot](https://github.com/Karumi/Shot) for 1,5 year.
It's built on top of [facebook screenshot test for Android](https://github.com/facebook/screenshot-tests-for-android)
and provides more features.
Checkout [Shot's readme](https://github.com/Karumi/Shot/blob/master/README.md) to get a better understanding 

I tried many different techniques of making screenshots.
Some of them was so useful,
so I mush share it with you!
Today we will talk about the top one - infrastructure for Day Night screenshot tests.

### Day night test


I use  for more than a year.
It's a fork of  with extra features.


### Links
* [Post image](https://flic.kr/p/qZYThs)