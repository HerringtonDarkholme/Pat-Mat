{noop} = require('./util')

# Three types of placeholder:
#   wildcard: _
#   parameter: $
#   quote: q

_ = wildcard = () ->
$$ = paramSeq = () ->

class Parameter
  getKey: () -> null
  @getKey = @::getKey


class IndexParameter extends Parameter
  constructor: (@index, @pattern, @guard) ->
    if typeof @index 'number'
      throw new TypeError('Indexed Parameter need number')
  getKey: () -> @index


class NamedParameter extends Parameter
  constructor: (@name, @pattern, @guard) ->
  getKey: () -> @name

$ = parameter = (index, pattern, guard) ->
  new Parameter(index, pattern, guard)

class Quote
  constructor: (@obj) ->

quote = (obj) -> new Quote(obj)

module.exports = {
  parameter
  Parameter
  IndexParameter
  NamedParameter
}
