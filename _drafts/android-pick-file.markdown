---
layout: post
title:  Pick a file on Android
description: "Simple guide how to implement upload file feature."
supportedFileTypes: "txt, doc, rtf, docx, pdf"
---

Some time ago,
during implementation of "upload document" feature,
I was looking for simple tutorial about picking a file on Android.
But didn't find anything that fits my requirements.
I needed:
1. Simple code examples so that I can quickly implement feature step by step copy pasting code and check if it what I need;
2. Explanation how it works with links to docs;
3. Edge cases, or what can easily be missed, but it's important scenario for the user.

Ok, as nobody has written it yet, I'm going to do it.
Please enjoy the reading.

### Requirements

As a user I want to be able to pick a file
from device or from the third party cloud storages
of supported format ({{page.supportedFileTypes}})
so that it's uploaded to the server.

In other words I had to implement file picker,
that lets user pick only file of supported type,
from different storages.

### Pick a file

After Android 11 the only way to access device file system is Storage Access Framework.

My goal is to open document one time, read the content and upload it to the server.
So Intent.ACTION_GET_CONTENT is exactly what I need.

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
Android will open system a UI,
where user is able to pick file of any type from any connected third party storage.

Let's quickly get thought the code:  
`Intent.ACTION_GET_CONTENT` - open file to read content one time //TODO: link to virtual files  
`addCategory(Intent.CATEGORY_OPENABLE)` - we don't want to deal with virtual files, only real ones. //TODO: link to virtual files  
`OPEN_DOCUMENT_REQUEST_CODE` - id of request //TODO: link to request id  

TODO: attach video

### Filter file by type

My "upload document" feature support only **{{page.supportedFileTypes}}** formats.
So picker shouldn't let user pick not supported file types.
We can achieve it by specifying supported formats.

```kotlin
object UploadDocument {
    val supportedMimeTypes = arrayOf<String>(
        "application/msword", // .doc
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document", // .docx
        "application/pdf", // .pdf
        "text/rtf", // .rtf
        "application/rtf", // .rtf,
        "application/x-rtf", // .rtf
        "text/richtext", // .rtf"
        "text/plain" // .txt
    )
}

fun Fragment.openDocumentPicker() {
    val openDocumentIntent = Intent(Intent.ACTION_GET_CONTENT).apply {
        addCategory(Intent.CATEGORY_OPENABLE)
        type = "*/*"
        putExtra(Intent.EXTRA_MIME_TYPES, UploadDocument.supportedMimeTypes)
    }

    startActivityForResult(openDocumentIntent, OPEN_DOCUMENT_REQUEST_CODE)
}
```

TODO: add video of how grayed out files looks like

You may noticed that some file types like rtf has many corresponding mime types.
Try to specify all possible options.

### Get the bytes

Once user picked file we get a result via `onActivityResult` callback.
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

For my feature I need file content + file name.

We can get content from `contentResolver` by calling 
`requireActivity().application.contentResolver.openInputStream(contentUri)`.
Don't get `contentResolver` from activity to avoid memory leaks
and don't forget to call `close` once you're done with the stream.

`queryFileName` is a custom function,
you can read about in the next section,
or remove it's call if you don't need file name.

### Get file name

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
```

My backend requires files names to have an extension,
so that backend knows how to process a file,
but `DISPLAY_NAME` sometime doesn't contain it.
So I check extension in `hasKnownExtension`,
if it's empty I try to guess it based on mime type.

