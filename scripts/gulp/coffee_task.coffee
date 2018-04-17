FileTasks = require './common/file_task.coffee'
rollup = require 'gulp-rollup'

# Coffeescrip 任务
class CoffeeTask extends FileTasks
    constructor: (paths) ->
        super paths,'coffee'

    watch: (commonMethod=false) =>
        super commonMethod
    
    change: (path,stats) =>
        super path,stats
        @copyFile path.path


module.exports = CoffeeTask

