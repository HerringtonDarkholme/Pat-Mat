{
  isFunc
  isArray
  isPlainObject
  isPrimitive
  hasOwn
  annotate
} = require('./util')

{
  Parameter
  ParameterSeq
  Quote
  Wildcard
  paramSeq
  parameter
  wildcard
  wildcardSeq
} = require('./placeholder')

class Matcher
  constructor: (annotation, transform, argList, ctor) ->
    @annotation = annotation or
      (ctor and annotate(ctor)) or []
    @ctor = ctor or Object
    @transform = transform
    @argList = argList

  # unapply:: ctorInstance -> AssignFunc -> Boolean
  # return whether match
  unapply: (other, assign) ->
    # apply transformation if applied
    # or it must be an instanceof @ctor
    if @transform?
      other = @transform(other)
      return false unless other?
      # don't rely on key enumeration
      # @annotation = (k for k of other) unless @annotation
    else if not (other instanceof @ctor)
      return false
    argList = @argList
    for ann, i in @annotation
      matching = deepMatch(argList[i], other[ann], assign)
      if not matching
        return false
    true

isSeq = (v) ->
  v is paramSeq or v is wildcardSeq or v instanceof ParameterSeq

deepMatch = (expr, obj, assign) -> switch
  when expr is wildcard
    true
  when expr instanceof Wildcard
    # don't match pattern inside Wildcard
    # only for incremental assigner
    deepMatch(expr.pattern, obj, ->)
  when expr instanceof Quote
    obj is expr.pattern
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
  if typeof expr is 'number' and isNaN(obj) and isNaN(expr)
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
  #  ArrayLike is okay
  # return false unless isArray(obj)

  for v, pre in expr
    break if isSeq(v)
    if not deepMatch(v, obj[pre], assign)
      return false

  len = obj.length
  for v, post in expr by -1
    break if isSeq(v) or pre >= post or len < pre
    if not deepMatch(v, obj[--len], assign)
      return false

  if isSeq(v)
    return false if pre > len
    if pre is post
      assign(v, Array::slice.call(obj, pre, len)) if v isnt wildcardSeq
    else
      throw new Error('multiple parameter sequence is not allowed')
    true
  else
    # if no $$ occur, length should be the same
    len is pre

matchObject = (expr, obj, assign) ->
  # skip obj type test for structrual typing
  # A.K.A duck typing :)
  return false if not obj?
  for key, value of expr when hasOwn(expr, key)
    objValue = obj[key]
    if (not objValue?) and (not hasOwn(obj, key))
      return false
    if not deepMatch(value, obj[key], assign)
      return false
  true


module.exports =  {
  Matcher
  deepMatch
}
