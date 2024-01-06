---
layout: post
title: "OutOfMemoryError on Android: find the root cause"
date: 2024-01-06 11:00:00 +0100
image: /assets/slow-down.jpg
description: ""
postImage:
  src: slow-down
  alt: A slow down sign
linkToGithubText: "See the full file on the Github."
twitterLink: https://twitter.com/VysotskiVadim/status/1532672644809732098
---

## Introduction

Dealing with the `OutOfMemoryError` can be challenging.
The error occurs when the Android runtime doesn't have enough memory to allocate new objects.
When good chunk of memory has already been leaked, `OutOfMemoryError` could happen in any part of your or third-party code.
The error's stack trace rarely points to the specific location of the memory leak that caused `OutOfMemoryError`.



