---
layout: post
title:  Error handling strategy for Android app
description: "How to organize error error handling in Android application."
---

There is something important, something that matters, something that I always miss - error handling strategy.
Strategy is a global plan applicable for all application code, it's a part of architecture.
I always use the straightforward one: when app crashes it's time for one more `try-catch`.

### The issue

Default error handling strategy given out of the box by Java far from perfect.
When something goes wrong
, for instance method was called on a pointer which is null,
code execution is interrupted by exceptions.
For developer it looks 

Basically exceptions itself is an object which contains info abo

Every time you miss the exception is a signal for runtime that we got into a stage which wasn't expected



What kind of problems do you have developing applications without 

Basic error handling strategy for software is straightforward:
when some process can't continue execution OS just shut it down.
That's fair.
Runtimes (Java or .Net for example) usually adhere to the same strategy.
To avoid crashes as a client developer I have only one option: setup an exception handling strategy in the app.
*Option to write code without bugs which cause exceptions isn't considered - it's impossible.*



Client application has default exceptions handing strategies as well,
it's called **crash**.


Android runtime is based on Java runtime.
In Java all the exceptions divided into two categories.