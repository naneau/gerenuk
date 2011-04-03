(function() {
  var Test;
  var __slice = Array.prototype.slice;
  Test = (function() {
    function Test() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this.args = args;
      this.foo = 'baz';
    }
    return Test;
  })();
  module.exports = {
    test1: Test,
    test2: Test,
    testFunction: function() {
      var args, instance;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      instance = (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return typeof result == "object" ? result : child;
      })(Test, args, function() {});
      return instance.foo;
    }
  };
}).call(this);
