globals [
  ;; the-short-list is a list of the addends for the current total
  ;; it is used to display the addends in the command center, and it is initialized for each new search
  ;; also, the "sum the-short-list" gives us the running total and is used to check if we're at the target yet
  the-short-list

  ;; used to display in a monitor the previous list of addends
  previous-short-list

  ;; the-long-list is a list of all the-short-lists, and it is used for the histogram
  the-long-list

  ;; addend is the number randomly generated by the model at each trial. Note that in this version of the model,
  ;; addends are drawn randomly from a sample space of addends that can still fit into the target total,
  ;; given the running total. So if the target-total slider is set to 20, and the running total is at 16,
  ;; then the addends are drawn randomly from a sample space between 1 and 4.
  ;; Thus, the active sample space decreases as the running total grows.
  addend

  ;; successes-so-far counts up how many times the-short-list has summed up to the total since last setup
  ;; it should be periodically equal to the quotient of "sum the-long-list / target-total"
  successes-so-far

  ;; counter of how many addends each series is taking
  #addends-so-far-in-this-series

  ;; list of how many addends it took to complete each total
  partition-series-list
  ]

to startup
  setup
end

to setup
  clear-all
  ;; during setup, both the-short-list and the-long-list are initialized,
  ;; but during the run, the-short-list keeps initializing at each success, whereas the-long-list does not
  set the-long-list []
  set the-short-list []
  set partition-series-list []
  reset-ticks
  set-current-plot "Addends"
  set-plot-x-range 1 ( target-total + 1 )
end

to go
  if ( successes-so-far >= num-successes ) [ stop ]
  random-guess-and-update-total
  tick
  update-plot
  finish-up
end

to random-guess-and-update-total
  let running-total sum the-short-list

  let temp-sample-space 0
  ifelse diminishing-sample-space?
  [
    ;; we draw a random number from the space remaining between the running total and the target-total
    set temp-sample-space ( target-total - running-total )
  ]
  [
    ;; we draw a random number from the entire target-total
    set temp-sample-space target-total
  ]


  ;; we add 1 because random x reports numbers between 0 and (x-1)
  set addend ( 1 + random temp-sample-space )

  ;; if the addend is small enough not to exceed the target-total, we keep it in the-short-list, and paint it in
  if sum the-short-list + addend <= target-total [
    set the-short-list lput addend the-short-list
    paint
  ]
  set #addends-so-far-in-this-series #addends-so-far-in-this-series + 1
  set the-long-list lput addend the-long-list
end

;;; make a histogram of all the addends in the-long-list at the right times
to update-plot
  set-current-plot "Addends"
  histogram the-long-list
  let maxbar modes the-long-list
  let maxrange length filter [ the-item -> the-item = item 0 maxbar ] the-long-list
  set-plot-y-range 0 max list 10 maxrange
end

to paint
  let pxcor-of-right-most-colored-patch 0
  ifelse length the-short-list = 1
    ;; we want to create a ribbon of addends, each addend with a different color
    [set pxcor-of-right-most-colored-patch ( -1 * max-pxcor - 1 ) ]
    [set pxcor-of-right-most-colored-patch ( max [ pxcor ] of patches with [ pcolor != black ] )]

  ;; temp-color will be any of 14 colors from the NetLogo color space
  let temp-color one-of base-colors

  ;; we color only the patches that reflect the latest addend
  ask patches with
    [ ( pxcor > pxcor-of-right-most-colored-patch ) and ( pxcor <= ( pxcor-of-right-most-colored-patch + addend ) ) ]
      [ set pcolor temp-color ]
end

to finish-up
  if sum the-short-list = target-total
  [
    set partition-series-list lput #addends-so-far-in-this-series partition-series-list
    set-current-plot"#Addends Per Total"
    set-plot-x-range 1 ( 1 + max partition-series-list )
    histogram partition-series-list
    let maxbar modes partition-series-list
    let maxrange length filter [ partition -> partition = item 0 maxbar ] partition-series-list
    set-plot-y-range 0 max list 10 maxrange
    set #addends-so-far-in-this-series 0
    set previous-short-list the-short-list
    set the-short-list []
    set addend "-"
    set successes-so-far successes-so-far + 1
    if wait-at-full? [ wait .5 ]
    clear-patches
    clear-turtles
  ]
end


; Copyright 2004 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
6
47
822
80
-1
-1
8.0
1
10
1
1
1
0
1
1
1
-50
50
-1
1
1
1
1
ticks
30.0

BUTTON
6
10
96
43
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
102
10
191
43
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
179
192
399
319
Addends
NIL
NIL
0.0
100.0
0.0
10.0
true
false
"" ""
PENS
"list" 1.0 1 -16777216 true "" ""

MONITOR
72
192
173
237
Running Total
sum the-short-list
0
1
11

MONITOR
7
272
127
317
Successes So Far
successes-so-far
0
1
11

SLIDER
21
102
821
135
target-total
target-total
2
100
72.0
1
1
NIL
HORIZONTAL

SLIDER
290
10
470
43
num-successes
num-successes
0
10000
10000.0
100
1
NIL
HORIZONTAL

MONITOR
7
192
69
237
Addend
addend
3
1
11

BUTTON
195
10
285
44
Add Once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
695
11
824
44
wait-at-full?
wait-at-full?
0
1
-1000

MONITOR
439
271
598
316
Mean #Addends Per Total
(length the-long-list) / (successes-so-far)
3
1
11

SWITCH
475
11
691
44
diminishing-sample-space?
diminishing-sample-space?
0
1
-1000

PLOT
604
191
825
320
#Addends Per Total
NIL
NIL
1.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" ""

MONITOR
7
140
825
185
Previous List of Included Addends
previous-short-list
3
1
11

@#$#@#$#@
## WHAT IS IT?

Partition Permutation Distribution is a model built around the idea of a partition function. This function relates between an integer, e.g., 4, and the number of different ways you can break this integer up into groups of integers, where order does not matter. For instance, 4 can be broken up in 5 ways:

(1) 4;
(2) 3 + 1;
(3) 2 + 2;
(4) 2 + 1 + 1; and
(5) 1 + 1 + 1 + 1.

Notice that in the above example, the number '1' appeared more often than the number '4.' Why is that? To address this question, this model allows you to repeatedly find partitions of a number and look at the distribution of integers in the partitions.

This model is a part of the ProbLab curriculum. The ProbLab Curriculum is currently under development at the CCL. For more information about the ProbLab Curriculum please refer to http://ccl.northwestern.edu/curriculum/ProbLab/.

## HOW IT WORKS

In this model, you choose a target-total, for instance 20, and the code randomly generates addends of the total and adds them to the running-total. These addends are represented in the view, too, as colorful lines that each are as long as the addend it represents. For instance, an addend of 13 will be 13 "patches" long ("patches" are the NetLogo square areas that make up the grid of the view). When the running-total reaches the total, there's been a 'success.' Unlike the actual partition function, this model will not return a value. Moreover, in this model, there is no explicit attempt to exhaust all the partitions. Instead, the randomized procedure keeps adding up the totals randomly. Over many such brute-force addings, a graph shape emerges, and the same shape emerges both for constant totals over many runs and for different totals. The question is why this shape emerges and what this shape means in terms of partitions. So this model uses partitions as an engaging riddle to explore the idea of distribution.

Note:
The shape of the graph does not correspond to a simple distribution of all possible permutations, nor to a simple scaling up of such a distribution, such as we would expect the model to create through repetition of previously created partitions. That is, it is not the case that the model chooses randomly from the set of all possible partition permutations of some total. There are two conditions for running this model, depending on the setting of the slider 'diminishing-sample-space?' The following comment refers to the case that the switch is set to 'On.'

The model chooses a first addend out of a space of the whole total, a second addend out of the space of the remainder of the total, and so on. So, the greater addends are "over represented." For instance, for a total of '5,' there is only a single partition with a single addend - the partition "[5]" that includes only '5' as an addend, whereas there are numerous partitions that do not include '5.' So you might expect that '5' would occur very rarely as compared to, say, '1.' However, due to the rationale of the model, '5' actually occurs much more often. Involved here are some subtleties and possible confusions as to what we mean by 'often' -- what our unit of analysis is: Are we counting per addend or per total? Each time a total has been obtained and the model begins creating a new total, there is a 1-out-of-5 chance that the first addend will be '5.' Another way to think of this is that you might expect the partition [5] to occur as often as the partition [1 1 1 1 1], but actually the partition [1 1 1 1 1] occurs 1/ 3125 as often as the partition [5], because we have to get a '1' AND a '1' AND a '1' AND a '1' AND a '1,' whereas for [5], all we have to get is a '5.' Understanding these subtleties may help you develop a more nuanced understanding of statistics experiments.

## HOW TO USE IT

When you open the model, numerical and Boolean values will already be set for an easy start, as following:
To begin, you can slow down the model with the 'adjust-speed' slider that is on the top-left corner of the view. TARGET-TOTAL is set at 20. Press GO and watch the RUNNING-TOTAL and ADDEND monitors. The addend will be a random number between 1 and 20. Immediately, this addend, say 7, will move over to the running-total, and now there will be a new addend. This new addend will be a random value between 1 and 13 (because the default setting of the switch 'DIMINISHING-SAMPLE-SPACE?' is set so that addends are chosen from the difference remaining up to the total). Say the second addend is 2. So now the running-total becomes 9. The third addend could be 5, so we'd get 14, and so on. Let us say that this run gave us the addends 7 + 2 + 5 + 1 + 4 for a total of 20.  The histogram grows one notch up for each of these addends.

Switches:
WAIT-AT-FULL? If it is set to 'On,' the experiment will wait briefly each time the target-total has been achieved.
DIMINISHING-SAMPLE-SPACE? -- if 'On,' addends will be selected from a sample space that is the size of the remaining difference to the target-total. For example, if the running total of the current adding-up is at 16 and our target-total is 20, then the next addend will be selected from the range 1-thru-4. However, if the switch is set to 'Off,' then the range will always be the target-total, 20.

Sliders:
TARGET-TOTAL -- sets the total towards which the program will be adding up the randomly generated values
NUM-SUCCESSES -- sets how many times the program will sum up to the target-total you have set

Monitors:
RUNNING-TOTAL -- shows how far towards the target-total the adding has gone
ADDEND -- shows the current value that has just been generated and added to the running-total
SUCCESSES-SO-FAR -- shows how many times the total has been reached. Once this is equal to the NUM-SUCCESSES slider value, the program stops.
MEAN #ADDENDS PER TOTAL -- shows how many acceptable addends it took, on average, to fill the target-total that you set, over all the trials
PREVIOUS LIST OF INCLUDED ADDENDS -- shows the last completed series of addends up to the target total

Buttons:
SETUP -- initialize variables
GO -- run the model under your chosen settings. It will run through as many 'num-successes' as you have set.
ADD-ONCE -- A single addend is added to the running-total and the histogram is updated. Use this to run the program step by step.

Plots:
ADDENDS -- plots the addends as they are randomly selected
\#ADDENDS PER TOTAL -- plots the number of addends it takes to complete each target-total

## THINGS TO NOTICE

When 'diminishing-sample-space?' is set to 'Off,' the addends get smaller as you get closer to the total.

The histogram columns get smaller as you move from left to right.

When 'diminishing-sample-space?' is set to 'Off,' the 'mean addends per total' value converges to the value of 'target-total.' Why is this so? Also, the 'Addends Per Total' distribution slopes down to the right. What can you say of that?

When 'diminishing-sample-space?' is set to 'On,' the 'mean addends per total' value converges to some value. Can you say anything about this value in relation to other settings in the model? Also, the 'Addends Per Total' distribution is normal. Why is that?

## THINGS TO TRY

Set the target-total to .5. Run the model over many num-successes, 'diminishing-sample-space?' set to 'On,' and with a high target-total.
The 2-column will be 1/2 the height of the 1-column.
The 3-column will be 1/3 the height of the 1-column.
The 4-column will be 1/4 the height of the 1-column.
The 5-column will be 1/5 the height of the 1-column.
etc. So we get a '1/n' function. Why is this? Does is work for other target-total values?

Another way to express this relation between the columns is as follows. Say we look at Column 'i.' The relation between the height of Column i and the column immediately to its left (Column 'i - 1') is
      (i - 1) / i . For instance, the relation between the heights of Column 9 and Column 8 is that Column 9 is 8/9 as tall as Column 8.

Set target-total to 2 and 'diminishing-sample-space?' to 'On.' Set 'num-successes' to 10,000 and run the model until it stops. Compare the value of 'Successes So Far' to the y-value of the 1-Column in the "Addends" plot. You will see that these values are very similar. So over many runs, we expect that the '1' will occur as many times as we have had runs. (See ProbLab model 'Expected Value' for an explanation of how to make predictions of expected values.) This is true for other target-totals -- we chose 2 so as to make this work fast.

Now look at the 'mean #addends per total' you received. It should be very near to 1.5.  This is related to our finding, above, that the 2-Column is 1/2 (.5) as tall as the 1-Column and to our expectation to get as many '1's as we have had successes. These ideas combined suggest that we should get .5 as many '2's as we have had successes. So the 1-Column and the 2-Column together are 1.5 as large as the number of successes. This means that there are about 1.5 addends in each total. For the case of a target-total of '3,' we'd need to add '1 + 1/2 + 1/3.' So we'd expect a mean of 1.833 addends per toal. Try this, too!

## EXTENDING THE MODEL

Add a monitor that shows the minimum, average, and maximum number of partitions in every run (the number of items is the length of the-short-list).
Add plots for these values.
What shape do you expect this distribution to have?
Will the values change per target-total?

Note that currently we are using this logic:

         set addend ( 1 + random temp-sample-space )

This means that the model chooses addends with an eye to how much space is left up to the total (temp-sample-space is the difference between the running total and the target total).  If we removed this, and only asked for "random total", how would the model change, if at all? How would the above extensions change, if at all?

## NETLOGO FEATURES

Note that in the above line of code, we set the addend to "1 +...etc." This is due to the nature of the 'random' reporter.  The command 'random 3' returns numbers between 0 and 2, and will never return the number 3. So by adding 1, we get the values we actually want. You will come across this often in NetLogo, such as when working with lists. For example, if we had a list named "friends" ["pat" "bob" "joe" "kate"], the 3th value, 'joe,' is called "item 2 friends."

## PEDAGOGICAL NOTE

This model is related to other models in the ProbLab suite. Like other models, it looks at the evolution of a distribution that reflects procedures that have random elements. However, unlike other models, the distribution here is never bell-shaped. The greatest learning gain expected to come from working with this model is in comparing it to other models in ProbLab. This comparison should in particular revolve around an articulation, possibly in general terms, of what precisely about this model makes a bell-shaped distribution unlikely.

This model is related in an interesting way to 9-Block Stalagmite. In that model, the distribution of permutations reflects the sample space of all possible permutations. But in this model, the distribution does not reflect the sample space directly (see introduction, above).

Also, the model is related to the Attempts-Until-Success histogram in Prob Graph Basic and to the Distances to Whites histogram in Shuffle Board. Actually, those two histograms behave similar, whereas the histogram in this model behaves differently. Understanding this difference may sensitize you to "graph families." Just because all these graphs decrease monotonously, it does not necessarily mean that they describe the same or related functions.

## CREDITS AND REFERENCES

This model is a part of the ProbLab curriculum. The ProbLab Curriculum is currently under development at Northwestern's Center for Connected Learning and Computer-Based Modeling. . For more information about the ProbLab Curriculum please refer to http://ccl.northwestern.edu/curriculum/ProbLab/.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Abrahamson, D. and Wilensky, U. (2004).  NetLogo Partition Permutation Distribution model.  http://ccl.northwestern.edu/netlogo/models/PartitionPermutationDistribution.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2004 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227.

<!-- 2004 Cite: Abrahamson, D. -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.1
@#$#@#$#@
need-to-manually-make-preview-for-this-model
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
