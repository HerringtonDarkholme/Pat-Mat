gulp = require 'gulp'
gutil = require 'gulp-util'
coffee = require 'gulp-coffee'
changed = require 'gulp-changed'
mocha = require 'gulp-mocha'
browserify = require 'gulp-browserify'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'

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

gulp.task 'browserify', ['compile', 'test'], ->
  gulp.src('./dest/api.js')
    .pipe(browserify())
    .pipe(uglify())
    .pipe(rename('pattern.js'))
    .pipe(gulp.dest('./browser/'))
