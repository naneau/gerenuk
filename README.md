# Gerenuk

## A Friendly Dependency Injection Container for node.js

Gerenuk - named after the animal - is a [Dependency Injection Container](http://en.wikipedia.org/wiki/Dependency_injection) for node.js. It targets [CoffeeScript](http://coffeescript.org), but should work for regular javascript code as well.

Gerenuk attempts to work around various problems that arise when working with asynchronous code. Its main goal is to facilitate easy application set up and independence of various parts of your code, in accordance with [Demeter's law](http://en.wikipedia.org/wiki/Law_of_Demeter#In_object-oriented_programming).

## Usage

Gerenuk is a Dependency Injection Container (DIC) that can hold various "services". You can retrieve a service from Gerenuk through the `get` method. Every service has a unique identifier, which is passed to `get`.

The container is initialized with a config. The config is a Javascript hash. In this config you can add nodes for every service you'd like to have. It's also possible to add children to nodes, and even to load a config for a node from a config file. The ids for the services are their positions in the config hash, like "foo", and "foo.bar.baz".

    # Sample config
    config = 
    
        # Simple service ("foo") with two params, and a child within a child ("foo.bar.baz")
        foo: 
            require: 'fooPackage'
            params:
                param1: 'param one'
                param2: 'param two'
            
            inject ['foo.param1', 'foo.param2']
            
            # Children of foo
            children:
                bar:
                    children:
                        baz: 'bazPackage'
                        
        # Create an instance of barPackage's Bar and pass the foo service to the constructor
        # This is like new (require 'barPackage').Bar foo
        bar:
            require: 'barPackage'
            instantiate: 'Bar'
            inject: ['foo']
        
        # Instead of creating an instance the `bazFunction` will be called on bazPackage with `foo` and `bar` as params
        baz:
            require: 'bazPackage'
            inject: ['foo', 'bar']
            call: 'bazFunction'

You can pass this configuration to Gerenuk's Container:
    
    # DI Container
    Container = (require 'gerenuk').Container
            
    # Container
    dic = new Container config 

Using this container you can resolve services:

    # Callback gets called with the resolved/injected service
    dic.get 'foo', (service) -> ...

## Asynchronous Operation

One of the more challenging aspects of working with node is asynchronous instantiation of resources. You may, for example, need to connect to a database before you can perform other operations. Gerenuk attempts to aid you with this by supporting asynchronously resolvable services.

In the example of the database connection, you might do the following

    config = 
        connection: 
            require: 'dbPackage'
        
            # Callback on the instance of dbPackage
            callback: (db, callback) ->
                db.connect (error, connection) ->
                    throw "Error!" if error
                    callback connection

Gerenuk keeps track of services it's currently waiting on. This means that when asking for a service twice, before it's ready, will still give you the same object once for both injections.

## Examples

When config is a string, the DIC will act like nothing more than wrapper around require()

    config =
        foo: 'fooPackage'
    
Same as before, but more explicit

    config =
        foo:
            require: 'fooPackage'
        
With `instantiate: true` the container will create a new object directly from the results of the require, which is handy when you have a package directly exporting a single class: `module.exports = SomeClass`.

    config =
        fooInstance:
            require: 'fooPackage'
            instantiate: true
    
When you only want to instantiate a part of the `module.exports` hash, you can name it in instantiate, in this case `bar`:

    # In fooPackage
    module.exports = 
        foo: FooClass
        bar: BarClass
        
    # In DIC config
    config =
        bar:
            require: 'fooPackage'
            instantiate: 'bar'
    
The container starts to become useful as soon as you start to inject services into other services. You can use `inject` to set up an array of services passed to the constructor.

    config = 
        foo:
            require: 'fooPackage'
            inject: ['bar']

You can set params, which you can reference by their name, just like a service. You can combine this with loading a configuration file. You can mix and match params and services in the `inject` array, but params get preference over services.

    config =
        foo:
            require: 'fooPackage'
            params:
                param1: 'foo'
                param2: 'bar'
            inject: ['foo.param1', 'foo.param2']
        
Services can have children, in this case the id of the child is `withChildren.someChild.twoDeep`.

    config =
        foo:
            children:
                bar:
                    # `foo.bar` works as a regular service, as well as parent for `foo.bar.baz`
                    require: 'barPackage'
                    instantiate: true
                
                    children:
                        baz:
                            require: 'bazPackage'
                            instantiate: true
    
It is possible to spread your DI config over multiple files. You can require a package and use as a config for a service.

    config =    
        foo:
            loadConfig: 'fooConfig'
    
Children can load configs just as their parents can

    config =
        foo:
            children:
                bar:
                    loadConfig: 'barConfig'
                
When you don't want to instantiate, but rather call a method from a required package, you can use `call`. The function named in `call` is assumed to return the service.

    config =    
        bar:
            require: 'barPackage'
            call: 'barFunction'
    
Call can also inject, so the following would work like `(require 'fooPackage').someFunction bar, baz`, where foo and baz are resolved services, which can themselves have dependencies, etc.:

    config =    
        # 
        foo:
            require: 'fooPackage'
            inject: ['bar', 'baz']
            call: 'fooFunction'

