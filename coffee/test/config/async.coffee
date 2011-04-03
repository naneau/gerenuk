# # Test configuration
# 
# Packages used here reside in coffee/test/lib
module.exports = 
    
    # When config is a string, the DIC is nothing more than wrapper around require()
    byPackageName: 'test/lib/testPackage'
    
    # Sometimes, you need to call a function on an object, to get a service, for instance to connect to a database
    # instanceCall lets you do this
    withCallback:
        require: 'test/lib/testAsync'
        instantiate: true
        
        # Call on the instance, that is expected to return the actual service for `withCallback`
        instanceCall: 
            call: 'connect'
            callback: (connected, someService) -> 
                # You are expected to throw an exception if you can't connect
                throw "Could not connect" if not connected
                someService
                
    # You can inject a callback-based service into a regular service
    injectedCallback:
        require: 'test/lib/testPackage'
        inject: ['withCallback']