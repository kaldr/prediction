gulp = require 'gulp'
del = require 'del'
stylus = require 'gulp-stylus'
concat = require 'gulp-concat'
argv = require('yargs').argv
cleanCSS = require 'gulp-clean-css'
sourcemaps = require 'gulp-sourcemaps'
nib = require 'nib'
serve = require 'gulp-serve'
pug = require 'gulp-pug'
browserSync = require('browser-sync').create()
inject = require 'gulp-inject'
reload = browserSync.reload
chalk=require 'chalk'
exit = require 'gulp-exit'
moment=require 'moment'
ignore=require 'gulp-ignore'
dom=require 'gulp-dom'
insert=require 'gulp-insert'
coffee=require 'gulp-coffee'
browserify=require 'gulp-browserify-globs'
uglify=require 'gulp-uglify'
inject=require 'gulp-inject'
source=require 'vinyl-source-stream'
glob=require 'glob'
rename=require 'gulp-rename'
coffeeify=require 'coffeeify'

paths =
    styles: 'src/**/*.styl'
    styleDest:'www/css'
    jsDest:'www/js'
    inject:['www/css/**/*.css','www/js/**/*.js']
    dist: 'www'
    pugs: ['src/**/*.pug']
    pugsToCompile: ['src/**/*.pug', '!src/**/templates/**/*.pug']
    projects:['src/projects/**/index.pug']
    animationsCoffee:['src/animations/js/**/*.coffee']
    animationsStylus:['src/animations/css/**/*.styl']
    coffee:['src/animations/renderers/*.js','src/animations/controls/*.js','src/**/*.coffee','src/*.coffee']
    # js:['src/animations/renderers/*.js']
    # coffeecache:['www/coffeecache/**/*.js','www/coffeecache/*.js']

appUrl = 'splendidlocal.iflying.com'
appUrl=argv.url if argv.url

currentTitle=""

currentTime=()->
    chalk.cyan "["+moment().format 'HH:mm:ss'+'] '

domManipulate=()->
    title=@querySelectorAll("body hidden")
    @querySelectorAll("head title")[0].innerHTML=title.innerHTML
    @

injectTransform=(filepath)->
    if filepath.indexOf(".js")>=0
        "<script type='text/javascript' src='"+filepath.replace('www/','')+"'></script>"
    else if filepath.indexOf(".css")>=0
        "<link rel='stylesheet' href='"+filepath.replace('www/','')+"'/>"

gulp.task 'compile_js:dev',['compile_coffee:dev'],(options)->

gulp.task 'coffee_browserify:dev',(options)->
    # compileCoffeeFile()
    browserify(paths.coffee,{
            debug:true
            transform:[coffeeify]
            # uglify:true
    })
        # .pipe rename 'app.js'
        .pipe gulp.dest paths.jsDest

# compileJSFile=(path,stats)->
#     paths.js.map (pattern)->
#         glob pattern,(err,files)->
#             bundle=browserify
#                 extensions:['.js']
#                 debug:true
#             # bundle.transform 'uglifyify',{global:true}
#             tasks=files.map (entry)->
#                 bundle.add entry
#             bundle.bundle()
#                 .pipe source 'bundle.js'
#                 # .pipe rename 'app.js'
#                 .pipe gulp.dest paths.jsDest
# gulp.task 'js_browserify:dev',(options)->
    # compileJSFile()
    

# jsWatcher=gulp.watch paths.js
# jsWatcher.on 'change',compileJSFile
# jsWatcher.on 'add',(path,stats)->
#     jsWatcher.add path.path
#     compileJSFile path,stats

gulp.task 'compile_coffee:dev',['coffee_browserify:dev'],(options)->
    # gulp.src paths.coffee
    #     .pipe sourcemaps.init()
    #     .pipe coffee({bare:true})
    #     .pipe concat 'app.js'
    #     .pipe sourcemaps.write '.'
    #     .pipe gulp.dest 'www/js'


gulp.task 'compile_coffee:prd',(options)->
    gulp.src paths.coffee,{read:false}
        .pipe browserify
            insertGlobals : true
            transform:['coffeeify']
            extensions:['.coffee']
        .pipe concat 'app.js'
        .pipe uglify()
        .pipe gulp.dest paths.jsDest

gulp.task 'compact_js',(options)->
    gulp.src 'www/js/app.js',{read:true}
        # .pipe concat 'app.min.js'
        # .pipe rename 'app.min.js'
        .pipe uglify()
        .pipe gulp.dest 'www/js/'

compileCoffeeFile=(path,stats)->
    bundle=browserify
        extensions:['.coffee']
        debug:true
    bundle.transform coffeeify,
        bare:true
        header: true 
    paths.coffee.map (pattern)->
        glob pattern,(err,files)->
            
            # bundle.transform 'uglifyify',{global:true}
            tasks=files.map (entry)->
                bundle.add entry
            
    bundle.bundle()
        .pipe source 'app.js'
        # .pipe rename 'app.js'
        .pipe gulp.dest paths.jsDest

coffeeWatcher=gulp.watch paths.coffee,['compile_coffee:dev']
# coffeeWatcher.on 'change',compileCoffeeFile
# coffeeWatcher.on 'add',(path,stats)->
#     coffeeWatcher.add path.path
#     compileCoffeeFile path,stats


gulp.task 'resource',()->
    gulp.src ['resources/**/*.*']
        .pipe gulp.dest 'www/resources'

copyResource=(path)->
    gulp.src path.path
        .pipe gulp.dest 'www/resources/'

resourceWatcher=gulp.watch 'resources/**/*.*',copyResource


gulp.task 'compile_pug', (options) ->
    gulp.src paths.pugsToCompile
        .pipe pug
            doctype:'html'
        .pipe insert.wrap '<html><head><title>Splendid</title>\n<!-- inject:css -->\n<!-- endinject -->\n</head><body>','\n<!-- inject:js -->\n<!-- endinject -->\n</body></html>'
        .pipe inject gulp.src(paths.inject,{read:false}),{relative:false,transform:injectTransform}
        # .pipe dom domManipulate
        .pipe gulp.dest paths.dist

pugWatcher = gulp.watch paths.pugs
pugCompiler=(path,stats)->
    dest=path.path.replace /[^\/]+.pug/g,''    
    if path.path.indexOf('templates/')>=0
        gulp.start 'compile_pug'
    else
        gulp.src path.path
            .pipe pug
                doctype:'html'
            .pipe insert.wrap '<html><head><title></title><!-- inject:css --><!-- endinject --></head><body>','<!-- inject:js --><!-- endinject --></body></html>'
            # .pipe dom domManipulate
            .pipe inject gulp.src(paths.inject,{read:false}),{relative:false,transform:injectTransform}
            .pipe gulp.dest dest.replace 'src','www'
pugWatcher.on 'change',pugCompiler
pugWatcher.on 'add',(path,stats)->
    pugWatcher.add path.path
    pugCompiler path,stats

gulp.task 'compile_stylus', (options) ->
    gulp.src paths.styles
        .pipe sourcemaps.init()
        .pipe stylus
            paths: ['node_modules'],
            import: ['jeet/stylus/jeet', 'stylus-type-utils', 'nib'],
            use: [nib()],
            'include css': true
        .pipe concat 'styles.css'
        .pipe sourcemaps.write '.'
        .pipe gulp.dest paths.styleDest

stylusWatcher=gulp.watch paths.styles,['compile_stylus']



gulp.task 'build:prd', (options) ->

gulp.task 'build:dev',(options)->

gulp.task 'serve', (options) ->
    browserSync.init
      host: appUrl,
      open: 'external',
      files:['www/**/*']
      server:
        baseDir:'www'
        index:'index.html'
      port: if argv.port then argv.port else '4000'
      browser: 'google chrome',
      url: if argv.port then appUrl + ':'+argv.port else appUrl+":4000"

gulp.task 'build', ['build:dev']

gulp.task 'watch', (options) ->

gulp.task 'showHelp',(options)->
    console.log currentTime()
    console.log currentTime()+ chalk.magenta '-------------------------------------------'
    console.log currentTime()
    console.log currentTime() + chalk.cyan '可以通过gulp执行如下任务：'
    console.log currentTime()
    console.log currentTime() + chalk.magenta('gulp\tbuild\t\t')+chalk.cyan '构建开发环境的项目'
    console.log currentTime() + chalk.magenta('gulp\tbuild:prd\t')+chalk.cyan '构建生产环境的项目，并打包。如果设置了服务器参数，可以直接上传到服务器。'
    console.log currentTime() + chalk.magenta('gulp\twatch\t\t')+chalk.cyan '构建项目，运行服务，并监听文件变化'
    console.log currentTime() + chalk.magenta('gulp\tserve\t\t')+chalk.cyan '运行服务，不监控'
    console.log currentTime()
    console.log currentTime() + '参数：'
    console.log currentTime()
    console.log currentTime() + "\t--port\t程序运行的端口\t默认4000"
    console.log currentTime() + "\t--url\t程序运行的网址\t默认splendidlocal.iflying.com"
    console.log currentTime()
    console.log currentTime()+ chalk.magenta '-------------------------------------------'
    console.log currentTime()



gulp.task 'default',['showHelp','compile_stylus','compile_js:dev','compile_pug','serve']
   