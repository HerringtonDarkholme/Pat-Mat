assert = require 'assert'

{Extractor, extract} = require '../dest/extractor'
{Matcher} = require '../dest/matcher'

class Point
  constructor: (@x, @y) ->

extractor = new Extractor(Point)
Point = extract Point

class AnnotatedPoint
  constructor: (xRename, yRename) ->
    @x = xRename
    @y = yRename
  @unapply = ['x', 'y']

annotation = ['r-test']
transform = (other) ->
  x = other.x
  y = other.y
  Math.abs(1 - (x*x + y*y) / (r * r)) < 0.05


class CustomExtractPoint
  constructor: (@r) ->
  @unapply = transform

APExtractor = new Extractor(AnnotatedPoint)

describe 'Extractor', ->


  it 'without new should return Matcher instance', ->
    assert(Point(3, 4) instanceof Matcher)

  it 'calling ctor with new returns instance', ->
    assert new Point(3, 4) instanceof Point

  it 'extractor can extract constructor params', ->
    assert extractor.annotation?
    assert extractor.annotation[0] is 'x'
    assert extractor.annotation[1] is 'y'
    assert extractor.transform is null

  it 'extractor.link should return Matcher instance', ->
    assert extractor.link([1,2]) instanceof Matcher

  it 'unapply as annotation', ->
    assert APExtractor.annotation[0] is 'x'
    assert APExtractor.annotation[1] is 'y'
    assert APExtractor.transform is null

  it 'customized unapply method', ->
    cpExtractor = new Extractor(CustomExtractPoint)
    argList = [5]
    cp = cpExtractor.link(argList)
    assert cpExtractor.transform is transform
    assert cp instanceof Matcher
    assert cp.annotation is cpExtractor.annotation
    assert cp.transform is cpExtractor.transform
    assert cp.argList is argList
    assert cp.ctor is CustomExtractPoint

  it 'make extractor from plain object', ->
    Circle = extract {
      annotation: ['r']
      transform: (other) ->
        x = other.x
        y = other.y
        {r: Math.sqrt(x*x + y*y)}
    }
    assert Circle(5) instanceof Matcher
