{isArray, isFunc} = require('./util')
{Matcher} = require('./matcher')

class Extractor

  FN_ARGS = ///
    ^function # function
    \s*       # optional white
    [^\(]*    # function name
    \(        # left paren
    \s*
    ([^\)]*)  #params
    \)        # right paren
  ///m

  COMMENT = ///
    \/\*[\s\S]*?\*\/ # block comment
    | \/\/.*$        # linewise comment
  ///mg

  FN_ARG_SPLIT = /,/
  FN_ARG = /^\s*(\S+)\s*$/mg

  annotate = (func) ->
    if not isFunc(func)
      throw new Error('need function')
    fnText = func.toString().replace(COMMENT, '')
    params = fnText.match(FN_ARGS)[1]
    (param.trim() for param in params.split(FN_ARG_SPLIT))

  constructor: (@ctor) ->
    @annotation = null
    @unapply = null
    annotation = @ctor.unapply
    if not (annotation?)
      @annotation = annotate(@ctor)
    else if isArray(annotation)
      @annotation = annotation
    else if isFunc(annotation)
      @unapply = annotation

  link: (argList) ->
    new Matcher(@annotation, @unapply, argList)


extract = (ctor) ->
  extractor = new Extractor(ctor)
  F = (args...) ->
    unless @ instanceof ctor
      extractor.link(args)
    else
      ctor.apply(this, args)
  F extends ctor
  F

class Point
  constructor: (@x, @y) ->
  @unapply = ['sss', 'ssss']
P = extract Point
console.log (new Extractor(Point)).annotation
matcher = P(2,3)

module.exports = {
  Extractor
  extract
}

