var IndexParameter, NamedParameter, Parameter, Quote, noop, parameter, quote, wildcard,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

noop = require('./util').noop;

wildcard = function() {};

Parameter = (function() {
  function Parameter() {}

  return Parameter;

})();

IndexParameter = (function(_super) {
  __extends(IndexParameter, _super);

  function IndexParameter(index, pattern, guard) {
    this.index = index;
    this.pattern = pattern;
    this.guard = guard;
  }

  return IndexParameter;

})(Parameter);

NamedParameter = (function(_super) {
  __extends(NamedParameter, _super);

  function NamedParameter(name, pattern, guard) {
    this.name = name;
    this.pattern = pattern;
    this.guard = guard;
  }

  return NamedParameter;

})(Parameter);

parameter = function(index, pattern, guard) {
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
