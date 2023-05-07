---
layout: post
title: "Notes from \"Pragmatic Programmer\" book"
date: 2023-05-05 10:20:00 +0200
image: /assets/detect_memory_leak_image.jpg
description: "Notes from \"Pragmatic Programmer\" book"
postImage:
  src: detect_memory_leak_image
  alt: Foam reveals a leak
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

### Why do we write code at all?

Users have business problems that need to be solved.
Software isn't a goal, it is only a means to achieve the goal.
Ask your customer, "How will we know that the project is successful after it's done?".
Keep the goal in mind, make it clear for your team.
Analyze requirements if they correlate with the goal, they're quite often aren't.
It doesn't matter if software is delivered in time, if it's bug free, etc, if the software doesn't solve user's problems.
Be more than a coder. Be a problem solver, that's what the essence of a Pragmatic Programmer.

Read `Topic 51: Delight Your Users`.

### Working with other people

Just a two quotes from the book with my comments.
The quotes were taken out of the context.
They were used discussing a different topic, so I added personal comment to explain why a specific quote resonated with me.

> Build the code, not your ego. 


> Try to understand others viewpoint, difference isn't wrong.

There're so many ways to achieve the same goal.
It's okay if somebody uses a technique that is different from what you think is the best.
Ask if they see the same disadvantages in this approach as you see.
Ask if they considered an approach that could illuminate this disadvantages.
Even if you think that they're obviously wrong not doing as you suggest - just accept that they're different.


### Different techniques

The goal it's using a technique, the goal is to deliver good software.





### Small steps

Good enough software today is better than perfect software tomorrow.
Don't be scare to throw prototype away

Perfection is when it's nothing to take away

Help people understand what they want in a feed back loop: explain consequences, edge cases, show mockups, prototypes. Try to be a customer to realize what it feels like


### What to learn?

Investing in knowledge like investing in finance 

### Good code

Every principle is about easier to change

Decoupling 

Inheritance tax

TDD won't help if you don't have destination in your head

Buy auth providers, they 

Property based tests often surprise you

Team structure dictates the way code looks like.

### Soft skills

Estimation unit represents certancy
Estimate with a range of scenarios 

Software is like gardening, not building

Clients don't read detailed specifications, it's for developers to explain what they are doing.

Requirements are need, not a design, not a user interface.

Identity real, not imaginative constraints. Find a bigger box. Example with a trojan horse.
