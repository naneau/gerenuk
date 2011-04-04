# Gerenuk

## A Friendly Dependency Injection Container for node.js

Gerenuk - named after the animal - is a [Dependency Injection Container](http://en.wikipedia.org/wiki/Dependency_injection) for node.js. It targets [CoffeeScript](http://coffeescript.org), but should work for regular javascript code as well.

Gerenuk attempts to work around various problems that arise when working with asynchronous code. Its main goal is to facilitate easy application set up and independence of various parts of your code, in accordance with [Demeter's law](http://en.wikipedia.org/wiki/Law_of_Demeter#In_object-oriented_programming).

## Usage

Gerenuk is a Dependency Injection Container (DIC) that can hold various "services". You can retrieve a service from Gerenuk through the `get` method. Every service has a unique identifier, which is passed to `get`. Services can have dependencies on other services, which get injected into their constructor or passed to a function you specify.

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
        
        # Instead of creating an instance the `bazFunction` will be called on bazPackage with the `foo` and `bar` services as params
        baz:
            require: 'bazPackage'
            inject: ['foo', 'bar']
            call: 'bazFunction'

You can pass this configuration to Gerenuk's Container:
    
    # DI Container
    Container = (require 'gerenuk').Container
            
    # Container
    dic = new Container config 

Using the container you can resolve services:

    dic.get 'foo', (service) -> ... your code ...

## Putting You Configuration In Files

When setting up your application, it is often useful to put your DI config into a configuration file (or files). Gerenuk supports this through the `loadConfig()` method. The config loaded through `loadConfig()` will be added to any existing configuration. It does *not* do a deep merge, however, and will throw an exception if you try to overwrite an existing config key.

    dic = new Container
    dic.loadConfig 'yourConfigFile'

The contents of `yourConfigFile.coffee` would be like:

    module.exports = 
        foo: 'fooPackage'
        bar: 
            require 'barPackage'
            instantiate: 'bar'
        ...etc...

You can also use `loadConfig` inside of a config item, replacing its contents with the loaded config. This has the disadvantage that the items loaded through this do not explicitly know the name of the node they are in, making it hard(er) to set up references.

    dic = new Container 
        foo: 
            loadConfig: 'yourConfigFile'

## Asynchronous Operation

One of the more challenging aspects of working with node is asynchronous instantiation of resources. You may, for example, need to connect to a database before you can perform other operations. Gerenuk attempts to aid you with this by supporting asynchronously resolvable services.

### Callbacks In Services

In the example of the database connection, you might do the following

    config = 
        connection: 
            require: 'dbPackage'
        
            # Callback on the instance of dbPackage
            callback: (db, callback) ->
                db.connect (error, connection) ->
                    throw "Error!" if error
                    callback connection

Gerenuk keeps track of services it's currently waiting on. This means that when asking for a service twice, before it's ready, will still give you the same object, once for both injections.

### EventEmitter Based Services

Another frequently encountered pattern is that the resource you're working with emits an event when it's ready for duty. When you have to wait for such an event to happen you can listen to it in the callback. Note that in this case "foo" will be instantiated, by the container. The callback waits for it to emit "connected", then passes the instance of "foo" back. Any services that are injected with foo can then assume it's connected.

    config = 
        foo: 
            require: 'fooPackage'
            instantiate: true
            
            # callback gets passed an instance of fooPackage
            callback: (foo, callback) ->
                foo.on 'connected', () ->
                    callback foo
                do foo.connect

## Config Examples

### Packages

When config is a string, the DIC will act like nothing more than wrapper around require(), the resulting object will be seen as the actual service.

    config =
        foo: 'fooPackage'
    
Same as before, but more explicit

    config =
        foo:
            require: 'fooPackage'

### Instantiation

With `instantiate: true` the container will attempt to create a new object directly from whatever `require` gave back, which is handy when you have a package directly exporting a single class: `module.exports = SomeClass`.

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

### Injection

The container will become really useful as soon as you start to inject services into other services. You can use `inject` to set up an array of services passed to the constructor. When `inject` is set, the DIC assumes that you want to instantiate.

    config =
        bar: 
            require: 'barPackage'
            instantiate: true
        foo:
            require: 'fooPackage'
            inject: ['bar']

You can set parameters, which you can reference by their name, just like a service. You can mix and match params and services in the `inject` array, but params get preference over (child) services if they have the same name.

    config =
        foo:
            require: 'fooPackage'
            params:
                param1: 'foo'
                param2: 'bar'
            inject: ['foo.param1', 'foo.param2']
        
Services can have children, in this case the id of the child is `foo.bar.baz`.

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
    
### Configuration files

It is possible to spread your DI config over multiple files. You can specify a package and use as a config for a service. When using `loadConfig` the entire node of the configuration you specify it for will be overwritten by the contents of the exports from the loaded file.

    config =    
        foo:
            loadConfig: 'fooConfig'
    
Children can load configs just like their parents can:

    config =
        foo:
            children:
                bar:
                    loadConfig: 'barConfig'
                    
### Injecting Into Package Methods
                    
When you don't want to instantiate, but rather call a method from a required package, you can use `call`. The function named in `call` is assumed to return the service directly (synchronously).

    config =    
        bar:
            require: 'barPackage'
            call: 'barFunction'
    
Call can also use injection, so the following would work like `(require 'fooPackage').someFunction bar, baz`, where foo and baz are resolved services, which can themselves have dependencies, etc.:

    config = 
        ... snip ...
        foo:
            require: 'fooPackage'
            inject: ['bar', 'baz']
            call: 'fooFunction'

### Callbacks And Asynchronous Operation

When going even further down the road towards asynchrony, you can set up a `callback`, which gets called on an instance of an object. The callback gets passed both the object and a function you are required to call with the service once you're done setting it up.

    config = 
        foo: 
            require: 'fooPackage'

            # callback gets passed an instance of fooPackage
            callback: (foo, callback) ->
                foo.doSomethingWithACallback (somethingUseful) ->
                    callback somethingUseful

You can also hook into EventEmitters with this:
    
    config = 
        foo: 
            require: 'fooPackage'
            instantiate: true
            
            # callback gets passed an instance of fooPackage
            callback: (foo, callback) ->
                foo.on 'connect', () ->
                    callback foo
                do foo.connect
