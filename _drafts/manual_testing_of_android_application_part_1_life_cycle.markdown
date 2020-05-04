---
layout: post
title:  "QA guide to advanced Android applications testing. Part 1: life cycle." 
description: "Android application testing guide for manual QA."
---

To find bugs faster and contributing less effort you need to know
*what developers usually forget to handle?*
If you start from checking things where chance of error is higher -
you will find a bug faster.

This article teaches you find bugs related to application life cycle.
Life cycle handling isn't such a complicated thing itself,
it's just super easy to forget about it,
and developers off course often do.

# Life cycle

Android Framework provides components with entry points,
where developers implement application UI and logic.
Those components have a non-trivial life cycle
([example](https://media.springernature.com/original/springer-static/image/chp%3A10.1007%2F978-3-319-59608-2_35/MediaObjects/450970_1_En_35_Fig1_HTML.gif)),
that is controlled by the framework.
During the lifetime components are created and destroyed.
Developers are in charge of state saving and restoring.
It's easy to spot life cycle related bug in 4 simple steps.

#### Life cycle bug detection algorithm: {#detection_algorithm}
1. Open a screen;
2. Change a screen state, i.e. do anything that changes UI: input text, start loading, ets;
3. Trigger life cycle event (will see them later);
4. Verify that application is in correct state;

We will consider different life cycle events,
just trigger them in the third step of bug detection algorithm.

### Configuration Changes {#configuration_change}
OS has many different configurations which affect UI appearance:
orientation (vertical/horizontal), Day/Night mode, system language, and others...
When one of configuration parameters changes Android recreates components to adopt app for a new settings.

<div align='center'>
    <img height='400px' src='https://github.com/VysotskiVadim/VysotskiVadim.github.io/raw/master/assets/configuration_change_orientation.gif'>
    <img height='400px' src='https://github.com/VysotskiVadim/VysotskiVadim.github.io/raw/master/assets/configuration_change_night_mode.gif'>
</div>
The easiest way to trigger configuration change is to rotate device or turn on/off night mode.

### Process Death {#process_death}
Android manages RAM memory without user interaction.
When there is a low amount of available memory,
OS trying to free up some space.
It selects a process with lowest priority among running processes and kill it.
Visible applications have the highest priority.
So when user switch between apps,
and there is a memory starvation,
previous app is likely to be killed by OS.
When user switch back to the previous app its state is restored,
so user even doesn't notice that violence took place here.

<div style="margin: 10px" align="center">
    {% include image.html src='background_process_limits' alt='background processes limit in settings' width='300px' %}
</div>

For testing purposes you can set **Background process limit** to **No background process**
in developer options.

To test switch from testing app to any other,
wait for a few seconds and switch back.
If your app has a splash screen,
you will see it during switching back.


# Practice

Let's practice by finding common bugs related to life cycle using 
[algorithm, that we've just considered](#detection_algorithm).
All this bugs was found in real Android projects,
and replicated by me in [test application](https://github.com/VysotskiVadim/lifecycle-testing).
All considered bugs will have one common thing:
feature work good until a life cycle event.

### Not saved state {#not_saved_state}

On *STATE* tab you can find following feature:
every time user clicks **+1** button counter increases by 1.

<div align='center'>
    <img height='400px' src='https://media.githubusercontent.com/media/VysotskiVadim/VysotskiVadim.github.io/master/assets/qa-guide-lifecycle/counter.gif'>
</div>

Let's try
[bug detection algorithm](#detection_algorithm)
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

Of course this is simplified example,
you probably will never find this bug.
But sometimes developers forget to restore one of many text pieces on the screen.

### Dialog action {#dialog_action_after_configuration_change}

In the next example user can choose a pill: red or blue.
After she clicks "Choose a pill" button,
dialog appears with possible options.
When user select a pill,
her choice is displayed on the screen.

<div align='center'>
    <img height='400px' src='https://media.githubusercontent.com/media/VysotskiVadim/VysotskiVadim.github.io/master/assets/qa-guide-lifecycle/pills-choice.gif'>
</div>

Let's use
[bug detection algorithm](#detection_algorithm)
with
[configuration change](#configuration_change)
and check that user can complete the journey:

1. Open the *DIALOG* tab;
2. Click "Choose a pill" button;
3. Rotate device to trigger configuration change;
4. Check that dialog is still present;
5. Select a pill;
6. Verify that selected option is on the screen;

<div align='center'>
    <img height='400px' src='https://media.githubusercontent.com/media/VysotskiVadim/VysotskiVadim.github.io/master/assets/qa-guide-lifecycle/pills-choice-after-configuration-change.gif'>
</div>

**Actual result:**
Dialog is still present after configuration change,
but it does nothing.
User has chosen a red pill, but there is still blue on the screen.

### User input loss

Consider following feature:
When user enters the screen, app loads some data from the server and lets user edit it.
Once user press "Update" buton, information is updated on the server.

<div align='center'>
    <img height='400px' src='https://media.githubusercontent.com/media/VysotskiVadim/VysotskiVadim.github.io/master/assets/qa-guide-lifecycle/input.gif'>
</div>

This examples works good after configuration change,
so this time we try
[bug detection algorithm](#detection_algorithm)
with
[process death](#process_death).


1. Set background process limit to *No background processes*;
1. Open the *INPUT* tab;
2. Fill-up input fields;
3. Switch to different app to cause a process death;
4. Switch back to original app; 
5. Verify that your input is still present;

<div align='center'>
    <img height='400px' src='https://media.githubusercontent.com/media/VysotskiVadim/VysotskiVadim.github.io/master/assets/qa-guide-lifecycle/input-after-process-deadth.gif'>
</div>

**Actual result:** 
App overrides inputted data by data from server.

This scenario may seems complex and unlikely to happen,
but on second thought it's common thing.
Imaging: you're filling-up a huge form,
and after a minute of hard work somebody calls you.
When you answer a call phone switches apps,
so there is a chance that system can kill the app.
The chance is much higher if it's a video call.

# Summary

Life cycle related bugs are tricky,
you won't see them if you just work with the app.
But users are different: 
they use app laying down on sofa,
turning from side to side,
causing configuration change because of rotation;
their phones run out of battery,
causing configuration change because of night node.
Knowledge that you get in this article
is a powerful weapon in you hand against life cycle related bugs.
Don't let them reach your users, good luck!