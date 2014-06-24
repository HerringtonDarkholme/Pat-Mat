var hasOwn, isArray, isFunc, isPlainObject;

hasOwn = {}.hasOwnProperty;

isArray = function(obj) {
  return Object.prototype.toString.call(obj) === '[object Array]';
};

isFunc = function(obj) {
  return typeof obj === 'function';
};

isPlainObject = function(o) {
  var e, key;
  if (!o || (typeof o !== 'object') || o.nodeType || o.window === o) {
    return false;
  }
  try {
    if (o.constructor && !(hasOwn.call(o, 'constructor')) && !hasOwn.call(o.constructor.prototype, 'isPrototypeOf')) {
      return false;
    }
  } catch (_error) {
    e = _error;
    return false;
  }
  for (key in o) {  }
  return key === void 0 || hasOwn.call(o, key);
};

module.exports = {
  isArray: isArray,
  isFunc: isFunc,
  isPlainObject: isPlainObject
};
