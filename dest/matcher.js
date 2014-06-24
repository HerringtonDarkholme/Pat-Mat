var Matcher, isArray, isFunc, isPlainObject, _ref;

_ref = require('./util'), isFunc = _ref.isFunc, isArray = _ref.isArray, isPlainObject = _ref.isPlainObject;

Matcher = (function() {
  function Matcher(annotation, unapply, argList) {
    this.annotation = annotation;
    this.unapply = unapply;
    this.argList = argList;
  }

  Matcher.prototype.match = function(other, assign) {
    var annotation, ret;
    annotation = this.annotation;
    if (this.unapply != null) {
      return this.unapply(other, this.argList, assign);
    }
    return ret = [];
  };

  return Matcher;

})();

module.exports = {
  Matcher: Matcher,
  deepMatch: deepMatch
};
