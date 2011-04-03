(function() {
  module.exports = {
    byPackageName: 'test/lib/testPackage',
    withInstanceCall: {
      require: 'test/lib/testAsync',
      instantiate: true,
      instanceCall: {
        call: 'connect',
        callback: function(connected, someService) {
          if (!connected) {
            throw "Could not connect";
          }
          return someService;
        }
      }
    },
    injectedInstanceCall: {
      require: 'test/lib/testPackage',
      inject: ['withInstanceCall']
    }
  };
}).call(this);
