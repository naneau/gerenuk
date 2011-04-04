(function() {
  var testCase;
  testCase = (require('nodeunit')).testCase;
  require.paths.unshift('./');
  module.exports = testCase({
    setUp: function(callback) {
      var DIContainer;
      DIContainer = (require('../lib/di')).Container;
      this.dic = new DIContainer(require('test/config/async'));
      return callback();
    },
    'Callbacks are called and return the service': function(test) {
      test.expect(1);
      return this.dic.get('withCallback', function(service) {
        test.equal(service, 'foo');
        return test.done();
      });
    },
    'When calling a service with a slow instantiation twice we get the same object': function(test) {
      var check, resolved;
      test.expect(1);
      resolved = null;
      check = function(service) {
        if (resolved) {
          test.equal(service, resolved);
          return test.done();
        } else {
          return resolved = service;
        }
      };
      this.dic.get('withSlowCallback', check);
      return this.dic.get('withSlowCallback', check);
    },
    'Callbacks can have their own injection without instantiation': function(test) {
      test.expect(3);
      return this.dic.get('withCallbackInjection', function(service) {
        test.equal(service.foo, 'foo');
        test.equal(service.bar, 'bar');
        test.equal(service.baz, 'baz');
        return test.done();
      });
    },
    'When both inject and callbackInject are set the container throws an exception': function(test) {
      test.expect(1);
      test.throws(function() {
        var dic;
        return dic = new DIContainer({
          item: {
            inject: [],
            injectCallback: []
          }
        });
      });
      return test.done();
    }
  });
}).call(this);
