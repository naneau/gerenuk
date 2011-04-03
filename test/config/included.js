(function() {
  module.exports = {
    require: 'test/lib/testPackage',
    instantiate: true,
    children: {
      someChild: {
        require: 'test/lib/testPackage',
        instantiate: true
      }
    }
  };
}).call(this);
