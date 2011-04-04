# Unit Test for loading/parsing of config

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
        
        # Instantiate the DIC *without* a config
        @dic = new DIContainer
        
        do callback
        
    # Loading a config
    'The container loads and parses a config': (test) ->
        test.expect 1
        
        @dic.loadConfig 'test/config/test'
        @dic.get 'byPackageName', (service) ->
            test.notEqual service, null
            do test.done
            
    # Loading a config twice should throw
    'When trying to overwrite an existing key, the container throws an exception': (test) ->
        test.expect 1

        test.throws () -> 
            # Load same config twice, should not work
            @dic.loadConfig 'test/config/test'
            @dic.loadConfig 'test/config/test'
            
        do test.done
            
    # Config loading
    "Configs are loaded from loadConfig keys": (test) ->
        test.expect 1
        
        @dic.loadConfig 'test/config/test'
        @dic.get 'useConfig', (service) ->
            test.deepEqual service, new (require 'test/lib/testPackage')

            do test.done

    # Configs in children
    "Configs are loaded in children from loadConfig keys": (test) ->
        test.expect 1
        
        @dic.loadConfig 'test/config/test'
        @dic.get 'useConfigInChild.configChild', (service) ->
            test.deepEqual service, new (require 'test/lib/testPackage')

            do test.done

    # Circular dependencies
    "Circular dependencies throw an exception": (test) ->
        test.expect 1
        
        @dic.loadConfig 'test/config/test'
        test.throws () =>
            @dic.get 'circularInjection1', (service) ->
        do test.done    