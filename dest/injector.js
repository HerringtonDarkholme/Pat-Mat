var CaseExpression, Guardian, IncrementalInjector, IndexedInjector, Injector, NominalInjector, Parameter, assignmentFactory, deepMatch, incrementalCounter, indexedCounter, isArray, isFunc, isRegExp, nominalCounter, objToArray, _ref, _ref1, _ref2,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

_ref = require('./util'), isArray = _ref.isArray, isRegExp = _ref.isRegExp, isFunc = _ref.isFunc, objToArray = _ref.objToArray;

_ref1 = require('./counter'), assignmentFactory = _ref1.assignmentFactory, incrementalCounter = _ref1.incrementalCounter, indexedCounter = _ref1.indexedCounter, nominalCounter = _ref1.nominalCounter;

_ref2 = require('./placeholder'), Parameter = _ref2.Parameter, Guardian = _ref2.Guardian;

deepMatch = require('./matcher').deepMatch;

Injector = (function() {
  function Injector(pattern) {
    this.pattern = pattern;
    this.assign = __bind(this.assign, this);
    this.counterFunc = null;
    this.cache = null;
    this.unnamed = [];
    this.assigner = null;
    this.defined = false;
  }

  Injector.prototype.isDefinedAt = function(ele) {
    this.clear();
    this.assigner = assignmentFactory(this.cache, this.unnamed, this.counterFunc);
    this.defined = deepMatch(this.pattern, ele, this.assign);
    if (!this.defined) {
      this.clear();
    }
    return this.defined;
  };

  Injector.prototype.inject = function(ele, action) {
    if (!this.defined) {
      throw new Error('cannot call matched function when unmatched');
    }
    return action.apply({
      m: ele,
      unnamed: this.unnamed
    }, objToArray(this.cache));
  };

  Injector.prototype.assign = function(expr, obj) {
    if (!(isFunc(expr) || isRegExp(expr))) {
      return this.assigner(expr, obj);
    }
  };

  Injector.prototype.clear = function() {
    this.cache = {};
    return this.unnamed = [];
  };

  return Injector;

})();

IncrementalInjector = (function(_super) {
  __extends(IncrementalInjector, _super);

  function IncrementalInjector(pattern) {
    this.assign = __bind(this.assign, this);
    IncrementalInjector.__super__.constructor.apply(this, arguments);
    this.counterFunc = incrementalCounter;
  }

  IncrementalInjector.prototype.assign = function(expr, obj) {
    var group, _i, _len, _results;
    if (isRegExp(expr)) {
      _results = [];
      for (_i = 0, _len = obj.length; _i < _len; _i++) {
        group = obj[_i];
        _results.push(this.assigner(RegExp, group));
      }
      return _results;
    } else {
      return this.assigner(expr, obj);
    }
  };

  return IncrementalInjector;

})(Injector);

IndexedInjector = (function(_super) {
  __extends(IndexedInjector, _super);

  function IndexedInjector(pattern) {
    IndexedInjector.__super__.constructor.apply(this, arguments);
    this.counterFunc = indexedCounter;
  }

  return IndexedInjector;

})(Injector);

NominalInjector = (function(_super) {
  __extends(NominalInjector, _super);

  function NominalInjector(pattern) {
    NominalInjector.__super__.constructor.apply(this, arguments);
    this.counterFunc = nominalCounter;
  }

  NominalInjector.prototype.inject = function(ele, action) {
    var c;
    c = this.cache;
    this.cache = isArray(c) ? c : [c];
    return NominalInjector.__super__.inject.apply(this, arguments);
  };

  return NominalInjector;

})(Injector);

CaseExpression = (function() {
  function CaseExpression(patterns, action, injectCtor) {
    var guardian, p, _i, _len;
    this.injector = null;
    this.guard = null;
    this.action = action;
    this.injectors = [];
    if (patterns.length === 2 && (guardian = patterns[1]) instanceof Guardian) {
      this.injectors.push(new injectCtor(patterns[0]));
      this.guard = guardian.guard;
    } else {
      for (_i = 0, _len = patterns.length; _i < _len; _i++) {
        p = patterns[_i];
        this.injectors.push(new injectCtor(p));
      }
    }
  }

  CaseExpression.prototype.hasMatch = function(ele) {
    var injector, ret, _i, _len, _ref3;
    ret = false;
    _ref3 = this.injectors;
    for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
      injector = _ref3[_i];
      if (injector.isDefinedAt(ele)) {
        ret = true;
        this.injector = injector;
        break;
      }
    }
    if (ret && (this.guard != null)) {
      ret = injector.inject(ele, this.guard);
      if (!ret) {
        injector.clear();
      }
    }
    if (!ret) {
      this.injector = null;
    }
    Parameter.reset();
    return ret;
  };

  CaseExpression.prototype.inject = function(ele) {
    return this.injector.inject(ele, this.action);
  };

  return CaseExpression;

})();

module.exports = {
  IncrementalInjector: IncrementalInjector,
  IndexedInjector: IndexedInjector,
  NominalInjector: NominalInjector,
  CaseExpression: CaseExpression
};
