{
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

Parameter = require('./placeholder').Parameter

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
    @cache = [@cache]
    super

class PatternMatcher
  constructor: (@patterns, @action, @injectCtor) ->
    @injector = undefined
  hasMatch: (ele)->
    for p in patterns
      injector = new (@injectCtor)(p)
      if injector.isDefinedAt(ele)
        @injector = injector
        Parameter.reset()
        return true
    Parameter.reset()
    false
  inject: (ele) ->
    @injector.inject(ele, @action)
