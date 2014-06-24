class Matcher
  constructor: (@annotation, @unapply, @argList) ->

  match: (other) ->
    annotation = @annotation
    if @unapply?
      return @unapply(other, @argList)

    ret = []
    for param, index in @argList
      matching = deepMatch(param, other[annotation[index]])
      if matching?
        ret.concat(matching)
      else
        return null
    ret

deepMatch = (param, obj) ->

module.exports =  {
  Matcher
  deepMatch
}
