# Three types of placeholder:
#   wildcard: _
#   parameter: $
#   quote: q

_ = wildcard = new ->
$$ = paramSeq = new ->

class Parameter
  constructor: (@pattern, @guard) ->
    if not @guard?
      @guard = -> true

  getKey: () -> null
  askGuard: (that, args...) => @guard.apply(that, args)
  @getKey = @::getKey


class IndexParameter extends Parameter
  constructor: (@index, pattern, guard) ->
    unless typeof @index is 'number'
      throw new TypeError('Indexed Parameter need number')
    super(pattern, guard)

  getKey: () -> @index


class NamedParameter extends Parameter
  constructor: (@name, pattern, guard) ->
    unless typeof @name is 'string'
      throw new TypeError('Named Parameter need string')
    super(pattern, guard)

  getKey: () -> @name


$ = parameter = (args...) -> switch args.length
  when 1
    # $({key1: String, key2: String})
    new Parameter(args[0])
  when 2
    # named/index $(0, String), $('name', Array)
    type = args[0]
    if typeof type is 'number'
      new IndexParameter(type, args[1])
    else if typeof type is 'string'
      new NamedParameter(type, args[1])
    else
      new Parameter(args[1])
  when 3
    # name, pattern, guard
    # $(0, Number, function(p) {return p % 2 === 0})
    # $(_, Number, (p) -> p % 2 === 0)
    type = args[0]
    if typeof type is 'number'
      new IndexParameter(args...)
    else if typeof type is 'string'
      new NamedParameter(args...)
    else
      new Parameter(args[1], args[2])
  else
    throw new RangeError('wrong number of arguments')

class Quote
  constructor: (@obj) ->

q = quote = (obj) -> new Quote(obj)

module.exports = {
  wildcard
  paramSeq
  parameter
  Parameter
  IndexParameter
  NamedParameter
}
