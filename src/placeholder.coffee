# Three types of placeholder:
#   wildcard: _
#   parameter: $
#   quote: q

class Parameter
  constructor: (@pattern) ->
    @index = Parameter._index++

  getKey: -> null
  @reset = => @._index = 0
  @_index = 0


# class IndexParameter extends Parameter
#   constructor: (@index, pattern, guard) ->
#     unless typeof @index is 'number'
#       throw new TypeError('Indexed Parameter need number')
#     super(pattern, guard)
#
#   getKey: () -> @index


class NamedParameter extends Parameter
  constructor: (@name, pattern) ->
    if @name is wildcard or not @name?
      @name = null
    else if not (typeof @name is 'string')
      throw new TypeError('Named Parameter need string')
    super(pattern)

  getKey: () -> @name

class ParameterSeq extends NamedParameter

class Quote
  constructor: (@pattern) ->

class Wildcard
  constructor: (@pattern) ->

_ = wildcard = (pattern) -> new Wildcard(pattern)

$$ = paramSeq = (name) -> new ParameterSeq(name, _)
$$.getKey = -> null
__ = wildcardSeq = new Wildcard(_)

q = quote = (obj) -> new Quote(obj)

$ = parameter = (args...) -> switch args.length
  when 0
    # alias to $(_)
    new Parameter(_)
  when 1
    # $({key1: String, key2: String})
    type = args[0]
    if typeof type is 'string'
      new NamedParameter(type, _)
    else
      new Parameter(type)
  when 2
    # NamedParameter $('name', Array)
    new NamedParameter(args...)
  else
    throw new RangeError('wrong number of arguments')

parameter.pattern = wildcard

class Guardian
  constructor: (@guard) ->

guard = If = (func) -> new Guardian(func)

module.exports = {
  Guardian
  NamedParameter
  Parameter
  ParameterSeq
  Quote
  Wildcard
  guard
  paramSeq
  parameter
  quote
  wildcard
  wildcardSeq
}
