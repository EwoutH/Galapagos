class window.AgentModel
  constructor: () ->
    @turtles = {}
    @patches = {}
    @links = {}
    @observer = {}
    @world = {}

  # The loops here have been optimized for V8 by replace for ... of ... loops
  # with regular loops over Object.keys. It would be better if they were
  # for ... of ... loops, but V8 wasn't able to optimize that. Note that this is
  # not a good optimization strategy in general. It only works in specific
  # situations.
  # The bodies of the loops are in inlineable loops. This also helps V8 reason
  # about the loops. --BCH (1/9/14)
  update: (modelUpdate) ->
    turtleUpdates = modelUpdate.turtles
    if turtleUpdates
      for turtleId in Object.keys(turtleUpdates)
        if isFinite(turtleId)
          @updateTurtle(turtleId, turtleUpdates[turtleId])
    linkUpdates = modelUpdate.links
    if linkUpdates
      for linkId in Object.keys(linkUpdates)
        @updateLink(linkId, linkUpdates[linkId])
    if modelUpdate.world? and modelUpdate.world[0]?
      # TODO: This is really not okay. The model and the updates should be the
      # same format.
      worldUpdate = modelUpdate.world[0]
      mergeObjectInto(modelUpdate.world[0], @world)
      # TODO: I don't like this either...
      if (worldUpdate.minPxcor? and
          worldUpdate.maxPxcor? and
          worldUpdate.minPycor? and
          worldUpdate.maxPycor?)
        # Preserve what patches we can. This is particularly to guard against
        # receiving new patch data from a resize-world before receiving the
        # updates to the world object. --BCH (3/28/2014)
        for index, patch of @patches
          if (patch.pxcor < worldUpdate.minPxcor or
              patch.pxcor > worldUpdate.maxPxcor or
              patch.pycor < worldUpdate.minPycor or
              patch.pycor > worldUpdate.maxPycor)
            delete @patches[index]
    patchUpdates = modelUpdate.patches
    if patchUpdates
      for patchId in Object.keys(patchUpdates)
        @updatePatch(patchId, patchUpdates[patchId])
    if modelUpdate.observer? and modelUpdate.observer[0]?
      mergeObjectInto(modelUpdate.observer[0], @observer)
    return

  updateTurtle: (turtleId, varUpdates) ->
    if varUpdates == null or varUpdates['WHO'] == -1
      delete @turtles[turtleId]
    else
      t = @turtles[turtleId]
      if not t?
        t = @turtles[turtleId] = {
          heading: 360*Math.random(),
          xcor: 0,
          ycor: 0,
          shape: 'default',
          color: 'hsl('+(360*Math.random())+',100%,50%)'
        }
      mergeObjectInto(varUpdates, t)

  updateLink: (linkId, varUpdates) ->
    if varUpdates == null or varUpdates['WHO'] == -1
      delete @links[linkId]
    else
      l = @links[linkId]
      if not l?
        l = @links[linkId] = {
          shape: 'default',
          color: 5
        }
      mergeObjectInto(varUpdates, l)

  updatePatch: (patchId, varUpdates) ->
    p = @patches[patchId]
    p ?= @patches[patchId] = {}
    mergeObjectInto(varUpdates, p)

  mergeObjectInto = (updatedObject, targetObject) ->
    # Chrome complains it can't inline this function. Changing this to a
    # regular for loop over Object.keys fixes this, but actually makes
    # performance worse. --BCH (1/9/14)
    for variable, value of updatedObject
      targetObject[variable.toLowerCase()] = value
    return