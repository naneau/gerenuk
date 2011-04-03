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
    }
  };
}).call(this);
