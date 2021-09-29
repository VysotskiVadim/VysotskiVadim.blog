---
layout: post
title: "Painless unit tests"
date: 2021-09-29 12:00:00 +0300
image: /assets/Asteracea_poster_3_part_2.jpg
description: "Rules that makes my tests valuable."
postImage:
  src: Asteracea_poster_3_part_2
  alt: Types of Asteraceaes
---

### Introduction

I've been writing unit tests since 2017.
I wrote many bad tests.
Bad tests didn't help me, they made my work harder.
I wrote many good tests.
Good tests helped me to refactor without bugs and deliver complex features faster.
Every time I wrote good or bad test I wondered:
why some tests help me work productive and some prevent from it. 

Over the time I learned more about testing and developed a set of rules that I follow.
Rules help me write good tests.
This article is an attempt to extract the rules from my head and put it on the paper.

The rules can be useful for newbies.
Rules doesn't overwhelm you with long and complex explanations.
When you learn more, you understand why you need them.
Or you can violate rules to get a valuable experience 😉.

# Rules

### Test is one of the clients.
A test shouldn't require changes when you refactor inside a module.
Use SUT in tests like its clients do, i.e. use only public API.

### Test should be specific.
Logic inside test isn't allowed.
Hardcode expected result.
Make test specific and simple.
Remember: Code is generic, tests are specific. 

### Isolate test from the world
Network, Filesystem, Current time, Random, Multithreading are not allowed. Fake them!

### Isolate tests from each other
You should be able to run tests in any order and any subsets of the tests.
Every test prepares an environment like it's the only one.
After the run, the test cleans up the environment and leaves it in the "untouched" state.

### Do not missuse test doubles
When you want a dependency to return a result - use Fake or Stub, do not use Mocks.
When you want to verify an interaction with an external system - use Mock.

### Do not overspecificate
Check only important things.
A test must fail when you break something, not when you add another feature.
A tests shouldn't break because of a new field that doesn't affect the tested feature.

### Do not check implementation details

For example it doesn't matter how many times 

