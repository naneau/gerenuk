(function() {
  var testCase;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  testCase = (require('nodeunit')).testCase;
  require.paths.unshift('./');
  module.exports = testCase({
    setUp: function(callback) {
      var DIContainer;
      DIContainer = (require('../lib/di')).Container;
      this.dic = new DIContainer;
      return callback();
    },
    'The container loads and parses a config': function(test) {
      test.expect(1);
      this.dic.loadConfig('test/config/test');
      return this.dic.get('byPackageName', function(service) {
        test.notEqual(service, null);
        return test.done();
      });
    },
    'When trying to overwrite an existing key, the container throws an exception': function(test) {
      test.expect(1);
      test.throws(function() {
        this.dic.loadConfig('test/config/test');
        return this.dic.loadConfig('test/config/test');
      });
      return test.done();
    },
    "Configs are loaded from loadConfig keys": function(test) {
      test.expect(1);
      this.dic.loadConfig('test/config/test');
      return this.dic.get('useConfig', function(service) {
        test.deepEqual(service, new (require('test/lib/testPackage')));
        return test.done();
      });
    },
    "Configs are loaded in children from loadConfig keys": function(test) {
      test.expect(1);
      this.dic.loadConfig('test/config/test');
      return this.dic.get('useConfigInChild.configChild', function(service) {
        test.deepEqual(service, new (require('test/lib/testPackage')));
        return test.done();
      });
    },
    "Circular dependencies throw an exception": function(test) {
      test.expect(1);
      this.dic.loadConfig('test/config/test');
      test.throws(__bind(function() {
        return this.dic.get('circularInjection1', function(service) {});
      }, this));
      return test.done();
    }
  });
}).call(this);
