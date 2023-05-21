---
layout: post
title: "Notes from \"Pragmatic Programmer\" book"
date: 2023-05-05 10:20:00 +0200
image: /assets/pragmatic-programming-book.jpg
description: "Notes from \"Pragmatic Programmer\" book"
postImage:
  src: pragmatic-programming-book
  alt: Pragmatic programming book
twitterLink: https://twitter.com/VysotskiVadim/
---



# Introduction

I have read the ["Pragmatic Programmer"](https://a.co/d/6TqIgPl) book and would like to share a few ideas/concepts that resonated with me.

> “The best books... are those that tell you what you know already.”  
-- George Orwell

I had 9 years of production experience when I read this book.
I had seen the majority of advice from the book before.
However some of the ideas were exactly what I was looking for, because they were related to the problems I experience daily.

# Notes

I ordered the notes by value, putting the ones I find the most important first. 
The notes themselves are brief, but I will include the name of the book chapter.

### Goal of a pragmatic programmer

Users have business problems that need to be solved.
Software isn't a goal, it is only a means to achieve the goal.
Ask your customer, "How will we know that the project is successful after it's done?".
Keep the goal in mind, make it clear for your team.
Analyze requirements if they correlate with the goal, they're quite often aren't.
It doesn't matter if software is delivered in time, if it's bug free, etc, if the software doesn't solve user's problems.
Be more than a coder. Be a problem solver, that's what the essence of a Pragmatic Programmer.
`Topic 51: Delight Your Users`.

Don't fall into the cargo cult trap.
Finishing all planned tasks at the end of a sprint or achieving 99.9% unit tests coverage is not what your users care about.
Your users want to solve their problems using the software you produce.
Focus on addressing the their problems instead of targeting artificial metrics such as: count of completed stories per sprint or code cleanliness.
Try different tools and continue using it only if they help you achieve your goals.
`Topic 50: Coconuts Don't Cut It`


### Working in a team

Two quotes from the book:

> Try to understand others viewpoint, difference isn't wrong.

and

> Build the code, not your ego. 

Try to remember a few recent conflicts with your teammates.
Would the conversation have been different if you had follow those advises?

### What to learn?

Knowledge is an expiring asset: everything in software development is rapidly changing, new tools/frameworks/techniques replace old ones.
Ability to learn is the most important skill you need to master to always be valuable.

We're limited by time and energy, how to choose knowledge to put it in knowledge portfolio?
Look at how people manage their financial assets:

1. They invest regularly;
2. They diversify;
3. They balance portfolio between conservative low risk low reward and high risk high reward investments
4. They buy low and sell high

Do the same with knowledge.

*I noticed that I prefer investing in conservative assets, both in my financial(like real estate) and my knowledge portfolio(like soft skills or in-demand frameworks). I believe that once I gain confidence and establish a solid foundation, I will be more inclined to do riskier investments, like shares or emerging frameworks.*

### Others

Usually, good enough software today is better than perfect software tomorrow.
`Topic 5. Good-Enough Software`

Perfection is achieved when there is nothing more to remove.
`Topic 45. The Requirements Pit`

Making code easier to change (aka ETC) is a common denominator among all principles (such as SOLID, KISS, DRY, etc.), laws (like the Law of Demeter), and best practices (such as decoupling).
`Topic 8. The Essence of Good Design`

Team structure dictates the code structure(aka Conway's Law).
`Topic 47. Working Together`.

Estimation units represent certainty.
Compare estimates: "half a year" and 181 day, which one represents more certainty?
`Topic 15. Estimating.`

Software development has more in common with gardening than with building, it's more organic than concrete.
`Topic 40. Refactoring.`
