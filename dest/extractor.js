var Extractor, Matcher, P, Point, extract, isArray, isFunc, matcher, _ref,
  __slice = [].slice,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

_ref = require('./util'), isArray = _ref.isArray, isFunc = _ref.isFunc;

Matcher = require('./matcher').Matcher;

Extractor = (function() {
  var COMMENT, FN_ARG, FN_ARGS, FN_ARG_SPLIT, annotate;

  FN_ARGS = /^function\s*[^\(]*\(\s*([^\)]*)\)/m;

  COMMENT = /\/\*[\s\S]*?\*\/|\/\/.*$/mg;

  FN_ARG_SPLIT = /,/;

  FN_ARG = /^\s*(\S+)\s*$/mg;

  annotate = function(func) {
    var fnText, param, params, _i, _len, _ref1, _results;
    if (!isFunc(func)) {
      throw new Error('need function');
    }
    fnText = func.toString().replace(COMMENT, '');
    params = fnText.match(FN_ARGS)[1];
    _ref1 = params.split(FN_ARG_SPLIT);
    _results = [];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      param = _ref1[_i];
      _results.push(param.trim());
    }
    return _results;
  };

  function Extractor(ctor) {
    var annotation;
    this.ctor = ctor;
    this.annotation = null;
    this.unapply = null;
    annotation = this.ctor.unapply;
    if (!(annotation != null)) {
      this.annotation = annotate(this.ctor);
    } else if (isArray(annotation)) {
      this.annotation = annotation;
    } else if (isFunc(annotation)) {
      this.unapply = annotation;
    }
  }

  Extractor.prototype.link = function(argList) {
    return new Matcher(this.annotation, this.unapply, argList);
  };

  return Extractor;

})();

extract = function(ctor) {
  var F, extractor;
  extractor = new Extractor(ctor);
  F = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (!(this instanceof ctor)) {
      return extractor.link(args);
    } else {
      return ctor.apply(this, args);
    }
  };
  __extends(F, ctor);
  return F;
};

Point = (function() {
  function Point(x, y) {
    this.x = x;
    this.y = y;
  }

  Point.unapply = ['sss', 'ssss'];

  return Point;

})();

P = extract(Point);

console.log((new Extractor(Point)).annotation);

matcher = P(2, 3);

module.exports = {
  Extractor: Extractor,
  extract: extract
};
