gulp = require 'gulp'
gutil = require 'gulp-util'
coffee = require 'gulp-coffee'
changed = require 'gulp-changed'
mocha = require 'gulp-mocha'

SRC = './src/*.coffee'
DEST =  './dest/'
TEST = './test/*.coffee'

gulp.task 'compile', ->
  gulp.src(SRC)
    .pipe(changed DEST)
    .pipe(coffee(bare: true).on('error', gutil.log))
    .pipe(gulp.dest DEST)

gulp.task 'default', ['compile'], ->
  gulp.watch SRC, ['compile']

gulp.task 'test', ['compile'], ->
  gulp.src(TEST)
    .pipe(mocha(
      compiler: 'coffee:coffee-script/register'
      reporter: 'nyan'
    ))
