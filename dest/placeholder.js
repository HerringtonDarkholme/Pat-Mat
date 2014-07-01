var $, $$, Guardian, If, NamedParameter, Parameter, ParameterSeq, Quote, Wildcard, guard, paramSeq, parameter, q, quote, wildcard, wildcardSeq, _, __,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __slice = [].slice;

Parameter = (function() {
  function Parameter(pattern) {
    this.pattern = pattern;
    this.index = Parameter._index++;
  }

  Parameter.prototype.getKey = function() {
    return null;
  };

  Parameter.reset = function() {
    return Parameter._index = 0;
  };

  Parameter._index = 0;

  return Parameter;

})();

NamedParameter = (function(_super) {
  __extends(NamedParameter, _super);

  function NamedParameter(name, pattern) {
    this.name = name;
    if (this.name === wildcard || (this.name == null)) {
      this.name = null;
    } else if (!(typeof this.name === 'string')) {
      throw new TypeError('Named Parameter need string');
    }
    NamedParameter.__super__.constructor.call(this, pattern);
  }

  NamedParameter.prototype.getKey = function() {
    return this.name;
  };

  return NamedParameter;

})(Parameter);

ParameterSeq = (function(_super) {
  __extends(ParameterSeq, _super);

  function ParameterSeq() {
    return ParameterSeq.__super__.constructor.apply(this, arguments);
  }

  return ParameterSeq;

})(NamedParameter);

Quote = (function() {
  function Quote(pattern) {
    this.pattern = pattern;
  }

  return Quote;

})();

Wildcard = (function() {
  function Wildcard(pattern) {
    this.pattern = pattern;
  }

  return Wildcard;

})();

_ = wildcard = function(pattern) {
  return new Wildcard(pattern);
};

$$ = paramSeq = function(name) {
  return new ParameterSeq(name, _);
};

$$.getKey = function() {
  return null;
};

__ = wildcardSeq = new Wildcard(_);

q = quote = function(obj) {
  return new Quote(obj);
};

$ = parameter = function() {
  var args, type;
  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  switch (args.length) {
    case 0:
      return new Parameter(_);
    case 1:
      type = args[0];
      if (typeof type === 'string') {
        return new NamedParameter(type, _);
      } else {
        return new Parameter(type);
      }
      break;
    case 2:
      return (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return Object(result) === result ? result : child;
      })(NamedParameter, args, function(){});
    default:
      throw new RangeError('wrong number of arguments');
  }
};

parameter.pattern = wildcard;

Guardian = (function() {
  function Guardian(guard) {
    this.guard = guard;
  }

  return Guardian;

})();

guard = If = function(func) {
  return new Guardian(func);
};

module.exports = {
  Guardian: Guardian,
  NamedParameter: NamedParameter,
  Parameter: Parameter,
  ParameterSeq: ParameterSeq,
  Quote: Quote,
  Wildcard: Wildcard,
  guard: guard,
  paramSeq: paramSeq,
  parameter: parameter,
  quote: quote,
  wildcard: wildcard,
  wildcardSeq: wildcardSeq
};
