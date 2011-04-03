(function() {
  module.exports = {
    byPackageName: 'test/lib/testPackage',
    withRequire: {
      require: 'test/lib/testPackage'
    },
    withInstantiate: {
      require: 'test/lib/testPackage',
      instantiate: true
    },
    withNamedInstantiate: {
      require: 'test/lib/testPackage2',
      instantiate: 'test1'
    },
    withInject: {
      require: 'test/lib/testPackage',
      inject: ['withInstantiate']
    },
    withParams: {
      require: 'test/lib/testPackage',
      params: {
        param1: 'foo',
        param2: 'bar'
      },
      inject: ['withParams.param1', 'withParams.param2']
    },
    withParamsAndInject: {
      require: 'test/lib/testPackage',
      params: {
        param1: 'foo',
        param2: 'bar'
      },
      inject: ['withParams.param1', 'withParams.param2', 'withInstantiate']
    },
    withChildren: {
      children: {
        someChild: {
          require: 'test/lib/testPackage2',
          instantiate: 'test1',
          children: {
            twoDeep: {
              require: 'test/lib/testPackage',
              instantiate: true
            }
          }
        }
      }
    },
    withParamAndChildWithSameName: {
      children: {
        test: 'test/lib/testPackage2'
      },
      params: {
        test: 'foo'
      }
    },
    useConfig: {
      loadConfig: 'test/config/included'
    },
    useConfigInChild: {
      children: {
        configChild: {
          loadConfig: 'test/config/included'
        }
      }
    },
    withCall: {
      require: 'test/lib/testPackage2',
      call: 'testFunction'
    },
    withCallAndInject: {
      require: 'test/lib/testPackage2',
      inject: ['byPackageName', 'useConfig'],
      call: 'testFunction'
    }
  };
}).call(this);
