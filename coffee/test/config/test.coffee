# # Test configuration
# 
# Packages used here reside in coffee/test/lib
module.exports = 
    
    # When config is a string, the DIC is nothing more than wrapper around require()
    byPackageName: 'test/lib/testPackage'
    
    # Some things are instantly require-able
    withRequire:
        require: 'test/lib/testPackage'
        
    # With instantiate
    withInstantiate:
        require: 'test/lib/testPackage'
        instantiate: true
    
    # Passing inject, will do `new (require 'test/lib/testPackage2').test1`
    withNamedInstantiate:
        require: 'test/lib/testPackage2'
        instantiate: 'test1'
    
    # Require a package like the before, but pass other services, this implicitly assumes instantiation
    # Like: new (require 'somePackage') injectedService1, injectedService2
    withInject:
        require: 'test/lib/testPackage'
        inject: ['withInstantiate']

    # You can set params, which you can reference by their name, just like a service
    # You can use withParams.param1 from everywhere, which the DIC will resolve before it resolves child services
    withParams:
        require: 'test/lib/testPackage'
        params:
            param1: 'foo'
            param2: 'bar'
        inject: ['withParams.param1', 'withParams.param2']
        
    # You can mix and match params and services, but params get preference over services
    withParamsAndInject:
        require: 'test/lib/testPackage'        
        params:
            param1: 'foo'
            param2: 'bar'
        inject: ['withParams.param1', 'withParams.param2', 'withInstantiate']
    
    # We can indent and have children, in this case the id is "withChildren.someChild.twoDeep"
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
    
            
    # When a child and a param with the same name are set the DIC should pick the param over the child
    withParamAndChildWithSameName:
        children:
            test: 'test/lib/testPackage2'
        params:
            test: 'foo'
            
    # Require a package, use as config for this item, the package will be used as the root of this item, and can reference any and all services
    useConfig:
        loadConfig: 'test/config/included'
    
    # Children can load configs just as their parents can
    useConfigInChild:
        children:
            configChild:
                loadConfig: 'test/config/included'
                
    # Call will not instantiate, but rather call a function from the required package
    withCall:
        require: 'test/lib/testPackage2'
        call: 'testFunction'
    
    # Call can also inject:
    # (require 'test/lib/testPackage2').someFunction services...
    withCallAndInject:
        require: 'test/lib/testPackage2'
        inject: ['byPackageName', 'useConfig']
        call: 'testFunction'
    
    # Neat little circle... this won't work
    circularInjection1:
        require: 'test/lib/testPackage2'
        inject: ['circularInjection2']
    circularInjection2:
        require: 'test/lib/testPackage2'
        inject: ['circularInjection1']
