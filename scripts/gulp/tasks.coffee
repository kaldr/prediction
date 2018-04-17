gulp = require 'gulp'
CoffeeTask = require './coffee_task.coffee'

coffeeTask = new CoffeeTask ['src/**/*.coffee','src/*.coffee']

gulp.task 'default', () ->
    coffeeTask.watch()

