---
layout: post
title:  Day Night screenshot test
description: "Best practice of using facebook screenshot tests: day night screenshots"
date:   2021-01-03 12:00:00 +0300
image: https://media.githubusercontent.com/media/VysotskiVadim/VysotskiVadim.github.io/master/assets/day-night-screenshots.jpg
postImage:
  src: day-night-screenshots
  alt: 'eclipse of the moon'
---

Refactoring is a very important aspect of development.
We never know in advance what is the next thing that we're going to do,
so that new features don't always perfectly fit in existing architecture/code base.
Usually it's easier to refactor existing code so that it works in the same way as it used to work.
Existing auto tests can verify that we haven't broke anything by refactoring.
And then it's straight forward to add a new feature in prepared code base.

This applies not only for Java/Kotlin code, but for xml views, styles, and themes as well.
That is why I'm a big fan of 
[facebook screenshot test for Android](https://github.com/facebook/screenshot-tests-for-android) 
and its fork 
[Shot](https://github.com/Karumi/Shot).
Screenshot testing is a great way to avoid visual regression,
after test run you're sure that even a single pixel hasn't changed after restructuring of styles for example.

It's a hell to do regression testing for every screen that uses styles modified during refactoring.
And don't forget about **night mode**, **that doubles** your effort for regression.

In this article I want to share one practice from my project.
I find it very useful and want to share with community.