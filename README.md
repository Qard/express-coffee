### NOTE: This package has been obsoleted by [crsh](http://github.com/qard/crsh).

[![Greenkeeper badge](https://badges.greenkeeper.io/Qard/express-coffee.svg)](https://greenkeeper.io/)

# express-coffee
Express-coffee is an express middleware that automatically compiles and serves coffeescript files. Live compilation can be easily disabled so you aren't wasting resources in production. A request for /javascripts/file.js will result in a recompilation check for /coffeescripts/file.coffee, if live is enabled. Recompilation only occurs if the .coffee file is newer than the .js file.

## WARNING: 0.0.2 has breaking changes. If you use this, update your code.

## Requirements
* Node.js 0.4+
* Coffeescript
* Express
* Uglify

## Install

    npm install express-coffee

## Usage

    app.use(require('express-coffee')({
      path: __dirname+'/public',
      live: !process.env.PRODUCTION,
      uglify: process.env.PRODUCTION
    }));
    app.use(express.static(__dirname+'/public'));

#### definition.path = (string)
The path variable is the path to your static files. Basically this is just used to map req.url onto for file paths. Requests to /javascripts/file.js will result in compilation of /coffeescripts/file.coffee

#### definition.src = (string)
Rather than specifying a 'path' you may specify a src and dest filepath.  If src is '/views' then coffeescript files will be compiled from '/views/coffeescripts/'.  If no src is specified, src will be set to the provided path option.  If neither is provided, an error will be thrown.

#### definition.dest = (string)
dest specifies the location in which to sace compiled javascript files.  If dest is '/public' then javascript files will be compiled to '/public/javascripts/'.  If no dest is specified, dest will be set to the provided path option.  If neither is provided, an error will be thrown.

#### definition.live = (boolean)
If live is enabled, the middleware will check every request if the coffeescript file has been modified recently and recompile the javascript file if it's older. Otherwise, the middleware will only check to make sure the compiled javascript file exists and serve that, regardless of age. Default is !process.env.PRODUCTION.

#### definition.uglify = (boolean)
Whether or not to uglify/minify the resulting javascript after the compile step. Default is process.env.PRODUCTION.

---

### Copyright (c) 2011 Stephen Belanger
#### Licensed under MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.