---
layout: post
title:  Notes from the "TDD by example book"
description: "My notes after reading the Test Driven Development: By Example book"
image: /assets/resized/pages_768.jpg
postImage:
  src: pagination-2
  alt: An opened book with many pages
---

## Into

I bought the "Test Driven Development: By Example" by Kent Beck on [amazon](https://www.amazon.com/dp/B095SQ9WP4/ref=cm_sw_r_tw_dp_56ZFZYAG5RRE5356BWB8) for kindle.
While reading the book I wrote a few notes which I'd like to share.

Notes are just a few ideas I took away from the book, nothing more.
They don't represent or substitute the book.
The "Money" and "XUnit" examples are the most valuable things I found in this book.
I do recommend you to see how Kent develops using TDD and shares his thought meanwhile.
I noticed changes in my tests after reading this book.

## Notes

The more stress you have the less testing you do.
The less testing you do the more errors you make.
The more errors you make the more stress you have.
It's a loop that makes your state worse each iteration.

Automated tests could break the cycle.
The more stress you have the more tests you write and run.
The more tests you run and write the fewer errors you make.
The fewer errors you make the less stress you have.

Tests that you get out of the TDD cycle don’t cover all testing for a project.
However, TDD affects the way you test.
When your code becomes stable enough, a professional tester could get enough time for usability, exploratory, and other types of testing.

How to improve tests coverage?
An obvious option is to add more tests to cover all possible inputs/cases/states.
Another option is to simplify the logic.
Decrease the count of possible cases/states/inputs on the refactoring step.
You will get better tests coverage with the same set of tests.

General pattern.  
Write a test that verifies one scenario of usage.  
Verify the test fails.  
Hardcode results.  
Verify the test passes.  
Refactor implementation by rewriting to a generic solution, i.e. supports more than 1 scenario.  

The triangulation technique.  
Write a test that verifies one scenario of usage.  
Verify the test fails.  
Hardcode results.  
Verify the test passes.  
Write another test that verifies another scenario of usage.  
Implement a generic solution.  

You have `test1` which tests `behavior1`.
You want to test `behavior2` which depends on the `behavior1`.
I always had doubts if I should verify `behavior1` in `test2`.
Kent Beck says that `test2` can be simple and confident that `behavior1` works if we already have `test1`.

Should I run a new test if I know it will fail?
Yes, always!
You save yourself from errors in the test.
If a red test becomes green after implementation - it tests what you want.

Make your tests fast.
Fast tests lead to frequent runs, which leads to faster feedback.
Application(E2E) tests can't be fast enough.
Seek tests at a smaller scale than the whole application.

It's fast to test small and isolated modules.
Break your problem into small and independent pieces.
Then compose a solution out of many highly cohesive and loosely coupled modules.
Test each of the modules in isolation.

Test Driven Development isn't a testing technique.
TDD helps me design a unit by trying to use it in tests.
I can design a complex feature stepping tiny steps,
focusing only on the current tiny problem, 
getting feedback about design and stability immediately.