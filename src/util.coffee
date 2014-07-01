hasOwn = (obj, key) -> {}.hasOwnProperty.call(obj, key)

isArray = (obj) -> Object::toString.call(obj) is '[object Array]'

isFunc = (obj) -> typeof obj is 'function'

isPrimitive = (obj) -> switch typeof obj
  when 'object', 'function'
    obj is null
  else
    true

isRegExp = (o) -> o instanceof RegExp

isPlainObject = (o) ->
  if !o or (typeof o isnt 'object') or  o.nodeType or o.window is o
    return false
  try
    if (
      o.constructor and
      !(hasOwn(o, 'constructor')) and
      !hasOwn(o.constructor.prototype, 'isPrototypeOf'))
      return false
  catch e
    return false

  for key of o then
  return key is undefined || hasOwn(o, key)

objToArray = (obj) ->
  if isArray(obj)
    obj
  else
    ret = ( [k,v] for k, v of obj )
    ret = ret.sort((a, b) -> switch
      when a[0] > b[0] then 1
      when a[0] < b[0] then -1
      else 0
    )
    e[1] for e in ret


# annotation util
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
    # return empty array if func is'nt a constructor
    return []
  fnText = func.toString().replace(COMMENT, '')
  params = fnText.match(FN_ARGS)[1]
  (param.trim() for param in params.split(FN_ARG_SPLIT))

module.exports = {
  annotate
  hasOwn
  isArray
  isFunc
  isPlainObject
  isPrimitive
  isRegExp
  objToArray
}
