{
  parameter
  Parameter
} = require('./placeholder')

# given an expression, return how parameters are arranged
assignmentFactory = (accumulation, counterFunc) ->
  accumulation.__unnamed__ = []
  (expression, value) ->
    count = counterFunc(expression)
    if count?
      accumulation[count] = value
    else
      accumulation.__unnamed__.push(value)

incrementalCounter = ->
  inc = 0
  (expression) -> switch
    when isFunc(expression)
      inc++
    when parameter is expression
      inc++
    when expression instanceof Parameter
      inc++
    else null

indexedCounter = nominalCounter = ->
  (expression) -> switch
    when expression instanceof Parameter
      expression.getKey()
    else null
