(function() {
  var Test;
  var __slice = Array.prototype.slice;
  Test = (function() {
    function Test() {
      var services;
      services = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this.services = services;
      this.foo = 'bar';
    }
    return Test;
  })();
  module.exports = Test;
}).call(this);
