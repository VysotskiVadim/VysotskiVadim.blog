---
layout: post
title: "Android Native Text"
date: 2021-10-1 12:00:00 +0300
image: /assets/Asteracea_poster_3_part_2.jpg
description: "How to use Android String and Plurals resources in a View Model + Unit testing them."
postImage:
  src: Asteracea_poster_3_part_2
  alt: Types of Asteraceaes
---

This article demonstrates my favorite approach to referring string and plural resources from view model - `NativeText`.
Thanks to [Alexey Bykov](https://twitter.com/nonewsss) for suggesting me it.

## Why

I use string and plural resources in a view model because of unit testing.
My view layer is as straight forward as possible, there is not conditions nor cycles.
I put all logic in View Models and write fast and stable unit test for them. 

## Popular but not working solution {#resource-provider}

Popular solution is to use `Context` in view model directly or to create abstraction around it.
You can see examples in the
[answers on the Stack Overflow](https://stackoverflow.com/questions/47628646/how-should-i-get-resourcesr-string-in-viewmodel-in-android-mvvm-and-databindi).

Given approach doesn't fit the system lifecycle.
It can't handle changes of a phone language.
A view model isn't recreated when user changes phone's language, but a view is recreated.
After configuration change a view model contains text from for the previous locale but a view displays text for a new one.
You can reed more about the issue [in the article by Jose Alcérreca](https://medium.com/androiddevelopers/locale-changes-and-the-androidviewmodel-antipattern-84eb677660d9)

## Solution that works

Don't keep text from resources in a view model.
Keep a resource id:
```kotlin
data class Resource(@StringRes val id: Int) : NativeText()
```
and get text by resource id on UI:
```kotlin
context.getString(id)
```


For string resource with arguments keep resource id and arguments:
```kotlin
data class Arguments(@StringRes val id: Int, val args: List<Any>) : NativeText()
```
and get text on UI:
```kotlin
context.getString(id, *args.toTypedArray())
```

For plurals keep plural id, number, and arguments:
```kotlin
data class Plural(@PluralsRes val id: Int, val number: Int, val args: List<Any>) : NativeText()
```
and get text on UI:
```kotlin
context.resources.getQuantityString(id, number, *args.toTypedArray())
```

Did you notice that all classes from example extend `NativeText`?

Instead of concatenation keep a list of `NativeText`:
```kotlin
  data class Multi(val text: List<NativeText>) : NativeText()
```
and concatenate strings on UI:
```kotlin
val builder = StringBuilder()
for (t in text) {
    builder.append(t.toCharSequence(context))
}
builder.toString()
```

Put it all together and you will get `NativeText.kt`:
```kotlin
sealed class NativeText {
    data class Simple(val text: String) : NativeText()
    data class Resource(@StringRes val id: Int) : NativeText()
    data class Plural(@PluralsRes val id: Int, val number: Int, val args: List<Any>) : NativeText()
    data class Arguments(@StringRes val id: Int, val args: List<Any>) : NativeText()
    data class Multi(val text: List<NativeText>) : NativeText()
}

fun NativeText.toCharSequence(context: Context): CharSequence {
    return when (this) {
        is NativeText.Arguments -> context.getString(id, *args.toTypedArray())
        is NativeText.Multi -> {
            val builder = StringBuilder()
            for (t in text) {
                builder.append(t.toCharSequence(context))
            }
            builder.toString()
        }
        is NativeText.Plural -> context.resources.getQuantityString(id, number, *args.toTypedArray())
        is NativeText.Resource -> context.getString(id)
        is NativeText.Simple -> text
    }
}
```

### Example

View model that always says "Hi":
```kotlin
class ExampleViewModel: ViewModel(){
  val text = MutableLiveData<NativeText>(NativeText.Resource(R.String.example_hi))
}
```

Observe a live data in an activity and resolve text there:
```kotlin
viewModel.text.observe(this) { text
  textView.text = text.toCharSequence(this)
}
```
### Unit testing

Unit testing is straight forward because view model doesn't interact with an Android Framework.
Just compare view model filed with expected resource.

Here's example of how I check logic inside a mapper:
```kotlin
@Test
fun `map movie that will be released tomorrow`() {
    val mapper = createMapper()
    val movie = createMovie(releaseDate = LocalDate.of(2021, Month.SEPTEMBER, 30))

    val listItem = mapper.map(movie)

    assertEquals(
        NativeText.Plural(R.plurals.movies_list_days_before_release, 1, listOf(1)),
        listItem.release
    )
}
```

The test isn't perfect.
In ideal world I would prefer to see `assertEquals("1 day before release", listItem.release)`
but localization mechanism isn't available on JVM, it's a part form the platform.
All we can test is parameters for specific case: resource ids, arguments, etc.