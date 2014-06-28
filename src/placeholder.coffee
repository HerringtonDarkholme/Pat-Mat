# Three types of placeholder:
#   wildcard: _
#   parameter: $
#   quote: q

class Parameter
  constructor: (@pattern, @guard) ->
    @index = Parameter._index++
    if not @guard?
      @guard = -> true

  getKey: -> null
  askGuard: (that, args...) -> @guard.apply(that, args)
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
  constructor: (@name, pattern, guard) ->
    unless typeof @name is 'string'
      throw new TypeError('Named Parameter need string')
    super(pattern, guard)

  getKey: () -> @name


class Quote
  constructor: (@pattern) ->

class Wildcard
  constructor: (@pattern) ->

_ = wildcard = (pattern) -> new Wildcard(pattern)

$$ = paramSeq = new ->
__ = wildcardSeq = new ->

q = quote = (obj) -> new Quote(obj)

$ = parameter = (args...) -> switch args.length
  when 0
    # alias to $(_)
    new Parameter(_)
  when 1
    # $({key1: String, key2: String})
    new Parameter(args[0])
  when 2
    # named/guarded $(String, guardFunc), $('name', Array)
    type = args[0]
    if typeof type is 'string'
      new NamedParameter(type, args[1])
    else
      new Parameter(args...)
  when 3
    # name, pattern, guard
    # $(0, Number, function(p) {return p % 2 === 0})
    # $(_, Number, (p) -> p % 2 === 0)
    type = args[0]
    if typeof type is 'string'
      new NamedParameter(args...)
    else
      new Parameter(args[1], args[2])
  else
    throw new RangeError('wrong number of arguments')

parameter.getKey = -> null

module.exports = {
  NamedParameter
  Parameter
  Quote
  Wildcard
  paramSeq
  parameter
  quote
  wildcard
  wildcardSeq
}
