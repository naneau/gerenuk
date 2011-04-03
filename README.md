# Gerenuk

## A Friendly Dependency Injection Container for node.js

Gerenuk - named after the animal - is a [Dependency Injection Container](http://en.wikipedia.org/wiki/Dependency_injection) for node.js. It targets [CoffeeScript](http://coffeescript.org), but should work for regular javascript code as well.

## Usage

The container is initialized with a config:

    # Sample config
    config = 
    
        # Simple service with two params
        foo: 
            require: 'fooPackage'
            params:
                param1: 'param one'
                param2: 'param two'
            
            inject ['foo.param1', 'foo.param2']
        
        # Create an instance of barPackage's Bar and pass the foo service to the constructor
        # This is like new (require 'barPackage').Bar foo
        bar:
            require: 'barPackage'
            instantiate: 'Bar'
            inject: ['byPackageName']
        
        # Instead of creating an instance the `bazFunction` will be called on bazPackage with `foo` and `bar` as params
        baz:
            require: 'bazPackage'
            inject: ['foo', 'bar']
            call: 'bazFunction'

You can pass this configuration to Gerenuk's Container
    
    # DI Container
    Container = (require 'gerenuk').Container
            
    # Container
    dic = new Container config 

    # Callback gets called with the resolved/injected service
    dic.get 'foo', (service) -> ...

## Asynchronous Operation

One of the more challenging aspects of working with node is asynchronous instantiation of resources. You may, for example, need to connect to a database before you can perform other operations. Gerenuk attempts to aid you with this by supporting asynchronously resolvable services.

In the example of the database connection, you might do the following

    config = 
        connection: 
            require: 'dbPackage'
        
            # Callback on the instance 
            callback: (db, callback) ->
                db.connect (error, connection) ->
                    throw "Error!" if error
                    callback connection

## Examples

When config is a string, the DIC will act like nothing more than wrapper around require()

    config =
        byPackageName: 'fooPackage'
    
Same as before, but more explicit

    config =
        withRequire:
            require: 'fooPackage'
        
With `instantiate: true` the container will create a new object directly from the results of the require, which is handy when you have a package directly exporting a single class: `module.exports = SomeClass`.

    config =
        withInstantiate:
            require: 'fooPackage'
            instantiate: true
    
When you only want to instantiate a part of the `module.exports` hash, you can name it in instantiate, in this case `bar`:

    # In fooPackage
    module.exports = 
        foo: SomeClass
        bar: SomeOtherClass
        
    # In DIC config
    config =
        withNamedInstantiate:
            require: 'fooPackage'
            instantiate: 'bar'
    
The container starts to become useful as soon as you start to inject services into other services. You can use `inject` to create an array of services passed to the constructor.

    config = 
        withInject:
            require: 'fooPackage'
            inject: ['withInstantiate']

You can set params, which you can reference by their name, just like a service. You can combine this with loading a configuration file. You can mix and match params and services in the `inject` array, but params get preference over services.

    config =
        withParams:
            require: 'fooPackage'
            params:
                param1: 'foo'
                param2: 'bar'
            inject: ['withParams.param1', 'withParams.param2']
        
Services can have children, in this case the id of the child is `withChildren.someChild.twoDeep`.

    config =
        withChildren:
            children:
                someChild:
                    # `withChildren.someChild` works as a regular service, as well as parent for twoDeep
                    require: 'fooPackage'
                    instantiate: 'bar'
                
                    children:
                        twoDeep:
                            require: 'barPackage'
                            instantiate: true
    
It is possible to spread your DI config over multiple files. You can require a package and use as a config for a service.

    config =    
        useConfig:
            loadConfig: 'fooConfig'
    
        # Children can load configs just as their parents can
        useConfigInChild:
            children:
                configChild:
                    loadConfig: 'test/config/included'
                
When you don't want to instantiate, but rather call a method from a required package, you can use `call`. The function named in `call` is assumed to return the service.

    config =    
        bar:
            require: 'barPackage'
            call: 'barFunction'
    
Call can also inject:

    config =    
        # (require 'barPackage').someFunction foo, bar
        bar:
            require: 'barPackage'
            inject: ['foo', 'baz']
            call: 'barFunction'

