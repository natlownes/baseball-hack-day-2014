gulp = require 'gulp'

fs         = require 'fs'
http = require 'http'

browserify = require 'gulp-browserify'
concat     = require 'gulp-concat'
ecstatic   = require 'ecstatic'
gutil      = require 'gulp-util'
less       = require 'gulp-less'
lrServer   = require('tiny-lr')()
mocha      = require 'gulp-mocha'
refresh    = require 'gulp-livereload'
sass       = require 'gulp-sass'

paths =
  scripts:  './src/**/*.coffee'
  tests:    './test/**/*.coffee'
  package:  './package.json'
  static:   './static/**/*'
  build:    './build'

gulp.task 'src', ->
  gulp.src('./src/index.coffee', read: false)
    .pipe(browserify({
      transform:  ['coffeeify'],
      extensions: ['.coffee']
    }))
    .pipe(concat('app.js'))
    .pipe(gulp.dest('./build/'))
    .pipe(refresh(lrServer))

gulp.task 'static', ->
  gulp.src(paths.static)
    .pipe(gulp.dest(paths.build))
    .pipe(refresh(lrServer))

gulp.task 'css', ->
  gulp.src('./static/*.scss')
    .pipe(sass())
    .pipe(gulp.dest("#{paths.build}"))
    .pipe(refresh(lrServer))

gulp.task 'serve', ->
  http.createServer(ecstatic(root: paths.build)).listen(8222)
  lrServer.listen(35729)

gulp.task 'watch', ->
  gulp.watch(paths.scripts, ['src'])
  gulp.watch(paths.static,  ['css', 'static'])

# TODO: This won't cause the proc to fail while running a normal test. The
# @emit('end') is to allow test:watch to work for the time being
gulp.task 'test', ->
  gulp.src(paths.tests, read: false)
    .pipe(mocha(reporter: 'spec', timeout: 200))
    .on 'error', (err) ->
      console.log(err.toString())
      @emit('end')

gulp.task 'test:watch', ['test'], ->
  gulp.watch([paths.tests, paths.scripts], ['test'])

gulp.task 'build', ['src', 'static']

gulp.task 'default', ['src', 'static', 'watch', 'serve']
