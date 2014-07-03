assert = require('assert')
{
  Match
  Is
  wildcard
  parameter
} = require('../dest/api')
w = wildcard
p = parameter
{
  matchReg
  decorateRegExpPrototype
} = require('../dest/extension')

describe 'extension', ->
  it 'matchReg should', ->
    Email = matchReg(/(.+?)@(.+?)\..+/)
    m = Match(
      Is Email(w, 'gmail'), -> 'gmail'
      Is Email(w, 'hotmail'), -> 'hotmail'
      Is Email(p, w), (name) -> "hi #{name}"
      Is w, -> 'not a mail'
    )
    assert m('horo@gmail.com') is 'gmail'
    assert m('horo@hotmail.com') is 'hotmail'
    assert m('homo@hotmale.com') is 'hi homo'
    assert m('hhh') is 'not a mail'

  it 'decorate', ->
    decorateRegExpPrototype()
    Email = /(.+?)@(.+?)\..+/.r()
    m = Match(
      Is Email(w, 'gmail'), -> 'gmail'
      Is Email(w, 'hotmail'), -> 'hotmail'
      Is Email(p, w), (name) -> "hi #{name}"
      Is w, -> 'not a mail'
    )
    assert m('horo@gmail.com') is 'gmail'
    assert m('horo@hotmail.com') is 'hotmail'
    assert m('homo@hotmale.com') is 'hi homo'
    assert m('hhh') is 'not a mail'
