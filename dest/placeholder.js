var $, $$, IndexParameter, NamedParameter, Parameter, Quote, noop, paramSeq, parameter, quote, wildcard, _,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

noop = require('./util').noop;

_ = wildcard = function() {};

$$ = paramSeq = function() {};

Parameter = (function() {
  function Parameter() {}

  Parameter.prototype.getKey = function() {
    return null;
  };

  Parameter.getKey = Parameter.prototype.getKey;

  return Parameter;

})();

IndexParameter = (function(_super) {
  __extends(IndexParameter, _super);

  function IndexParameter(index, pattern, guard) {
    this.index = index;
    this.pattern = pattern;
    this.guard = guard;
    if (typeof this.index('number')) {
      throw new TypeError('Indexed Parameter need number');
    }
  }

  IndexParameter.prototype.getKey = function() {
    return this.index;
  };

  return IndexParameter;

})(Parameter);

NamedParameter = (function(_super) {
  __extends(NamedParameter, _super);

  function NamedParameter(name, pattern, guard) {
    this.name = name;
    this.pattern = pattern;
    this.guard = guard;
  }

  NamedParameter.prototype.getKey = function() {
    return this.name;
  };

  return NamedParameter;

})(Parameter);

$ = parameter = function(index, pattern, guard) {
  return new Parameter(index, pattern, guard);
};

Quote = (function() {
  function Quote(obj) {
    this.obj = obj;
  }

  return Quote;

})();

quote = function(obj) {
  return new Quote(obj);
};

module.exports = {
  parameter: parameter,
  Parameter: Parameter,
  IndexParameter: IndexParameter,
  NamedParameter: NamedParameter
};
