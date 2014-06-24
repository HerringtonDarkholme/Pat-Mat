{noop} = require('./util')

# Three types of placeholder:
#   wildcard: _
#   parameter: $
#   quote: q

wildcard = () ->

class Parameter

class IndexParameter extends Parameter
  constructor: (@index, @pattern, @guard) ->

class NamedParameter extends Parameter
  constructor: (@name, @pattern, @guard) ->

parameter = (index, pattern, guard) ->
  new Parameter(index, pattern, guard)

class Quote
  constructor: (@obj) ->

quote = (obj) -> new Quote(obj)
