assert = require 'assert'

{
  NamedParameter
  Parameter
  Wildcard
  Quote
  paramSeq
  parameter
  quote
  wildcard
  wildcardSeq
} = require('../dest/placeholder')


describe 'Placeholder', ->

  it 'Parameter should preserve pattern, return null key', ->
    param = new Parameter(String)
    assert param.pattern is String
    assert param.getKey() is null
    assert param.askGuard({}, 123) is true
    Parameter.reset()

  it 'Parameter with guard should show whether match', ->
    guard = (s) ->
      s.length > 4 and !!@.m
    param = new Parameter(String, guard)
    injected = {m: undefined, unnamed: undefined}
    assert param.askGuard(injected, 'test_string') is false
    injected.m = true
    assert param.askGuard(injected, 'test_string') is true
    Parameter.reset()

  it 'Parameter counter should increment', ->
    p0 = new Parameter(Number)
    p1 = new Parameter(String)
    assert p0.index is 0
    assert p1.index is 1
    assert Parameter._index is 2
    Parameter.reset()
    assert Parameter._index is 0

  it 'NamedParameter should store name', ->
    guard = (s) -> s.length > 2
    np = new NamedParameter('test', String, guard)
    assert np.getKey() is 'test'
    assert np.pattern is String
    assert np.askGuard({}, 'longlong') is true
    assert np.askGuard({}, '') is false
    assert Parameter._index is 1
    assert.throws(
      (-> new NamedParameter(123, String)),
      TypeError)
    Parameter.reset()

  it 'wildcard function should return Wildcard instance', ->
    pattern = {a: 1, b: 2}
    wildcardPattern = wildcard(pattern)
    assert wildcardPattern instanceof Wildcard
    assert wildcardPattern.pattern is pattern

  it 'quote fuction should return Quote instance', ->
    pattern = {a: 1, b: 2}
    quotePattern = quote(pattern)
    assert quotePattern instanceof Quote
    assert quotePattern.pattern is pattern


  describe '$ should behave polymorphically', ->
    $ = parameter

    it 'zero arity is the alias of $(_)', ->
      $0 = $()
      assert $0 instanceof Parameter
      assert $0.pattern is wildcard
      Parameter.reset()

    it 'arity 1: pattern', ->
      $1 = $(String)
      assert $1.pattern is String
      Parameter.reset()

    it 'arity 2: guarded or named', ->
      $2 = $(String, -> false)
      assert $2.askGuard({}, '') is false
      assert $2.pattern is String
      assert $2.getKey() is null
      assert not ($2 instanceof NamedParameter)
      $2 = $('testname', String)
      assert $2.askGuard({}, '') is true
      assert $2.pattern is String
      assert $2.getKey() is 'testname'
      assert $2 instanceof NamedParameter
      Parameter.reset()

    it 'arity 3: NamedParameter with guard', ->
      $3 = $('testname', String, -> false)
      assert $3.askGuard({}, '') is false
      assert $3.pattern is String
      assert $3.getKey() is 'testname'
      assert $3 instanceof NamedParameter
      Parameter.reset()

