exec = (require 'child_process').exec

build = (callback) ->

    # Quick 'n dirty build
    exec "coffee -o . -c coffee", (err, stdout, stderr) ->
        throw new Error "Could not execute #{cmd}" if err?
        do callback

# Build coffeescript into js
task 'build', 'Build CoffeeScript lib/test into JS lib/test', ->

    console.log 'Building...'
    
    build () ->
        console.log 'Build complete'

# Run nodeunit
task 'test', 'Run tests through nodeunit', ->
    console.log 'Running test suite, building first'
    
    # We need to build first
    build () ->
        console.log 'Build complete, running nodeunit'
        exec "nodeunit test", (err, stdout, stderr) ->
            process.stdout.write stdout