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
  scripts:    './src/index.coffee'
  tests:      './test/**/*.coffee'
  package:    './package.json'
  static:     './static/**/*'
  build:      './build'
  testBuild:  './test/build'

gulp.task 'src', ->
  gulp.src('./src/**.coffee', read: false)
    .pipe(browserify({
      transform:  ['coffeeify'],
      extensions: ['.coffee']
    }))
    .pipe(concat('app.js'))
    .pipe(gulp.dest('./build/'))
    .pipe(refresh(lrServer))

gulp.task 'src-app-test', ->
  gulp.src('./src/**.coffee', read: false)
    .pipe(browserify({
      transform:  ['coffeeify'],
      extensions: ['.coffee']
    }))
    .pipe(concat('app.js'))
    .pipe(gulp.dest('./test/build/'))
    .pipe(refresh(lrServer))

gulp.task 'src-test', ->
  gulp.src('./test/**.coffee', read: false)
    .pipe(browserify({
      transform:  ['coffeeify'],
      extensions: ['.coffee']
    }))
    .pipe(concat('tests.js'))
    .pipe(gulp.dest('./test/build/'))
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

gulp.task 'test_serve', ->
  http.createServer(ecstatic(root: paths.testBuild)).listen(8223)
  lrServer.listen(36729)

gulp.task 'watch', ->
  gulp.watch(paths.scripts, ['src'])
  gulp.watch(paths.static,  ['css', 'static'])

# TODO: This won't cause the proc to fail while running a normal test. The
# @emit('end') is to allow test:watch to work for the time being
#gulp.task 'test', ->
  #gulp.src(paths.tests, read: false)
    #.pipe(mocha(reporter: 'spec', timeout: 200))
    #.on 'error', (err) ->
      #console.log(err.toString())
      #@emit('end')

  #gulp.src(paths.tests, read: false)
    #.pipe(mocha(reporter: 'spec', timeout: 200))
    #.on 'error', (err) ->
      #console.log(err.toString())
      #@emit('end')

gulp.task 'build', ['src', 'static']

gulp.task 'test', ['src-app-test', 'src-test', 'test_serve']

gulp.task 'test_build', ['src-app-test', 'src-test']

gulp.task 'test:watch', ->
  gulp.watch([paths.tests, paths.scripts], ['test_build'])

gulp.task 'default', ['src', 'static', 'watch', 'serve']
