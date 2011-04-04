(function() {
  module.exports = {
    withCallback: {
      require: 'test/lib/testAsync',
      callback: function(async, callback) {
        return async.connect(function(error, someVal) {
          if (error) {
            throw "Error!";
          }
          return callback(someVal);
        });
      }
    },
    withSlowCallback: {
      require: 'test/lib/testAsync',
      callback: function(async, callback) {
        var fn;
        fn = function() {
          return callback(Math.random());
        };
        return setTimeout(fn, 100);
      }
    },
    withCallbackInjection: {
      params: {
        bar: 'bar',
        baz: 'baz'
      },
      injectCallback: ['withCallback', 'withCallbackInjection.bar', 'withCallbackInjection.baz'],
      callback: function(foo, bar, baz, callback) {
        var fn;
        fn = function() {
          return callback({
            foo: foo,
            bar: bar,
            baz: baz
          });
        };
        return process.nextTick(fn);
      }
    }
  };
}).call(this);
