FileTasks = require './common/file_task.coffee'
rollup = require 'gulp-rollup'
coffee = require 'gulp-coffee'
gulp=require 'gulp'
sourcemaps=require 'gulp-sourcemaps'
resolve=require 'rollup-plugin-node-resolve'

# Coffeescrip 任务
class CoffeeTask extends FileTasks
    constructor: (paths) ->
        super paths, 'coffee'

    watch: (commonMethod = false) =>
        super commonMethod

    change: (path, stats) =>
        super path, stats
        @compileFileOnChange path.path

    validateCoffee: (filepath) =>

    compileFileOnChange: (filepath, despath = false, minify = false) =>
        destpath = @generateDesPath filepath, despath
        
        filename = @getFilename filepath
            .replace 'coffee','js'
        
        gulp.src filepath
            .pipe sourcemaps.init()
            .pipe coffee
                bare:true
            .pipe(sourcemaps.write())
            .pipe gulp.dest destpath
            .pipe rollup
                entry:'bundle.js'
                allowRealFiles: true
                input:destpath+"/"+filename
                format:'iife'
                plugins: [
                  resolve({
                    jsnext: true,
                    main: true,
                    browser: true
                  })
                ]

            .pipe gulp.dest 'www/js/'

module.exports = CoffeeTask

