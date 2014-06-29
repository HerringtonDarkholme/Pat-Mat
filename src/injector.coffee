{
  isArray
  isRegExp
  isFunc
  objToArray
} = require('./util')

{
  assignmentFactory
  incrementalCounter
  indexedCounter
  nominalCounter
} = require('./counter')

{
  Parameter
  Guardian
} = require('./placeholder').Parameter


class Injector
  constructor: (@pattern) ->
    @counterFunc = null
    @cache = null
    @unnamed = []
    @assigner = null
    @defined = false
  isDefinedAt: (ele) ->
    @cache = {}
    @unnamed = []
    @assigner = assignmentFactory(@cache, @unnamed,@counterFunc)
    @defined = deepMatch(@pattern, ele, @assign)
    @defined
  inject: (ele, action) ->
    if not @defined
      throw new Error('cannot call matched function when unmatched')
    action.apply({
      m: ele
      unnamed: @unnamed
    }, objToArray(@cache))
  assign: (expr, obj) =>
    unless isFunc(expr) or isRegExp(expr)
      @assigner(expr, obj)


class IncrementalInjector extends Injector
  constructor: (pattern) ->
    super
    @counterFunc = incrementalCounter

  assign: (expr, obj) =>
    if isRegExp(expr)
      for group in obj
        @assigner(RegExp, group)
    else
      @assigner(expr, obj)

class IndexedInjector extends Injector
  constructor: (pattern) ->
    super
    @counterFunc = indexedCounter

class NominalInjector extends Injector
  constructor: (pattern) ->
    super
    @counterFunc = nominalCounter
  inject: (ele, action) ->
    c = @cache
    @cache = if isArray(c) then c else [c]
    super

class PatternMatcher
  constructor: (@patterns, @action, @injectCtor) ->
    @injector = undefined
  hasMatch: (ele)->
    # handle guarded pattern
    ret = false
    ps = @patterns
    injectCtor = @injectCtor
    if (ps.length is 2 and
    (guardian = ps[1]) instanceof Guardian)
      injector = new injectCtor(ps[0])
      if (injector.isDefinedAt(ele) and
      injector.inject(ele, guardian.guard))
        @injector = injector
        ret = true
    else
      for p in ps
        injector = new injectCtor(p)
        if injector.isDefinedAt(ele)
          @injector = injector
          ret = true
          break
    Parameter.reset()
    false
  inject: (ele) ->
    @injector.inject(ele, @action)
