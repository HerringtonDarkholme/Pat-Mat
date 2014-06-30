assert = require('assert')

{
  Matcher
  deepMatch
} = require('../dest/matcher')

{
  quote
  paramSeq
  parameter
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
