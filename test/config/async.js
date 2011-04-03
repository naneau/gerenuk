(function() {
  module.exports = {
    byPackageName: 'test/lib/testPackage',
    withCallback: {
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
    injectedCallback: {
      require: 'test/lib/testPackage',
      inject: ['withCallback']
    }
  };
}).call(this);
