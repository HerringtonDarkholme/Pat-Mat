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
    for ann, index in @annotation
      matching = deepMatch(argList[index], other[ann], assign)
      if not matching
        return false
    return true


deepMatch = (expr, obj, assign) -> switch
  when expr is wildcard
    true
  when expr instanceof Quote
    obj is expr.obj
  when isPrimitive(expr)
    obj is expr or (isNaN(obj) and isNaN(expr))
  when expr instanceof Parameter
    matchParam(expr, obj, assign)
  when isPlainObject(expr)
    matchObject(expr, obj, assign)
  when isArray(expr)
    matchArray(expr, obj, assign)
  when isFunc(expr)
    matchFunc(expr, obj, assign)
  when expr instanceof Matcher
    expr.unapply(obj, assign)
  else
    false

matchParam = (expr, obj, assign) ->
  assign(expr, obj)
  deepMatch(expr.pattern, obj, assign)

matchFunc = (expr, obj, assign) ->
  isMatch = obj instanceof expr
  assign(expr, obj) if isMatch
  isMatch

matchArray = (expr, obj, assign) ->
  #  [1, Number, $, $$, 3, String, $]
  #  ---- pre -----    ---- post ----
  return false unless isArray(obj)

  for v, pre in expr
    break if v is paramSeq
    return false if not deepMatch(v, obj[pre], assign)

  len = obj.length
  for v, post in expr by -1
    break if v is paramSeq
    return false if not deepMatch(v, obj[--len], assign)

  if (expr[pre] is paramSeq)
    assign(paramSeq, obj.slice(pre, len)) if pre is post
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
