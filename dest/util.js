var isArray, isFunc;

isArray = function(obj) {
  return Object.prototype.toString.call(obj) === '[object Array]';
};

isFunc = function(obj) {
  return typeof obj === 'function';
};

module.exports = {
  isArray: isArray,
  isFunc: isFunc
};
