(function() {
  var testCase;
  testCase = (require('nodeunit')).testCase;
  require.paths.unshift('./');
  module.exports = testCase({
    setUp: function(callback) {
      var DIContainer;
      DIContainer = (require('../lib/di')).Container;
      this.dic = new DIContainer(require('test/config/test'));
      return callback();
    },
    'Packages are resolved and required by name, without instantiating': function(test) {
      test.expect(2);
      return this.dic.get('byPackageName', function(service) {
        test.notEqual(service, void 0, 'Service should not be undefined');
        test.equal(service, require('test/lib/testPackage', 'Service should be equal to the require it was supposed to do'));
        return test.done();
      });
    },
    'Packages that can not be resolved throw an exception': function(test) {
      test.expect(1);
      test.throws(function() {
        return this.dic.get('packageDoesNotExist');
      });
      return test.done();
    },
    'Packages are required by config.require, without instantiating': function(test) {
      test.expect(2);
      return this.dic.get('withRequire', function(service) {
        test.notEqual(service, void 0, 'Service should not be undefined');
        test.equal(service, require('test/lib/testPackage', 'Service should be equal to the require it was supposed to do'));
        return test.done();
      });
    },
    'Services are instantiated': function(test) {
      test.expect(1);
      return this.dic.get('withInstantiate', function(service) {
        test.deepEqual(service, new (require('test/lib/testPackage')));
        return test.done();
      });
    },
    'Services are instantiated by name': function(test) {
      test.expect(1);
      return this.dic.get('withNamedInstantiate', function(service) {
        test.deepEqual(service, new (require('test/lib/testPackage2')).test1);
        return test.done();
      });
    },
    "Injected service equals normal initialization of same service": function(test) {
      test.expect(1);
      return this.dic.get('withInject', function(service) {
        test.deepEqual(service.services[0], new (require('test/lib/testPackage')));
        return test.done();
      });
    },
    "Params are injected": function(test) {
      test.expect(2);
      return this.dic.get('withParams', function(service) {
        test.equal(service.services[0], 'foo');
        test.equal(service.services[1], 'bar');
        return test.done();
      });
    },
    "Params resolve next to services": function(test) {
      test.expect(3);
      return this.dic.get('withParamsAndInject', function(service) {
        test.equal(service.services[0], 'foo');
        test.equal(service.services[1], 'bar');
        test.deepEqual(service.services[2], new (require('test/lib/testPackage')));
        return test.done();
      });
    },
    "Params resolve over children": function(test) {
      test.expect(1);
      return this.dic.get('withParamAndChildWithSameName.test', function(service) {
        test.equal(service, 'foo');
        return test.done();
      });
    },
    "Children resolve": function(test) {
      test.expect(1);
      return this.dic.get('withChildren.someChild.twoDeep', function(service) {
        test.deepEqual(service, new (require('test/lib/testPackage')));
        return test.done();
      });
    },
    "Parents of children resolve as regular services": function(test) {
      test.expect(1);
      return this.dic.get('withChildren.someChild', function(service) {
        test.deepEqual(service, new (require('test/lib/testPackage2')).test1);
        return test.done();
      });
    },
    "Calls are executed without injection": function(test) {
      test.expect(1);
      return this.dic.get('withCall', function(result) {
        test.equal(result, 'baz');
        return test.done();
      });
    },
    "Calls are executed with injection": function(test) {
      test.expect(1);
      return this.dic.get('withCallAndInject', function(result) {
        test.equal(result, 'baz');
        return test.done();
      });
    }
  });
}).call(this);
