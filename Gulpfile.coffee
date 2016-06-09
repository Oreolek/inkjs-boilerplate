watchify    = require('watchify')
browserify  = require('browserify')
browserSync = require('browser-sync')
gulp        = require('gulp')
source      = require('vinyl-source-stream')
gutil       = require('gulp-util')
coffeify    = require('coffeeify')
coffee      = require("gulp-coffee")
uglify      = require('gulp-uglify')
buffer      = require('vinyl-buffer')
zip         = require('gulp-zip')
concat      = require('gulp-concat')

reload = browserSync.reload

html = (target) ->
  return () ->
    return gulp.src(['html/index.html', 'html/en.html']).pipe(gulp.dest(target))

# Images
img = (target) ->
  return () ->
    return gulp.src(['img/*.png', 'img/*.jpeg', 'img/*.jpg']).pipe(gulp.dest(target))

# Audio assets
audio = (target) ->
  return () ->
    return gulp.src(['audio/*.mp3']).pipe(gulp.dest(target))

# Ink files
ink = (target) ->
  return () ->
    return gulp.src(['game/*.json']).pipe(gulp.dest(target))

gulp.task('html', html('./build'))
gulp.task('img', img('./build/img'))
gulp.task('audio', audio('./build/audio'))
gulp.task('ink', ink('./build'))

bundler = watchify(browserify({
  entries: ["./build/game/main.coffee"]
  debug: true
  transform: [coffeify]
}))

bundle = () ->
  return bundler.bundle()
    .on('error', gutil.log.bind(gutil, 'Browserify Error'))
    .pipe(source('bundle.js'))
    .pipe(gulp.dest('./build/game'))

gulp.task('concatCoffee', () ->
  return gulp.src([
      './game/game.coffee',
    ]).pipe(concat('./main.coffee')).pipe(gulp.dest('./build/game'))
)

gulp.task('coffee', ['concatCoffee'], bundle)

bundler.on('update', bundle)
bundler.on('log', gutil.log)

gulp.task('build', ['html', 'ink', 'img', 'coffee', 'audio'])

gulp.task('serve', ['build'], () ->
  browserSync({
    server: {
      baseDir: 'build'
    }
  })

  gulp.watch(['./html/*.html'], ['html'])
  gulp.watch(['./game/*.json'], ['ink'])
  gulp.watch(['./img/*.png', './img/*.jpeg', './img/*.jpg'], ['img'])
  gulp.watch(['./game/*.coffee'], ['coffee']);

  gulp.watch(
    ['./build/game/bundle.js', './build/img/*', './build/index.html'],
    browserSync.reload)
)

gulp.task('html-dist', html('./dist'))
gulp.task('img-dist', img('./dist/img'))
gulp.task('audio-dist', audio('./dist/audio'))
gulp.task('ink-dist', ink('./dist'))
gulp.task('legal-dist', () ->
  return gulp.src(['LICENSE.txt'])
         .pipe(gulp.dest("./dist"))
)

distBundler = browserify({
  debug: false,
  entries: ['./build/game/main.coffee'],
  transform: ['coffeeify']
})

gulp.task('coffee-dist', ['concatCoffee'], () ->
  return distBundler.bundle()
        .pipe(source('bundle.js'))
        .pipe(buffer())
        .pipe(uglify())
        .on('error', gutil.log)
        .pipe(gulp.dest('./dist/game'))
)

gulp.task('dist', [
  'html-dist',
  'ink-dist',
  'img-dist',
  'coffee-dist',
  'audio-dist',
  'legal-dist'
])

gulp.task('zip', ['dist'], () ->
  return gulp.src('dist/**')
    .pipe(zip('dist.zip'))
    .pipe(gulp.dest('.'))
)
