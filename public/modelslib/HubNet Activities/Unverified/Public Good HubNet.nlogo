;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variable and Breed declarations ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

globals
[
   turn
   bank

   good-patches
]

breed [ students student ]

students-own
[
  user-id
  investment
  my-money
  return-investment
  invested
  fraction-put-in
  punishing
  base-color
]


;;;;;;;;;;;;;;;;;;;;;
;; Setup Functions ;;
;;;;;;;;;;;;;;;;;;;;;

to startup
  setup
  hubnet-reset
end

to setup
  reset-ticks
  ask patches [ set pcolor white ]
  set good-patches patches with [pxcor mod 2 = 0 xor pycor mod 2 = 0 and ( abs ( pxcor - min-pxcor) > 2 ) ]
end

;;;;;;;;;;;;;;;;;;;;;;;
;; Runtime Functions ;;
;;;;;;;;;;;;;;;;;;;;;;;

to go
  ;; get commands and data from the clients
  listen-clients

  every 0.5 [
    ask students
    [
      ifelse (labels-on?)
      [
        set label ( word  user-id ", $" my-money )
      ]
      [
        set label ( word  my-money )
      ]
    ]
    tick
 ]
end

to start-over
  set turn 1
  ask students [ reset-student-money ]
end

to reset-student-money
  set my-money 10
  hubnet-send user-id "my-money" standardize-money my-money
  set investment 5
  hubnet-send user-id "Money Put In" (investment)
  set invested 0
  set return-investment 0
  set label ""
  set bank 0
  set punishing 0
end

to-report standardize-money [ money ]
  report precision money 2
end

to take-money
   ask students
   [
     set investment round ( fraction-put-in * my-money )
     hubnet-send user-id "Money Put In" (investment)
   ]

  ;;;turn turtles from green to white
  ask turtles [set color base-color]
  wait .1
  repeat 3
  [
    ask turtles [set color color + 1]
    wait .1
  ]
  ask turtles [set color base-color + 4.5]
  wait .2
  ;;;end of turning turtles from green to white

  ask students
  [
    set bank  investment  + bank
    set my-money standardize-money ( my-money -  investment )
    hubnet-send user-id "my-money" (my-money)
    set punishing 0
  ]
  plot bank
  wait 1
end


to give-money
  ;;;turn turtles from white to green
  ask students [set color base-color + 4.5]
  wait .3
  ask students [set color base-color + 3]
  wait .2
  repeat 3
  [
    ask students
    [set color color - 1]
    wait .1
  ]
  ;;;end of turning turtles from white to green

  set turn turn + 1
  set bank bank * 2

  ask students
  [
    set my-money my-money + ( bank / count students )
    set my-money standardize-money my-money

    hubnet-send user-id "my-money" (my-money)
    ifelse (labels-on?)
    [
      set label ( word  user-id ", " my-money )
    ]
    [
      set label ( word  my-money )
    ]
    set punishing 0
  ]
  set bank 0
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code for interacting with the clients ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; determines which client sent a command, and what the command was
to listen-clients
  while [ hubnet-message-waiting? ]
  [
    hubnet-fetch-message
    ifelse hubnet-enter-message?
    [ create-new-student display ]
    [
      ifelse hubnet-exit-message?
      [ remove-student display ]
      [ execute-command hubnet-message-tag ]
    ]
  ]
end

to execute-command [command]
  if command = "fraction-put-in"
  [
      ask students with [user-id = hubnet-message-source]
      [
        set fraction-put-in hubnet-message
      ]
      ask students
      [
        set investment round ( fraction-put-in * my-money )
        hubnet-send user-id "Money Put In" (investment)
      ]
  ]

  if command = "pay-1-dollar-to-punish-the-rich"
  [
    ask students with [user-id = hubnet-message-source]
    [
      set my-money my-money - 1
      hubnet-send user-id "my-money" (my-money)
    ]

    ask max-one-of students [my-money]
    [
      set my-money my-money - 1
      hubnet-send user-id "my-money" (my-money)
      set punishing 1
    ]
  ]
end

to create-new-student
  create-students 1
  [
    setup-student-vars
    send-info-to-clients
  ]
end

;; sets the turtle variables to appropriate initial values
to setup-student-vars  ;; turtle procedure
  set user-id hubnet-message-source
  set shape "circle"
  set base-color one-of [ blue gray yellow brown red orange magenta cyan violet ]
  set color base-color
  set label-color black
  set fraction-put-in 0.50
  let my-patch one-of good-patches with [ not any? turtles-here ]
  ifelse (my-patch != nobody)
    [ move-to my-patch ]
    [ setxy random-xcor random-ycor ]
  reset-student-money
end

;; sends the appropriate monitor information back to the client
to send-info-to-clients
  hubnet-send user-id "You are:" (user-id)
end

;; Kill the turtle, set its shape, color, and position
;; and tell the node what its turtle looks like and where it is
to remove-student
  ask students with [user-id = hubnet-message-source]
  [ die ]
end


; Copyright 2003 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
226
10
630
415
-1
-1
44.0
1
18
1
1
1
0
1
1
1
-4
4
-4
4
1
1
1
ticks
30.0

MONITOR
148
140
205
185
Turn
turn
3
1
11

BUTTON
22
34
205
67
Restart Activity
setup start-over
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
14
263
214
308
bank
bank
3
1
11

SWITCH
507
438
628
471
labels-on?
labels-on?
0
1
-1000

SLIDER
18
148
144
181
total-turn-time
total-turn-time
5
30
30.0
5
1
NIL
HORIZONTAL

BUTTON
22
71
206
134
Go
go every total-turn-time [ take-money give-money ]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
14
312
214
462
bank
time
money
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

BUTTON
24
190
204
223
Take Money
take-money
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
24
223
204
256
Give Money
give-money
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

Public Good is a game that asks each of the players to contribute to a common pool that will then be multiplied by the game leader and redistributed to all players.

The standard economic prediction based on 'rational' behavior is that all individuals will contribute nothing.  However, in practice, players show a wide diversity of strategies.  This game also allows players to pay to remove money from players who are 'doing too well.'

The game can be used to demonstrate basic multiplication, cooperative behavior, and the evolution of altruism as players negotiate fair play.

## HOW IT WORKS

At the beginning of the game, all players are given the same amount of money.  Each turn begins with players anonymously deciding how much money to contribute to a common pool held by the game leader.  Then the game leader collects the money and multiplies it by a number greater than one, and then redistributes this money to all the players.  At any point during the game a player may press the "punish the rich" button which takes away one dollar from the presser and one dollar from the richest player.  The game continues like this until the game leader decides it is an appropriate time to stop.

## HOW TO USE IT

To begin the game, have students log into the game by initiating their HubNet clients.

Once all players have logged in, the game leader can press "Go" to make players visible in the public space.  Then press "Restart Activity" to give each player their starting amount of money (10$).  After pressing "Restart Activity" the players should be asked to move their "fraction-put-in" slider to control the amount of money they want to contribute to the common pool to be collected by the game leader. The game moves through "Take Money"-"Give Money" cycles. "Take Money" collects money from all the players and removes it from their individual accounts; the cumulative amount taken is visible in the "Bank". This turns each player's turtle the color white.  Then the money is doubled and redistributed equally to all players by pressing "Give Money." This returns the players to their former color.

Players can press the "pay-1-dollar-to-punish-the-rich" button at any time, which takes one dollar from their accounts but also removes one dollar from the wealthiest players account.

The game leader may choose to end the game after a certain number of turns or after a certain player reaches a specific dollar amount in their account.

"labels-on?"  will allow players to see names next to each of the accounts visible in the public viewing space.  By turning the labels "off" students can remain anonymous during the game.

## THINGS TO NOTICE

Discussion on the following topics may be appropriate for different levels of players:

- How does the fraction slider affect how much money is given to the bank?
- How does the participation of other players affect the outcome for each individual?
- Can predictions be made about how much money will be returned for specific investments?  Are the predictions correct?  Why or why not?
- How do different individuals play?  What is the best way to play?  Would this change if individuals were put into small teams who competed against one another?
- What role does punishment play in this game?  How can it be used effectively?
- How is this game like or not like real life situations where cooperation is necessary?
- How might situations like this in real life lead to altruistic behavior on the part of the participants?

## THINGS TO TRY

Try playing the game once with labels "Off" then once with labels "On."  Does this change the game play?

Try changing the multiplier that the bank uses to increase the money before it is redistributed.

## CREDITS AND REFERENCES

Here are some references to increase your understanding and appreciation of this game and others like it

Henrich, J. and R. Boyd and S.Bowles and C. Camerer and E.Fehr and H. Gintis and R. McElreath (2001) Cooperation, Reciprocity and Punishment in Fifteen Small-scale Societies," Working Papers 01-01-007, Santa Fe Institute.

Sanfey, A. et al. (2003) The Neural basis of economic decision-making in the ultimatum game. Science 300: 1755-1758.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (2003).  NetLogo Public Good HubNet model.  http://ccl.northwestern.edu/netlogo/models/PublicGoodHubNet.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the HubNet software as:

* Wilensky, U. & Stroup, W. (1999). HubNet. http://ccl.northwestern.edu/netlogo/hubnet.html. Center for Connected Learning and Computer-Based Modeling, Northwestern University. Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2003 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This activity and associated models and materials were created as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227.

<!-- 2003 -->
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
VIEW
270
10
666
406
0
0
0
1
1
1
1
1
0
1
1
1
-4
4
-4
4

MONITOR
39
12
228
61
You are:
NIL
3
1

SLIDER
43
129
215
162
fraction-put-in
fraction-put-in
0.0
1.0
0.5
0.01
1
NIL
HORIZONTAL

MONITOR
90
71
170
120
my-money
NIL
2
1

MONITOR
85
171
177
220
Money Put In
NIL
3
1

BUTTON
17
229
255
262
pay-1-dollar-to-punish-the-rich
NIL
NIL
1
T
OBSERVER
NIL
NIL

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
