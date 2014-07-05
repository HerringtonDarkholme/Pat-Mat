{
  Match
  Is
  As
  On
  NoMatchError
  extract
  guard
  parameter
  paramSeq
  wildcard
  wildcardSeq
} = require('../dest/api')
assert = require('assert')

$ = parameter
$$ = paramSeq
_ = wildcard
__ = wildcardSeq

describe 'Match ', ->

  it 'should match Is branch', ->
    m = Match(
      Is Number,  (p) -> p * 2
      Is String,  (s) -> s + s
      Is [0, $$], (t) -> t.length
      Is Array,   (a) -> (2*i for i in a)
    )

    assert m(1) is 2
    assert m('s') is 'ss'
    assert m([1])[0] is 2
    assert m([0, 1, 2]) is 2

  it 'Is should inject RegExp param', ->
    MAIL_REG = /(.*?)@(.*?)\..*/
    m = Match(
      Is MAIL_REG, (_, name, domain) -> [name, domain]
      Is _, -> 'no match'
    )
    ret = m('bob@alice.com')
    assert ret[0] is 'bob'
    assert ret[1] is 'alice'
    assert m('sss') is 'no match'

  it 'test custom extract', ->
    Circle = extract {
      annotation: ['r']
      transform: (other) ->
        x = other.x
        y = other.y
        {r: Math.sqrt(x*x + y*y)}
    }

    Point = extract class Point
      constructor: (@x, @y) ->
    m = Match(
      Is Point(3, 4), -> 'point'
      Is Circle(5),   -> 'circle'
      Is _,           -> 'nothing'
    )

    assert m(new Point(3, 4)) is 'point'
    assert m(new Point(4, 3)) is 'circle'
    assert m(x: 4, y: 3) is 'circle'
    assert m(r: 5) is 'nothing'

  it 'As should ignore RegExp', ->
    MAIL_REG = /(.*?)@(.*?)\..*/
    m = Match(
      As MAIL_REG, -> arguments.length
      As _, -> 'no match'
    )
    assert m('bob@alice.com') is 0

  it 'As test', ->
    pm = As String, -> arguments.length
    assert pm.hasMatch('sss')
    assert pm.inject('sss') is 0
    pm = As undefined, -> arguments.length
    assert pm.hasMatch('sss') is false

  it 'As should match', ->
    argCount = -> arguments.length
    m = Match(
      As null               , -> 'null'
      As undefined          , -> 'undefined'
      As 42                 , -> 'meaning of life'
      As String             , argCount
      As {x: $()}           , argCount
      As [$(), __ , Number] , argCount
    )
    assert m(null) is 'null'
    assert m(undefined) is 'undefined'
    assert m(42) is 'meaning of life'
    assert m('love live') is 0
    assert m(x: 2, y: 3) is 1
    assert m([1,2,3]) is 1

  it 'On should inject parameter as object k-v pair', ->
    m = Match(
      On $('n', Number), (m) -> m.n * 2
      On {x: $('x'), y: $('y')}, (m) -> m.x + m.y
      On $(), -> @unnamed[0]
    )
    assert m(2) is 4
    assert m({x: 5, y: 5}) is 10
    assert m(true)

  it 'should throw error if no match', ->
    m = Match(
      On $('n', Number), (m) -> m.n * 2
      On {x: $('x'), y: $('y')}, (m) -> m.x + m.y
    )
    assert.throws( ->
      m('no match')
    NoMatchError)

  it 'should ask guard', ->
    m = Match(
      Is Number, guard(-> @m%2 == 0), -> 'even'
      Is Number, guard(-> @m%2 == 1), -> 'odd'
      Is wildcard, -> 'not integer'
    )
    assert m(2) is 'even'
    assert m(3) is 'odd'
    assert m('dd') is 'not integer'
