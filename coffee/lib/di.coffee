
# DI Container
class Container
    
    # Constructor, pass root config
    constructor: (config) -> 
        # Hash of already resolved services
        @resolved = {}

        # Hash of required items, so we don't have to require() packages twice
        @required = {}
        
        # Parse config
        @config = @parseConfig config
        
        undefined
    
    # Parse config file
    parseConfig: (config) ->
        result = {}
        for key, val of config
            do (key, val) =>
                result[key] = @parseConfigItem val
        result
        
    # Parse a single config item, require loadConfig, etc.
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
        
        # Get with stack
        @getWithStack id, [], (resolved) =>
        
            # Store for later use
            @resolved[id] = resolved if not diConfig.store? or diConfig.store
            
            # Do original callback with the resolved service
            callback resolved
            
        undefined

    # Get with stack
    getWithStack: (id, stack, callback) ->
        # Guard for circular dependencies
        throw new Error "Circular dependency for #{id}" if (service for service in stack when service is id).length > 0
        
        # Add the id to the stack
        stack.push id
        
        # Try to resolve as param through the config
        resolvedAsParam = @resolveParam id
        return callback resolvedAsParam if resolvedAsParam?
        
        # Resolve config
        diConfig = @getDiConfig id
        
        # If we have a param by the exact name of the service we can resolve it directly
        return callback diConfig.params[id] if diConfig.params?[id]?
        
        # Require the package
        required = @require id
            
        # No callback or instantiation, call the callback with the required package
        return callback required if not diConfig.call? and not diConfig.instantiate? and not diConfig.inject?
        
        # No injection to resolve, that's the easy case :x
        if not diConfig.inject?
            instantiated = @instantiate required, diConfig 
            
            # No instance calls to do
            return callback instantiated if not diConfig.instanceCall?
            
            # Do a call on the instance to retrieve the actual service
            @doCallback instantiated, diConfig.instanceCall, (service) ->
                callback service
                
        else 
            # Injection have to be resolved
            @resolveInjection id, diConfig.inject, stack, (services...) =>
                callback @instantiate required, diConfig, services...
        
        # Callback based func, no result
        undefined

    # Get dependencies with params recursively
    resolveInjection: (id, items, stack, parentCallback) ->
        # Set of resolved params
        resolved = []
        
        # Loop function over all services to inject
        next = () =>
            # Get the next service of the stack
            nextService = do items.shift

            # We have a service to resolve
            if nextService?
                @getWithStack nextService, stack, (resolvedService) =>
                
                    # Remove nextService from stack
                    stack = service for service in stack when service is not nextService

                    # Push it to the stack of resolved 
                    resolved.push resolvedService
                    # Iterate on
                    do next
                    
            # We're done resolving
            else
                parentCallback resolved...
        
        # Do initial round
        do next
    
        undefined

    # Instantiate from config and a resolved set of injected services
    instantiate: (what, diConfig, resolvedServices...) ->
        
        # If the instantiate is set to a string, we need to instantiate a specific part of the package
        if typeof diConfig.instantiate is 'string'
            return new what[diConfig.instantiate] resolvedServices...
        
        # We need to call a function from the required package
        if diConfig.call
            return what[diConfig.call] resolvedServices...
        
        # In all other cases, assume we want to instantiate the thing we required 
        else
            return new what resolvedServices...
    
    # Do callback funcs on a service on the 
    doCallback: (service, callback, complete) ->
        service[callback.call] (results...) ->
            complete callback.callback results...
    
    # Resolve an id to the relevant type, note it can resolve to undefined
    getDiConfig: (id) ->
        # Id can reference a child object, we need to resolve each part
        parts = id.split '.'
        
        # Start with the first part
        result = @config?[do parts.shift]
        
        # Resolve children
        result = result?.children?[part] for part in parts
                
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
module.exports = Container