---
layout: post
title:  Test Android specific 
description: "Checklist for QA engineer to test integration with Android OS"
---

I wrote this checklist to share with Quality Assurance engineers from my team,
as a reminder how to test our app in terms of integration with Android OS.
Article contains not obvious test scenarios which can be easy missed during feature testing.


* Life cycle
    * Configuration Change
    * Process death
* performance
    * Dropped frames (Chareographer, frames bars)
    * overdraw
    * app start time (activity manager via adb)
    * android vitals
* Security ?
* Accessability ?

# Life cycle

Android Framework provides components with entry points,
where developers implement application UI and logic.
Those components have a non-trivial life cycle
([example](https://media.springernature.com/original/springer-static/image/chp%3A10.1007%2F978-3-319-59608-2_35/MediaObjects/450970_1_En_35_Fig1_HTML.gif)),
that is controlled by the framework.
Many Android bugs is related to incorrect life cycle handling.

### Configuration Changes {#configuration_change}

Every time device configuration changes Android Framework by default recreates components.
Example of configuration change is a change of:
* Orientation
* Day/Night mode
* System language
* Others...

The easiest way to trigger configuration change is to rotate device.

Usually framework restores state of UI after recreation.
But developer in charge of restoring logic and custom controls states.

Let's see common mistakes in configuration change handling.

#### Dialog action #{dialog_action_after_configuration_change}
