class Async
    
    constructor: (@services...) -> null
    
    # Connect, will call callback (connected) after a second
    connect: (callback) ->
        fn = () ->callback true, 'foo'
        setTimeout fn, 1
    
    # Failing connect
    failingConnect: (callback) ->
        fn = () -> callback false
        setTimeout fn, 1
        
module.exports = Async