---
layout: post
title: "Pick lint version"
date: 2021-07-28 18:00:00 +0300
image: /assets/gears-automation.jpg
description: "How to pick lint dependency version when you implement a custom lint rule for Android project."
postImage:
  src: gears-automation
  alt: Gears
twitterLink: https://twitter.com/VysotskiVadim/status/1420402282412265481
---

## Introduction

When you write a custom lint rule,
you connect two dependencies in the `build.gradle` file
```groovy
compileOnly "com.android.tools.lint:lint-api:$lint_version"
compileOnly "com.android.tools.lint:lint-checks:$lint_version"
```

What the `lint_version` should be?
You can't just use the latest like you do with other libraries. 


## Select version number

The lint version must be compatible with the Android Gradle Plugin version, aka **AGP**.

Find the version of your AGP.
Open root `build.gradle` and find **com.android.tools.build:gradle:**.
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
My AGP has version 4.2.2.

Calculate the lint version.
Add 23 to the [major number](https://semver.org/).
*AGP and lint versions aren't the same because of
[some historical reasons](https://googlesamples.github.io/android-custom-lint-rules/api-guide.html#example:samplelintcheckgithubproject/lintversion?)*.

**lintVersion = gradlePluginVersion + 23.0.0**

In my case **4.2.2 + 23.0.0 = 27.2.2**.

## Automate

If you follow Google samples, you will calculate the version manually every time you update AGP.
It's not a true dev way.
The true dev way is automation.

Automate lint version calculation in 3 steps.

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

Step 2. Calculate lint version in lint's `build.gradle`
```goovy
def (agp_major, agp_minor, agp_patch) = rootProject.ext.agp_version.split("\\.").collect { it.toInteger() }
def lint_version = "${agp_major + 23}.${agp_minor}.${agp_patch}"
```
Code above gets AGP version from root project's ext properties, parses it, and adds 23 to a major version.

Step 3. Use `lint_version` in dependencies.

```groovy
def (agp_major, agp_minor, agp_patch) = rootProject.ext.agp_version.split("\\.").collect { it.toInteger() }
def lint_version = "${agp_major + 23}.${agp_minor}.${agp_patch}"

dependencies {
    compileOnly "com.android.tools.lint:lint-api:$lint_version"
    compileOnly "com.android.tools.lint:lint-checks:$lint_version"
}
```

Optional step 4. Enjoy.

## Useful links

* [Example project with custom lint rule](https://github.com/VysotskiVadim/jetpack-navigation-example).
Check out [root build.gradle](https://github.com/VysotskiVadim/jetpack-navigation-example/blob/master/build.gradle)
and [lint's build.gradle](https://github.com/VysotskiVadim/jetpack-navigation-example/blob/master/lintrules/build.gradle)
* [Post image](https://flic.kr/p/beLdMH)
* [Google Samples](https://googlesamples.github.io/android-custom-lint-rules/api-guide.html)