# Simple class, will store @foo = 'bar' and all services passed to the constructor
class Test

    constructor: (@services...) ->
        @foo = 'bar'

module.exports = Test
