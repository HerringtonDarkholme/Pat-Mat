{
  parameter
  Parameter
} = require('./placeholder')

# given an expression, return how parameters are arranged
# (acc, cnt) -> (expr, val) -> void
assignmentFactory = (accumulation, unnamed, counterFunc) ->
  counter = counterFunc()
  (expression, value) ->
    count = counter(expression)
    if count?
      accumulation[count] = value
    else
      unnamed.push(value)

incrementalCounter = ->
  inc = 0
  (expression) -> switch
    when isFunc(expression)
      inc++
    when expression is parameter
      inc++
    when expression instanceof Parameter
      inc++
    else null

indexedCounter = ->
  (expression) -> switch
    when expression instanceof Parameter
      expression.index
    else null

nominalCounter = ->
  (expression) -> switch
    when expression instanceof Parameter
      expression.getKey()
    else null

module.exports = {
  assignmentFactory
  incrementalCounter
  indexedCounter
  nominalCounter
}
