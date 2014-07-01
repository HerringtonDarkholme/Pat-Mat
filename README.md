Pat-Mat
==========

A full-feature [pattern matching](http://en.wikipedia.org/wiki/Pattern_match) library for JavaScript and CoffeeScript

## Feature

* Plain Old JavaScript Object as Pattern
* Variable Binding
* Pattern Guard
* Alternative Pattern
* Customizable Extractor
* Concise API
* Automatic Class Annotator
* Enumeration Order Independent

## Reason

[There](https://github.com/natefaubion/matches.js) [are](https://github.com/jfd/match-js) [pretty](https://github.com/dherman/pattern-match) [much](https://github.com/pb82/MissMatch) [pattern](https://github.com/puffnfresh/bilby.js) [matching](https://github.com/jiyinyiyong/coffee-pattern) [libraries](https://github.com/bramstein/funcy) [existing](https://github.com/natefaubion/sparkler). However, few of them are feature rich. Even though some libraries are powerful,  they are either deprecated or require advanced [macro](https://github.com/mozilla/sweet.js) system.

This repository, highly inspired by Scala, aims at creating a feature-rich pattern matching library while keeping every thing like plain old JavaScript. Being more powerful and concise is this library's Raison d'être.

Pat-Mat itself was written in CoffeeScript so all the example are also presented in that language. Pat-Mat looks better with Coffee's DSL extensibility. If you don't bother brew a jar of coffee, just add curly braces, `return` and etc. to make it work.

Install
---
Assuming you have installed `npm` and NodeJS. Then in your console.
`npm install pat-mat`

And in code:

```coffee
# import
{Match, Is, parameter, paramSeq} = require('pat-mat')
# rename for eye candy
$ = parameter
$$ = paramSeq
# later use, (username)@(domain).xx
MAIL_REG = /(.*?)@(.*?)\..+/

# example usage
m = Match(
  # literal
  Is 42, -> 'meaning of life'
  # Type
  Is Function, -> 'get a function'
  # object
  Is {x: 3, y: 4}, ->  'x is 3, y is 4'
  # alternative
  Is Number, Boolean, -> 'num or func'
  # variable binding
  Is [$, $$], (head, tail) -> head
  # RegExp
  Is MAIL_REG, (s, name, domain) -> name
)

# match element by calling
m(42) # 'meaning of life'
# Match() returns a function
m(m) # 'get a function'
```

And all patterns are just [POJO](http://en.wikipedia.org/wiki/Plain_Old_Java_Object) -- plain old javascript objects, rather than [string pattern](https://news.ycombinator.com/item?id=4519367). So you still have syntax highlight in your patterns.

Basic
---

Starting pattern match is just calling pat-mat's `Match` function. It receive several `case expression` as arguments and return a function that takes element to match. `Case expression` is  the result of `Is` function. `Is` takes at least two arguments: the last one is a function to be called when a match is found, and other arguments before it are patterns.

Case expressions (and Patterns) are sequentially matched from top to down as passed when calling `Match`. The first matching pattern will trigger the matched function and pass matched variable to the latter.

Pat-Mat provides a `parameter` singleton for variable binding. If `parameter` occurs in pattern, it will be recorded in `Is` expression and be passed to matched function as argument.

Matched function's return value will be the result of pattern-matching, make sure you do `return`. Matched function will be passed arguments of variable length, depending on the matching pattern. Arguments order is generally left to right, top to down, but that's not guaranteed for object because [ECMA's spec](http://stackoverflow.com/a/5525820). Solution for this will be presented later.

> NB: Pat-Mat also provides other case expression for different variable binding policies).

For now, if it is unclear for you, just reading the following example to see how to use Pat-Mat

```coffee
{Match, Is, parameter} = require('pat-mat')

# finding the factorial of n
fact = Match(
  Is 0, -> 1
  Is parameter, (n) -> n * fact(n-1)
)

# fact is a function
fact(3) # is 6
fact(6) # is 720
```
To summarize, there are just three points to leverage the basic of Pat-Mat
  * `Match`, call it and pass it several
  * `Is`, case expressions to match. Every `Is` has
  * patterns and matched action. Matched action is just function

And how patterns are composed is just explained in the following section.

Patterns
----

> TODO

Matched Action
---

> TODO

Case Expression
---
`Is/As/On`
> TODO

Class Annotator
---
> TODO

Customized Extractor
---
> TODO

Pattern Guard
---
> TODO
