---
layout: post
title: "OutOfMemoryError on Android: looking for the cause"
date: 2024-01-06 11:00:00 +0100
image: /assets/green-robot-looking-for-a-leak.jpg
description: ""
postImage:
  src: green-robot-looking-for-a-leak
  alt: A green robot which is looking for a leak
twitterLink: https://twitter.com/VysotskiVadim/status/1532672644809732098
---

## Introduction

`OutOfMemoryError` requires a special approach in troubleshooting.
The delay between the memory leak, which causes the error, and the moment when the Android Runtime realizes that there is no more memory makes regular debug info useless.
The error's stack trace points to an allocation that happened when the memory is already full.
Logs don't contain info about allocations and objects collected by the Garbage Collector.
A different approach is needed for addressing `OutOfMemoryError`.

This article explains how to collect data essential to finding the cause of `OutOfMemoryError`: a heap dump at the moment of the last allocation, which failed with `OutOfMemoryError`.

## Heap Dump recording

The most useful information for `OutOfMemoryError` troubleshooting is a Java heap dump. You can explore which objects consume the memory, how much is consumed by each object, and what stops the Garbage Collector from collecting them.

[The official guide](https://developer.android.com/studio/profile/memory-profiler) provides instructions on collecting heap dumps from Android Studio.
Simply launch the profiler and click "Record".
The challenge lies in determining when to record.
The heap dump recording should coincide with the occurrence of a noticeable memory leak; otherwise, the heap dump won't be valuable.
The optimal moment for recording is when `OutOfMemoryError` happens, a task not feasible for a human to perform.

### When to record a heap dump

### How to record a heap dump