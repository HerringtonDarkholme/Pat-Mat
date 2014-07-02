var Matcher, Parameter, ParameterSeq, Quote, Wildcard, annotate, deepMatch, hasOwn, isArray, isFunc, isPlainObject, isPrimitive, isSeq, matchArray, matchFunc, matchObject, matchParam, matchPrimitive, matchReg, paramSeq, parameter, wildcard, wildcardSeq, _ref, _ref1;

_ref = require('./util'), isFunc = _ref.isFunc, isArray = _ref.isArray, isPlainObject = _ref.isPlainObject, isPrimitive = _ref.isPrimitive, hasOwn = _ref.hasOwn, annotate = _ref.annotate;

_ref1 = require('./placeholder'), Parameter = _ref1.Parameter, ParameterSeq = _ref1.ParameterSeq, Quote = _ref1.Quote, Wildcard = _ref1.Wildcard, paramSeq = _ref1.paramSeq, parameter = _ref1.parameter, wildcard = _ref1.wildcard, wildcardSeq = _ref1.wildcardSeq;

Matcher = (function() {
  function Matcher(annotation, transform, argList, ctor) {
    this.annotation = annotation || (ctor && annotate(ctor)) || [];
    this.ctor = ctor || Object;
    this.transform = transform;
    this.argList = argList;
  }

  Matcher.prototype.unapply = function(other, assign) {
    var ann, argList, i, matching, _i, _len, _ref2;
    if (this.transform != null) {
      other = this.transform(other);
      if (other == null) {
        return false;
      }
    } else if (!(other instanceof this.ctor)) {
      return false;
    }
    argList = this.argList;
    _ref2 = this.annotation;
    for (i = _i = 0, _len = _ref2.length; _i < _len; i = ++_i) {
      ann = _ref2[i];
      matching = deepMatch(argList[i], other[ann], assign);
      if (!matching) {
        return false;
      }
    }
    return true;
  };

  return Matcher;

})();

isSeq = function(v) {
  return v === paramSeq || v === wildcardSeq || v instanceof ParameterSeq;
};

deepMatch = function(expr, obj, assign) {
  switch (false) {
    case expr !== wildcard:
      return true;
    case !(expr instanceof Wildcard):
      return deepMatch(expr.pattern, obj, function() {});
    case !(expr instanceof Quote):
      return obj === expr.pattern;
    case !(expr instanceof Matcher):
      return expr.unapply(obj, assign);
    case !(expr instanceof RegExp):
      return matchReg(expr, obj, assign);
    case !(expr instanceof Parameter):
    case expr !== parameter:
      return matchParam(expr, obj, assign);
    case !isPrimitive(expr):
      return matchPrimitive(expr, obj);
    case !isPlainObject(expr):
      return matchObject(expr, obj, assign);
    case !isArray(expr):
      return matchArray(expr, obj, assign);
    case !isFunc(expr):
      return matchFunc(expr, obj, assign);
    default:
      return false;
  }
};

matchPrimitive = function(expr, obj) {
  if (typeof expr === 'number' && isNaN(obj) && isNaN(expr)) {
    return true;
  } else if (obj === expr) {
    return true;
  } else {
    return false;
  }
};

matchReg = function(expr, obj, assign) {
  var ret;
  if (typeof obj !== 'string') {
    return false;
  }
  ret = expr.exec(obj);
  if (ret) {
    assign(expr, ret);
    return true;
  } else {
    return false;
  }
};

matchParam = function(expr, obj, assign) {
  assign(expr, obj);
  return deepMatch(expr.pattern, obj, assign);
};

matchFunc = function(expr, obj, assign) {
  var isMatch;
  isMatch = (function() {
    switch (expr) {
      case Number:
        return typeof obj === 'number';
      case String:
        return typeof obj === 'string';
      case Boolean:
        return typeof obj === 'boolean';
      default:
        return obj instanceof expr;
    }
  })();
  if (isMatch) {
    assign(expr, obj);
  }
  return isMatch;
};

matchArray = function(expr, obj, assign) {
  var len, post, pre, v, _i, _j, _len;
  for (pre = _i = 0, _len = expr.length; _i < _len; pre = ++_i) {
    v = expr[pre];
    if (isSeq(v)) {
      break;
    }
    if (!deepMatch(v, obj[pre], assign)) {
      return false;
    }
  }
  len = obj.length;
  for (post = _j = expr.length - 1; _j >= 0; post = _j += -1) {
    v = expr[post];
    if (isSeq(v) || pre >= post || len < pre) {
      break;
    }
    if (!deepMatch(v, obj[--len], assign)) {
      return false;
    }
  }
  if (isSeq(v)) {
    if (pre > len) {
      return false;
    }
    if (pre === post) {
      if (v !== wildcardSeq) {
        assign(v, Array.prototype.slice.call(obj, pre, len));
      }
    } else {
      throw new Error('multiple parameter sequence is not allowed');
    }
    return true;
  } else {
    return len === pre;
  }
};

matchObject = function(expr, obj, assign) {
  var key, objValue, value;
  if (obj == null) {
    return false;
  }
  for (key in expr) {
    value = expr[key];
    if (!(hasOwn(expr, key))) {
      continue;
    }
    objValue = obj[key];
    if ((objValue == null) && (!hasOwn(obj, key))) {
      return false;
    }
    if (!deepMatch(value, obj[key], assign)) {
      return false;
    }
  }
  return true;
};

module.exports = {
  Matcher: Matcher,
  deepMatch: deepMatch
};
