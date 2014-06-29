assert = require 'better-assert'

{Extractor, extract} = require '../dest/extractor'
{Matcher, deepMatch} = require '../dest/matcher'

class Point
  constructor: (@x, @y) ->

extractor = new Extractor(Point)
Point = extract Point

class AnnotatedPoint
  constructor: (xRename, yRename) ->
    @x = xRename
    @y = yRename
  @unapply = ['x', 'y']

customUnapply = (other, argList, assign) ->
  r = argList[0]
  x = other.x
  y = other.y
  Math.abs(1 - (x*x + y*y) / (r * r)) < 0.05

class CustomExtractPoint
  constructor: (@r) ->
  @unapply = customUnapply

APExtractor = new Extractor(AnnotatedPoint)

describe 'Extractor', ->


  it 'call Point without new should return Matcher instance', ->
    assert(Point(3, 4) instanceof Matcher)

  it 'calling ctor with new returns instance', ->
    assert new Point(3, 4) instanceof Point

  it 'extractor can extract constructor params', ->
    assert extractor.annotation?
    assert extractor.annotation[0] is 'x'
    assert extractor.annotation[1] is 'y'
    assert extractor.unapply is null

  it 'extractor.link should return Matcher instance', ->
    assert extractor.link([1,2]) instanceof Matcher

  it 'annotation should use unapply if provided', ->
    assert APExtractor.annotation[0] is 'x'
    assert APExtractor.annotation[1] is 'y'
    assert APExtractor.unapply is null

  it 'customized unapply method', ->
    cpExtractor = new Extractor(CustomExtractPoint)
    argList = [5]
    cp = cpExtractor.link(argList)
    assert cpExtractor.unapply is customUnapply
    assert cp instanceof Matcher
    assert cp.annotation is cpExtractor.annotation
    assert cp.customUnapply is cpExtractor.unapply
    assert cp.argList is argList
    assert cp.ctor is CustomExtractPoint
