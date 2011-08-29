# express-coffee
Express-coffee is an express middleware that automatically compiles and serves coffeescript files.

## WARNING: 0.0.2 has breaking changes. If you use this, update your code.

## Requirements
* Node.js 0.4+
* Coffeescript
* Express

## Install

    npm install express-coffee

## Usage

    app.use(require('express-coffee')({
      path: __dirname+'/public',
      live: true,
      watch: ['.coffee','.js']
    }));

#### definition.path = (string)
The path variable is the path to your static files. Basically this is just used to map req.url onto for file paths. Requests to /javascripts/file.js will result in compilation of /coffeescripts/file.coffee

#### definition.live = (boolean)
If live is enabled, the middleware will check every request if the coffeescript file has been modified recently and recompile the javascript file if it's older. Otherwise, the middleware will only check to make sure the compiled javascript file exists and serve that, regardless of age. Live is disabled by default. I recommend using something like !process.env.PRODUCTION to set it, so it only recompiles per-request while in development.

#### definition.watch = (string | array)
The watch list is an array or comma-separated string used to specify if you want the middleware to run for both .coffee and .js extensions. By default, only the .coffee extension is monitored.

---

### Copyright (c) 2011 Stephen Belanger
#### Licensed under MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.