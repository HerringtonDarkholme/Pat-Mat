assert = require('assert')

{
  Matcher
  deepMatch
} = require('../dest/matcher')
extract = require('../dest/extractor').extract

Point = extract class Point
  constructor: (@x, @y) ->

Circle = extract class Circle extends Point
  constructor: (@r) ->
  @unapply: (other, argList, assign) ->
    r = argList[0]
    x = other.x
    y = other.y
    if r*r is x*x + y*y
      assign(r, r)
      true
    else
      false

describe 'Matcher', ->
  it 'should use defaultUnapply if unprovided', ->
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

  it 'should use customUnapply if provided', ->
    matcher = Circle(5)
    p = new Point(3, 4)
    pp = new Point(4, 5)
    assert matcher.unapply(p, ->)
    assert matcher.unapply(pp, ->) is false
