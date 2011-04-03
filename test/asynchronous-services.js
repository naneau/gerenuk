(function() {
  var testCase;
  testCase = (require('nodeunit')).testCase;
  require.paths.unshift('./');
  module.exports = testCase({
    setUp: function(callback) {
      var DIContainer;
      DIContainer = require('../lib/di');
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
    'Asynchronously instantiated services are injected into non-async services': function(test) {
      test.expect(1);
      return this.dic.get('injectedCallback', function(service) {
        test.equal(service.services[0], 'foo');
        return test.done();
      });
    }
  });
}).call(this);
