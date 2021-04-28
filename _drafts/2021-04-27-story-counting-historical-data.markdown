---
layout: post
title: Does Story Counting work?
description: "Verifying story counting on historical data from real project. #NoEstimates"
date:   2021-04-27 00:00:00 +0300
image: /assets/resized/story-counting-post-image_640.jpg
postImage:
  src: story-counting-post-image
  alt: 'Tools for counting'
---

### Introduction

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

#### Start of the project

In the beginning, we had many high-level stories like “Sign in”, “Search”, etc.
Usually, it’s called an epic.
But we created them as stories in jira, it means I counted them on the graphics.

We had many meetings to discover and creates new stories for the epics.
PO asked developers "What do we need to implement sign in?".
Developers were telling details of implementation: "We need integrate with Google to provide google sign".
PO created new stories for the discovered details. 

#### 6 weeks of development

After 6 weeks of work we got at least some historical data.
Trends predicted release on Match 22.

{% include image.html src="story-counting-diagram-explanation-due-date" alt="commutative flow for week 6" %}

#### 12 weeks of development

We created more and more stories as we went.
After 12 weeks predicted due date became June 5.

{% include image.html src="story-counting-week-12" alt="commutative flow for week 12" %}

#### 18 weeks of development

In week 18 created stories trend is almost parallel to the closed stories trend.
No due date prediction this time.
We won't ever release the app if we continue adding so many stories.

{% include image.html src="story-counting-week-18" alt="commutative flow for week 18" %}

#### Release

We released the app on July 7th.
At some point, PO just stopped adding new user stories.
All epics were split into stories and clarified.

{% include image.html src="story-counting-release" alt="commutative flow for released app" %}

All features were complement on May 28.
Than we had our first and long regression.
It took 40 days.

{% include image.html src="story-counting-release-with-comments" alt="commutative flow for released app with comments" %}


#### Prediction vs Reality


| Weeks of development | Predicted Release Date |
| ----------- | ----------- |
| 6           | Match 22    |
| 12          | June 5      |
| 18          | Unknown     |
| All features are completed| May 28 |
| Regression testing are completed |  July 7|


### Summary


### Links
* [Post image](https://flic.kr/p/JxqpKJ)
* [#NoEstimates video by Allen Holub](https://youtu.be/QVBlnCTu9Ms)
* [#NoEstimates Part 1 — Doing Scrum Without Estimates](https://neilkillick.medium.com/noestimates-part-1-doing-scrum-without-estimates-b42c4a453dc6)
* [An unbiased look at the #NoEstimates debate](https://techbeacon.com/app-dev-testing/noestimates-debate-unbiased-look-origins-arguments-thought-leaders-behind-movement)