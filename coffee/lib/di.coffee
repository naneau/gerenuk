# We emit some events to facilitate asynchronous resolving
EventEmitter = (require 'events').EventEmitter

# DI Container
class Container extends EventEmitter
    
    # Constructor, pass (optional) config, or use loadConfig()
    constructor: (config = {}) -> 
        # Parse config
        @config = @parseConfig config

        # Hash of items we're waiting on, subscribe to "async.#{id}" for event when loaded
        @resolving = {}
        # Hash of already resolved services
        @resolved = {}
        # Hash of required items, so we don't have to require() packages twice
        @required = {}
        
        undefined
        
    # Load config from file
    loadConfig: (file) -> @addConfig require file
    
    # Add a config object, will merge with existing config, but will only accept *new* root items
    addConfig: (config) ->
        # Parse it
        parsedConfig = @parseConfig config
        
        for key, val of parsedConfig
            # We don't even attempt to do a deep merge here, we only accept new root items
            throw new Error "#{key} already exists" if @config[key]?
            
            # Add new item
            @config[key] = val
        
    # Parse config hash, recursively parsing all children
    parseConfig: (config) ->
        result = {}
        for key, val of config
            do (key, val) =>
                result[key] = @parseConfigItem val
        result
        
    # Parse a single config item, require loadConfig and loop over children
    parseConfigItem: (item) ->
        # Load configs
        item = require item.loadConfig if item.loadConfig

        # Parse children recursively
        if item.children?
            for name, child of item.children
                # Skip string children
                continue if typeof child is 'string'
                item.children[name] = @parseConfigItem child
        
        # Result
        item
        
    # Get a service by id, callback will be called with the resolved service
    get: (id, callback) ->
        
        # Get it from internal storage if possible
        callback @resolved[id] if @resolved[id]?

        # Resolve the config for the obj
        diConfig = @getDiConfig id

        # Sanity check
        throw new Error "Can not resolve #{id}" if not diConfig?
        
        # @getWithStack does the actual resolving and injecting
        @getWithStack id, [], (resolved) =>
        
            # Store for later use
            @resolved[id] = resolved if not diConfig.store? or diConfig.store
            
            # Do original callback with the resolved service
            callback resolved
            
        undefined

    # Resolve a service and inject dependencies
    # The stack in this method is what guards against circular dependencies
    getWithStack: (id, stack, callback) ->

        # Guard for circular dependencies
        throw new Error "Circular dependency for #{id}" if (service for service in stack when service is id).length > 0
        
        # Add the current id to the stack
        stack.push id
        
        # Try to resolve as param, this takes preference over services/children
        resolvedAsParam = @resolveParam id
        return callback resolvedAsParam if resolvedAsParam?
        
        # Get the config for this item
        diConfig = @getDiConfig id
        
        # If not, we have to require a package
        required = @require id
            
        # No instantiation, so call the callback with the required package
        return callback required if (key for key of diConfig when key in ['call', 'instantiate', 'inject', 'callback']).length is 0
        
        # We're already waiting on this service to become available...
        if @resolving[id]?
            @on "async.#{id}", (service) ->
                callback service
        else
            # We're resolving now
            @resolving[id] = true
            
            # No injection to resolve, that's the easy case :x
            return @handleAsync id, (@instantiate required, diConfig), diConfig, callback if not diConfig.inject?
            
            # Injection have to be resolved
            @resolveInjection diConfig.inject, stack, (services...) =>
                @handleAsync id, (@instantiate required, diConfig, services...), diConfig, callback
                    
            # Callback based func, no result
            undefined

    # Get a list of dependencies, will `@getWithStack` all items, in order and serially
    resolveInjection: (items, stack, parentCallback) ->
        # Set of resolved params
        resolved = []
        
        # Loop function over all services to inject
        next = () =>
            # Get the next service of the stack
            nextService = do items.shift
            
            # We're done resolving
            return parentCallback resolved... if not nextService?
            
            @getWithStack nextService, stack, (resolvedService) =>
                # Remove nextService from stack
                stack = service for service in stack when service is not nextService

                # Push it to the stack of resolved 
                resolved.push resolvedService
                # Iterate on
                do next
        
        # Do initial round
        do next
    
        undefined

    # Instantiate from config and a resolved set of injected services
    instantiate: (what, diConfig, resolvedServices...) ->
        # If the instantiate is set to a string, we need to instantiate a specific part of the package
        return new what[diConfig.instantiate] resolvedServices... if typeof diConfig.instantiate is 'string'

        # We need to call a function from the required package
        return what[diConfig.call] resolvedServices... if diConfig.call

        # In all other cases, assume we want to instantiate the thing we required 
        return new what resolvedServices...

    # Handle any async actions *after* intanstiation
    handleAsync: (id, service, diConfig, parentCallback) ->
        
        # Complete the async stuff, time to finally bubble upwards
        complete = (service) =>
            # Notify others who may be waiting for this service
            @emit "async.#{id}", service
            delete @resolving[id]
            
            parentCallback service
            
        # No instance calls to do
        return complete service if not diConfig.callback?

        # Call the callback to retrieve the actual service
        diConfig.callback service, (service) -> complete service
        
    # Resolve an id to the relevant type, note it can resolve to undefined
    getDiConfig: (id) ->
        # Id can reference a child object, we need to resolve each part
        parts = id.split '.'
        
        # Start with the first part
        result = @config?[do parts.shift]
        
        # Resolve children
        result = result?.children?[part] for part in parts
        
        # Sanity check
        throw "Can not find configuration for #{id}" if not result?
        
        result
    
    # Resolve a param
    resolveParam: (id) ->
        parts = id.split '.'
        
        # Params are always more than a single part
        return undefined if parts.length < 2
        
        # Name of the param
        paramName = do parts.pop
        
        # Resolve the item with the leftover ID
        item = @getDiConfig parts.join '.'
        
        item?.params?[paramName]
    
    # Require
    require: (id) ->
        diConfig = @getDiConfig id
        
        # Sanity check, at this point we need a require
        throw new Error "Can not instantiate #{id}, missing require statement" if not diConfig.require? and typeof diConfig isnt 'string'

        # Require the package or get it from our stack of already required stuff
        if @required[id]?
           required = @required[id] 
        else 
           required = require (if typeof diConfig is 'string' then diConfig else diConfig.require)
        
        # We can store the required item unless explicitly told we can't
        if not diConfig.storeRequire? or diConfig.storeRequire
            @required[id] = required       

# Export
module.exports = {Container}