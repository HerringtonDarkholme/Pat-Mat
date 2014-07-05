var As, CaseExpression, IncrementalInjector, IndexedInjector, Is, Match, NoMatchError, NominalInjector, On, exports, extract, guard, isFunc, makeAPI, paramSeq, parameter, validatePatterns, wildcard, wildcardSeq, _ref, _ref1,
  __slice = [].slice,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

isFunc = require('./util').isFunc;

_ref = require('./injector'), IncrementalInjector = _ref.IncrementalInjector, IndexedInjector = _ref.IndexedInjector, NominalInjector = _ref.NominalInjector, CaseExpression = _ref.CaseExpression;

_ref1 = require('./placeholder'), guard = _ref1.guard, parameter = _ref1.parameter, paramSeq = _ref1.paramSeq, wildcard = _ref1.wildcard, wildcardSeq = _ref1.wildcardSeq;

extract = require('./extractor').extract;

validatePatterns = function(args) {
  var matchedAction;
  matchedAction = args.pop();
  if (!isFunc(matchedAction)) {
    throw new Error('Handler must be an function');
  }
  return [args, matchedAction];
};

makeAPI = function(injectCtor) {
  return function() {
    var args, matchedAction, patterns, _ref2;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    _ref2 = validatePatterns(args), patterns = _ref2[0], matchedAction = _ref2[1];
    return new CaseExpression(patterns, matchedAction, injectCtor);
  };
};

Is = makeAPI(IncrementalInjector);

As = makeAPI(IndexedInjector);

On = makeAPI(NominalInjector);

NoMatchError = (function(_super) {
  __extends(NoMatchError, _super);

  function NoMatchError() {
    this.message = 'no matching case';
  }

  return NoMatchError;

})(Error);

Match = function() {
  var args;
  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  return function(ele) {
    var injector, _i, _len;
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      injector = args[_i];
      if (!(injector instanceof CaseExpression)) {
        throw new TypeError('need Is/As/On clause');
      }
      if (injector.hasMatch(ele)) {
        return injector.inject(ele);
      }
    }
    throw new NoMatchError();
  };
};

exports = {
  Match: Match,
  Is: Is,
  As: As,
  On: On,
  NoMatchError: NoMatchError,
  guard: guard,
  parameter: parameter,
  paramSeq: paramSeq,
  wildcard: wildcard,
  wildcardSeq: wildcardSeq,
  extract: extract
};

if (typeof define === 'function') {
  define(function() {
    return exports;
  });
} else if (typeof module !== 'undefined' && module.exports) {
  module.exports = exports;
} else {
  global.patternMatch = exports;
}
