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