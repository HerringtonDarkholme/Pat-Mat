assert = require('assert')

{
  Matcher
  deepMatch
} = require('../dest/matcher')

{
  quote
  paramSeq
  parameter
  Parameter
  wildcard
  wildcardSeq
} = require('../dest/placeholder')
_ = wildcard
q = quote
$ = parameter
$$ = paramSeq
__ = wildcardSeq

extract = require('../dest/extractor').extract

Point = extract class Point
  constructor: (@x, @y) ->

Circle = extract class Circle extends Point
  constructor: (@r) ->
  @unapply: (other) ->
    x = other.x
    y = other.y
    { r: Math.sqrt(x*x + y*y) }

UnitVector = extract class UnitVector
  constructor: (@x, @y) ->
  @unapply: {
    transform: (other) ->
      x = other.x
      y = other.y
      norm = Math.sqrt(x*x + y*y)
      {x: x/norm, y: y/norm}
  }

describe 'Matcher', ->
  it 'default unapply should check constructor', ->
    annotation = ['x', 'y']
    argList = [3, 4]
    ctor = Point
    matcher = new Matcher(annotation, null, argList, ctor)
    p = new Point(3, 4)
    pp = new Point(4, 5)
    assert matcher.unapply(p, ->)
    assert matcher.unapply(pp, ->) is false
    assert matcher.unapply({x: 3, y: 4}, ->) is false

  it 'should cooperate with extractor', ->
    matcher = Point(3, 4)
    p = new Point(3, 4)
    pp = new Point(4, 5)
    assert matcher.unapply(p, ->)
    assert matcher.unapply(pp, ->) is false
    assert matcher.unapply({x: 3, y: 4}, ->) is false

  it 'should use transform if provided', ->
    matcher = Circle(5)
    p = new Point(3, 4)
    pp = new Point(4, 5)
    assert matcher.unapply(p, ->)
    assert matcher.unapply(pp, ->) is false
    assert Circle($).unapply(p, ->)
    assert Circle($).unapply(pp, ->)

  it 'should use unapply object', ->
    matcher = UnitVector(3/5, 4/5)
    p = new Point(3, 4)
    pp = new Point(4, 5)
    assert matcher.unapply(p, ->)
    assert matcher.unapply(pp, ->) is false

  describe 'deepMatch', ->
    it 'match wildcard and Wildcard instance', ->
      assign = -> throw 'should not call'
      assert deepMatch(_, 1, assign)
      assert deepMatch(_, null, assign)
      assert deepMatch(_, 'whatever', assign)
      assert deepMatch(_(Number), 1, assign)
      assert deepMatch(_(Number), 'ddd', assign) is false

    it 'quoted pattern should match literally', ->
      assign = -> throw 'should not call'
      assert deepMatch(q(1), 1, assign)
      assert deepMatch(q($), $, assign)
      assert deepMatch(q(Number), 1, assign) is false
      assert deepMatch(q($), 'whatever', assign) is false

    it 'should make Matcher happy', ->
      exprs = []
      values = []
      assign = (expr, obj) ->
        exprs.push(expr)
        values.push(obj)

      p = new Point(3, 4)
      pp = new Point(4, 4)
      matcher0 = Point(3, 4)
      matcher1 = Circle(5)
      matcher2 = UnitVector(3/5, 4/5)
      assert deepMatch(matcher0, p, assign)
      assert deepMatch(matcher1, p, assign)
      assert deepMatch(matcher2, p, assign)
      assert deepMatch(matcher1, pp, assign) is false
      assert deepMatch(matcher2, pp, assign) is false
      assert deepMatch(Point($('x', _), $('y', _)), p, assign)
      # exprs = [$x, $y]
      # values = [3, 4]
      assert exprs.shift().name is 'x'
      assert exprs.shift().name is 'y'
      assert values.shift() is 3
      assert values.shift() is 4
      assert deepMatch(Point(3, $), p, assign)
      assert exprs.shift() is $
      assert values.shift() is 4
      assert deepMatch(Point(3, $), pp, assign) is false
      assert exprs.length is 0
      assert values.length is 0
      assert deepMatch(Circle($), p, assign)
      assert exprs.shift() is $
      assert values.shift() is 5

    it 'match Regex and assign matched array', ->
      mailReg = /(.+?)@([^\.]+)\..+/
      exprs = []
      values = []
      assign = (expr, obj) ->
        exprs.push(expr)
        values.push(obj)
      assert deepMatch(mailReg, 'bob@mail.com', assign)
      assert exprs.shift() is mailReg
      v = values.shift()
      assert v[0] is 'bob@mail.com'
      assert v[1] is 'bob'
      assert v[2] is 'mail'
      assert deepMatch(mailReg, 'xxx', assign) is false
      assert exprs.length is 0
      assert values.length is 0

    it 'match parameter', ->
      exprs = []
      values = []
      assign = (expr, obj) ->
        exprs.push(expr)
        values.push(obj)
      assert deepMatch($, 5, assign)
      assert exprs.shift() is $
      assert values.shift() is 5
      assert deepMatch($(String), 5, assign) is false
      # unmatch does not clean exprs
      exprs.pop()
      values.pop()
      assert deepMatch($(String), 'string', assign)
      assert exprs.shift().pattern is String
      assert values.shift() is 'string'

    it 'match primitive', ->
      assign = -> throw 'should not come here'
      assert deepMatch(5, 5, ->)
      assert deepMatch('5', 5, ->) is false
      assert deepMatch(NaN, NaN, ->)
      assert deepMatch(q(NaN), NaN, ->) is false
      assert deepMatch(undefined, undefined, ->)
      assert deepMatch(undefined, 'ss', ->) is false
      assert deepMatch(null, undefined, ->) is false

    it 'match plain object', ->
      Parameter.reset()
      matched = []
      assign = (expr, obj) ->
        matched[expr.index] = obj
      p = new Point(3, 4)
      assert deepMatch({x: 3, y: 4}, p, assign)
      assert deepMatch({x: $(), y: $(Number)}, p, assign)
      assert matched[0] is 3
      assert matched[1] is 4

    it 'match array', ->
      Parameter.reset()
      obj = [1..5]
      matched = []

      assign = -> throw 'never here'
      assert deepMatch([1, 2, 3, 4, 5], obj, assign)
      assert deepMatch([1, __, 5], obj, assign)

      assign = (expr, obj) ->
        matched[0] = obj
      assert deepMatch([1, 2, $$], obj, assign)
      tail = matched.shift()
      assert tail[0] is 3 and tail[1] is 4 and tail[2] is 5

      assign = (expr, obj) ->
        matched[expr.getKey()] = obj
      assert deepMatch([$$('head'), 4, 5], obj, assign)
      head = matched.head
      assert head[0] is 1 and head[1] is 2 and head[2] is 3

      assign = (expr, obj) ->
        matched[expr.index] = obj
      Parameter.reset()
      $$()
      assert deepMatch([1, $$(), 5], obj, assign)
      mid = matched[1]
      assert mid[0] is 2 and mid[1] is 3 and mid[2] is 4
      Parameter.reset()

    it 'fail to match array', ->
      assign = -> throw 'never here'
      obj = [1..5]
      assert deepMatch([1, $$, 6], obj, assign) is false
      assert deepMatch([], 123, assign) is false
      assert.throws(->
        deepMatch([$$, 3, $$, 5], obj, assign)
      Error)

    it 'should fail to match array', ->
      assign = -> throw 'never here'
      # would match because only pre and post are tested
      obj = [1, 2]
      assert deepMatch([1, 2, $$, 1, 2], obj, assign) is false
      assert deepMatch([], obj, assign) is false

    it 'should not match twice', ->
      counter = 0
      assign = -> counter++
      assert deepMatch([$], [1], assign)
      assert counter is 1
    it 'patter length and that of obj are different', ->
      assert deepMatch([$, $, $], [1, 2], ->) is false
      assert deepMatch([$, $], [1, 2, 3], ->) is false

    it 'match func javascript primitive', ->
      counter = 0
      i = 0
      assign = -> ++counter
      assert deepMatch(String, 'ttt', assign)
      assert counter is ++i
      assert deepMatch(String, 3, assign) is false
      assert counter is i
      assert deepMatch(Number, 3, assign)
      assert counter is ++i
      assert deepMatch(Boolean, true, assign)
      assert counter is ++i
      assert deepMatch(Point, new Point(3, 4), assign)
      assert counter is ++i
      assert deepMatch(Point, new Circle(5), assign)
      assert counter is ++i
      assert deepMatch(Point, new UnitVector(.727, .727), assign) is false
      assert counter is i
      assert deepMatch(Array, [1,2,3], assign)
      assert counter is ++i
      assert deepMatch(Number, true, ->) is false
