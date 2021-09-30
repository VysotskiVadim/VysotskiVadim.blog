---
layout: post
title: "Rules of painless unit tests"
date: 2021-09-29 12:00:00 +0300
image: /assets/school-rules-1887.jpg
description: "Rules that make unit tests useful."
postImage:
  src: school-rules-1887
  alt: The School rules painting
---

### Introduction

I've been writing unit tests since 2017.
I've written many bad tests.
Bad tests didn't help me, they made refactoring harder.
I've also written many good tests.
Good tests helped me to refactor without introducing regression bugs and deliver complex features faster.

Every time I wrote a good or a bad test I wondered:
why some tests help me work productive and some prevent it. 
Over time I learned more about testing and developed a set of rules that I follow.
Rules help me write good tests.
This article is an attempt to extract the rules from my head and put them on paper.

The rules can be useful for newbies.
Rules don't overwhelm you with long and complex explanations.
When you learn more, you understand why the rules make sense.
Or you can violate some rule to get a valuable experience 😉.

### Dictionary

**SUT** - system under the test.

# Rules

### Use SUT in tests as its clients do
Use only public API in the same way as SUT's clients.
A test shouldn't require changes when you refactor inside a unit.

### Tests should be specific
Logic inside test isn't allowed.
Hardcode expected result.
Make test specific and simple.
Remember: *Code is generic, tests are specific.*

### Isolate tests from the world
Network, Filesystem, Current time, Random, Multithreading, Sleeps, and Delays are not allowed.
Fake\Stub\Mock them.

### Isolate tests from each other
You should be able to run tests in any order and any subsets of the tests.
Every test prepares an environment like it's the only one.
After the run, the test cleans up the environment and leaves it in the "untouched" state.

### Do not misuse test doubles
When you want a dependency to return a result - use Fake or Stub, do not use Mocks.
Use Mocks when you want to verify an interaction with an external system.

### Do not overspecificate
Check only important things.
A test must fail when you break something, not when you add another feature.
Tests shouldn't break because of a new field that doesn't affect the tested feature.

### Do not check implementation details
If your case isn't communication with an external system
it doesn't matter how exactly SUT interacted with dependencies.
It's important that SUT returns a correct result or it stays in a correct state.
Internal communication is an implementation detail.
Count calls to dependencies and check called methods when it's important, for example when you send an email.

Do not check implementation details.
Implementation details change during refactoring.
Tests became Red when a changed feature works fine.

### Test you tests
Tests can contain mistakes.
Break SUT to see if the test fails when the code is broken.
Or write tests before the implementation to see how it becomes green.

### Class ≠ Unit
Don't create a test file for every class.
Test code by units.
A unit is a group of coherent classes that are hidden behind a [facade](https://en.wikipedia.org/wiki/Facade_pattern).
Unit tests help you refactor code inside a unit.
Just change the code and run tests.