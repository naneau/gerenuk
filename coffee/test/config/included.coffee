# This file is included in the config
module.exports =

    # Not different than any other DI config
    require: 'test/lib/testPackage'
    instantiate: true
    
    children:
        someChild:
            require: 'test/lib/testPackage'
            instantiate: true