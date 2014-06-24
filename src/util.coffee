isArray = (obj) -> Object::toString.call(obj) is '[object Array]'

isFunc = (obj) -> typeof obj is 'function'

module.exports = {
  isArray
  isFunc
}
