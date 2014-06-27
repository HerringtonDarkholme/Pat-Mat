{
  isFunc
  isArray
  isPlainObject
  isPrimitive
  hasOwn
} = require('./util')

{
  parameter
  paramSeq
  Parameter
  wildcard
  Wildcard
  Quote
} = require('./placeholder')

class Matcher
  constructor: (@annotation, @customUnapply, @argList, @ctor) ->

  # unapply:: ctorInstance -> AssignFunc -> Boolean
  # return whether match
  unapply: (other, assign) ->
    annotation = @annotation
    if @customUnapply?
       @customUnapply(other, @argList, assign)
    else
       @defaultUnapply(other, @argList, assign)

  defaultUnapply: (other, assign) ->
    if not (other instanceof @ctor)
      return false
    for ann, i in @annotation
      matching = deepMatch(argList[i], other[ann], assign)
      if not matching
        return false
    true


deepMatch = (expr, obj, assign) -> switch
  when expr is wildcard
    true
  when expr instanceof Wildcard
    # don't match pattern inside Wildcard
    # only for incremental assigner
    deepMatch(expr.pattern, obj, ->)
  when expr instanceof Quote
    obj is expr.obj
  when expr instanceof Matcher
    expr.unapply(obj, assign)
  when expr instanceof RegExp
    matchReg(expr, obj, assign)
  when expr instanceof Parameter, expr is parameter
    matchParam(expr, obj, assign)
  when isPrimitive(expr)
    matchPrimitive(expr, obj)
  when isPlainObject(expr)
    matchObject(expr, obj, assign)
  when isArray(expr)
    matchArray(expr, obj, assign)
  when isFunc(expr)
    # must be the last
    matchFunc(expr, obj, assign)
  else
    false

matchPrimitive = (expr, obj) ->
  # handle NaN typeof NaN === 'number'
  if isNaN(obj) and isNaN(expr)
    true
  else if obj is expr
    true
  else
    false

matchReg = (expr, obj, assign) ->
  if typeof obj isnt 'string'
    return false
  ret = expr.exec(obj)
  if ret
    assign(expr, ret)
    true
  else
    false

matchParam = (expr, obj, assign) ->
  assign(expr, obj)
  deepMatch(expr.pattern, obj, assign)

matchFunc = (expr, obj, assign) ->
  isMatch = switch expr
    # match primitive value
    when Number
      typeof obj is 'number'
    when String
      typeof obj is 'string'
    when Boolean
      typeof obj is 'boolean'
    else
      obj instanceof expr
  if isMatch
    assign(expr, obj)
  isMatch

matchArray = (expr, obj, assign) ->
  #  [1, Number, $, $$, 3, String, $]
  #  ---- pre -----    ---- post ----
  return false unless isArray(obj)

  for v, pre in expr
    break if v is paramSeq
    if not deepMatch(v, obj[pre], assign)
      return false

  len = obj.length
  for v, post in expr by -1
    break if v is paramSeq
    if not deepMatch(v, obj[--len], assign)
      return false

  if (expr[pre] is paramSeq)
    if pre is post
      assign(paramSeq, obj.slice(pre, len))
  true

matchObject = (expr, obj, assign) ->
  # skip obj type test for structrual typing
  for key, value of expr when hasOwn.call(expr, key)
    if not deepMatch(value, obj[key], assign)
      return false
  true


module.exports =  {
  Matcher
  deepMatch
}
