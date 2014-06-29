###
  NB: Parameter.reset() should be called after every it block
  Mocha's it execution order is not kept as in the file
###
assert = require 'assert'
{
  assignmentFactory
  incrementalCounter
  indexedCounter
  nominalCounter
} = require('../dest/counter')
{
  parameter
  Parameter
  NamedParameter
} = require('../dest/placeholder')

describe 'Counter', ->

  it 'assignmentFactory', ->
    counterFunc = -> (expr) ->
      if expr is 'test' then 'test'
      else null
    acc = {}
    unnamed = []
    testAssign = assignmentFactory(acc, unnamed, counterFunc)
    testAssign('test', 1)
    testAssign('unnamed', 2)
    assert acc.test is 1
    assert unnamed[0] is 2

  describe 'incrementalCounter should', ->
    counter = incrementalCounter()
    i = 0
    it 'add counter for function', ->
      a = counter(String)
      b = counter(Number)
      assert a is i++
      assert b is i++

    it 'add counter for parameter constant', ->
      c = counter(parameter)
      assert c is i++

    it 'add counter for Parameter instance', ->
      d = counter(parameter(b: 'test'))
      assert d is i++
      # Clean up is required
      Parameter.reset()

    it 'do not add counter otherwise', ->
      e = counter({})
      f = counter(2)
      g = counter('ss')
      assert e is null
      assert f is null
      assert g is null
      Parameter.reset()

  describe 'indexedCounter', ->
    counter = indexedCounter()
    i = 0
    it 'add counter for Parameter instance', ->
      a = counter(parameter())
      b = counter(parameter(b: 'test'))
      assert a is i++
      assert b is i++
      Parameter.reset()

    it 'do nothing otherwise', ->
      a = counter(3)
      b = counter(String)
      c = counter(/regex/)
      assert a is null
      assert b is null
      assert c is null

  describe 'nominalCounter', ->
    counter = nominalCounter()
    $ = parameter
    it 'add counter for NamedParameter', ->
      a = counter($('name1', String))
      assert a is 'name1'
      Parameter.reset()
    it 'otherwise null', ->
      a = counter($(String))
      b = counter(a: 1, b: 2)
      assert a is null
      assert b is null
      Parameter.reset()
