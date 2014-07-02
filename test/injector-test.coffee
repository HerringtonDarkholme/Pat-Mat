assert = require('assert')

{
  IncrementalInjector
  IndexedInjector
  NominalInjector
  CaseExpression
} = require('../dest/injector')

{
  wildcard
  parameter
  guard
  quote
} = require('../dest/placeholder')

q = quote
$ = parameter
_ = wildcard

describe 'Injector', ->
  describe 'Incremental injector should', ->
    it 'match according to pattern', ->
      injector = new IncrementalInjector([1, 2, Number])
      assert injector.isDefinedAt([1, 2, 3])
      assert injector.inject([1,2,3], (p) -> @m.length is 3 and p is 3)
      assert injector.inject([1,2,3], (p) -> @m.length is 2) is false

    it 'make cache orderly', ->
      injector = new IncrementalInjector([String, _, $])
      assert injector.isDefinedAt(['test', 1, 2])
      assert injector.cache[0] is 'test'
      assert injector.cache[1] is 2

    it 'be sensitive to Function', ->
      injector = new IncrementalInjector(Number)
      assert injector.isDefinedAt(4)
      assert injector.inject(4, (p) -> @m is p)

    it 'be sensitive to RegExp', ->
      injector = new IncrementalInjector(/([A-z]+)-(\d+)/)
      str = 'I am SCP-013, an SCP doc not a torrent'
      assert injector.isDefinedAt(str)
      assert injector.cache[0] is 'SCP-013'
      assert injector.cache[1] is 'SCP'
      assert injector.cache[2] is '013'
      assert injector.inject(str, (m, factory, number) ->
        @m is str and
        m is 'SCP-013' and
        factory is 'SCP' and
        number is '013'
      )

  describe 'IndexedInjector should', ->
    it 'preserve key value order', ->
      injector = new IndexedInjector(b: $(String), a: $(3))
      assert injector.isDefinedAt(a: 3, b: 'sss')
      assert injector.cache[0] is 'sss'
      assert injector.cache[1] is 3
      assert injector.inject({a: 3, b: 'sss'}, (b, a) ->
        b is 'sss' and a is 3
      )
    it 'ignore Func', ->
      injector = new IndexedInjector(String)
      assert injector.isDefinedAt('sss')
      assert injector.cache[0] is undefined
      assert injector.inject(null, -> not arguments.length)

    it 'ignore Regex', ->
      injector = new IndexedInjector(/(s)(s)(s)/)
      assert injector.isDefinedAt('sss')
      assert injector.cache[0] is undefined
      assert injector.inject(null, -> not arguments.length)

  describe 'NominalInjector should', ->
    it 'insert k-v pairs to arguments', ->
      injector = new NominalInjector(b: $('a', String), a: $('b', 3))
      assert injector.isDefinedAt(a: 3, b: 'sss')
      assert injector.cache.a is 'sss'
      assert injector.cache.b is 3
      assert injector.inject({a: 3, b: 'sss'}, (m) ->
        @m.a is m.b and @m.b is m.a
      )

  describe 'CaseExpression', ->
    p0 = $(q('test'))
    p1 = Boolean
    p2 = {x: 1, y: Number}
    p3 = [1, 2, $]
    patterns = [p0, p1, p2, p3]
    pm = new CaseExpression(
      patterns,
      (p)->p,
      IncrementalInjector)

    it 'should use the first pattern', ->
      assert pm.hasMatch('test')
      assert pm.injector.pattern is p0
      assert pm.inject('test') is 'test'

    it 'should use the second pattern', ->
      assert pm.hasMatch(true)
      assert pm.injector.pattern is p1
      assert pm.inject() is true

    it 'should use the third', ->
      assert pm.hasMatch({x: 1, y: 2})
      assert pm.injector.pattern is p2
      assert pm.inject() is 2

    it 'should use the fourth', ->
      assert pm.hasMatch([1, 2, 3])
      assert pm.injector.pattern is p3
      assert pm.inject() is 3

    it 'should not match', ->
      assert pm.hasMatch('no match') is false
      assert pm.injector is null

    it 'shouldnt ask guardian before match', ->
      patterns = [String, guard(-> throw 'never here')]
      pm = new CaseExpression(
        patterns
        (p) -> p
        IncrementalInjector
      )
      assert pm.hasMatch(3) is false

    it 'should ask guardian', ->
      guardian = guard(-> @m % 2 is 0)
      patterns = [Number, guard(-> @m % 2 is 0)]
      pm = new CaseExpression(
        patterns
        (p) -> p
        IncrementalInjector
      )
      assert pm.guard = guardian.guard
      assert pm.hasMatch(2)
      assert pm.injector isnt null
      assert pm.inject(2) is 2
      assert pm.hasMatch(3) is false
      assert pm.injector is null
      assert.throws(
        -> pm.inject(2)
      Error)
