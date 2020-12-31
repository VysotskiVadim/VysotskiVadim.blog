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

My "upload document" feature support only {{page.supportedFileTypes}} formats.
