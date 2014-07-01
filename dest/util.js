var COMMENT, FN_ARG, FN_ARGS, FN_ARG_SPLIT, annotate, hasOwn, isArray, isFunc, isPlainObject, isPrimitive, isRegExp, objToArray;

hasOwn = function(obj, key) {
  return {}.hasOwnProperty.call(obj, key);
};

isArray = function(obj) {
  return Object.prototype.toString.call(obj) === '[object Array]';
};

isFunc = function(obj) {
  return typeof obj === 'function';
};

isPrimitive = function(obj) {
  switch (typeof obj) {
    case 'object':
    case 'function':
      return obj === null;
    default:
      return true;
  }
};

isRegExp = function(o) {
  return o instanceof RegExp;
};

isPlainObject = function(o) {
  var e, key;
  if (!o || (typeof o !== 'object') || o.nodeType || o.window === o) {
    return false;
  }
  try {
    if (o.constructor && !(hasOwn(o, 'constructor')) && !hasOwn(o.constructor.prototype, 'isPrototypeOf')) {
      return false;
    }
  } catch (_error) {
    e = _error;
    return false;
  }
  for (key in o) {  }
  return key === void 0 || hasOwn(o, key);
};

objToArray = function(obj) {
  var e, k, ret, v, _i, _len, _results;
  if (isArray(obj)) {
    return obj;
  } else {
    ret = (function() {
      var _results;
      _results = [];
      for (k in obj) {
        v = obj[k];
        _results.push([k, v]);
      }
      return _results;
    })();
    ret = ret.sort(function(a, b) {
      switch (false) {
        case !(a[0] > b[0]):
          return 1;
        case !(a[0] < b[0]):
          return -1;
        default:
          return 0;
      }
    });
    _results = [];
    for (_i = 0, _len = ret.length; _i < _len; _i++) {
      e = ret[_i];
      _results.push(e[1]);
    }
    return _results;
  }
};

FN_ARGS = /^function\s*[^\(]*\(\s*([^\)]*)\)/m;

COMMENT = /\/\*[\s\S]*?\*\/|\/\/.*$/mg;

FN_ARG_SPLIT = /,/;

FN_ARG = /^\s*(\S+)\s*$/mg;

annotate = function(func) {
  var fnText, param, params, _i, _len, _ref, _results;
  if (!isFunc(func)) {
    return [];
  }
  fnText = func.toString().replace(COMMENT, '');
  params = fnText.match(FN_ARGS)[1];
  _ref = params.split(FN_ARG_SPLIT);
  _results = [];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    param = _ref[_i];
    _results.push(param.trim());
  }
  return _results;
};

module.exports = {
  annotate: annotate,
  hasOwn: hasOwn,
  isArray: isArray,
  isFunc: isFunc,
  isPlainObject: isPlainObject,
  isPrimitive: isPrimitive,
  isRegExp: isRegExp,
  objToArray: objToArray
};
