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
        @dic = new DIContainer require 'test/config/test'
        
        do callback
        
    # Simple require
    'Packages are resolved and required by name, without instantiating': (test) ->
        test.expect 2
        
        @dic.get 'byPackageName', (service) ->
        
            test.notEqual service, undefined, 'Service should not be undefined'
            test.equal service, require 'test/lib/testPackage', 'Service should be equal to the require it was supposed to do'
            
            do test.done
            
    # Failure
    'Packages that can not be resolved throw an exception': (test) ->
        test.expect 1
        test.throws () -> @dic.get 'packageDoesNotExist'
        do test.done
        
    # Require by config.require
    'Packages are required by config.require, without instantiating': (test) ->
        test.expect 2
    
        @dic.get 'withRequire', (service) ->
    
            test.notEqual service, undefined, 'Service should not be undefined'
            test.equal service, require 'test/lib/testPackage', 'Service should be equal to the require it was supposed to do'
        
            do test.done
    
    # Instantiate directly
    'Services are instantiated': (test) ->
        test.expect 1
        
        @dic.get 'withInstantiate', (service) ->
            test.deepEqual service, new (require 'test/lib/testPackage')
            do test.done
    
    # Instantiate a named part of the package
    'Services are instantiated by name': (test) ->
        test.expect 1
        
        @dic.get 'withNamedInstantiate', (service) ->
            test.deepEqual service, new (require 'test/lib/testPackage2').test1
            do test.done
            
    # This is where it starts to get interesting
    "Injected service equals normal initialization of same service": (test) ->
        test.expect 1
        
        @dic.get 'withInject', (service) ->
            test.deepEqual service.services[0], new (require 'test/lib/testPackage')
            do test.done
            
    # Params should resolve
    "Params are injected": (test) ->
        test.expect 2

        @dic.get 'withParams', (service) ->
            test.equal service.services[0], 'foo'
            test.equal service.services[1], 'bar'
        
            do test.done
    
    # Params next to injection
    "Params resolve next to services": (test) ->
        test.expect 3
    
        @dic.get 'withParamsAndInject', (service) ->
            test.equal service.services[0], 'foo'
            test.equal service.services[1], 'bar'
            test.deepEqual service.services[2], new (require 'test/lib/testPackage')
            do test.done
            
    # Children
    "Params resolve over children": (test) ->
        test.expect 1

        @dic.get 'withParamAndChildWithSameName.test', (service) ->
            test.equal service, 'foo'
            do test.done

    # Children
    "Children resolve": (test) ->
        test.expect 1
        
        @dic.get 'withChildren.someChild.twoDeep', (service) ->
            test.deepEqual service, new (require 'test/lib/testPackage')
            do test.done
            
    # Children
    "Parents of children resolve as regular services": (test) ->
        test.expect 1

        @dic.get 'withChildren.someChild', (service) ->
            test.deepEqual service, new (require 'test/lib/testPackage2').test1
            do test.done
    
    # Call
    "Calls are executed without injection": (test) ->
        test.expect 1
        @dic.get 'withCall', (result) ->
            test.equal result, 'baz'
            do test.done

    # Call
    "Calls are executed with injection": (test) ->
        test.expect 1
        @dic.get 'withCallAndInject', (result) ->
            test.equal result, 'baz'
            do test.done
            
    # Config loading
    "Configs are loaded": (test) ->
        test.expect 1
        
        @dic.get 'useConfig', (service) ->
            test.deepEqual service, new (require 'test/lib/testPackage')
            
            do test.done
    
    # Configs in children
    "Configs are loaded in children": (test) ->
        test.expect 1

        @dic.get 'useConfigInChild.configChild', (service) ->
            test.deepEqual service, new (require 'test/lib/testPackage')

            do test.done