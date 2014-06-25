hasOwn = {}.hasOwnProperty

isArray = (obj) -> Object::toString.call(obj) is '[object Array]'

isFunc = (obj) -> typeof obj is 'function'

isPrimitive = (obj) -> switch typeof obj
  when 'object', 'function'
    obj is null
  else
    true

isPlainObject = (o) ->
  if !o or (typeof o isnt 'object') or  o.nodeType or o.window is o
    return false
  try
    if (
      o.constructor and
      !(hasOwn.call(o, 'constructor')) and
      !hasOwn.call(o.constructor.prototype, 'isPrototypeOf'))
      return false
  catch e
    return false

  for key of o then
  return key is undefined || hasOwn.call(o, key)

module.exports = {
  isPrimitive
  isArray
  isFunc
  isPlainObject
  hasOwn
}
