---
layout: post
title: Does Story Counting work?
description: "Verifying story counting on historical data from the real project. #NoEstimates"
date:   2021-04-29 13:00:00 +0300
image: /assets/resized/story-counting-post-image_640.jpg
postImage:
  src: story-counting-post-image
  alt: 'Tools for counting'
---

### Introduction

[Allen Holub](https://twitter.com/allenholub) says that we can predict a release date without estimations using story counting.
Check out his [#NoEstimates video](https://youtu.be/QVBlnCTu9Ms) on youtube.

Story Counting sounds like a dream for me.
No more countless meetings where you argue is that 2 or 3 story points story.

Let's check if story counting works.
I have historical data from one of my projects.
I will try to predict the release date and then compare it with the real one.

### A brief introduction to Story Counting

Allen explains Story Counting very well in the [#NoEstimates video](https://youtu.be/QVBlnCTu9Ms).
If you don’t want to spend 38 minutes, read at least a brief explanation from this section.

#### Step 1
Build a commutative flow diagram to predict the release date.
The X-axis is time, the Y-axis is stories count.
Every day put two points: created and closed stories count.

{% include image.html src="story-counting-diagram-explanation" alt="commutative flow diagram of created and closed stories" %}

#### Step 2
Build a trend for created and closed stories count.
The trend shows our progress if we continue to work at the average tempo.

{% include image.html src="story-counting-diagram-explanation-trend" alt="commutative flow diagram of created and closed stories with trends" %}

To build a trend calculate average velocity per day: `average close velocity = (count of closed stories in the last 14 days) / 14`.
Repeat the same for created stories count.
Every day add average day velocity: `next day = previous day + average velocity`.

#### Step 3
Predict the release date date.
Created and closed stories trends meet at the predicted release date.

{% include image.html src="story-counting-diagram-explanation-due-date" alt="commutative flow diagram of created and closed stories with trends and comments" %}

Here’s the prediction after the 6 weeks of development.
It says March 22.

### Dictionary

Let's refresh and align our dictionary.
I use the following terms in the article.

**User story** - describes one feature.
It's like a task for one developer.
Cards that you move in Jira from "In progress" to "Closed" in most cases are user stories.

**Epic** - a bunch of user stories related to the same piece of functionality.
Some features are too big, for example, *"Sign in"*.
It can be split into many user stories like:
*"As a user, I want to sign in using email and password"*,
*"As a user, I want to sign in using Google account"*,
etc.

Epics are handy when you aren't sure how exactly you're going to implement the feature.
You know that you need *"Sign in"* feature, but you don't know all the details.
You discuss features with your team.
During the discussion, you realize that *"Sign in"* requires:
*"Password complexity validation"*, *"Sign in via Google"*, "Forget password".
So you create a new user story for each discovered piece of functionality.

### Story of one release

#### The beginning

In the beginning, we had many high-level stories like “Sign in”, “Search”, etc.
Usually, they're called epics.
But we created them as stories in Jira, which means I counted them on the graphics.

We had many meetings to discover and create new stories for the epics.
PO asked developers "What do we need to implement sign-in?".
Developers were telling details of implementation: "We need integrate with Google to provide google sign".
PO created new stories for the discovered details. 

#### 2 weeks of development

After 2 weeks of work, we got at least some historical data.
Trends predicted release date on 4 May.

{% include image.html src="story-counting-2-weeks" alt="commutative flow for week 6" %}

#### 6 weeks of development

After 6 weeks of work, the release date came closer.
Trends predicted release date on 22 March.

{% include image.html src="story-counting-diagram-explanation-trend" alt="commutative flow for week 6" %}

#### 12 weeks of development

We created more and more stories as we went.
After 12 weeks predicted release date became 5 June.

{% include image.html src="story-counting-week-12" alt="commutative flow for week 12" %}

#### 18 weeks of development

In week 18 created stories trend is almost parallel to the closed stories trend.
No release date prediction this time.
We won't ever release the app if we continue adding so many stories.

{% include image.html src="story-counting-week-18" alt="commutative flow for week 18" %}

#### Release

We released the app on 7 July.
At some point, PO just stopped adding new user stories.
All epics were split into stories and clarified.

{% include image.html src="story-counting-release" alt="commutative flow for released app" %}

All features were completed on 28 May.
Then we had our first and long regression.
It took 40 days.

{% include image.html src="story-counting-release-with-comments" alt="commutative flow for released app with comments" %}


#### Prediction vs Reality

| Weeks of development | Predicted Release Date |
| ----------- | ----------- |
| 2           | 4 May       |
| 6           | 22 Match    |
| 12          | 5 June      |
| 18          | Unknown     |
| All features are completed| 28 May |
| App tested and released |  7 July |


#### Analysis of results

In my case *created stories* count trend was parallel to *closed stories*.
At some point in time, we had just stopped adding more stories and released the app.

{% include image.html src="story-counting-release-created-closed-trends" alt="commutative flow for released app with trends" %}

Story counting failed to predict user stories count.
Imagine a team where developers close stories faster than PO creates them.
When the team closes all stories, a release doesn’t happen.
We release the app when all the functionality of MVP is ready.
I.e. we need to close all epics.

But closed stories count is linear.
It should be predictable.

#### What if all stories were created in advance

We could spend more time discovering and splitting down epics in the beginning.
Would it help us to get a better prediction?
Let’s try to predict the release date using the final number of stories - 97.

On the diagram created stories count became parallel to X-axis.
{% include image.html src="story-counting-6-weeks-stories-created" alt="commutative flow after 6 weeks if all stories were created" %}

| Weeks of development | Predicted Release Date | Diff with reality\* |
| :-----------: | :-----------: | :----------: |
| 2           | Unknown     | Unknown  |
| 6           | May 3       | 32%      |
| 12          | July 5      | 1%       |
| 18          | June 17     | 10%      |
| Actual date |  July 7     |          |

**\*** How far the predicted due date from the actual date with respect to release length.
(Diff in days * 100%) / release duration in days.

### Story Points vs Story Counting 

The team’s velocity is equally linear for both approaches.
If you believe in story points-based burndown predictions, you can believe in story counting as well.

{% include image.html src="story-counting-vs-story-points" alt="story counting vs story points" %}

### Summary

Story Counting isn't a silver bullet.
It won't help you if don't invest time in discovery and requirements clarification in the beginning.
The more stories you create at the beginning, the more exact due date you get.
A prediction can't be more accurate than the plan. Vague plan - vague predicted release date.

### Links
* [Post image](https://flic.kr/p/JxqpKJ)
* [#NoEstimates video by Allen Holub](https://youtu.be/QVBlnCTu9Ms)
* [#NoEstimates Part 1 — Doing Scrum Without Estimates](https://neilkillick.medium.com/noestimates-part-1-doing-scrum-without-estimates-b42c4a453dc6)
* [An unbiased look at the #NoEstimates debate](https://techbeacon.com/app-dev-testing/noestimates-debate-unbiased-look-origins-arguments-thought-leaders-behind-movement)