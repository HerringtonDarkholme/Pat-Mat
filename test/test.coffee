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

APExtractor = new Extractor(AnnotatedPoint)
console.log(APExtractor.annotation)

describe 'Extractor', ->


  it 'call Point without new should return Matcher instance', ->
    assert(Point(3, 4) instanceof Matcher)

  it 'extractor can extract constructor params', ->
    assert(extractor.annotation?)
    assert(extractor.annotation[0] is 'x')
    assert(extractor.annotation[1] is 'y')

  it 'extractor.link should return Matcher instance', ->
    assert(extractor.link([1,2]) instanceof Matcher)

  it 'annotation should use unapply if provided', ->
    assert(APExtractor.annotation[0] is 'x')
    assert(APExtractor.annotation[1] is 'y')
