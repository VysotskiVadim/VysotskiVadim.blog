---
layout: post
title: "OutOfMemoryError on Android: looking for the cause"
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

`OutOfMemoryError` requires a special approach in troubleshooting.
The delay between the memory leak, which causes the error, and the moment when the Android Runtime realizes that there is no more memory makes regular debug info useless.
The error's stack trace points to an allocation that happened when the memory is already full.
Logs don't contain info about allocations and objects collected by the Garbage Collector.
A different approach is needed for addressing `OutOfMemoryError`.

This article explains how to collect data essential to finding the cause of `OutOfMemoryError`: a heap dump at the moment of the last allocation, which failed with `OutOfMemoryError`.

## Collect Heap Dump

