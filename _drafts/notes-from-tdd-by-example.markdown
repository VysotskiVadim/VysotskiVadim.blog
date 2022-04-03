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

Warning ⚠️  
The notes are just ideas I got or learned reading the book.
They don't represent or substitute the book.
I may have understood Kent wrong.

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

Clean code that works is a goal of TDD.

TDD doesn't guarantee flashes of insight at the right moment.
But TDD creates a perfect environment for them.
Confidence giving tests let up apply any insight as soon as it comes.

Just make things work on the implementation stage.
Don’t waste your time cleaning up the code. 
Duplication will help you find missing design elements later in the refactoring stage.

The less code you need to write to get to a green bar, the safer you are.
Don't write tests that make you write much code on the implementation stage.

What if I write tests after code?
Code without tests makes you less confident and more stressed.
The more stress you have the less testing you do.
The less testing you do the more stress you have.
You're getting into cycle.  
Write tests before code.

Start a test from an assert.
A project starts from a story, a feature from a test, a test from an assert.

Don't test 10 different inputs if they lead to the same design and implementation decisions as three inputs.

You're writing tests for a reader, not a computer only.

Focus only on one problem.
Don't spread your mental resources on other things.
Concentration increases your productivity.  
Red stage - think about what you want from a unit.  
Green stage - work on making test green, don't care about quality.  
Refactoring stage - make the code that works clean.  

What if I get an insight about a feature Y when I'm working on a feature X.
Write the insight down and get back later to it.
Don't let new ideas spoil your concentration.

Write all your ideas about a unit down.
Select an easiest one to achieve and start your TDD cycle.
Consider every idea as a step to your goal.
Implementing ideas one by one, you're moving step by step to the goal.

A program grows from known to unknown.
In the beginning, you don't know how exactly you're going to solve your problem.
On each TDD cycle, you learn more about it.
New knowledge affects your code: you're changing API, tests, and implementation.
New code brings you new knowledge and ideas about the problem.
This feedback loop is how a program grows in TDD.

Test doubles add risk to your project.
Their behavior can be different from real objects.
Write tests for a test double to reduce that risk.
You can replace the test double with a real object in tests later.

The log string pattern helps you to check the order of called methods.
Whenever a method is called, append it to the log string.
Compare log string with an expected result in a test.
`assertEquals("methodA methodC methodB", subjectUnderTest.logString)`

Are you working alone or independently from the team?
Finish day's work on the red stage.
A broken test will help you quickly remember where you stopped yesterday.

Are you working with a team and integrating your code often?
Finish day's work with green tests only.
You won't know the next morning if the feature isn't implemented yet or one of your colleagues has broken something.

Kent suggests learning how a new library works via tests.
Instead of trying using the library in your app, write a test for it.
This way you check if the library behaves in the way you think it does.
Plus, on each update, you can rerun tests to make sure that the library didn't change the behavior you rely on.  
But I prefer a different strategy.
My final goal is to make a feature that works.
Why do I need to have tests against a library which is not my final goal?
It doesn't really matter how the library behaves until the feature works.
Why not write tests for your unit which uses the library internally.
Learn and explore the new library developing your unit in tiny steps.
This way you're gonna get red tests only when changes in the library affect your functionality.