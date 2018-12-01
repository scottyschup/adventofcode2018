# Advent of Code 2018
<h2 id="day01">Day 1</h2>

### Part 1
After feeling like you've been falling for a few minutes, you look at the device's tiny screen. "Error: Device must be calibrated before first use. Frequency drift detected. Cannot maintain destination lock." Below the message, the device shows a sequence of changes in frequency (your puzzle input). A value like +6 means the current frequency increases by 6; a value like -3 means the current frequency decreases by 3.

For example, if the device displays frequency changes of +1, -2, +3, +1, then starting from a frequency of zero, the following changes would occur:

Current frequency  0, change of +1; resulting frequency  1.
Current frequency  1, change of -2; resulting frequency -1.
Current frequency -1, change of +3; resulting frequency  2.
Current frequency  2, change of +1; resulting frequency  3.
In this example, the resulting frequency is 3.

Here are other example situations:

+1, +1, +1 results in  3
+1, +1, -2 results in  0
-1, -2, -3 results in -6
Starting with a frequency of zero, what is the resulting frequency after all of the changes in frequency have been applied?

[Input](inputs/01.txt)

[Solution](solutions/d01p1.rb)

### Part 2
You notice that the device repeats the same frequency change list over and over. To calibrate the device, you need to find the first frequency it reaches twice.

For example, using the same list of changes above, the device would loop as follows:

Current frequency  0, change of +1; resulting frequency  1.
Current frequency  1, change of -2; resulting frequency -1.
Current frequency -1, change of +3; resulting frequency  2.
Current frequency  2, change of +1; resulting frequency  3.
(At this point, the device continues from the start of the list.)
Current frequency  3, change of +1; resulting frequency  4.
Current frequency  4, change of -2; resulting frequency  2, which has already been seen.
In this example, the first frequency reached twice is 2. Note that your device might need to repeat its list of frequency changes many times before a duplicate frequency is found, and that duplicates might be found while in the middle of processing the list.

Here are other examples:

+1, -1 first reaches 0 twice.
+3, +3, +4, -2, -4 first reaches 10 twice.
-6, +3, +8, +5, -6 first reaches 5 twice.
+7, +7, -2, -7, -4 first reaches 14 twice.
What is the first frequency your device reaches twice?

[Input](inputs/01.txt)

[Solution](solutions/d01p2.rb)


<h2 id="day02">Day 2</h2>
### Part 1
[Input](inputs/02.txt)

[Solution](solutions/d02p1.rb)

### Part 2
[Input](inputs/.txt)

[Solution](solutions/dp2.rb)

<h2 id="day03">Day 3</h2>
### Part 1
[Input](inputs/03.txt)

[Solution](solutions/d03p1.rb)

### Part 2
[Input](inputs/03.txt)

[Solution](solutions/d03p2.rb)

<h2 id="day04">Day 4</h2>
### Part 1
[Input](inputs/04.txt)

[Solution](solutions/d04p1.rb)

### Part 2
[Input](inputs/04.txt)

[Solution](solutions/d04p2.rb)

<h2 id="day05">Day 5</h2>
### Part 1
[Input](inputs/05.txt)

[Solution](solutions/d05p1.rb)

### Part 2
[Input](inputs/05.txt)

[Solution](solutions/d05p2.rb)

<h2 id="day06">Day 6</h2>
### Part 1
[Input](inputs/06.txt)

[Solution](solutions/d06p1.rb)

### Part 2
[Input](inputs/06.txt)

[Solution](solutions/d06p2.rb)

<h2 id="day07">Day 7</h2>
### Part 1
[Input](inputs/07.txt)

[Solution](solutions/d07p1.rb)

### Part 2
[Input](inputs/07.txt)

[Solution](solutions/d07p2.rb)

<h2 id="day08">Day 8</h2>
### Part 1
[Input](inputs/08.txt)

[Solution](solutions/d08p1.rb)

### Part 2
[Input](inputs/08.txt)

[Solution](solutions/d08p2.rb)

<h2 id="day09">Day 9</h2>
### Part 1
[Input](inputs/09.txt)

[Solution](solutions/d09p1.rb)

### Part 2
[Input](inputs/09.txt)

[Solution](solutions/d09p2.rb)

<h2 id="day10">Day 10</h2>
### Part 1
[Input](inputs/10.txt)

[Solution](solutions/d10p1.rb)

### Part 2
[Input](inputs/10.txt)

[Solution](solutions/d10p2.rb)

<h2 id="day11">Day 11</h2>
### Part 1
[Input](inputs/11.txt)

[Solution](solutions/d11p1.rb)

### Part 2
[Input](inputs/11.txt)

[Solution](solutions/d11p2.rb)

<h2 id="day12">Day 12</h2>
### Part 1
[Input](inputs/12.txt)

[Solution](solutions/d12p1.rb)

### Part 2
[Input](inputs/12.txt)

[Solution](solutions/d12p2.rb)

<h2 id="day13">Day 13</h2>
### Part 1
[Input](inputs/13.txt)

[Solution](solutions/d13p1.rb)

### Part 2
[Input](inputs/13.txt)

[Solution](solutions/d13p2.rb)

<h2 id="day14">Day 14</h2>
### Part 1
[Input](inputs/14.txt)

[Solution](solutions/d14p1.rb)

### Part 2
[Input](inputs/14.txt)

[Solution](solutions/d14p2.rb)

<h2 id="day15">Day 15</h2>
### Part 1
[Input](inputs/15.txt)

[Solution](solutions/d15p1.rb)

### Part 2
[Input](inputs/15.txt)

[Solution](solutions/d15p2.rb)

<h2 id="day16">Day 16</h2>
### Part 1
[Input](inputs/16.txt)

[Solution](solutions/d16p1.rb)

### Part 2
[Input](inputs/16.txt)

[Solution](solutions/d16p2.rb)

<h2 id="day17">Day 17</h2>
### Part 1
[Input](inputs/17.txt)

[Solution](solutions/d17p1.rb)

### Part 2
[Input](inputs/17.txt)

[Solution](solutions/d17p2.rb)

<h2 id="day18">Day 18</h2>
### Part 1
[Input](inputs/18.txt)

[Solution](solutions/d18p1.rb)

### Part 2
[Input](inputs/18.txt)

[Solution](solutions/d18p2.rb)

<h2 id="day19">Day 19</h2>
### Part 1
[Input](inputs/19.txt)

[Solution](solutions/d19p1.rb)

### Part 2
[Input](inputs/19.txt)

[Solution](solutions/d19p2.rb)

<h2 id="day20">Day 20</h2>
### Part 1
[Input](inputs/20.txt)

[Solution](solutions/d20p1.rb)

### Part 2
[Input](inputs/20.txt)

[Solution](solutions/d20p2.rb)

<h2 id="day21">Day 21</h2>
### Part 1
[Input](inputs/21.txt)

[Solution](solutions/d21p1.rb)

### Part 2
[Input](inputs/21.txt)

[Solution](solutions/d21p2.rb)

<h2 id="day22">Day 22</h2>
### Part 1
[Input](inputs/22.txt)

[Solution](solutions/d22p1.rb)

### Part 2
[Input](inputs/22.txt)

[Solution](solutions/d22p2.rb)

<h2 id="day23">Day 23</h2>
### Part 1
[Input](inputs/23.txt)

[Solution](solutions/d23p1.rb)

### Part 2
[Input](inputs/23.txt)

[Solution](solutions/d23p2.rb)

<h2 id="day24">Day 24</h2>
### Part 1
[Input](inputs/24.txt)

[Solution](solutions/d24p1.rb)

### Part 2
[Input](inputs/24.txt)

[Solution](solutions/d24p2.rb)

<h2 id="day25">Day 25</h2>
### Part 1
[Input](inputs/25.txt)

[Solution](solutions/d25p1.rb)

### Part 2
[Input](inputs/25.txt)

[Solution](solutions/d25p2.rb)
