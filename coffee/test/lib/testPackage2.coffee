# Test package
class Test
    constructor: (@args...) ->
        @foo = 'baz'

        #console.log 'Test instantiated'
        #console.log @args
        
# Export hash
module.exports = 

    # Aliases for the class
    test1: Test
    test2: Test
    
    # Function to be called, will instantiate Test, and return its foo
    testFunction: (args...) -> 
        instance = new Test args...
        return instance.foo
