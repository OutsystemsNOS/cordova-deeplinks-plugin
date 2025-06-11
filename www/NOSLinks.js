var exec = require('cordova/exec');

module.exports = {
  someFunction: function () {
    exec(null, null, "NOSLinks", "someNativeMethod", []);
  }
};
