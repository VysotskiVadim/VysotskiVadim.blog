## Measurements

I run each test 5 times from Android Studio and gathered execution times in [the table](https://docs.google.com/spreadsheets/d/e/2PACX-1vQb3HN-M4jj417zp1hl77S2at7_3YUfbdMFZhpWLRjVKRBlRFmibZDS8KDidZlMmEBVuQ990FltpSv8/pubhtml) and calculated an average time.
The numbers you've seen in the article are the average execution time of several tries.

Android Studio's UI displays time in milliseconds.
I don't know how exactly Android Studio rounds numbers.
I.e what does it show if the result is 1.5 or 1.7?
It can either show 2 or 1.
Let's assume Android Studio rounds in the worst way for measurement - takes only an integer part of a number, i.e. 1.7 displays as 1.
The expected measurement accuracy is ±0.9 milliseconds then.

See versions of the libraries in the [gradle file](https://github.com/VysotskiVadim/slow-unit-tests/blob/main/app/build.gradle#L40).

I run tests using following hardware:
```
  Model Identifier:	MacBookPro16,1
  Processor Name:	6-Core Intel Core i7
  Processor Speed:	2,6 GHz
  Number of Processors:	1
  Total Number of Cores:	6
  L2 Cache (per Core):	256 KB
  L3 Cache:	12 MB
  Hyper-Threading Technology:	Enabled
  Memory:	32 GB
```