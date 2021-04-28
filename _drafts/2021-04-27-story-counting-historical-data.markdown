---
layout: post
title: Does Story Counting work?
description: "Verifying story counting on historical data from real project. #NoEstimates"
date:   2021-04-27 00:00:00 +0300
image: /assets/day-night-screenshots.jpg
postImage:
  src: day-night-screenshots
  alt: 'eclipse of the moon'
---

### Origin

[Allen Holub](https://twitter.com/allenholub) says that we can predict a release date without estimations using story counting.
Check out [#NoEstimates video](https://youtu.be/QVBlnCTu9Ms) on youtube.

Story Counting sounds like a dream for me.
No more countless meetings where you argue is that 2 or 3 story points story.

Let's check if story counting works.
I have historical data from one of my projects.
I will try to predict release date, and than compare with the real one.

### Brief introduction to Story Counting

Allen explains Story Counting very well on the [#NoEstimates video](https://youtu.be/QVBlnCTu9Ms).
If you don't want to spend 38 minutes time, read at lest brief explanation from this section.

#### Step 1
Build a commutative flow diagram to predict the due date.
The X-axis is time, Y-axis is stories count. Every day put two points: created and closed stories count.

{% include image.html src="story-counting-diagram-explanation" alt="commutative flow diagram of created and closed stories" %}

#### Step 2
Build a trend for created and closed stories count.
I calculated the average velocity per day. The trend shows our progress if we continue to work at the average tempo.

{% include image.html src="story-counting-diagram-explanation-trend" alt="commutative flow diagram of created and closed stories with trends" %}

#### Step 3
Predict the due date.
Created and closed stories trends meet at the predicted due date.
Here’s the prediction after the 6 weeks of development.
It says March 22.

{% include image.html src="story-counting-diagram-explanation-due-date" alt="commutative flow diagram of created and closed stories with trends and comments" %}

### Dictionary

Let's refresh and align our dictionary.
I use following terms in the article.

**User story** - describes one feature. It's like a task for one developer. Cards that you move in jira from "In progress" to "Closed" in most cases are user stories.

**Epic** - bunch of user stories related to the same piece of functionality.
Some features are too big, for example *"Sign in"*.
It can be spited in many user stories like:
*"As a user I want to sign in using email and password"*,
*"As a user I want to sign in using google account"*,
etc.

Epics are handy when you aren't sure how exactly you're going to implement the feature.
You know that you need *"Sign in"* features, but you don't know all the details.
You discuss features with your team.
During the discussion you realize that *"Sign in"* requires:
*"password complexity validation"*, *"sign in via Google"*, "forget password".
So you create new user story for each discover piece of functionality.

### Story of one release

#### What we had in the beginning

In the beginning, we had many high-level stories like “Sign in”, “Search”, etc.
Usually, it’s called an epic.
Epics consist of user stories.
When all stories are closed, the epic is done.

Consider example of epics.
Epic "Sign in" contains user stories: 
* As a user I want to sign in using email and password
* As a user I want to sign in using google account
* ...

Epic "Products" contains:
* As a user I want to see the list of all products
* As a user I want to scroll to see all available products
* ...

I Hope you get the idea.

#### 6 weeks of development

{% include image.html src="story-counting-diagram-explanation-due-date" alt="commutative flow diagram of created and closed stories with trends and comments" %}

### Summary

If you already use Shot of Facebook screenshot tests,
just copy my infrastructure to your project. 
You will get more screenshots and less testing effort.

### Links
* [Post image](https://flic.kr/p/qZYThs)
* [Shot](https://github.com/Karumi/Shot)
* [Example project](https://github.com/VysotskiVadim/screenshot-tests-best-practice)
* [How Android draws](https://developer.android.com/guide/topics/ui/how-android-draws)