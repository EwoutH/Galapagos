extensions [ sound ]

globals [ instrument-index memory ]

;; initializes the instrument-index and the memory bank
to startup
  set instrument-index 0
  set memory (list "" "" "" "")
end

;; plays the current note and prints it to the output area
to play
  run generate-command
  output-print generate-command
end

;; generates a NetLogo command to play the current instrument
;; at the current tone with the current velocity
to-report generate-command
  report (word "sound:play-note \"" ( item instrument-index sound:instruments )
               "\" " tone " " velocity " " duration)
end

;; saves the current command in the nth memory slot
to save [ n ]
  set memory replace-item n memory generate-command
end

;; returns a list of tones comprising a middle-C major scale
to-report c-major-scale
  report map [ note -> note + 60] [0 2 4 5 7 9 11 12]
end

;; arrow keys to scroll through the instrument list
to first-instrument
  set instrument-index 0
  play
end

to last-instrument
  set instrument-index length sound:instruments - 1
  play
end

to next-instrument
  if instrument-index < length sound:instruments - 1 [
    set instrument-index instrument-index + 1
    play
  ]
end

to prev-instrument
  if instrument-index > 0 [
    set instrument-index instrument-index - 1
    play
  ]
end


; Public Domain:
; To the extent possible under law, Uri Wilensky has waived all
; copyright and related or neighboring rights to this model.
@#$#@#$#@
GRAPHICS-WINDOW
458
10
771
24
-1
-1
5.0
1
10
1
1
1
0
1
1
1
-30
30
0
0
1
1
1
ticks
30.0

MONITOR
147
17
365
66
instrument
(word (instrument-index + 1) \". \" \n(item instrument-index sound:instruments))
3
1
12

BUTTON
79
32
134
65
<--
prev-instrument
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
376
31
431
64
-->
next-instrument
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
22
79
174
112
velocity
velocity
0
127
91.0
1
1
NIL
HORIZONTAL

SLIDER
22
149
173
182
tone
tone
0
120
65.0
1
1
NIL
HORIZONTAL

BUTTON
200
139
293
172
Play note
play
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
22
113
174
146
duration
duration
0
2
1.15
0.05
1
NIL
HORIZONTAL

BUTTON
21
32
76
65
|<--
first-instrument
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
435
31
490
64
-->|
last-instrument
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
23
429
79
477
Save 1
save 1
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
151
425
476
474
NIL
item 1 memory
3
1
12

BUTTON
23
483
80
528
Save 2
save 2
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
152
480
476
529
NIL
item 2 memory
3
1
12

BUTTON
479
426
535
474
Play
run item 1 memory
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
538
426
593
474
Print
output-print item 1 memory
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
84
429
139
477
Clear
set memory replace-item 1 memory \"\"
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
479
480
535
528
Play
run item 2 memory
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
538
480
593
528
Print
output-print item 2 memory
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
84
482
140
528
Clear
set memory replace-item 2 memory \"\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
25
386
439
418
MEMORY BANK\n-----------------------------------------------------
12
0.0
0

BUTTON
23
534
80
579
Save 3
save 3
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
151
533
475
582
NIL
item 3 memory
3
1
12

BUTTON
479
534
534
579
Play
run item 3 memory
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
538
534
593
579
Print
output-print item 3 memory
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
84
534
139
579
Clear
set memory replace-item 3 memory \"\"
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
474
389
547
422
Play all
foreach memory run
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
328
139
431
172
stop music
sound:stop-music
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
396
327
532
360
Play C-major chord
let tmp tone\nforeach [ 60 64 67 ] [ n -> set tone n play ]\nset tone tmp
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
266
327
389
360
Play C-major scale
let tmp tone\nforeach c-major-scale [ note ->\n  set tone note\n  play\n  wait duration\n]\nset tone tmp
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
23
326
251
375
C-major scale
c-major-scale
3
1
12

MONITOR
181
80
544
129
NIL
generate-command
3
1
12

TEXTBOX
610
55
700
412
48    C\n49    C#\n50    D\n51    D#\n52    E\n53    F\n54    F#/Gb\n55    G\n56    A#/Bb\n57    A\n58    A#/Bb\n59    B\n60    C\n61    C#\n62    D\n63    D#\n64    E\n65    F\n66    F#/Gb\n67    G\n68    A#/Bb\n69    A\n70    A#/Bb\n71    B\n72    C
12
0.0
0

OUTPUT
22
193
546
308
12

@#$#@#$#@
## WHAT IS IT?

This model demonstrates the capabilities of the sound extension. It allows modelers to experiment with different instruments.

The instrument section allows you to choose one of the 128 instruments provided by the sound extension. (For a complete list, see the Sound section of the NetLogo User Manual.) After you choose an instrument, you can listen to a C-major scale or chord in that instrument, or choose a particular pitch.

Each time the model plays a sound, it writes the command used to generate the sound to the output area. You can copy and paste the command to use in your models.

The memory bank lets you store the current sound for later retrieval, allowing you to hear how different sounds will sound together.

<!-- 2004 -->
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
