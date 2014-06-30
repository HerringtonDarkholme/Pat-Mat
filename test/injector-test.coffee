assert = require('assert')

{
  IncrementalInjector
  IndexedInjector
  NominalInjector
  PatternMatcher
} = require('../dest/injector')

{
  wildcard
  parameter
} = require('../dest/placeholder')

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
