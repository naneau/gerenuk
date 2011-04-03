# Gerenuk

## A Friendly Dependency Injection Container for node.js

Gerenuk - named after the animal - is a [Dependency Injection Container](http://en.wikipedia.org/wiki/Dependency_injection) for node.js. It targets [CoffeeScript](http://coffeescript.org), but should work for regular javascript code as well.

## Usage

The container is initialized with a config:

    Container = require 'gerenuk'
    
    # Sample config
    config = 
        # When config is a string, the DIC is nothing more than wrapper around require()
        byPackageName: 'test/lib/testPackage'
        
        # Require a package like the before, but pass other services, this implicitly assumes instantiation
        # Like: new (require 'somePackage') injectedService1, injectedService2, ...
        withInject:
            require: 'test/lib/testPackage'
            inject: ['byPackageName']
    
    # Container
    dic = new Container config 

    dic.get 'withInject', (service) -> ...

## Examples

When config is a string, the DIC will act like nothing more than wrapper around require()

    config =
        byPackageName: 'test/lib/testPackage'
    
Same as before, but more explicit

    config =
        withRequire:
            require: 'test/lib/testPackage'
        
With instantiate

    config =
        withInstantiate:
            require: 'test/lib/testPackage'
            instantiate: true
    
Passing inject, will do `new (require 'test/lib/testPackage2').test1`

    config =
        withNamedInstantiate:
            require: 'test/lib/testPackage2'
            instantiate: 'test1'
    
Require a package like the before, but pass other services, this implicitly assumes instantiation, like: `new (require 'somePackage') injectedService1, injectedService2`

    config = 
        withInject:
            require: 'test/lib/testPackage'
            inject: ['withInstantiate']

You can set params, which you can reference by their name, just like a service. You can use `withParams.param1` from everywhere, just like a service.

    config =
        withParams:
            require: 'test/lib/testPackage'
            params:
                param1: 'foo'
                param2: 'bar'
            inject: ['withParams.param1', 'withParams.param2']
        
You can mix and match params and services, but params get preference over services

    config =
        withParamsAndInject:
            require: 'test/lib/testPackage'        
            params:
                param1: 'foo'
                param2: 'bar'
            inject: ['withParams.param1', 'withParams.param2', 'withInstantiate']
    
We can indent and have children, in this case the id is "withChildren.someChild.twoDeep"

    config =
        withChildren:
            children:
                someChild:
                    # `withChildren.someChild` works as a regular service, as well as parent for twoDeep
                    require: 'test/lib/testPackage2'
                    instantiate: 'test1'
                
                    children:
                        twoDeep:
                            require: 'test/lib/testPackage'
                            instantiate: true
    
            
When a child and a param with the same name are set the DIC will pick the param over the child

    config =    
        # withParamAndChildWithSameName.test will resolve to 'foo'
        withParamAndChildWithSameName:
            children:
                test: 'test/lib/testPackage2'
            params:
                test: 'foo'
            
Require a package, use as config for this item, the package will be used as the root of this item, and can reference any and all services

    config =    
        useConfig:
            loadConfig: 'test/config/included'
    
        # Children can load configs just as their parents can
        useConfigInChild:
            children:
                configChild:
                    loadConfig: 'test/config/included'
                
Call will not instantiate, but rather call a function from the required package

    config =    
        withCall:
            require: 'test/lib/testPackage2'
            call: 'testFunction'
    
Call can also inject:

    config =    
        # (require 'test/lib/testPackage2').someFunction services...
        withCallAndInject:
            require: 'test/lib/testPackage2'
            inject: ['byPackageName', 'useConfig']
            call: 'testFunction'

