var coffee = require('coffee-script');
var middleware = require('./middleware');
module.exports = function(opts){
  return middleware(opts, coffee);
}