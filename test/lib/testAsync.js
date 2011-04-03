(function() {
  var Async;
  var __slice = Array.prototype.slice;
  Async = (function() {
    function Async() {
      var services;
      services = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this.services = services;
      null;
    }
    Async.prototype.connect = function(callback) {
      var fn;
      fn = function() {
        return callback(true, 'foo');
      };
      return setTimeout(fn, 1);
    };
    Async.prototype.failingConnect = function(callback) {
      var fn;
      fn = function() {
        return callback(false);
      };
      return setTimeout(fn, 1);
    };
    return Async;
  })();
  module.exports = Async;
}).call(this);
