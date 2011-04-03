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
      return this.dic.get('withInstanceCall', function(service) {
        test.equal(service, 'foo');
        return test.done();
      });
    },
    'Asynchronously instantiated services are injected into non-async services': function(test) {
      test.expect(1);
      return this.dic.get('injectedInstanceCall', function(service) {
        test.equal(service.services[0], 'foo');
        return test.done();
      });
    }
  });
}).call(this);
