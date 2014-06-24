var Matcher, deepMatch;

Matcher = (function() {
  function Matcher(annotation, unapply, argList) {
    this.annotation = annotation;
    this.unapply = unapply;
    this.argList = argList;
  }

  Matcher.prototype.match = function(other) {
    var annotation, index, matching, param, ret, _i, _len, _ref;
    annotation = this.annotation;
    if (this.unapply != null) {
      return this.unapply(other, this.argList);
    }
    ret = [];
    _ref = this.argList;
    for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
      param = _ref[index];
      matching = deepMatch(param, other[annotation[index]]);
      if (matching != null) {
        ret.concat(matching);
      } else {
        return null;
      }
    }
    return ret;
  };

  return Matcher;

})();

deepMatch = function(param, obj) {};

module.exports = {
  Matcher: Matcher,
  deepMatch: deepMatch
};
