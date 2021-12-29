---
layout: post
title:  Pick a file on Android
description: "Simple guide of how to pick a file on Android: SAF, supported types, edge cases"
supportedFileTypes: "txt, doc, rtf, docx, pdf"
date: 2021-01-01 22:30:00 +0300
image: /assets/pick-a-file-cover.jpg
postImage:
  src: pick-a-file-cover
  alt: 'Files on the shelf'
twitterLink: https://twitter.com/VysotskiVadim/status/1427957292176191489
---     

I was looking for a simple tutorial that explains how to pick a file on Android but didn't find anything that has:
1. Simple code examples;
2. Explanation of how everything works with links to docs;
3. Edge cases, or what can easily be missed, but it's an important scenario for the user.

As nobody has written it yet, I'm going to do it.
Please enjoy the reading or go straight to the [code of the final solution](#code).

### Requirements

As a user, I want to pick a file
from my phone or third-party cloud storage*(like Dropbox or Goole Drive)*,
of supported format ({{page.supportedFileTypes}})
so that file is uploaded to the server.

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
where the user can pick a file of any type from any connected third-party storage.

Let's quickly get through the code:  
`Intent.ACTION_GET_CONTENT` - open file to read content one time, reed more in the [doc](https://developer.android.com/reference/android/content/Intent#ACTION_GET_CONTENT)  
`addCategory(Intent.CATEGORY_OPENABLE)` - we don't want to deal with [virtual files](https://www.youtube.com/watch?v=4h7yCZt231Y),
we need only real ones, i.e. file that contains bytes of data.  
`OPEN_DOCUMENT_REQUEST_CODE` - id of request, we will use this number during result handing.

Users will see system UI where all real files are available to pick
*(as you can see google slides files are virtual and not available for picking)*:

<div style="display:flex;justify-content: space-between;">
    {% include image.html src="all-files-example" alt="Example of all files" width='45%'%}
</div>


### Get the bytes {#get_the_bytes}

I use following utils functions to work with files.
I keep them in the `PickDocument.kt` file.

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
                    return OpenFileResult.ErrorOpeningFile
                }

            val fileName = "not implemented" // will implement file names later

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

Notice that I get `contentResolver` from the `Application`, not from the `Activity` to avoid memory leak.

Call `tryHandleOpenDocumentResult` from the `onActivityResult`:
```kotlin
when (val result = tryHandleOpenDocumentResult(requestCode, resultCode, data)) {
    OpenFileResult.DifferentResult, OpenFileResult.OpenFileWasCancelled -> { }
    OpenFileResult.ErrorOpeningFile -> Log.e(TAG, "error opening file")
    is OpenFileResult.FileWasOpened -> {
        // access result.fileName and result.content here
    }
}
```

Call `close` on the `InputStream` when you finished reading the file.

### Get file name (optional feature) {#get_file_name}

Getting a file's name is a little bit more tricky.

Here are utils functions to work with file names.
I keep them in the **SafUtils.kt** file.

```kotlin
private const val TAG = "SafUtils"

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
        Log.e(TAG, "unknown file type: $type, for file: $name")
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

private fun <K, V> Map<K, V>.invert(): Map<V, K> {
    val inverted = mutableMapOf<V, K>()
    for (item in this) {
        inverted[item.value] = item.key
    }
    return inverted
}
```

My backend requires file names to have an extension
so that it knows how to process a file.
But the `DISPLAY_NAME` sometimes doesn't contain an extension, just a name.
So I check the extension in `hasKnownExtension`,
if it's empty I try to guess the file`s extension based on mime type.

Some file types like rtf have many corresponding mime types.
Try to specify all possible options,
I noticed that all of them are used.

Call the `queryFileName` function from the `handleOpenDocumentResult` to get file name.
```kotlin
val fileName = requireContext().contentResolver.queryFileName(contentUri)
```

### Filter file by type {#filer_files_by_type}

My "upload document" feature supports only **{{page.supportedFileTypes}}** formats.
Picker shouldn't let users pick a file of a not supported type.
We can achieve it by specifying supported formats in the `Intent`.

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
as you can see all files except **.doc** are grayed out and not available for picking.
<div style="display:flex;justify-content: space-between;">
    {% include image.html src="all-files-example" alt="Example of all files" width='45%'%}
    {% include image.html src="filtered-files-example" alt="Example of filtered files" width='45%'%}
</div>


### MIME types filter doesn't work {#mime_filter_do_not_work}

`Intent.EXTRA_MIME_TYPES` filter works only for third-party [document providers](https://developer.android.com/guide/topics/providers/document-provider#overview).
But some third-party app lets user access files via specifying intent filter for `android.intent.action.GET_CONTENT`,
and handling these intents in their activities.

<div align='center'>
    {% include video.html src='/assets/pick-file-android/pick-file-dropbox-vs-google-photos.webm' %}
</div>

Google Photos handles `ACTION_GET_CONTENT`.
It lets the user pick any photo no matter which `EXTRA_MIME_TYPES` you've set.
So `EXTRA_MIME_TYPES` doesn't always work with `ACTION_GET_CONTENT`. 

One possible solution is to change `GET_CONTENT` intent action to `ACTION_OPEN_DOCUMENT`.
`ACTION_OPEN_DOCUMENT` [works only with document providers](https://developer.android.com/reference/android/content/Intent#ACTION_OPEN_DOCUMENT),
so `EXTRA_MIME_TYPES` will always work.

`ACTION_OPEN_DOCUMENT` reduces the number of sources the user can pick a file from.
Some cloud storages don't provide a document provider and show custom UI (Yandex disk for example),
so I keep using `GET_CONTENT`.

<div style="display:flex;justify-content: space-between;">
    {% include image.html src="pick-file-get-content" alt="Available third paries for get content" width='45%'%}
    {% include image.html src="pick-file-open-document" alt="Available third parties for open document" width='45%'%}
</div>

`GET_CONTENT`*(left image)* vs `ACTION_OPEN_DOCUMENT`*(right image)*: the last option has fewer available data sources.

`GET_CONTENT` contains redundant entries like Google Photo,
but it also has additional third parties that haven't migrated to the document provider yet.

I let users get data from any source,
but I check file type and show an error if a picked file type isn't supported.

### The code {#code}

Check out the [file picker repository](https://github.com/VysotskiVadim/android-pick-file-example).

### Links

* [Post image](https://flic.kr/p/RwDusv)
* [Open a file using Storage Access Framework](https://developer.android.com/guide/topics/providers/document-provider)