---
layout: post
title:  Pick a file on Android
description: "Simple guide how to pick file on Android: SAF, supported types, edge cases"
supportedFileTypes: "txt, doc, rtf, docx, pdf"
date: 2021-01-01 22:30:00 +0300
image: /assets/pick-a-file-cover.jpg
postImage:
  src: pick-a-file-cover
  alt: 'Files on the shelf'
twitterLink: https://twitter.com/VysotskiVadim/status/1427957292176191489
---     

Some time ago,
during the implementation of an "upload document" feature,
I was looking for a simple tutorial about picking a file on Android
but didn't find anything that fits my requirements.
I needed:
1. Simple code examples so that I can quickly implement feature step by step copy-pasting code and check if it what I need;
2. Explanation of how everything works with links to docs;
3. Edge cases, or what can easily be missed, but it's an important scenario for the user.

Ok, as nobody has written it yet, I'm going to do it.
Please enjoy the reading or go straight to the [code of the final solution](#code).

### Requirements

As a user, I want to be able to pick a file
from a device or from the third-party cloud storage,
of supported format ({{page.supportedFileTypes}})
so that file is uploaded to the server.

In other words, I had to implement file picker,
that lets user pick only files of supported type,
from different storages: local or third party.

### Pick a file {#pick_a_file}

After Android 11 the only way to access file system is Storage Access Framework.

My goal is to open document one time, read the content and upload it to the server.
So [Intent.ACTION_GET_CONTENT](https://developer.android.com/reference/android/content/Intent#ACTION_GET_CONTENT)
is exactly what I needed.

```kotlin
fun Fragment.openDocumentPicker() {
    val openDocumentIntent = Intent(Intent.ACTION_GET_CONTENT).apply {
        addCategory(Intent.CATEGORY_OPENABLE)
        type = "*/*"
    }

    startActivityForResult(openDocumentIntent, OPEN_DOCUMENT_REQUEST_CODE)
}

const val OPEN_DOCUMENT_REQUEST_CODE = 2
```

Executing the code above,
Android opens system UI,
where user is able to pick a file of any type from any connected third-party storage.

Let's quickly get thought the code:  
`Intent.ACTION_GET_CONTENT` - open file to read content one time, reed more in the [doc](https://developer.android.com/reference/android/content/Intent#ACTION_GET_CONTENT)  
`addCategory(Intent.CATEGORY_OPENABLE)` - we don't want to deal with [virtual files](https://www.youtube.com/watch?v=4h7yCZt231Y),
we need only real ones, i.e. file that contains bytes of data.  
`OPEN_DOCUMENT_REQUEST_CODE` - id of request, we will use this number during result handing.

User will see system UI where all real files available to pick
*(as you can see google slides file are virtual and not available for picking)*:

<div style="display:flex;justify-content: space-between;">
    {% include image.html src="all-files-example" alt="Example of all files" width='45%'%}
</div>


### Get the bytes {#get_the_bytes}

Once the user picked the file we get a result via `onActivityResult` callback.
Here I call `tryHandleOpenDocumentResult` and handle one of `OpenFileResult`.

```kotlin
fun Fragment.tryHandleOpenDocumentResult(requestCode: Int, resultCode: Int, data: Intent?): OpenFileResult {
    return if (requestCode == OPEN_DOCUMENT_REQUEST_CODE) {
        handleOpenDocumentResult(resultCode, data)
    } else OpenFileResult.DifferentResult
}

private fun Fragment.handleOpenDocumentResult(resultCode: Int, data: Intent?): OpenFileResult {
    return if (resultCode == Activity.RESULT_OK && data != null) {
        val contentUri = data.data
        if (contentUri != null) {
            val stream =
                try {
                    requireActivity().application.contentResolver.openInputStream(contentUri)
                } catch (exception: FileNotFoundException) {
                    Timber.e(exception)
                    return OpenFileResult.ErrorOpeningFile
                }

            val fileName = requireContext().contentResolver.queryFileName(contentUri)

            if (stream != null && fileName != null) {
                OpenFileResult.FileWasOpened(fileName, stream)
            } else OpenFileResult.ErrorOpeningFile
        } else {
            OpenFileResult.ErrorOpeningFile
        }
    } else {
        OpenFileResult.OpenFileWasCancelled
    }
}

sealed class OpenFileResult {
    object OpenFileWasCancelled : OpenFileResult()
    data class FileWasOpened(val fileName: String, val content: InputStream) : OpenFileResult()
    object ErrorOpeningFile : OpenFileResult()
    object DifferentResult : OpenFileResult()
}
```

For my feature, I need file content + file name.

We can get content from `contentResolver` by calling 
`requireActivity().application.contentResolver.openInputStream(contentUri)`.
Don't get `contentResolver` from activity to avoid memory leaks
and don't forget to call `close` once you're done with the stream.

`queryFileName` is a custom function,
you can read about in the next section,
or remove its call if you don't need the file name.

### Get file name (optional feature) {#get_file_name}

Getting file name is a little bit more tricky.

```kotlin
val allSupportedDocumentsTypesToExtensions = mapOf(
    "application/msword" to ".doc",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" to ".docx",
    "application/pdf" to ".pdf",
    "text/rtf" to ".rtf",
    "application/rtf" to ".rtf",
    "application/x-rtf" to ".rtf",
    "text/richtext" to ".rtf",
    "text/plain" to ".txt"
)
private val extensionsToTypes = allSupportedDocumentsTypesToExtensions.invert()

fun ContentResolver.queryFileName(uri: Uri): String? {
    val cursor: Cursor = query(uri, null, null, null, null) ?: return null
    val nameIndex: Int = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
    cursor.moveToFirst()
    val name: String = cursor.getString(nameIndex)
    cursor.close()
    return appendExtensionIfNeeded(name, uri)
}

private fun ContentResolver.appendExtensionIfNeeded(name: String, uri: Uri): String? {
    return if (hasKnownExtension(name)) {
        name
    } else {
        val type = getType(uri)
        if (type != null && allSupportedDocumentsTypesToExtensions.containsKey(type)) {
            return name + allSupportedDocumentsTypesToExtensions[type]
        }
        Timber.e("unknown file type: $type, for file: $name")
        name
    }
}

private fun hasKnownExtension(filename: String): Boolean {
    val lastDotPosition = filename.indexOfLast { it == '.' }
    if (lastDotPosition == -1) {
        return false
    }
    val extension = filename.substring(lastDotPosition)
    return extensionsToTypes.containsKey(extension)
}

// utils function
fun <K, V> Map<K, V>.invert(): Map<V, K> {
    val inverted = mutableMapOf<V, K>()
    for (item in this) {
        inverted[item.value] = item.key
    }
    return inverted
}
```

My backend requires file names to have an extension,
so that backend knows how to process a file,
but `DISPLAY_NAME` sometimes doesn't contain it.
So I check the extension in `hasKnownExtension`,
if it's empty I try to guess the file`s extension based on mime type.

You've probably noticed that some file types like rtf have many corresponding mime types.
Try to specify all possible options,
I noticed that all of them are used.

### Filter file by type {#filer_files_by_type}

My "upload document" feature support only **{{page.supportedFileTypes}}** formats.
So picker shouldn't let user pick file of not supported type.
We can achieve it by specifying supported formats.

```kotlin

val supportedMimeTypes = allSupportedDocumentsTypesToExtensions.keys.toTypedArray()

fun Fragment.openDocumentPicker() {
    val openDocumentIntent = Intent(Intent.ACTION_GET_CONTENT).apply {
        addCategory(Intent.CATEGORY_OPENABLE)
        type = "*/*"
        putExtra(Intent.EXTRA_MIME_TYPES, supportedMimeTypes)
    }

    startActivityForResult(openDocumentIntent, OPEN_DOCUMENT_REQUEST_CODE)
}
```

Not filtered*(left image)* vs filtered*(right image)*:
as you can see all files except **.doc** one are grayed out and not available for picking.
<div style="display:flex;justify-content: space-between;">
    {% include image.html src="all-files-example" alt="Example of all files" width='45%'%}
    {% include image.html src="filtered-files-example" alt="Example of filtered files" width='45%'%}
</div>


### MIME types filter doesn't work {#mime_filter_do_not_work}

`Intent.EXTRA_MIME_TYPES` filter works only for third party [document providers](https://developer.android.com/guide/topics/providers/document-provider#overview).
But some third-party app lets user access files via specifying intent filter for `android.intent.action.GET_CONTENT`,
and handling these intents in their activities.

<div align='center'>
    {% include video.html src='/assets/pick-file-android/pick-file-dropbox-vs-google-photos.webm' %}
</div>

On the video,
you can see that when user chooses Google Photos
from the system file picker,
the app is opened and the user sees all files.
Our file types filter doesn't work there
so the user can pick any photo.

One possible solution is to change `GET_CONTENT` intent action to `ACTION_OPEN_DOCUMENT`.
`ACTION_OPEN_DOCUMENT` [works only with document providers](https://developer.android.com/reference/android/content/Intent#ACTION_OPEN_DOCUMENT),
so `EXTRA_MIME_TYPES` always works with `ACTION_OPEN_DOCUMENT` .
But I want user to be able to use **all** possible data sources,
some cloud storage doesn't provide document provider and shows custom UI (Yandex disk for example)
, so I keep `GET_CONTENT`.

I let user get data from any source,
but when user picks a file I have to check file type and show an error if picked file type isn't supported.

<div style="display:flex;justify-content: space-between;">
    {% include image.html src="pick-file-get-content" alt="Available third paries for get content" width='45%'%}
    {% include image.html src="pick-file-open-document" alt="Available third parties for open document" width='45%'%}
</div>

`GET_CONTENT`*(left image)* vs `ACTION_OPEN_DOCUMENT`*(right image)*: the last option has less available data sources.


`GET_CONTENT` contains redundant entries like Google Photo,
but it also has additional third parties that haven't migrated to document provider yet.

### The code {#code}

Here is all code that you've seen reading the article.
I split code in a few files:

**PickDocument.kt**
```kotlin
const val OPEN_DOCUMENT_REQUEST_CODE = 2

val supportedMimeTypes: Array<String> = allSupportedDocumentsTypesToExtensions.keys.toTypedArray()

fun Fragment.openDocumentPicker() {
    val openDocumentIntent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
        addCategory(Intent.CATEGORY_OPENABLE)
        type = "*/*"
        putExtra(Intent.EXTRA_MIME_TYPES, supportedMimeTypes)
    }

    startActivityForResult(openDocumentIntent, OPEN_DOCUMENT_REQUEST_CODE)
}

fun Fragment.tryHandleOpenDocumentResult(requestCode: Int, resultCode: Int, data: Intent?): OpenFileResult {
    return if (requestCode == OPEN_DOCUMENT_REQUEST_CODE) {
        handleOpenDocumentResult(resultCode, data)
    } else OpenFileResult.DifferentResult
}

private fun Fragment.handleOpenDocumentResult(resultCode: Int, data: Intent?): OpenFileResult {
    return if (resultCode == Activity.RESULT_OK && data != null) {
        val contentUri = data.data
        if (contentUri != null) {
            val stream =
                try {
                    requireActivity().application.contentResolver.openInputStream(contentUri)
                } catch (exception: FileNotFoundException) {
                    Timber.e(exception)
                    return OpenFileResult.ErrorOpeningFile
                }

            val fileName = requireContext().contentResolver.queryFileName(contentUri)

            if (stream != null && fileName != null) {
                OpenFileResult.FileWasOpened(fileName, stream)
            } else OpenFileResult.ErrorOpeningFile
        } else {
            OpenFileResult.ErrorOpeningFile
        }
    } else {
        OpenFileResult.OpenFileWasCancelled
    }
}

sealed class OpenFileResult {
    object OpenFileWasCancelled : OpenFileResult()
    data class FileWasOpened(val fileName: String, val content: InputStream) : OpenFileResult()
    object ErrorOpeningFile : OpenFileResult()
    object DifferentResult : OpenFileResult()
}
```

**SafUtils.kt**
```kotlin
val allSupportedDocumentsTypesToExtensions = mapOf(
    "application/msword" to ".doc",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" to ".docx",
    "application/pdf" to ".pdf",
    "text/rtf" to ".rtf",
    "application/rtf" to ".rtf",
    "application/x-rtf" to ".rtf",
    "text/richtext" to ".rtf",
    "text/plain" to ".txt"
)
private val extensionsToTypes = allSupportedDocumentsTypesToExtensions.invert()

fun ContentResolver.queryFileName(uri: Uri): String? {
    val cursor: Cursor = query(uri, null, null, null, null) ?: return null
    val nameIndex: Int = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
    cursor.moveToFirst()
    val name: String = cursor.getString(nameIndex)
    cursor.close()
    return appendExtensionIfNeeded(name, uri)
}

private fun ContentResolver.appendExtensionIfNeeded(name: String, uri: Uri): String? {
    return if (hasKnownExtension(name)) {
        name
    } else {
        val type = getType(uri)
        if (type != null && allSupportedDocumentsTypesToExtensions.containsKey(type)) {
            return name + allSupportedDocumentsTypesToExtensions[type]
        }
        Timber.e("unknown file type: $type, for file: $name")
        name
    }
}

private fun hasKnownExtension(filename: String): Boolean {
    val lastDotPosition = filename.indexOfLast { it == '.' }
    if (lastDotPosition == -1) {
        return false
    }
    val extension = filename.substring(lastDotPosition)
    return extensionsToTypes.containsKey(extension)
}
```

### Usage examples {#usage}

You can request document picker to appear on button click for example:

```kotlin
pickDocumentButton.setOnClickListener {
    openDocumentPicker()
}
```

and handle result in fragment:

```kotlin
override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    super.onActivityResult(requestCode, resultCode, data)
    tryOpenDocument(requestCode, resultCode, data)
    // try handle other results
}

private fun tryOpenDocument(requestCode: Int, resultCode: Int, data: Intent?) {
    when (val openFileResult = tryHandleOpenDocumentResult(requestCode, resultCode, data)) {
        is OpenFileResult.FileWasOpened -> viewModel.uploadDocument(openFileResult.fileName, openFileResult.content)
        OpenFileResult.ErrorOpeningFile -> viewModel.errorOpeningDocument()
        OpenFileResult.OpenFileWasCancelled -> viewModel.userCancelledOpenOfDocument()
        OpenFileResult.DifferentResult -> {
            // Do nothing
        }
    }
}
```

### Links

* [Post image](https://flic.kr/p/RwDusv)
* [Open file using Storage Access Framework](https://developer.android.com/guide/topics/providers/document-provider)