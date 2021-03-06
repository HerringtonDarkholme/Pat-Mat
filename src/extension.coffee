{
  Match
  extract
} = require('./api')

# hideous hack
matchReg = (reg) ->
  anns = []
  verified = false
  extract({
    annotation: anns
    transform: (text) ->
      ret = reg.exec(text)
      unless ret?
        return null
      ret.shift()
      if not verified
        i = 0
        anns.push(i++) while i < ret.length
        verified = true
      ret
  })

decorateRegExpPrototype = ->
  RegExp::r = -> matchReg(this)

decoratePrototype = (name='Match') ->
  String::[name] = Number::[name] = Boolean::[name] = Object::[name] = (args...) ->
    Match(args...)(this)

module.exports = {
  matchReg
  decorateRegExpPrototype
  decoratePrototype
}
