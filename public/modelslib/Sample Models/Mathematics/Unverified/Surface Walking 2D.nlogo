;; =========================== Main Procedures ===============================

to setup
  clear-all
  if surface-shape = "circle" [ draw-big-circle ]
  if surface-shape = "square" [ draw-square     ]
  if surface-shape = "mouse"  [ draw-mouse      ]
  ask n-of number-of-turtles patches with [any? different-colored-neighbors]
    [ sprout 1
       [ set size 5
         set pen-size 2
         set color one-of remove violet base-colors ] ]
  reset-ticks
end

to go
  ask turtles [ sfd step-size ]
  tick
end

;; =========================== Surface Walking ===============================

to sfd [how-far]  ;; turtle procedure
  face-chosen-neighbor
  fd how-far
end

to face-chosen-neighbor  ;; turtle procedure
  ;; turtle faces the patch that requires the least change in
  ;; heading to face
  let closest-border-patch min-one-of different-colored-neighbors [abs turn-amount]
  rt [turn-amount / 2] of closest-border-patch
end

;; computes the turn the calling turtle would have to make to face this patch
to-report turn-amount  ;; patch procedure
  let this-patch self
  report [subtract-headings (towards this-patch) heading] of myself
end

;; ======================= Other Surface Procedures ==========================

to draw-surface
  if mouse-down? [
    create-turtles 1 [
      setxy mouse-xcor mouse-ycor
      ask patches in-radius 3 [ set pcolor violet ]
      die
    ]
    display
  ]
end

to-report different-colored-neighbors  ;; patch procedure
  ;; report neighbors that are a different color than me
  report neighbors with [pcolor != [pcolor] of myself]
end

;; =========================== Surface Drawing ===============================

to draw-big-circle
  draw-circle 0 0 (world-width * 0.45)
end

to draw-square
  ask patches with [pxcor > world-width * -0.45 and
                    pxcor < world-width *  0.45 and
                    pycor > world-width * -0.45 and
                    pycor < world-width *  0.45]
    [ set pcolor violet ]
end

to draw-mouse
  draw-circle 0                    (world-width * -0.1 ) (world-width * 0.35)
  draw-circle (world-width *  0.3) (world-width *  0.25) (world-width * 0.17)
  draw-circle (world-width * -0.3) (world-width *  0.25) (world-width * 0.17)
end

to draw-circle [x y radius]
  ask patches with [distancexy x y < radius]
    [ set pcolor violet ]
end


; Copyright 2007 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
240
10
703
474
-1
-1
5.0
1
2
1
1
1
0
0
0
1
-45
45
-45
45
1
1
1
ticks
30.0

BUTTON
95
120
220
153
draw-surface
draw-surface
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
20
70
207
115
surface-shape
surface-shape
"circle" "square" "mouse"
2

BUTTON
10
120
90
153
NIL
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

SLIDER
20
36
207
69
number-of-turtles
number-of-turtles
1
20
10.0
1
1
NIL
HORIZONTAL

BUTTON
25
165
105
198
NIL
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

SLIDER
25
205
205
238
step-size
step-size
0
.75
0.25
.01
1
NIL
HORIZONTAL

BUTTON
110
165
205
198
NIL
pen-down
NIL
1
T
TURTLE
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

This model is a 2D version of a surface-walking algorithm used in "Surface Walking 3D". Turtles approximate a user-defined surface using a simple algorithm that considers the turtle's current position relative to neighboring surface patches.

## HOW IT WORKS

Turtles exist in a world that consists of two different kinds of patches: surface and non-surface. Turtles follow two basic rules in order to walk along the patch-defined surface:

1. Look for opposite neighboring patches. If the turtle is currently on a surface patch, it will look for a non-surface one, and vice versa.
2. Of those neighboring patches of opposite type, identify the one that requires the smallest change in turtle heading for the turtle to face.
3. Turn halfway to that patch that requires the smallest change in heading to face and take a step.

Why does this algorithm work? Consider any perturbation along a flat surface (in the case of 2D, a curve or angle along an otherwise straight line). In order to traverse the perturbation and remain on the surface, a turtle needs to find and remain on the 'edge' of the surface, and maintain its direction while travelling along this edge. Since turtles in NetLogo always report being on only one patch (the one that the center of their body is over), we maintain the turtle's position along the edge by having it search for a patch that is of opposite type to the patch it is positioned over (Rule 1).

Rule 2 enables the turtles to travel along that edge while maintaining their current direction. Consider a surface in 2d: turtles are able to travel along that surface in one of two opposite directions (for example, they can walk along a circle in either a clockwise or counterclockwise direction). If a surface is flat, a turtle needs not change its heading at all to continue to travel in the same direction along that surface. But, if the surface is curved or has an angle, then in order to continue to stay along the edge of the surface the turtle must change its heading. If it changes its heading exactly 180 degrees, it will reverse its direction of travel. But whether the angle is concave or convex, it will be of some measure between 0 and 360 degrees (non-inclusive). Then the heading change required to continue along the surface without reversing the direction of travel will be less than that required to reverse direction.

Finally, Rule 3 reduces the 'weaving' effects produced by turtles moving toward surface and non-surface patches in order to remain close to the edge by having turtles actually point only halfway to the patch of interest.

## HOW TO USE IT

NUMBER-OF-TURTLES: Allows the user to adjust the number of turtles that will appear along the shape surface when SETUP is pressed.
STEP-SIZE: Allows the user to adjust how far each turtle moves forward during each step.
SURFACE-SHAPE: Allows the user to select the surface shape to appear when SETUP is pressed.
COLORED-SURFACE?: Allows user to toggle whether the surface on which turtles will walk is colored red, or is invisible.
DRAW-SURFACE: Allows the user to add mouse-drawn components to an existing surface by pressing the button and then clicking and dragging anywhere in the view. The area surrounding patches identified by the mouse will be set to behave as a surface, and if the COLORED-SURFACE? switch is on, the area will also turn red.
TRACE: Asks one of the turtles to draw a trail as it moves.
SETUP: Sets up the environment by creating a surface and placing turtles along the surface.
GO: Runs the model by asking turtles to walk along the surface.

## THINGS TO NOTICE

Try adjusting STEP-SIZE while the model is running. What happens to the motion of the turtles? What happens to their speed?

Do turtles behave differently on different types of surfaces? Try using the SURFACE-SHAPE chooser to test different shapes. Then, try drawing your own by clicking on DRAW-SURFACE and clicking and dragging your mouse in the view.

## THINGS TO TRY

What might happen if the STEP-SIZE is set to 1 or larger? Currently, turtles turn half of the way to the edge-patch they identify. What happens if they turn the whole way?

Select "Mickey Mouse" from the SURFACE-SHAPE chooser. SETUP and tell the model to GO. What happens to turtles when they pass over the acute angles where Mickey's ears meet his head? Try adjusting the STEP-SIZE slider while the model is running to investigate.

When does the surface-walking algorithm fail? Why? Use the DRAW-SURFACE button to test different shapes and angles. Does changing the resolution of the world's grid of patches affect turtle motion?

## EXTENDING THE MODEL

Currently, turtles seek the surface edge by seeking patches that are classified in certain ways. Find and implement another way that patches can be identified or that turtles can identify edge patches.

Try using `stamp` to trace the trajectory of a turtle over different kinds of surfaces. How might one describe surface-walking accuracy?

The surface-walking algorithm used in this model fails for surfaces (or gaps in surfaces) that are only one patch wide. Why? How might this be fixed?

## NETLOGO FEATURES

Note the use of `towards` to compute headings and `min-one-of` to make a choice between competing patches.

## RELATED MODELS

See Surface Walking 3D (NetLogo 3D) and Virus on a Surface 3D (NetLogo 3D).

Wall Following Example is a simpler version of this example.  It is entirely grid-based; the turtles move from patch center to center.  The code for this is much less complicated and the turtles are always able to follow the wall perfectly correctly.

## CREDITS AND REFERENCES

Thanks to Michelle Wilkerson for her work on this model.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilkerson, M. and Wilensky, U. (2007).  NetLogo Surface Walking 2D model.  http://ccl.northwestern.edu/netlogo/models/SurfaceWalking2D.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2007 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

<!-- 2007 Cite: Wilkerson, M. -->
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
