isFunc = require('./util').isFunc
{
  PatternMatcher
  IncrementalInjector
  IndexedInjector
  NominalInjector
} = require('./injector')

validatePatterns = (args) ->
  # common pattern
  matchedAction = args.pop()
  unless isFunc(matchedAction)
    throw new Error('Handler must be an function')
  [args, matchedAction]

makeAPI = (injectCtor) -> (args...) ->
  [patterns, matchedAction] = validatePatterns(args)
  new PatternMatcher(patterns, matchedAction, injectCtor)

Is = makeAPI(IncrementalInjector)
As = makeAPI(IndexedInjector)
On = makeAPI(NominalInjector)

decorateObjectPrototype = (name='Match') ->
  Object::[name] = (args...) ->
    Match(args...)(this)

Match = (args...) -> (ele) ->
  for injector in args
    unless injector instanceof PatternMatcher
      throw new TypeError('need Is/As/On clause')
    if injector.hasMatch(ele)
      return injector.inject(ele)
  null
