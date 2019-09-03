---
layout: post
title:  "Old forgotten async approach"
date:   2019-09-03 12:00:00 +0300
---

Now days it's so many approaches to write asynchronous code: callbacks, Promises/Futures, Rx, async/await, coroutines. But all of them requires infrastructure: to use callbacks conveniently you need functions as first class citizens in chosen language as well as for Futures/Promises, Rx requires implementation of tons of operators(without them it's just a observer), to use async/await and coroutines you need compiler which can transform your code to state machines.

But what if you can't use them? Stop! You may ask why can't I use them?! I see at least 2 reasons when it's true:

* you may found that some language solves your problem better then others: like C for embedded devices;
* it's a lot of code which has been written, and still developing and supporting, at time when popular now days approaches haven't exited yet or wasn't applicable: AOSP is a great example.

We will consider some study example then move to something real, let's go!

## Study

Task: make 3 network request using just one thread which shouldn't been blocked: 