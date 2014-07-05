isFunc = require('./util').isFunc
{
  IncrementalInjector
  IndexedInjector
  NominalInjector
  CaseExpression
} = require('./injector')

{
  guard
  parameter
  paramSeq
  wildcard
  wildcardSeq
} = require('./placeholder')

extract = require('./extractor').extract

validatePatterns = (args) ->
  # common pattern
  matchedAction = args.pop()
  unless isFunc(matchedAction)
    throw new Error('Handler must be an function')
  [args, matchedAction]

makeAPI = (injectCtor) -> (args...) ->
  [patterns, matchedAction] = validatePatterns(args)
  new CaseExpression(patterns, matchedAction, injectCtor)

Is = makeAPI(IncrementalInjector)
As = makeAPI(IndexedInjector)
On = makeAPI(NominalInjector)

class NoMatchError extends Error
  constructor: -> @message = 'no matching case'

Match = (args...) -> (ele) ->
  for injector in args
    unless injector instanceof CaseExpression
      throw new TypeError('need Is/As/On clause')
    if injector.hasMatch(ele)
      return injector.inject(ele)
  throw new NoMatchError()

exports = {
  Match
  Is
  As
  On
  NoMatchError
  guard
  parameter
  paramSeq
  wildcard
  wildcardSeq
  extract
}

# export
if typeof define is 'function'
  define -> exports
else if typeof module isnt 'undefined' and module.exports
  module.exports = exports
else
  global.patternMatch = exports
