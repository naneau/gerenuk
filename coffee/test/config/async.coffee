# # Test configuration
# 
# Packages used here reside in coffee/test/lib
module.exports = 
    
    # You can use a callback to do async tasks on an instantiated service
    withCallback: 
        require: 'test/lib/testAsync'
        
        # Callback on the instance 
        callback: (async, callback) ->
            async.connect (error, someVal) ->
                throw "Error!" if error
                callback someVal
        
    withSlowCallback:
        require: 'test/lib/testAsync'
        
        # Callback on the instance 
        callback: (async, callback) ->
            
            fn = () -> callback do Math.random
            setTimeout fn, 100
            
    withCallbackInjection:
        params: 
            bar: 'bar',
            baz: 'baz'
        
        # withCallback should be "foo"
        injectCallback: ['withCallback', 'withCallbackInjection.bar', 'withCallbackInjection.baz']
        
        # Callback gets 3 params
        callback: (foo, bar, baz, callback) ->
            fn = () -> callback {foo, bar, baz}
            process.nextTick fn
                
        