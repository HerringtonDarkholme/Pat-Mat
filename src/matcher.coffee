{isFunc, isArray, isPlainObject} = require('./util')

class Matcher
  constructor: (@annotation, @unapply, @argList) ->

  match: (other, assign) ->
    annotation = @annotation
    if @unapply?
      return @unapply(other, @argList, assign)

    ret = []


module.exports =  {
  Matcher
  deepMatch
}
