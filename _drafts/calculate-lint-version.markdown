---
layout: post
title: "Setup Android lint dependencies"
date: 2021-07-26 19:00:00 +0300
image: /assets/jetpack-safe-helmets.jpg
description: "How to specify lint dependency version when you implement a custom lint rule for Android project."
postImage:
  src: jetpack-safe-helmets
  alt: Helmets makes navigation safe
---

## Introduction

When you write custom linter rule,
you connect two dependencies in `build.gradle` file
```groovy
compileOnly "com.android.tools.lint:lint-api:$lint_version"
compileOnly "com.android.tools.lint:lint-checks:$lint_version"
```

What the `lint_version` should be?
You can't just use the latest like you do with other libraries. 


## Select version number

Linter's dependencies should be compatible with Android Gradle Plug, aka AGP, version that you use.

Find version of your AGP.
Open root `build.gradle` and find AGP.
Or just search for a string **com.android.tools.build:gradle:**.
```groovy
buildscript {
    ...
    dependencies {
        classpath "com.android.tools.build:gradle:4.2.2"
        ...
    }
    ...
}
```
Mine AGP has version 4.2.2.

Calculate linter's dependencies version.
Add 23 to a major number.
AGP and linter versions don't match because of
[historical reasons](https://googlesamples.github.io/android-custom-lint-rules/api-guide.html#example:samplelintcheckgithubproject/lintversion?).

**lintVersion = gradlePluginVersion + 23.0.0**

In my case **4.2.2 + 23.0.0 = 27.2.2**.

## Automate

Google samples recommend you to calculate version manually every time you update AGP.
It's not a true dev way.
Let's automate it in 3 steps.

Step 1. Extract the AGP version to a project's ext properties.

```groovy
buildscript {
     ext {
        agp_version = "4.2.2"
    }
    ...
    dependencies {
        classpath "com.android.tools.build:gradle:$agp_version"
        ...
    }
    ...
}
```

Step 2. Calculate linter version in linter's `build.gradle`
```goovy
def (agp_major, agp_minor, agp_patch) = rootProject.ext.agp_version.split("\\.").collect { it.toInteger() }
def lint_version = "${agp_major + 23}.${agp_minor}.${agp_patch}"
```
Code above gets AGP version from root project's ext properties, parces it, and adds 23 to a major version.

