---
layout: post
title: Does story counting work?
description: "Verifying story counting on historical data from real project."
date:   2021-04-27 00:00:00 +0300
image: /assets/day-night-screenshots.jpg
postImage:
  src: day-night-screenshots
  alt: 'eclipse of the moon'
---

### Origin

[Allen Holub](https://twitter.com/allenholub) says that we can predict a release date without estimations using story counting.
Check out [#NoEstimates video](youtu.be/QVBlnCTu9Ms) on youtube.

Story Counting sounds like a dream for me.
No more countless meetings where you argue is that 2 or 3 story points story.
Let's check story counting using historical data from one of my projects.

### Brief introduction to Story Counting

Allen explains Story Counting on the [#NoEstimates video](youtu.be/QVBlnCTu9Ms) very well.
If you don't want to spend time, read at lest brief explanation from this section.

Step 1. Build a commutative flow diagram to predict the due date.
The X-axis is time, Y-axis is stories count. Every day put two points: created and closed stories count.

{% include image.html src="story-counting-diagram-explanation" alt="commutative flow diagram of created and closed stories" %}

Step 2. Build a trend for created and closed stories count.
I calculated the average velocity per day. The trend shows our progress if we continue to work at the average tempo.

{% include image.html src="story-counting-diagram-explanation-trend" alt="commutative flow diagram of created and closed stories" %}

### Story of one release



### Summary

If you already use Shot of Facebook screenshot tests,
just copy my infrastructure to your project. 
You will get more screenshots and less testing effort.

### Links
* [Post image](https://flic.kr/p/qZYThs)
* [Shot](https://github.com/Karumi/Shot)
* [Example project](https://github.com/VysotskiVadim/screenshot-tests-best-practice)
* [How Android draws](https://developer.android.com/guide/topics/ui/how-android-draws)