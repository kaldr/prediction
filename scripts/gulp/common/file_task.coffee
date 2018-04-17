gulp = require 'gulp'
moment = require 'moment'
chalk = require 'chalk'
glob=require 'glob'
_=require 'lodash'
###*
    * 基础文件任务
    *
    * 包含如下功能：
    * 【1】文件的监控并编译为一个文件
    * 【2】把glob路径的文件转换为一个文件
    * 【3】复制文件
    *
###
class FileTask
    ###*
     * 输出日志
     * @param  {string} str 字符串
     * @return {无}     
    ###
    log: (str) =>
        console.log "["+chalk.gray(moment().format("HH:mm:ss"))+"]"+" " + str
    ###*
        * 构造方法
        * @param { array } @paths glob路径数组
        * @return { 无 }
    ###
    constructor: (@paths,@ext=false) ->
    ###*
        * 监控
        * @return { 无 }
    ###
    watch: (commonMethod = false) =>
        if commonMethod
            if commonMethod instanceof Array
                @watcher = gulp.watch @paths, commonMethod
            else if typeof commonMethod == 'string'
                @watcher = gulp.watch @paths, [commonMethod]
        else
            @watcher = gulp.watch @paths
            @watcher.on 'add', @add
                .on 'change', @change
                .on 'unlink', @remove
                .on 'addDir', @addDir
                .on 'unlinkDir', @unlinkDir
            
    unlinkDir: (path, stats) =>
        ext=""
        if @ext then ext="*."+@ext

        glob path.path+ext,{},(er,files)=>
            console.log path.path+ext
            files.map (file)=>
                @watcher.unwatch file
            @watcher.unwatch path.path


    addDir: (path, stats) =>
        ext=""
        if @ext then ext="*."+@ext
        glob path.path+ext,{},(er,files)=>
            files.map (file)=>
                @watcher.add file
            @watcher.add path.path


    add: (path, stats) =>
        @watcher.add path.path


    change: (path, stats) =>
        @log chalk.cyan(path.path) + " " + chalk.magenta path.type


    remove: (path, stats) =>
        @unlinkDir path,stats
        @watcher.unwatch path.path
        


    watchAndCompileToOneFile: (glob, despath) =>

    compileToOneFile: (glob, despath, minify = false) =>

    compileFile: (filepath, despath, minify = false) =>

    ###*
     * 生成文件路径
     * @param  {[type]} path          [description]
     * @param  {[type]} despath=false [description]
     * @return {[type]}               [description]
    ###
    generateDesPath:(path,despath=false)=>
        if despath
            finalpath=''
            despathstrs=despath.split '/'
            _.map despathstrs,(s,i)=>
                if s.indexOf('.')==-1
                    finalpath+=s+'/'
            finalpath
        else
            despath=''
            desstrs=path.split '/'
            _.map desstrs,(s,i)=>
                if s=='src'
                    desstrs[i]='www'
                if s.indexOf(".")==-1
                    despath+=desstrs[i]+'/'
            despath
    
    ###*
     * 复制文件
     * 如果没有指定目标文件夹，那么，会根据源文件路径自动生成
     * 默认复制到www的相同相对路径下
     * 
     * @param  {string} filepath      源文件路径
     * @param  {string} despath=false 目标文件路径
     * @return {无}               无
    ###
    copyFile: (filepath, despath=false) =>
        despath=@generateDesPath filepath,despath
        gulp.src filepath
            .pipe gulp.dest despath
        
module.exports = FileTask
