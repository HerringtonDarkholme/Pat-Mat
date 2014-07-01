var Extractor, Matcher, annotate, extract, isArray, isFunc, isPlainObject, makeMatcherFrom, _ref,
  __slice = [].slice,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

_ref = require('./util'), isArray = _ref.isArray, isFunc = _ref.isFunc, isPlainObject = _ref.isPlainObject, annotate = _ref.annotate;

Matcher = require('./matcher').Matcher;

Extractor = (function() {
  function Extractor(ctor) {
    var unapply;
    this.ctor = ctor;
    this.annotation = null;
    this.transform = null;
    unapply = this.ctor.unapply;
    if (isArray(unapply)) {
      this.annotation = unapply;
    } else if (isFunc(unapply)) {
      this.transform = unapply;
    } else if (isPlainObject(unapply)) {
      this.annotation = unapply.annotation;
      this.transform = unapply.transform;
    }
    if (this.annotation == null) {
      this.annotation = annotate(this.ctor);
    }
  }

  Extractor.prototype.link = function(argList) {
    return new Matcher(this.annotation, this.transform, argList, this.ctor);
  };

  return Extractor;

})();

makeMatcherFrom = function(obj) {
  var annotation, constructor, transform;
  annotation = obj.annotation;
  transform = obj.transform;
  constructor = obj.constructor;
  return function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return new Matcher(annotation, transform, args, constructor);
  };
};

extract = function(ctor) {
  var F, extractor;
  if (isPlainObject(ctor)) {
    return makeMatcherFrom(ctor);
  }
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

module.exports = {
  Extractor: Extractor,
  extract: extract
};
