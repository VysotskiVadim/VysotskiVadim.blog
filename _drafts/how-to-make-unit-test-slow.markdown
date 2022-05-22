---
layout: post
title: "Slow unit tests"
date: 2022-03-14 12:00:00 +0300
image: /assets/slow-down.jpg
description: "Slow your tests down in a few simple steps."
postImage:
  src: slow-down
  alt: A slow down sign
---
## Intro

I've seen a test suite which could have completed in seconds but it executes for 20 minutes.
What does make it so slow?
I measured different factors that could slow test down in isolation.
This numbers help you understand how different decisions affect execution time of your test suite.

## Mock


## Coroutines
## Static mocking
## Robolectric
## Combine
## Summary
## Measurements

I run tests a few times from Android Studio.
I gathered execution times in [the table](https://docs.google.com/spreadsheets/d/1WaZOIJ67hcxg6cnQPjiuo-eVsp-acmwTQvJcZdnKUK4/edit?usp=sharing) and calculated average time.
The numbers you've seen in the article are average execution time of a several tries.

I run tests using following hardware:
```
  Model Identifier:	MacBookPro16,1
  Processor Name:	6-Core Intel Core i7
  Processor Speed:	2,6 GHz
  Number of Processors:	1
  Total Number of Cores:	6
  L2 Cache (per Core):	256 KB
  L3 Cache:	12 MB
  Hyper-Threading Technology:	Enabled
  Memory:	32 GB
```

## Links
* [Post image](https://www.flickr.com/photos/88158306@N03/45968616764/)