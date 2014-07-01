var As, IncrementalInjector, IndexedInjector, Is, Match, NominalInjector, On, PatternMatcher, decorateObjectPrototype, exports, extract, isFunc, makeAPI, paramSeq, parameter, validatePatterns, wildcard, wildcardSeq, _ref, _ref1,
  __slice = [].slice;

isFunc = require('./util').isFunc;

_ref = require('./injector'), IncrementalInjector = _ref.IncrementalInjector, IndexedInjector = _ref.IndexedInjector, NominalInjector = _ref.NominalInjector, PatternMatcher = _ref.PatternMatcher;

_ref1 = require('./placeholder'), parameter = _ref1.parameter, paramSeq = _ref1.paramSeq, wildcard = _ref1.wildcard, wildcardSeq = _ref1.wildcardSeq;

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
    return new PatternMatcher(patterns, matchedAction, injectCtor);
  };
};

Is = makeAPI(IncrementalInjector);

As = makeAPI(IndexedInjector);

On = makeAPI(NominalInjector);

decorateObjectPrototype = function(name) {
  if (name == null) {
    name = 'Match';
  }
  return Object.prototype[name] = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return Match.apply(null, args)(this);
  };
};

Match = function() {
  var args;
  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  return function(ele) {
    var injector, _i, _len;
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      injector = args[_i];
      if (!(injector instanceof PatternMatcher)) {
        throw new TypeError('need Is/As/On clause');
      }
      if (injector.hasMatch(ele)) {
        return injector.inject(ele);
      }
    }
    return null;
  };
};

exports = {
  Match: Match,
  Is: Is,
  As: As,
  On: On,
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
