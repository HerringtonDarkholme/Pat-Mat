Pat-Mat
==========

A full-feature [pattern matching](http://en.wikipedia.org/wiki/Pattern_match) library for JavaScript and CoffeeScript

## Feature

* Plain Old JavaScript Object as Pattern
* Variable Binding
* Case Class
* Pattern Guard
* Alternative Pattern
* Customizable Extractor
* Concise API
* Automatic Class Annotator
* Enumeration Order Independent

## Reason

[There](https://github.com/natefaubion/matches.js) [are](https://github.com/jfd/match-js) [pretty](https://github.com/dherman/pattern-match) [much](https://github.com/pb82/MissMatch) [pattern](https://github.com/puffnfresh/bilby.js) [matching](https://github.com/jiyinyiyong/coffee-pattern) [libraries](https://github.com/bramstein/funcy) [existing](https://github.com/natefaubion/sparkler). However, few of them are feature rich. Even though some libraries are powerful,  they are either deprecated or require advanced [macro](https://github.com/mozilla/sweet.js) system.

This repository, highly inspired by Scala, aims at creating a feature-rich pattern matching library while keeping every thing like plain old JavaScript. Being more powerful and concise is this library's _Raison d'être_.

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

### Literals
Check value literally. It supports all JavaScript primitive values including string, number, `null`, `undefined` and `NaN`
Note that since patterns are just normal JavaScript objects, variables in patterns are passed as their value/reference.

```coffee
k = 'a string'
patmat = Match(
  Is 42, -> ...
  Is 'a string', ->
  Is k, -> ... # same as above
  Is null, -> ...
  Is undefined, -> ...
  Is NaN, -> ... # matched by isNaN
)
```

### Parameter
Variables can be captured by using parameter. They are passed as arguments to matched actions.

``` coffee
# for shorter name
$ = parameter

patmat = Match(
  Is [$, 2, 3], (p) -> 'p is ' + p
  Is {x: $}, (x) -> 'x is ' + x
)

patmat([1, 2, 3]) # p is 1
patmat({x: 1}) # x is 1
```

You can also use `parameter` as function to specify what kind of value will be captured.
`parameter` takes `pattern` as argument, except for string pattern.

```coffee
_ = require('pat-mat').wildcard

patmat = Match(
  Is [$(Number), 2, 3], -> 'matched'
  Is _, -> 'no match'
)

patmat([1, 2, 3])
# matched
patmat(['str', 2, 3])
# no match
```
If you worry that enumerating order of object keys is not stable, as specified by ECMA, you can use string to name the parameter.
And you need another function to generate `case expression`: `On`.
Matched action in `On` expression receives an plain object as argument, in which the names you assign to parameters are keys.
The second argument in `parameter` is `pattern`.

```coffee
_ = require('pat-mat').wildcard
matchPoint = Match(
  On {x: $('x', Number), $('y')}, (point) -> p.x + p.y
  On _, -> 'not a point'
)

matchPoint({x: 3, y: 4}) # 7
matchPoint({x: '3' , y: 4}) # not a point
```

### Wildcard
`Match` will throws an `NoMatchError` if no `CaseExpression` fits the element.
You can use a `wildcard` pattern as the **default** case. Wildcard can also be nested pattern.

```coffee
_  = require('pat-mat').wildcard
patmat = Match(
  Is [_, _], -> 'two element array as tuple'
  Is _,      -> 'anything else'
)

patmat([2, 3]) # two element array as tuple
patmat(Array) # anything else
```

### Array
Matches on entire array or pick up a few elements.
Pat-Mat provides `paramSeq` and `wildcardSeq` for matching subarray.
(`Seq` stands for _sequence_)

```coffee
$ = require('pat-mat').parameter
$$ = require('pat-mat').paramSeq

sum = Match(
  # $$ captures the subarray
  Is [$, $$], (head, tail)-> head + sum(tail)
  Is [], -> 0
)

sum([1, 2, 3]) # 6
```

Just like `wildcard`, `wildcardSeq` does not bind subarray to any variables.
One array pattern can have one and only one sequence pattern. Otherwise an Error will occurs.

Array pattern matches all **Array Like**(has `length` property and its elements can be accessed by index) elements. So you can, for example, pass `arguments` to pattern matcher.

### Object
Object is matched by comparing key-value pairs, so here _Duck Typing_ is conducted.

```coffee
# will match as long as element has x and y property
matchPoint = Match(
  Is {x: $, y: $}, (x, y) -> 'get point'
)

class Point
  constructor: (@x, @y)

# take any type
matchPoint(new Point(3, 4)) # get point
# even the property is null or undefined
matchPoint({x: 'd', y: null}) # get point
# but not if it has no such key
matchPoint({x: 1}) # NoMatchError
```

### Type
If the pattern is a function, then the function will be treated as a constructor function. The element matched against must be a subtype of that constructor.

```coffee

class Animal
class Snake extends Animal
class Python extends Snake
class Naja extends Snake
class Frog extends Animal

findAnimal = Match(
  Is Python, -> 'large snake'
  Is Snake, -> 'snake'
  Is Animal, -> 'new species'
)

findAnimal(new Python) # 'large snake'
findAnimal(new Naja) # 'snake'
findAnimal(new Frog) # 'new species'
```

> NB: `instanceof` is used as subtype checking. [Comparing](https://github.com/bramstein/funcy#patterns) `element.constructor` will violates [Liskov Substitution Principle](http://en.wikipedia.org/wiki/Liskov_substitution_principle)

For core JavaScript datatype `Number`, `String`, `Boolean`, their corresponding primitive values are taken as matching elements.

```coffee
# monoid like mappend
append = (a, b) -> Match(
  Is [String, String], -> a + b
  Is [Number, Number], -> a + b
  Is [Array, Array], -> a.concat(b)
)(arguments)
```
> NB: Only in `In` case expression is `Type` pattern captured.

### Regular Expression
Regular Expression is matched against element. If a match is found, the match and its capturing group will be passed to the matched action.

```coffee
MAIL_REG = /(.*?)@(.*?)\..*/

mail = Match(
  Is MAIL_REG, (_, name, domain) -> {name, domain}
  Is _, -> 'no match'
)

mail('test@mail.com') # {name: 'test', domain: 'mail'}
```
> NB: Regular Expression is only captured in `Is`.

### Case Class
Pat-mat mocks Scala's `case class` by the function `extract`.
_Case classes are regular classes which exports their constructor parameters and which provide a recursive decomposition mechanism via pattern matching._([source](http://www.scala-lang.org/old/node/107))
Applying `extract` to constructor function will return a equivalent constructor function that also doubles as case class pattern.
With `new`, **extracted** function returns a new instance; without `new`, **extracted** function returns a case class pattern.

Here is an example. This example uses Coffee's class syntax which is a natural fit for `Case Class`. (That's why Pat-Mat was written in Coffee)

```coffee
Point = extract class Point
  constructor: (@x, @y) ->
  # more code

takeY = Match(
  Is Point(3, $), (y) -> y
  Is _, -> 'no match'
)

# a new Point instance
takeY(new Point(3, 4)) # 4
# a pattern instance
takeY(Point(3, 4)) # no match
# because x fails to match
takeY(new Point(4, 4)) # no match
```

If you are using JavaScript:
```js
function Point(x, y) {
  this.x = x;
  this.y = y;
}
Point.prototype = {
  // more code
}
var Point = extract(Point);

var takeY = Match(
  Is(Point(3, $), function(y) {
    return y;
  }),
  Is(_, function() {
    return 'no match';
  })
);

takeY(new Point(3, 4)); // 4
takeY(Point(3, 4)); // no match
```

By default, Pat-Mat tries to annotate the constructor and to retrieve its parameter name.
If the element to be matched is an instance of the constructor, then the element's fields with same names with parameter will be recursively matched against the pattern in the case class pattern. So the pattern `Point(3, $)` matches element `p` if `p.x == 3`, and then pass `p.y` to the action as argument if matched.

However, automatic annotation does not work in compressed JavaScript, and fails to match if the fields in constructor are modified during initialization.
For solution, please refer to [Class Annotator](https://github.com/HerringtonDarkholme/Pat-Mat#class-annotator) section.

Case Expression
---
`Is/As/On`
Object in JavaScript is a collection of unordered key-value pair. Though expressions like `{x: $, y: $}` will usually keep the order, Pat-Mat gives different `case expression` function to guarantee order.

`As` will apply arguments to the matched action, but variable binding needs to call `parameter` in pattern.

```coffee
argCount = -> arguments.length
m = Match(
  # no captured group
  As /test/             , argCount
  # function constructor will not be captured
  As String             , argCount
  # will be captured because it invokes `parameter`
  As {x: $()}           , argCount
  # only capture the first element
  As [$(), __ , Number] , argCount
  # `parameter` itself is not captured
  As $,                   argCount
)

m('test') # 0
m('ssss') # 0
m({x: 5, y: 5}) # 1
m([3, 3, 3]) # 1
m(null) # 0
```

`On` will pass an object of which the values are captured variables .`On` requires `NamedParameter`, which means `parameter` should be invoked with a name string as its first argument. The `name` of parameter will be the key of the object.

```coffee
m = Match(
  On $('n', Number), (m) -> m.n * 2
  On {x: $('x'), y: $('y')}, (m) -> m.x + m.y
  On $(), -> @unnamed[0]
)

m(2) # 4
m({x: 5, y: 5}) # 10
m(true) # true
```

Uninvoked `parameter` in `As` and `On`, and `parameter` instance other than `NamedParameter` will be stored in `this.unnamed` array and binded to matched function.

> NB: `Is` stands for _incremental_. `As` stands for _Array_. `On` stands for _Object_. The initials of these functions suggests their argument passing policies.

Matched Action
---

Matched action is just plain function. How it receives arguments is dependent on the `case expression`, as specified before.

Matched action has binded to matching objects to pass more information. You can access the whole match via `this.m` and variables that are not captured by `As`/`On` via `this.unnamed`.

```coffee
fib = Match(
  As 0, -> 0
  As 1, -> 1
  As Number, -> fib(@m-1) + fib(@m-2)
)
fib(longProcess().getData().getMockNumber().canBeBindedToThisM())
```

Class Annotator
---

`extract` is a function that returns a case class constructor.
It will analyzes the original constructor function by `toString()` and extracts the fields.
However, compressed JavaScript will lose the information. You can set the `unapply` static attribute of the **constructor function** to give Pat-Mat a hint.
`unapply` can be `annotation`, an array of string that corresponds to the constructor's argument and instance fields.

```coffee
Point = extract class Point
  constructor: (longlongx, longlongy) ->
    @x = longlongx
    @y = longlongy

  @unapply = ['x', 'y']

p = new Point(3, 4)
# now Pat-Mat will compare p.x and p.y
# Point(3, 4) will match p
```

If the fields are modified in constructor, you can set `unapply` to a `transform` function.
`transform` function takes the element to be  matched as argument, and should return an objects with properties specified in `annotation`.
`annotation` is just the array described above. If `unapply` is function, `annotation` is programatically found.

```coffee
UnitVector = extract class UnitVector
  constructor: (x, y) ->
    norm = Math.sqrt(x*x + y*y)
    @x = x / norm
    @y = y / norm

  @unapply = (other) ->
    x = other.x
    y = other.y
    norm = Math.sqrt(x*x + y*y)
    # in this case you can also return
    # new UnitVector(other.x, other.y)
    # because the constructor is side-effect free
    return {
      x: x / norm
      y: y / norm
    }
```

Combining `annotation` and `transform` is okay.
Set `unapply` to an object with `transform` and `annotation`.

```coffee
Circle = extract class Circle
  constructor: (longlongr) ->
    @r = longlongr
  @unapply = {
    annotation: ['r']
    transform: Match(
      # only transform Circle/Point instance
      Is Circle, -> @m
      Is Point($, $), (x, y) ->
        {r: Math.sqrt(x*x + y*y)}
      Is _, -> null
    )
  }

getRadius = Match(
  Is Circle($), (r) -> 'radius: ' + r
)
getRadius(new Circle(5)) # radius: 5
getRadius(new Point(3, 4)) # radius: 5
getRadius({r: 5}) # throw NoMatchError
```

If `transform` is defined, then the case class pattern can match any type, as long as the `transform`'s return value is not null.

As illustrated above, `transform` can be implemented easily with Pat-Mat.

Customized Extractor
---

Much similar to class annotator, customized extractor is constructed by passing an `unapply` object to `extract`.
`unapply` should have `annotation` property and optional `transform` property.

Attention: extractor is not a constructor function.

```
Circle = extract({
  annotation: ['r']
  transform: Match(
    Is {r: Number}, -> @m # duck typing
    Is Point($, $), (x, y) ->
      {r: Math.sqrt(x*x + y*y)}
    Is _, -> null
  )
})

getRadius = Match(
  Is Circle($), (r) -> 'radius: ' + r
)

getRadius(new Point(3, 4)) # radius: 5
getRadius({r: 5}) # radius: 5
getRadius(new Circle(5)) # TypeError, Circle is not a constructor function
```
Pattern Guard
---
Pattern guard is also supported by `guard` function.
Pattern guard should immediately follow the pattern in case expression. Only one pattern can precede the guard, so no alternative pattern cannot be used.

```coffee
m = Match(
  Is Number, guard(-> @m%2 == 0), -> 'even'
  Is Number, guard(-> @m%2 == 1), -> 'odd'
  Is wildcard, -> 'not integer'
)
m(2) # is 'even'
m(3) # is 'odd'
m('dd') # is 'not integer'
```

API
===

Start Match
---

### `Match(CaseExpressions...) -> Function`
Take serveral `CaseExpression`s as arguments and return a function that matches element.
If one argument is not `CaseExpression`, then a `TypeError` is thrown.
If no `CaseExpression` is matched, then an `NoMatchError` is thrown.

Generate CaseExpression
---
### `Is(Patterns..., Function) -> CaseExpression`
### `Is(Pattern, Guard, Function) -> CaseExpression`
The last argument should be a function for matched action. `Is` feeds captured variables to matched action as arguments sequentially.
`Is` also captures Constructor pattern and RegExp pattern.
And the whole matching element is binded to `this` keyword, you can access  by `this.m` in the function.

### `As(Patterns..., Function) -> CaseExpression`
### `As(Pattern, Guard, Function) -> CaseExpression`
The last argument should be a function for matched action. `As` only captures patterns that is generated by calling `parameter`.
So `As` does not capture Constructor pattern and RegExp pattern.
And the whole matching element is binded to `this` keyword, you can access  by `this.m` in the function.
If `parameter` occurs in patterns that is not called, they can be accessed by `this.unnamed` array in the function.

### `On(Patterns..., Function) -> CaseExpression`
### `On(Pattern, Guard, Function) -> CaseExpression`
The last argument should be a function for matched action. `On` only captures patterns that is named parameter like `$('name', Pattern)`
`On` does not capture Constructor pattern and RegExp pattern.
And the whole matching element is binded to `this` keyword, you can access  by `this.m` in the function.
If parameter is not named, they can be accessed by `this.unnamed` array in the function.

Parameter
---
### `parameter() -> Parameter`
### `parameter(Pattern) -> Parameter`
### `parameter(nameString, Pattern) -> NamedParameter`
