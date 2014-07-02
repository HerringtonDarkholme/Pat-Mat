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
} = require('./placeholder')

deepMatch = require('./matcher').deepMatch

class Injector
  constructor: (@pattern) ->
    @counterFunc = null
    @cache = null
    @unnamed = []
    @assigner = null
    @defined = false
  isDefinedAt: (ele) ->
    @clear()
    @assigner = assignmentFactory(@cache, @unnamed,@counterFunc)
    @defined = deepMatch(@pattern, ele, @assign)
    if not @defined
      @clear()
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
  clear: ->
    @cache = {}
    @unnamed = []


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

class CaseExpression
  constructor: (patterns, action, injectCtor) ->
    # intern patterns into injector
    @injector = null
    @guard = null
    @action = action
    @injectors = []

    # handle guarded pattern
    if (patterns.length is 2 and
    (guardian = patterns[1]) instanceof Guardian)
      @injectors.push(new injectCtor(patterns[0]))
      @guard = guardian.guard
    else
      for p in patterns
        @injectors.push(new injectCtor(p))

  hasMatch: (ele)->
    ret = false
    # match against patterns
    for injector in @injectors
      if (injector.isDefinedAt(ele))
        ret = true
        @injector = injector
        break

    # ask guardian if certain pattern matches
    # make injector clean if guardian disagree
    if ret and @guard?
      ret = injector.inject(ele, @guard)
      if not ret
        injector.clear()

    # clean up injector if no matches found
    if not ret
      @injector = null

    Parameter.reset()
    ret
  inject: (ele) ->
    @injector.inject(ele, @action)

module.exports = {
  IncrementalInjector
  IndexedInjector
  NominalInjector
  CaseExpression
}
