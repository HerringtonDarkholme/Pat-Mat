var Match, decorateObjectPrototype, decorateRegExpPrototype, extract, matchReg, _ref,
  __slice = [].slice;

_ref = require('./api'), Match = _ref.Match, extract = _ref.extract;

matchReg = function(reg) {
  var anns, verified;
  anns = [];
  verified = false;
  return extract({
    annotation: anns,
    transform: function(text) {
      var i, ret;
      ret = reg.exec(text);
      if (ret == null) {
        return null;
      }
      ret.shift();
      if (!verified) {
        i = 0;
        while (i < ret.length) {
          anns.push(i++);
        }
        verified = true;
      }
      return ret;
    }
  });
};

decorateRegExpPrototype = function() {
  return RegExp.prototype.r = function() {
    return matchReg(this);
  };
};

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

module.exports = {
  matchReg: matchReg,
  decorateRegExpPrototype: decorateRegExpPrototype,
  decorateObjectPrototype: decorateObjectPrototype
};
