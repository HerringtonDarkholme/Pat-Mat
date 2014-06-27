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

class Injector
  constructor: (@pattern) ->
    @counterFunc = null
    @cache = null
    @assigner = null
    @defined = false
  isDefinedAt: (ele) ->
    @cache = {}
    @assigner = assignmentFactory(@cache, @counterFunc)
    @defined = deepMatch(@pattern, ele, @assign)
    @defined
  inject: (ele, action) ->
    if not @defined
      throw new Error('cannot call matched function when unmatched')
    action.apply(ele, objToArray(@cache))
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
        return true
    false
  inject: (ele) ->
    @injector.inject(ele, @action)
