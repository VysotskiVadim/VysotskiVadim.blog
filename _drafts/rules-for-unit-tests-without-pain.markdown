---
layout: post
title: "Unit testing without pain"
date: 2021-09-29 12:00:00 +0300
image: /assets/Asteracea_poster_3_part_2.jpg
description: "N rules that makes your tests pain free"
postImage:
  src: Asteracea_poster_3_part_2
  alt: Types of Asteraceaes
---

### Tests must help you change a system {#tests-changes}
A test must fail when you break something, not when you add another feature.
A tests shouldn't break because of a new field that doesn't affect the tested feature.

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

Do not check how many times SUT has called a repository, check the result.
The way SUT interacts with the repository is implementation details that could be changed. 

