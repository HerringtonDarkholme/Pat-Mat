Is = (pattern, matched) ->
As = (pattern, matched) ->
On = (pattern, matched) ->


class Injector
  constructor: (@assign, @pattern, @matched) ->
    @cache = {}
  isDefinedAt: (ele) ->
    @cache = {}
    deepMatch(@pattern, ele, @assign)
  inject: ->
    @matched()


decorateObjectPrototype = (name='Match') ->
  Object::[name] = (args...) ->
    Match(args...)(this)

Match = (args...) -> (ele) ->
  for injector in args
    unless injector instanceof Injector
      throw new TypeError('need at/to clause')
    if injector.isDefinedAt(ele)
      return injector.inject()
  null
