---
layout: post
title: "Navigate safe using Android Jetpack Navigation"
date: 2021-07-26 19:00:00 +0300
image: /assets/parent-child-navigation.jpg
description: "Do not crash an app during navigation. Navigate safe."
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

Given approach also saved us from the issues related to double navigation. 