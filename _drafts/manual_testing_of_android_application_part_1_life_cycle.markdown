---
layout: post
title:  "Manual testing of Android applications. Part 1: life cycle." 
description: "Android application testing guide for manual QA."
---



Techniques like *Boundary Value Analysis* and *Equivalence Partitioning* 
are popular in testing because 
they help us spot error faster by identifying areas
with a higher chance of bugs.

Modern operation systems provide huge amount of features,
which we use every day without even noticing it.
For instance when you turn on Dark Theme all apps became dark.
Or how it so happens that you can run 

Android Operation System has features which is actively in use,
but regular user doesn't notice it.
Multitasking is one of them.
User can switch between many apps in a short period of time.
Given limited amount of device's resource Android has  

I wrote this checklist to share with Quality Assurance engineers from my team,
as a reminder how to test our app in terms of integration with Android OS.
Article contains not obvious test scenarios which can be easy missed during feature testing.


# Life cycle

Android Framework provides components with entry points,
where developers implement application UI and logic.
Those components have a non-trivial life cycle
([example](https://media.springernature.com/original/springer-static/image/chp%3A10.1007%2F978-3-319-59608-2_35/MediaObjects/450970_1_En_35_Fig1_HTML.gif)),
that is controlled by the framework.
During the lifetime components are created and destroyed.
Developers are in charge of state saving and restoring.

Basic algorithm to spot life cycle related bugs are following:
1. Open a screen;
2. Change a screen state, for instance launch long running process to see a loading indicator;
3. Trigger life cycle event (will see them later);
4. Verify that application is in correct state;

We will consider different life cycle events,
just trigger them in third step of bug detection algorithm.

### Configuration Changes {#configuration_change}
OS has many different configurations which affect UI appearance:
orientation (vertical/horizontal), Day/Night mode, system language, and others...
When one of configuration parameters changes Android recreates components to adopt app for a new settings.

<div align='center'>
    <img height='400px' src='https://github.com/VysotskiVadim/VysotskiVadim.github.io/raw/master/assets/configuration_change_orientation.gif'>
    <img height='400px' src='https://github.com/VysotskiVadim/VysotskiVadim.github.io/raw/master/assets/configuration_change_night_mode.gif'>
</div>
The easiest way to trigger configuration change is to rotate device or turn on/off night mode.
Despite the fact that configuration is constantly changing developers sometime forget handle it.

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
If the your app has a splash screen,
you will see it during switching back.


# Common bugs

Let's practice by finding common bugs related to life cycle using algorithm we've just considered.

#### Dialog action {#dialog_action_after_configuration_change}
