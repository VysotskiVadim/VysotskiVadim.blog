---
layout: post
date: 2020-05-05 12:00:00 +0300
title:  "QA guide to Android application testing. Part 1: Lifecycle." 
description: "Test Android applications like a professional: learn technique of catching Lifecycle related bugs."
image: https://media.githubusercontent.com/media/VysotskiVadim/VysotskiVadim.github.io/master/assets/resized/caught-a-bug_768.jpg
postImage:
  src: caught-a-bug
  alt: 'A bird caught a bug'
---

To find bugs faster and contributing less effort you need to know
*what developers usually forget to handle*.
If you start checking things where the chance of error is higher -
you will find a bug faster.

This article teaches you to find bugs related to an application Lifecycle.
Lifecycle handling isn't such a complicated thing itself,
it's just super easy to forget about it,
and developers of course often do.

# Lifecycle

Android Framework provides components with entry points,
where developers implement application UI and logic.
Those components have a non-trivial Lifecycle
([example](https://media.springernature.com/original/springer-static/image/chp%3A10.1007%2F978-3-319-59608-2_35/MediaObjects/450970_1_En_35_Fig1_HTML.gif)),
that is controlled by the framework.
During the lifetime components are created and destroyed.
Developers are in charge of state saving and restoring.
It's easy to spot Lifecycle related bug in 4 simple steps.

#### Lifecycle bug detection algorithm: {#detection_algorithm}
1. Open a screen;
2. Change a screen state, i.e. do anything that changes UI: input text, start loading, etc;
3. Trigger Lifecycle event (will see them later);
4. Verify that application is in the correct state;

We will consider different Lifecycle events,
just trigger them in the third step of the bug detection algorithm.

### Configuration Changes {#configuration_change}
OS has many different configurations that affect UI appearance:
orientation (vertical/horizontal), Day/Night mode, system language, and others...
When one of the configuration parameters changes Android recreates components to adopt the app for a new setting.

<div align='center'>
    <img height='400px' src='https://github.com/VysotskiVadim/VysotskiVadim.github.io/raw/master/assets/configuration_change_orientation.gif'>
    <img height='400px' src='https://github.com/VysotskiVadim/VysotskiVadim.github.io/raw/master/assets/configuration_change_night_mode.gif'>
</div>
The easiest way to trigger configuration change is to rotate a device or turn on/off night mode.

### Process Death {#process_death}
Android manages RAM without user interaction.
When there is a low amount of available memory,
OS trying to free up some space.
It selects a process with the lowest priority among running processes and kills it.
Visible applications have the highest priority.
So when a user switches between apps,
and there is memory starvation,
the previous app is likely to be killed by OS.
When a user switches back to the previous app its state is restored,
so a user even doesn't notice that violence took place here.

<div style="margin: 10px" align="center">
    {% include image.html src='background_process_limits' alt='background processes limit in settings' width='300px' %}
</div>

For testing purposes,
you can set **Background process limit** to **No background process**
in developer options.

To test switch from testing app to any other,
wait for a few seconds and switch back.
If your app has a splash screen,
you will see it during switching back.


# Practice

Let's practice by finding common bugs related to Lifecycle using 
[the algorithm, that we've just considered](#detection_algorithm).
All these bugs were found in real Android projects
and replicated by me in [the test application](https://github.com/VysotskiVadim/lifecycle-testing).
All considered bugs will have one common thing:
feature works well until a Lifecycle event.

### Not saved state {#not_saved_state}

On the *STATE* tab, you can find the following feature:
every time user clicks **+1** button counter increases by 1.

<div align='center'>
    <img height='400px' src='https://media.githubusercontent.com/media/VysotskiVadim/VysotskiVadim.github.io/master/assets/qa-guide-lifecycle/counter.gif'>
</div>

Let's try
[the bug detection algorithm](#detection_algorithm)
with
[configuration change](#configuration_change):

1. Open the *STATE* tab;
2. Click three times to change counter to three;
3. Rotate device to trigger configuration change;
4. Check that counter is still there after rotation.

<div align='center'>
    <img height='400px' src='https://media.githubusercontent.com/media/VysotskiVadim/VysotskiVadim.github.io/master/assets/qa-guide-lifecycle/counter_configuration_changed.gif'>
</div>

**Actual result:**
After configuration change counter was reset to 0.

Of course, this is a simplified example,
you probably will never find bug exactly like this.
But sometimes developers forget to restore one of many text pieces on the screen.

### Dialog action {#dialog_action_after_configuration_change}

In the next example, a user can choose a pill: red or blue.
After she clicks the "Choose a pill" button,
a dialog appears with possible options.
When a user selects a pill,
her choice is displayed on the screen.

<div align='center'>
    <img height='400px' src='https://media.githubusercontent.com/media/VysotskiVadim/VysotskiVadim.github.io/master/assets/qa-guide-lifecycle/pills-choice.gif'>
</div>

Let's use
[the bug detection algorithm](#detection_algorithm)
with
[configuration change](#configuration_change)
and check that user can complete the journey:

1. Open the *DIALOG* tab;
2. Click "Choose a pill" button;
3. Rotate device to trigger configuration change;
4. Check that dialog is still present;
5. Select a pill;
6. Verify that the selected option is on the screen;

<div align='center'>
    <img height='400px' src='https://media.githubusercontent.com/media/VysotskiVadim/VysotskiVadim.github.io/master/assets/qa-guide-lifecycle/pills-choice-after-configuration-change.gif'>
</div>

**Actual result:**
Dialog is still present after the configuration change,
but it does nothing.
a user has chosen a red pill, but there is still blue on the screen.

### User input loss

Consider the following feature:
when a user enters the screen, the app loads some data from the server and lets a user edit it.
Once a user presses the "Update" button, new information is updated on the server.

<div align='center'>
    <img height='400px' src='https://media.githubusercontent.com/media/VysotskiVadim/VysotskiVadim.github.io/master/assets/qa-guide-lifecycle/input.gif'>
</div>

This example works well after a configuration change,
so this time we try
[bug detection algorithm](#detection_algorithm)
with
[process death](#process_death).


1. Set background process limit to *No background processes*;
1. Open the *INPUT* tab;
2. Fill-up input fields;
3. Switch to a different app to cause a process death;
4. Switch back to the original app; 
5. Verify that your input is still present;

<div align='center'>
    <img height='400px' src='https://media.githubusercontent.com/media/VysotskiVadim/VysotskiVadim.github.io/master/assets/qa-guide-lifecycle/input-after-process-deadth.gif'>
</div>

**Actual result:** 
App overrides inputted data by data from the server.

This scenario may seem complex and unlikely to happen,
but on second thought it's a common thing.
Imaging: you're filling-up a huge form,
and after a minute of hard work somebody calls you.
When you answer a call, phone switches apps.
Now your app with a form in the background,
so there is a chance that the system can kill it.
The chance is much higher if it's a video call.

# Summary

Lifecycle related bugs are tricky,
you won't see them if you just work with the app.
But users are different: 
they use app laying down on a sofa,
turning from side to side,
causing configuration change because of rotation;
their phones run out of battery,
causing configuration change because of night node.
The knowledge that you get in this article
is a powerful weapon in your hand against Lifecycle related bugs.
Don't let them reach your users, good luck!

## Links
* Post image was taken from [flickr](https://flic.kr/p/c9vEmb)
* [Process and Application Lifecycle](https://developer.android.com/guide/components/activities/process-lifecycle)
* [Activity Lifecycle](https://developer.android.com/guide/components/activities/activity-lifecycle)
* [Example application](https://github.com/VysotskiVadim/lifecycle-testing)