{
  isArray
  isFunc
  isPlainObject
  annotate
} = require('./util')
Matcher = require('./matcher').Matcher


class Extractor
  constructor: (@ctor) ->
    @annotation = null
    @transform = null
    unapply = @ctor.unapply

    if isArray(unapply)
      @annotation = unapply
    else if isFunc(unapply)
      @transform = unapply
    else if isPlainObject(unapply)
      @annotation = unapply.annotation
      @transform = unapply.transform

    unless @annotation?
      @annotation = annotate(@ctor)

  link: (argList) ->
    new Matcher(@annotation, @transform, argList, @ctor)


makeMatcherFrom = (obj) ->
  annotation = obj.annotation
  transform = obj.transform
  constructor = obj.constructor
  (args...) ->
    new Matcher(
      annotation
      transform
      args
      constructor
    )


extract = (ctor) ->
  if isPlainObject(ctor)
    return makeMatcherFrom(ctor)

  extractor = new Extractor(ctor)
  F = (args...) ->
    unless @ instanceof ctor
      extractor.link(args)
    else
      ctor.apply(this, args)
  F extends ctor
  F


module.exports = {
  Extractor
  extract
}

