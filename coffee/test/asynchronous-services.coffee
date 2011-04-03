# Unit Test for simple dependency resolving
#
# The test case uses configs from coffee/test/config and packages from coffee/test/lib
#
# Note that this file can only be run in compiled form (js) in test/, see the Cakefile

# Nodeunit's test case
testCase = (require 'nodeunit').testCase

# Set up require path (this test should be run from root dir)
require.paths.unshift './'

# Test case for DI Container
module.exports = testCase 

    # Set up DIC with the config
    setUp: (callback) ->
        # require
        DIContainer = (require '../lib/di').Container
        
        # Instantiate the DIC with our config
        @dic = new DIContainer require 'test/config/async'
        
        do callback
        
    # Simple require
    'Callbacks are called and return the service': (test) ->
        test.expect 1
        
        @dic.get 'withInstanceCall', (service) ->
            test.equal service, 'foo'
            do test.done
     
    # Async injection
    'Asynchronously instantiated services are injected into non-async services': (test) ->
        test.expect 1

        @dic.get 'injectedInstanceCall', (service) ->
            test.equal service.services[0], 'foo'
            do test.done