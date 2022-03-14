---
layout: post
title: "To mock or not to mock value objects"
date: 2022-03-14 12:00:00 +0300
image: /assets/Asteracea_poster_3_part_2.jpg
description: "Proc and Cons of mocking value objects"
postImage:
  src: Asteracea_poster_3_part_2
  alt: Types of Asteraceaes
---

### Why do people mock value objects?

We don't always need all the fields a value object has.

For example you have a value object which represents a person:
```kotlin
data class Person(
  val name: String,
  val surname: String,
  val birthday: Date
)
```

And you need to test `NameValidator`:
```koltin
class NameValidator {
  fun validate()
}
```

By mocking a value object you move it out of your unit
=> changes in value object may lead to broken behavior with green tests
you can test DTO in isolation, but seems just too hard.
Testing a regular codebase with real dto verifies that everyting you need from DTO works fine.

mock doesn't have proper equals and get hash code
